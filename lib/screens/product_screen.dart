import 'package:flutter/material.dart';
import '../services/open_food_facts_service.dart';

class ProductScreen extends StatefulWidget {
  final String barcode;
  final List<String> userAllergies;
  final List<String> userConditions;

  ProductScreen({
    required this.barcode,
    required this.userAllergies,
    required this.userConditions,
  });

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  Map<String, dynamic>? product;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  void fetchProduct() async {
    final result = await OpenFoodFactsService.fetchProduct(widget.barcode);
    setState(() {
      product = result;
      loading = false;
    });
  }

  List<String> evaluateIngredients(String ingredientsText, List<String> allergies) {
    List<String> warnings = [];
    final lowerIngredients = ingredientsText.toLowerCase();
    for (var allergy in allergies) {
      if (lowerIngredients.contains(allergy.toLowerCase())) {
        warnings.add("⚠ Contains allergen: $allergy");
      }
    }
    if (warnings.isEmpty) warnings.add("✅ No allergens detected");
    return warnings;
  }

  List<String> evaluateHealth(Map<String, dynamic> product, List<String> conditions) {
    List<String> warnings = [];
    final nutriments = product['nutriments'] ?? {};
    double sugar = (nutriments['sugars_100g'] ?? 0).toDouble();
    double fat = (nutriments['fat_100g'] ?? 0).toDouble();
    double saturates = (nutriments['saturated-fat_100g'] ?? 0).toDouble();

    if (conditions.contains("diabetes") && sugar > 10) {
      warnings.add("⚠ High sugar content may affect diabetes");
    }
    if (conditions.contains("cholesterol") && saturates > 5) {
      warnings.add("⚠ High saturated fat may affect cholesterol");
    }
    if (conditions.contains("fatty_liver") && fat > 10) {
      warnings.add("⚠ High fat content may affect fatty liver");
    }
    return warnings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Info')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : product != null
          ? SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product Name: ${product!['product_name'] ?? 'N/A'}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("Brands: ${product!['brands'] ?? 'N/A'}"),
            SizedBox(height: 8),
            Text("Ingredients: ${product!['ingredients_text'] ?? 'N/A'}"),
            SizedBox(height: 16),
            Text(
              "Allergens & Warnings:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...evaluateIngredients(
              product!['ingredients_text'] ?? '',
              widget.userAllergies,
            ).map((e) => Text(e, style: TextStyle(color: e.contains("⚠") ? Colors.red : Colors.green))),
            ...evaluateHealth(
              product!,
              widget.userConditions,
            ).map((e) => Text(e, style: TextStyle(color: Colors.red))),
            SizedBox(height: 16),
            Text(
              "Nutrition Info:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            product!['nutriments'] != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Energy: ${product!['nutriments']['energy-kcal_100g'] ?? 'N/A'} kcal"),
                Text("Fat: ${product!['nutriments']['fat_100g'] ?? 'N/A'} g"),
                Text("Saturates: ${product!['nutriments']['saturated-fat_100g'] ?? 'N/A'} g"),
                Text("Carbohydrates: ${product!['nutriments']['carbohydrates_100g'] ?? 'N/A'} g"),
                Text("Sugars: ${product!['nutriments']['sugars_100g'] ?? 'N/A'} g"),
                Text("Proteins: ${product!['nutriments']['proteins_100g'] ?? 'N/A'} g"),
                Text("Salt: ${product!['nutriments']['salt_100g'] ?? 'N/A'} g"),
              ],
            )
                : Text("No nutrition data available"),
          ],
        ),
      )
          : Center(child: Text("Product not found")),
    );
  }
}
