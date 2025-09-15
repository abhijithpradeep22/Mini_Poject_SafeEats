import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'OcrResultScreen.dart';

class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  File? _image;
  String _recognizedText = "";
  final ImagePicker _picker = ImagePicker();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _performOCR(File(pickedFile.path));
    }
  }

  Future<void> _performOCR(File imageFile) async {
    final textRecognizer = TextRecognizer();
    final inputImage = InputImage.fromFile(imageFile);

    final RecognizedText recognizedText =
    await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text;
    });

    textRecognizer.close();

    // Save OCR text to Firestore under user's UID
    if (_recognizedText.isNotEmpty) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('scans')
          .add({
        'text': _recognizedText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to result screen for harmful ingredient check
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OcrResultScreen(ocrText: _recognizedText),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OCR Scanner")),
      body: Column(
        children: [
          if (_image != null)
            Image.file(_image!, height: 200, fit: BoxFit.cover),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.camera),
            child: Text("Take a Photo"),
          ),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: Text("Pick from Gallery"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                _recognizedText.isEmpty
                    ? "No text recognized yet"
                    : _recognizedText,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
