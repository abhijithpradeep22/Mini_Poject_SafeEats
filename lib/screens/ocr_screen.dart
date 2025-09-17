import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'ocr_result_screen.dart';

class OcrScreen extends StatefulWidget {
  final List<String> userAllergies;
  final List<String> userConditions;

  const OcrScreen({
    Key? key,
    required this.userAllergies,
    required this.userConditions,
  }) : super(key: key);

  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _performOCR(imageFile);
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);

    final recognizedText = await textRecognizer.processImage(inputImage);

    textRecognizer.close();

    if (!mounted) return;

    // Navigate directly to result screen with OCR text and image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OcrResultScreen(
          ocrText: recognizedText.text,
          userAllergies: widget.userAllergies,
          userConditions: widget.userConditions,
          imageFile: imageFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OCR Scanner")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Take a Photo"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text("Pick from Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
