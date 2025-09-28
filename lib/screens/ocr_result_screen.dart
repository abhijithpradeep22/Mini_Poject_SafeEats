import 'dart:io';
import 'package:flutter/material.dart';
import '../ingredient_database/ingredients_data.dart';
import '../models/user_goal.dart';

/// Map allergens to keywords to detect derivatives
const allergenMapping = {
  "milk": ["milk", "butter", "cream", "cheese", "ghee", "yogurt"],
  "egg": ["egg", "egg white", "egg yolk"],
  "nuts": ["almond", "cashew", "walnut", "pistachio"],
  "soy": ["soy", "soya", "soybean", "tofu"],
  "gluten": ["wheat", "barley", "rye", "malt"],
};

/// Concise warning text mapping
const conciseWarningText = {
  "allergy": "⚠ May trigger allergy",
  "diabetes": "⚠ May affect diabetes",
  "cholesterol": "⚠ May affect cholesterol",
  "fatty_liver": "⚠ May affect fatty liver",
  "weight_loss": "⚠ May affect weight loss goal",
  "weight_gain": "⚠ May affect weight gain goal",
  "weight_maintain": "⚠ May affect weight maintenance",
  "banned": "⚠ May contain banned ingredient",
};

extension StringCasingExtension on String {
  String capitalize() => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

class OcrResultScreen extends StatelessWidget {
  final String ocrText;
  final List<String> userAllergies;
  final List<String> userConditions;
  final UserGoal userGoal;
  final File? imageFile;

