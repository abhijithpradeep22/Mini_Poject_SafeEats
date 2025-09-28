import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // For navigating back to AuthScreen
import 'barcode_scanner_screen.dart';
import 'ocr_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('SafeEats'),
        backgroundColor: Colors.pink.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user logged in'))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var userData = snapshot.data!;
          final allergies = (userData['allergies'] as List<dynamic>).cast<String>();
          final conditions =
          (userData['medicalConditions'] as List<dynamic>).cast<String>();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                // -------- User Info Card --------
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['name'] ?? 'No Name',
                          style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Age: ${userData['age'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Gender: ${userData['gender'] ?? '-'}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Divider(height: 30),
                        Text(
                          "Allergies: ${allergies.join(', ')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Health Conditions: ${conditions.join(', ')}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // -------- Check Product Section --------
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.qr_code_scanner,
                            color: Colors.pink),
                        title: const Text('Scan Barcode'),
                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BarcodeScannerScreen(
                                userAllergies: allergies,
                                userConditions: conditions,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading:
                        const Icon(Icons.camera_alt, color: Colors.pink),
                        title: const Text('Food Label Scanner'),
                        trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OcrScreen(
                                userAllergies: allergies,
                                userConditions: conditions,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
