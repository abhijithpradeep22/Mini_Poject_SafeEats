import 'dart:io';
import 'package:flutter/material.dart';
import '../ingredient_database/ingredients_data.dart';

class OcrResultScreen extends StatelessWidget {
  final String ocrText;
  final List<String> userAllergies;
  final List<String> userConditions;
  final File? imageFile;

  const OcrResultScreen({
    Key? key,
    required this.ocrText,
    required this.userAllergies,
    required this.userConditions,
    this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<String>>(
          future: processOcrText(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final warnings = snapshot.data ?? [];

            // Build set of words that triggered warnings for highlighting
            final warningWords = <String>{};
            for (var ingredient in ingredientsDatabase) {
              final nameLower = ingredient.name.toLowerCase();
              if (ocrText.toLowerCase().contains(nameLower)) {
                if (userAllergies.any((a) => a.toLowerCase() == nameLower) ||
                    ingredient.banned ||
                    (ingredient.affectsDiabetes && userConditions.contains("diabetes")) ||
                    (ingredient.affectsCholesterol && userConditions.contains("cholesterol")) ||
                    (ingredient.affectsFattyLiver && userConditions.contains("fatty_liver"))) {
                  warningWords.add(nameLower);
                }
              }
            }

            // Numeric evaluation highlights
            final sugarMatch = RegExp(r'sugar\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(ocrText);
            final fatMatch = RegExp(r'fat\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(ocrText);
            final saturatesMatch = RegExp(r'saturated[-\s]?fat\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(ocrText);

            if (sugarMatch != null && userConditions.contains("diabetes") && double.tryParse(sugarMatch.group(1)!)! > 10) {
              warningWords.add('sugar');
            }
            if (saturatesMatch != null && userConditions.contains("cholesterol") && double.tryParse(saturatesMatch.group(1)!)! > 5) {
              warningWords.add('saturated');
            }
            if (fatMatch != null && userConditions.contains("fatty_liver") && double.tryParse(fatMatch.group(1)!)! > 10) {
              warningWords.add('fat');
            }

            // Split OCR text into words and highlight if they are in warningWords
            final words = ocrText.split(RegExp(r'\s+'));
            List<TextSpan> spans = words.map((word) {
              final cleanWord = word.replaceAll(RegExp(r'[.,()]'), '').toLowerCase();
              if (warningWords.contains(cleanWord)) {
                return TextSpan(
                  text: '$word ',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                );
              }
              return TextSpan(text: '$word ', style: const TextStyle(color: Colors.black));
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageFile != null) ...[
                    Image.file(imageFile!, height: 200, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                  ],
                  const Text("OCR Text:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  RichText(text: TextSpan(children: spans)),
                  const SizedBox(height: 24),
                  const Text("Warnings:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (warnings.isEmpty)
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("No harmful ingredients detected ✅", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  else
                    Column(
                      children: warnings
                          .map((e) => Card(
                        color: Colors.red,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(e, style: const TextStyle(color: Colors.white)),
                        ),
                      ))
                          .toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Main processing function
  Future<List<String>> processOcrText() async {
    final warnings = <String>[];
    final textLower = ocrText.toLowerCase();

    // Allergy warnings
    for (var allergen in userAllergies) {
      if (textLower.contains(allergen.toLowerCase())) {
        warnings.add("⚠ Contains allergen: $allergen");
      }
    }

    // Ingredient-based warnings
    for (var ingredient in ingredientsDatabase) {
      final nameLower = ingredient.name.toLowerCase();
      if (textLower.contains(nameLower)) {
        if (ingredient.banned) warnings.add("⚠ ${ingredient.name} is banned in India");
        if (ingredient.affectsDiabetes && userConditions.contains("diabetes")) {
          warnings.add("⚠ ${ingredient.name} may affect diabetes");
        }
        if (ingredient.affectsCholesterol && userConditions.contains("cholesterol")) {
          warnings.add("⚠ ${ingredient.name} may affect cholesterol");
        }
        if (ingredient.affectsFattyLiver && userConditions.contains("fatty_liver")) {
          warnings.add("⚠ ${ingredient.name} may affect fatty liver");
        }
      }
    }

    // Numeric evaluation warnings
    final numericWarnings = await evaluateHealthFromOcr(ocrText, userConditions);
    for (var w in numericWarnings) {
      if (!warnings.contains(w)) warnings.add("⚠ $w");
    }

    if (warnings.isEmpty) warnings.add("✅ No harmful ingredients detected");

    return warnings;
  }

  // Numeric evaluation
  Future<List<String>> evaluateHealthFromOcr(String text, List<String> conditions) async {
    final warnings = <String>[];

    final sugarMatch = RegExp(r'sugar\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(text);
    final fatMatch = RegExp(r'fat\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(text);
    final saturatesMatch = RegExp(r'saturated[-\s]?fat\s*[:=]?\s*(\d+(\.\d+)?)', caseSensitive: false).firstMatch(text);

    final sugar = sugarMatch != null ? double.tryParse(sugarMatch.group(1)!) ?? 0 : 0;
    final fat = fatMatch != null ? double.tryParse(fatMatch.group(1)!) ?? 0 : 0;
    final saturates = saturatesMatch != null ? double.tryParse(saturatesMatch.group(1)!) ?? 0 : 0;

    if (conditions.contains("diabetes") && sugar > 10) warnings.add("High sugar may affect diabetes");
    if (conditions.contains("cholesterol") && saturates > 5) warnings.add("High saturated fat may affect cholesterol");
    if (conditions.contains("fatty_liver") && fat > 10) warnings.add("High fat may affect fatty liver");

    return warnings;
  }
}
