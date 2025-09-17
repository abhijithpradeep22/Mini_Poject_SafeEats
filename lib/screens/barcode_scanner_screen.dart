import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'product_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final List<String> userAllergies;
  final List<String> userConditions;

  const BarcodeScannerScreen({
    Key? key,
    required this.userAllergies,
    required this.userConditions,
  }) : super(key: key);

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();

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

          // Navigate to ProductScreen with user profile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProductScreen(
                barcode: code,
                userAllergies: widget.userAllergies,
                userConditions: widget.userConditions,
              ),
            ),
          );
        },
      ),
    );
  }
}
