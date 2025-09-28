import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_screen.dart';
import '../models/user_goal.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final List<String> userAllergies;
  final List<String> userConditions;
  final UserGoal userGoal;

  const BarcodeScannerScreen({
    super.key,
    required this.userAllergies,
    required this.userConditions,
    required this.userGoal,
  });

  @override
  BarcodeScannerScreenState createState() => BarcodeScannerScreenState();
}

class BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Barcode")),
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;

          final code = barcodes.first.rawValue;
          if (code == null) return;

          // Pass userGoal to ProductScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProductScreen(
                barcode: code,
                userAllergies: widget.userAllergies,
                userConditions: widget.userConditions,
                userGoal: widget.userGoal,
              ),
            ),
          );
        },
      ),
    );
  }
}
