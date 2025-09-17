class IngredientInfo {
  final String name;
  final bool banned;        // true if banned in India
  final bool affectsDiabetes;
  final bool affectsCholesterol;
  final bool affectsFattyLiver;

  IngredientInfo({
    required this.name,
    this.banned = false,
    this.affectsDiabetes = false,
    this.affectsCholesterol = false,
    this.affectsFattyLiver = false,
  });
}

final List<IngredientInfo> ingredientsDatabase = [
  IngredientInfo(name: "Sugar", affectsDiabetes: true),
  IngredientInfo(name: "Salt", affectsCholesterol: true),
  IngredientInfo(name: "Vanaspati", banned: true, affectsCholesterol: true),
  IngredientInfo(name: "Monosodium Glutamate", banned: true),
  IngredientInfo(name: "Palm Oil", affectsFattyLiver: true),
];