  const OcrResultScreen({
    super.key,
    required this.ocrText,
    required this.userAllergies,
    required this.userConditions,
    required this.userGoal,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Map<String, List<String>>>(
          future: processOcrText(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? {};
            final generalWarnings = data['general'] ?? [];
            final detailedWarnings = data['detailed'] ?? [];

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageFile != null) ...[
                    Image.file(imageFile!, height: 200, fit: BoxFit.cover),
                    const SizedBox(height: 16),
                  ],
                  const Text("Ingredients:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  RichText(text: highlightText(ocrText)),
                  const SizedBox(height: 24),
                  const Text("Warnings:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  if (generalWarnings.isEmpty)
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          "✅ No harmful ingredients detected",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: generalWarnings
                          .map(
                            (w) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          constraints: const BoxConstraints(maxWidth: 250),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            w,
                            softWrap: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  const SizedBox(height: 16),
                  if (detailedWarnings.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: ListView(
                                children: detailedWarnings
                                    .map((w) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(w, style: const TextStyle(fontSize: 14)),
                                ))
                                    .toList(),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text(
                        "Know More",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextSpan highlightText(String text) {
    final warningPhrases = <String>{};

    for (var ingredient in ingredientsDatabase) {
      warningPhrases.add(ingredient.name.toLowerCase());
    }

    for (var allergen in userAllergies) {
      final keywords = allergenMapping[allergen.toLowerCase()] ?? [allergen.toLowerCase()];
      warningPhrases.addAll(keywords);
    }

    warningPhrases.addAll(['sugar', 'fat', 'saturated fat']);

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    int currentIndex = 0;

    while (currentIndex < text.length) {
      RegExpMatch? nextMatch;

      for (var phrase in warningPhrases) {
        final matches = RegExp(RegExp.escape(phrase)).allMatches(lowerText).where((m) => m.start >= currentIndex);
        final match = matches.isEmpty ? null : matches.first;
        if (match != null && (nextMatch == null || match.start < nextMatch.start)) {
          nextMatch = match;
        }
      }

      if (nextMatch == null) {
        spans.add(TextSpan(text: text.substring(currentIndex), style: const TextStyle(color: Colors.black)));
        break;
      }

      if (nextMatch.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, nextMatch.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(nextMatch.start, nextMatch.end),
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ));

      currentIndex = nextMatch.end;
    }

    return TextSpan(children: spans);
  }

  Future<Map<String, List<String>>> processOcrText() async {
    final generalWarnings = <String>[];
    final detailedWarnings = <String>[];
    final textLower = ocrText.toLowerCase();

    for (var allergen in userAllergies) {
      final keywords = allergenMapping[allergen.toLowerCase()] ?? [allergen.toLowerCase()];
      for (var keyword in keywords) {
        if (textLower.contains(keyword)) {
          detailedWarnings.add("⚠ Contains allergen: ${allergen.capitalize()} (found: $keyword)");
          if (!generalWarnings.contains(conciseWarningText["allergy"])) {
            generalWarnings.add(conciseWarningText["allergy"]!);
          }
        }
      }
    }

    for (var ingredient in ingredientsDatabase) {
      final nameLower = ingredient.name.toLowerCase();
      if (textLower.contains(nameLower)) {
        if (ingredient.banned) {
          detailedWarnings.add("⚠ ${ingredient.name} is banned in India");
          if (!generalWarnings.contains(conciseWarningText["banned"])) {
            generalWarnings.add(conciseWarningText["banned"]!);
          }
        }
        if (ingredient.affectsDiabetes && userConditions.contains("diabetes")) {
          detailedWarnings.add("⚠ ${ingredient.name} may affect diabetes");
          if (!generalWarnings.contains(conciseWarningText["diabetes"])) {
            generalWarnings.add(conciseWarningText["diabetes"]!);
          }
        }
        if (ingredient.affectsCholesterol && userConditions.contains("cholesterol")) {
          detailedWarnings.add("⚠ ${ingredient.name} may affect cholesterol");
          if (!generalWarnings.contains(conciseWarningText["cholesterol"])) {
            generalWarnings.add(conciseWarningText["cholesterol"]!);
          }
        }
        if (ingredient.affectsFattyLiver && userConditions.contains("fatty_liver")) {
          detailedWarnings.add("⚠ ${ingredient.name} may affect fatty liver");
          if (!generalWarnings.contains(conciseWarningText["fatty_liver"])) {
            generalWarnings.add(conciseWarningText["fatty_liver"]!);
          }
        }
        if (_affectsGoal(ingredient, userGoal)) {
          final goalKey = userGoal == UserGoal.lose
              ? "weight_loss"
              : userGoal == UserGoal.gain
              ? "weight_gain"
              : "weight_maintain";
          detailedWarnings.add("${ingredient.name}: ${goalWarningText(userGoal)}");
          if (!generalWarnings.contains(conciseWarningText[goalKey])) {
            generalWarnings.add(conciseWarningText[goalKey]!);
          }
        }
      }
    }

    final numericWarnings = await evaluateHealthFromOcr(ocrText, userConditions, userGoal);
    for (var w in numericWarnings) {
      detailedWarnings.add("⚠ $w");
      if (!generalWarnings.contains("⚠ $w")) generalWarnings.add("⚠ $w");
    }

    if (generalWarnings.isEmpty) generalWarnings.add("✅ No harmful ingredients detected");

    return {'general': generalWarnings, 'detailed': detailedWarnings};
  }

  Future<List<String>> evaluateHealthFromOcr(String text, List<String> conditions, UserGoal goal) async {
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

    if (goal == UserGoal.lose && (sugar > 10 || fat > 10)) warnings.add("May affect weight loss goal");
    if (goal == UserGoal.gain && (sugar > 10 || fat > 10)) warnings.add("May affect weight gain goal");

    return warnings;
  }

  bool _affectsGoal(IngredientInfo ingredient, UserGoal goal) {
    switch (goal) {
      case UserGoal.gain:
        return false;
      case UserGoal.lose:
      case UserGoal.maintain:
        return ingredient.affectsDiabetes || ingredient.affectsFattyLiver || ingredient.affectsCholesterol;
    }
  }

  String goalWarningText(UserGoal goal) {
    switch (goal) {
      case UserGoal.lose:
        return "May affect weight loss goal";
      case UserGoal.gain:
        return "May affect weight gain goal";
      case UserGoal.maintain:
        return "May affect weight maintenance";
    }
  }
}
