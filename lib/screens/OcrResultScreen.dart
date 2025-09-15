import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OcrResultScreen extends StatelessWidget {
  final String ocrText;

  OcrResultScreen({required this.ocrText});

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    // Save OCR text automatically
    saveOcrText(ocrText);

    return Scaffold(
      appBar: AppBar(title: Text("OCR Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<String>>(
          future: checkHarmfulIngredients(ocrText),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final harmful = snapshot.data ?? [];

            // Highlight harmful ingredients in the text
            final words = ocrText.split(RegExp(r'\s+'));
            List<TextSpan> spans = words.map((word) {
              final cleanWord = word.replaceAll(RegExp(r'[.,]'), '');
              if (harmful.any(
                      (h) => cleanWord.toLowerCase().contains(h.toLowerCase()))) {
                return TextSpan(
                  text: '$word ',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                );
              }
              return TextSpan(text: '$word ', style: TextStyle(color: Colors.black));
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "OCR Text:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  RichText(text: TextSpan(children: spans)),
                  SizedBox(height: 24),
                  Text(
                    "Warnings:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  harmful.isEmpty
                      ? Text(
                    "No harmful ingredients found ✅",
                    style: TextStyle(color: Colors.green),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: harmful
                        .map((e) => Text(
                      "⚠ $e",
                      style: TextStyle(color: Colors.red),
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

  Future<void> saveOcrText(String text) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('scans')
        .add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> checkHarmfulIngredients(String text) async {
    final snapshot = await firestore.collection('harmful_ingredients').get();
    final ingredients = snapshot.docs.map((doc) => doc['name'] as String);

    final found = ingredients
        .where((ingredient) =>
        text.toLowerCase().contains(ingredient.toLowerCase()))
        .toList();
    return found;
  }
}
