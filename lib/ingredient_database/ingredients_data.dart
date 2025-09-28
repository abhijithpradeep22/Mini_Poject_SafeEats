class IngredientInfo {
  final String name;
  final bool banned;
  final bool affectsDiabetes;
  final bool affectsCholesterol;
  final bool affectsFattyLiver;
  final bool affectsWeightGain;
  final bool affectsWeightLoss;

  IngredientInfo({
    required this.name,
    this.banned = false,
    this.affectsDiabetes = false,
    this.affectsCholesterol = false,
    this.affectsFattyLiver = false,
    this.affectsWeightGain = false,
    this.affectsWeightLoss = false,
  });
}


final List<IngredientInfo> ingredientsDatabase = [
  // Diabetes-related
  IngredientInfo(name: "Sugar", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Honey", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Corn Syrup", affectsDiabetes: true, affectsWeightGain: true),

  // Cholesterol-related
  IngredientInfo(name: "Salt", affectsCholesterol: true),
  IngredientInfo(name: "Vanaspati", banned: true, affectsCholesterol: true, affectsWeightGain: true),
  IngredientInfo(name: "Butter", affectsCholesterol: true, affectsWeightGain: true),

  // Fatty liver-related
  IngredientInfo(name: "Palm Oil", affectsFattyLiver: true, affectsWeightGain: true),
  IngredientInfo(name: "Processed Cheese", affectsFattyLiver: true, affectsWeightGain: true),
  IngredientInfo(name: "Fried Foods", affectsFattyLiver: true, affectsWeightGain: true),

  // Weight loss-related
  IngredientInfo(name: "Ice Cream", affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Chocolate", affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Soft Drinks", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),

  // General banned / harmful
  IngredientInfo(name: "Artificial Sweetener X", banned: true),
  IngredientInfo(name: "Monosodium Glutamate", banned: false, affectsCholesterol: true, affectsFattyLiver: true),
];


