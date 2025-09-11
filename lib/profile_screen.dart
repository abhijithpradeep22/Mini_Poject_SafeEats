import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final ageController = TextEditingController();
  bool loading = true;

  List<String> selectedConditions = [];
  List<String> selectedAllergies = [];
  List<String> selectedGoals = [];

  final List<String> conditionOptions = [
    "Diabetes",
    "Hypertension",
    "Cholesterol",
    "Heart Disease",
    "None",
  ];

  final List<String> allergyOptions = [
    "Dairy",
    "Gluten",
    "Nuts",
    "Eggs",
    "None",
  ];

  final List<String> goalOptions = [
    "Weight Loss",
    "Weight Gain",
    "Muscle Gain",
    "Maintain Weight",
    "Healthy Eating",
  ];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      ageController.text = data['age'].toString();
      selectedConditions = List<String>.from(data['conditions']);
      selectedAllergies = List<String>.from(data['allergies']);
      selectedGoals = List<String>.from(data['goals']);
    }
    setState(() => loading = false);
  }

  Future<void> updateProfile() async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'age': int.tryParse(ageController.text) ?? 0,
      'conditions': selectedConditions,
      'allergies': selectedAllergies,
      'goals': selectedGoals,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Profile updated!")));
  }

  Widget buildMultiSelectChips(List<String> options, List<String> selectedList) {
    return Wrap(
      spacing: 8,
      children: options.map((option) {
        final isSelected = selectedList.contains(option);
        return ChoiceChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.deepPurple,
          backgroundColor: Colors.grey.shade200,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (option == "None") {
                  selectedList.clear();
                  selectedList.add("None");
                } else {
                  selectedList.remove("None");
                  selectedList.add(option);
                }
              } else {
                selectedList.remove(option);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget buildSection(String title, List<String> options, List<String> selectedList) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            buildMultiSelectChips(options, selectedList),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text("Health Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Age",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            buildSection("Conditions", conditionOptions, selectedConditions),
            buildSection("Allergies", allergyOptions, selectedAllergies),
            buildSection("Dietary Goals", goalOptions, selectedGoals),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Update Profile", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
