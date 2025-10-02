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
  // --- Regular Ingredients ---
  IngredientInfo(name: "Sugar", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Honey", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Corn Syrup", affectsDiabetes: true, affectsWeightGain: true),

  IngredientInfo(name: "Salt", affectsCholesterol: true),
  IngredientInfo(name: "Vanaspati", affectsCholesterol: true, affectsWeightGain: true),
  IngredientInfo(name: "Butter", affectsCholesterol: true, affectsWeightGain: true),

  IngredientInfo(name: "Palm Oil", affectsFattyLiver: true, affectsWeightGain: true),
  IngredientInfo(name: "Processed Cheese", affectsFattyLiver: true, affectsWeightGain: true),
  IngredientInfo(name: "Fried Foods", affectsFattyLiver: true, affectsWeightGain: true),

  IngredientInfo(name: "Ice Cream", affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Chocolate", affectsWeightGain: true, affectsWeightLoss: true),
  IngredientInfo(name: "Soft Drinks", affectsDiabetes: true, affectsWeightGain: true, affectsWeightLoss: true),

  IngredientInfo(name: "oil", affectsCholesterol: true, affectsWeightGain: true),

  // --- FSSAI Banned Ingredients ---
  IngredientInfo(name: "Frysol", banned: true),
  IngredientInfo(name: "Fulvic acid (CHD-FA)", banned: true),
  IngredientInfo(name: "S-Adenosyl-L-Methionine disulfate P-toluene Sulfonate Tablets", banned: true),
  IngredientInfo(name: "S-Adenosyl-I-Methionine (SAMe)", banned: true),
  IngredientInfo(name: "Magnesium Threonate", banned: true),
  IngredientInfo(name: "Dipotassium orthophosphate (INS No-340(ii))", banned: true),
  IngredientInfo(name: "Silicon dioxide (INS No 551)", banned: true),
  IngredientInfo(name: "Starch (INS No 1405)", banned: true),
  IngredientInfo(name: "S-Adenosyl-L-Methionine P-toulensulfonate (Adonat®)", banned: true),
  IngredientInfo(name: "Herbal infusion (Rooibos with/without ingredients)", banned: true),
  IngredientInfo(name: "Acai Berry Fruit Juice Concentrate", banned: true),
  IngredientInfo(name: "Reboost Tablets", banned: true),
  IngredientInfo(name: "Sugar Jaggery", banned: true),
  IngredientInfo(name: "Super Life Total care 30 (STC30)", banned: true),
  IngredientInfo(name: "HemoHIM", banned: true),
  IngredientInfo(name: "Vitamin E Soft Gelatin Capsules", banned: true),
  IngredientInfo(name: "Notoginseng extract powder", banned: true),
  IngredientInfo(name: "Hydrogenated Vegetable Fat (Lauric Based)", banned: true),
  IngredientInfo(name: "Hydrogenated Vegetable Fat (Palm Based)", banned: true),
  IngredientInfo(name: "Refined Fractionated Hydrogenated Palm Kernel Oil", banned: true),
  IngredientInfo(name: "Refined Fractionated Palm Oil", banned: true),
  IngredientInfo(name: "Alkaline Water", banned: true),
  IngredientInfo(name: "Blackmores Nails, Hair and Skin", banned: true),
  IngredientInfo(name: "Blackmores Multivitamins for men", banned: true),
  IngredientInfo(name: "Lyophilized Bacterial Lysates for UTI Soft Capsules", banned: true),
  IngredientInfo(name: "Fungal Diastase, Papain, Activated Charcoal, Liquorice Tablets (Unienzyme XT)", banned: true),
  IngredientInfo(name: "Pectin based hair vitamin gummy candy with Biotin", banned: true),
  IngredientInfo(name: "Q-Force", banned: true),
  IngredientInfo(name: "Calcium D-Betahydroxybutyrate (Ca-BHB)", banned: true),
  IngredientInfo(name: "Trypsin Chymotrypsin", banned: true),
  IngredientInfo(name: "NHT Global Stemrenu", banned: true),
  IngredientInfo(name: "S-Adenosyl-L-Methionine disulfate p-toluenesulfonate (Adonat®)", banned: true),
  IngredientInfo(name: "S-Adenosyl-L-Methionine disulfate p-toluensesulfonate (Adonat®)", banned: true),
  IngredientInfo(name: "Low Sodium Sea Mineral Complex", banned: true),
  IngredientInfo(name: "Herbanova Supergreen", banned: true),
  IngredientInfo(name: "Ashwagandha Liquid concentrate (Aquasule)", banned: true),
  IngredientInfo(name: "Succinic Acid", banned: true),
  IngredientInfo(name: "Elemental Selenium (200mg/day from L-Selenomethionine)", banned: true),
  IngredientInfo(name: "KYRON T-314 Polacrilin Potassium", banned: true),
  IngredientInfo(name: "Raspberry ketone", banned: true),
  IngredientInfo(name: "Slica", banned: true),
  IngredientInfo(name: "Angelica sinensis", banned: true),
  IngredientInfo(name: "Paullinia cupana", banned: true),
  IngredientInfo(name: "Saw palmetto", banned: true),
  IngredientInfo(name: "Notoginseng", banned: true),
  IngredientInfo(name: "Chlorella growth factor", banned: true),
  IngredientInfo(name: "Pine bark extracted to Pinus radiata", banned: true),
  IngredientInfo(name: "Pine bark extracted from Pinus pinaster", banned: true),
  IngredientInfo(name: "Vitamin D3-veg", banned: true),
  IngredientInfo(name: "Chaga extract", banned: true),
  IngredientInfo(name: "Oxalobacter formigenes", banned: true),
  IngredientInfo(name: "Phytavail iron", banned: true),
  IngredientInfo(name: "Tea tree oil", banned: true),
  IngredientInfo(name: "Succinic acid", banned: true),
  IngredientInfo(name: "Inosine", banned: true),
  IngredientInfo(name: "Para amino benzoic acid (PABA)", banned: true),
  IngredientInfo(name: "Vanadium", banned: true),
  IngredientInfo(name: "Prenolit", banned: true),
  IngredientInfo(name: "Selenium dioxide", banned: true),
  IngredientInfo(name: "D-ribose", banned: true),
  IngredientInfo(name: "Ipriflavone", banned: true),
  IngredientInfo(name: "Polypodium leucotomos", banned: true),
];
