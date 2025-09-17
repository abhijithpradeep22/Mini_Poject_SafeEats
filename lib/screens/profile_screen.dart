import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_screen.dart';
import 'ocr_screen.dart';
import 'barcode_scanner_screen.dart'; // New screen for camera barcode scanning

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final barcodeController = TextEditingController();
  List<String> userAllergies = [];
  List<String> userConditions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      setState(() {
        userAllergies = List<String>.from(doc['allergies'] ?? []);
        userConditions = List<String>.from(doc['conditions'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile Screen")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Profile Screen")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Welcome! Your health profile:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text("Allergies: ${userAllergies.isNotEmpty ? userAllergies.join(', ') : 'None'}"),
            Text("Conditions: ${userConditions.isNotEmpty ? userConditions.join(', ') : 'None'}"),
            SizedBox(height: 24),

            // Manual barcode entry
            Text(
              "Enter a product barcode to check details:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16),
            TextField(
              controller: barcodeController,
              decoration: InputDecoration(
                labelText: "Barcode",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.qr_code),
              ),
            ),
            SizedBox(height: 24),

            // Action buttons: manual check, barcode scanner, OCR scanner
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (barcodeController.text.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductScreen(
                              barcode: barcodeController.text.trim(),
                              userAllergies: userAllergies,
                              userConditions: userConditions,
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.info_outline),
                    label: Text("Check Product"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BarcodeScannerScreen(
                            userAllergies: userAllergies,
                            userConditions: userConditions,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text("Scan Barcode"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OcrScreen(
                            userAllergies: userAllergies,
                            userConditions: userConditions,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.camera_alt_outlined),
                    label: Text("OCR Scanner"),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
