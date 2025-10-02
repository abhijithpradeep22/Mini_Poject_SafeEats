import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/profile_screen.dart';
import '../models/user_goal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SafeEatsApp());
}

class SafeEatsApp extends StatelessWidget {
  const SafeEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeEats',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: true,
          fillColor: Colors.white70,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final allergiesController = TextEditingController();
  List<String> conditions = [];
  String gender = 'Male';
  UserGoal? selectedGoal;
  bool isLogin = true;
  String message = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    ageController.dispose();
    allergiesController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    try {
      if (isLogin) {
        // LOGIN
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;
        setState(() => message = "✅ Login successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      } else {
        // VALIDATE FIELDS
        if (nameController.text.isEmpty ||
            ageController.text.isEmpty ||
            gender.isEmpty ||
            selectedGoal == null) {
          setState(() => message = "❌ Name, Age, Gender and Goal are required.");
          return;
        }

        // REGISTER
        final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // SAVE USER DATA TO FIRESTORE
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCred.user!.uid)
            .set({
          'name': nameController.text.trim(),
          'age': int.tryParse(ageController.text.trim()) ?? 0,
          'gender': gender,
          'allergies': allergiesController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          'medicalConditions': conditions,
          'goal': selectedGoal!.displayName,
        });

        if (!mounted) return;

        // Show success dialog and reset fields
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Registration Successful"),
            content: const Text("✅ Registration successful! Please login."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  setState(() {
                    isLogin = true; // switch to login page
                    // Clear all registration fields
                    nameController.clear();
                    ageController.clear();
                    allergiesController.clear();
                    conditions.clear();
                    selectedGoal = null;
                    gender = 'Male';
                    message = "";
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => message = "❌ $e");
    }
  }


  Future<void> resetPassword() async {
    if (emailController.text.isEmpty) {
      if (!mounted) return;
      setState(() => message = "❌ Enter your email first");
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => message = "✅ Password reset email sent!");
    } catch (e) {
      if (!mounted) return;
      setState(() => message = "❌ $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(
          "Welcome",
          style: TextStyle(
            color: Colors.pink.shade100,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink.shade50,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "SafeEats",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.pink.shade700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Smart Ingredient Risk Analysis and Personal Diet Assistant",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Email & Password
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Colors.pink),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock, color: Colors.pink),
                      ),
                    ),

                    if (isLogin) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: resetPassword,
                          child: const Text("Forgot Password?"),
                        ),
                      ),
                    ],

                    // REGISTRATION FIELDS
                    if (!isLogin) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Name",
                          prefixIcon: Icon(Icons.person, color: Colors.pink),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Age",
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.pink),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            "Gender: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: gender,
                            items: <String>['Male', 'Female', 'Other']
                                .map((val) => DropdownMenuItem(
                              value: val,
                              child: Text(val),
                            ))
                                .toList(),
                            onChanged: (val) {
                              setState(() => gender = val!);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Your Health Conditions:",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: [
                          CheckboxListTile(
                            title: const Text("Diabetes"),
                            value: conditions.contains("diabetes"),
                            onChanged: (val) {
                              setState(() {
                                if (val!) {
                                  conditions.add("diabetes");
                                } else {
                                  conditions.remove("diabetes");
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.pink,
                          ),
                          CheckboxListTile(
                            title: const Text("High Cholesterol"),
                            value: conditions.contains("cholesterol"),
                            onChanged: (val) {
                              setState(() {
                                if (val!) {
                                  conditions.add("cholesterol");
                                } else {
                                  conditions.remove("cholesterol");
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.pink,
                          ),
                          CheckboxListTile(
                            title: const Text("Fatty Liver"),
                            value: conditions.contains("fatty_liver"),
                            onChanged: (val) {
                              setState(() {
                                if (val!) {
                                  conditions.add("fatty_liver");
                                } else {
                                  conditions.remove("fatty_liver");
                                }
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.pink,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Your Goal:",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: UserGoal.values.map((goal) {
                          return RadioListTile<UserGoal>(
                            title: Text(goal.name.capitalize()),
                            value: goal,
                            groupValue: selectedGoal,
                            onChanged: (val) {
                              setState(() => selectedGoal = val);
                            },
                            activeColor: Colors.pink,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: allergiesController,
                        decoration: const InputDecoration(
                          labelText: "Allergies (comma separated)",
                          prefixIcon: Icon(Icons.medical_services, color: Colors.pink),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink.shade600,
                            ),
                            child: Text(isLogin ? "Login" : "Register"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(isLogin
                          ? "Don't have an account? Register"
                          : "Already registered? Login"),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// String extension for capitalizing goal names
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
