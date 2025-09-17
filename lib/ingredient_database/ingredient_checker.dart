import '../ingredient_database/ingredients_data.dart';

List<String> evaluateIngredientsText(String text, List<String> userConditions) {
  final warnings = <String>[];
  final lowerText = text.toLowerCase();

  for (var ingredient in ingredientsDatabase) {
    final name = ingredient.name.toLowerCase();
    if (lowerText.contains(name)) {
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

  if (warnings.isEmpty) warnings.add("✅ No harmful ingredients detected");
  return warnings;
}
