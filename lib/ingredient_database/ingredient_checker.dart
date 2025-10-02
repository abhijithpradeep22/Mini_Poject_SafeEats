import '../ingredient_database/ingredients_data.dart';

List<String> evaluateIngredientsText(
    String text,
    List<String> userConditions,
    String userGoal // "gain", "lose", "maintain"
    ) {

  final warnings = <String>[];
  final lowerText = text.toLowerCase();

  for (var ingredient in ingredientsDatabase) {
    final name = ingredient.name.toLowerCase();

    // Regex with word boundaries to avoid partial matches
    final regex = RegExp(r'\b' + RegExp.escape(name) + r'\b');
    if (regex.hasMatch(lowerText)) {

      // Banned ingredient
      if (ingredient.banned) {
        warnings.add("⚠ ${ingredient.name} is banned in India");
      }

      // Condition-based warnings
      if (ingredient.affectsDiabetes && userConditions.contains("diabetes")) {
        warnings.add("⚠ ${ingredient.name} may affect diabetes");
      }
      if (ingredient.affectsCholesterol && userConditions.contains("cholesterol")) {
        warnings.add("⚠ ${ingredient.name} may affect cholesterol");
      }
      if (ingredient.affectsFattyLiver && userConditions.contains("fatty_liver")) {
        warnings.add("⚠ ${ingredient.name} may affect fatty liver");
      }

      // Goal-based warnings
      if (userGoal == "gain" && ingredient.affectsWeightGain) {
        warnings.add("⚠ ${ingredient.name} may contribute to weight gain");
      }
      if (userGoal == "lose" && ingredient.affectsWeightLoss) {
        warnings.add("⚠ ${ingredient.name} may hinder weight loss");
      }
    }
  }

  // Generic oils check for cholesterol & weight gain
  final oilRegex = RegExp(r'\b(?:oil|vegetable oil|palm oil|coconut oil|sunflower oil|canola oil|hydrogenated oil|rapeseed oil|corn oil|soybean oil)\b', caseSensitive: false);
  if (oilRegex.hasMatch(lowerText)) {
    if (userConditions.contains("cholesterol")) {
      warnings.add("⚠ Oil content may affect cholesterol");
    }
    if (userGoal == "gain") {
      warnings.add("⚠ Oil content may contribute to weight gain");
    }
    if (userGoal == "lose") {
      warnings.add("⚠ Oil content may hinder weight loss");
    }
  }

  if (warnings.isEmpty) warnings.add("✅ No harmful ingredients detected");
  return warnings;
}
