import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ImageUploadPage(),
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.green[50],
      ),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({Key? key}) : super(key: key);

  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  final picker = ImagePicker();
  String _result = "No result yet";

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    try {
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final requestPayload = {'image': base64Image};

      var response = await http.post(
        Uri.parse('https://susya.onrender.com'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _result = """
Disease: ${responseData['disease']}
Plant: ${responseData['plant']}
Remedy: ${responseData['remedy']}
        """;
        });
      } else {
        setState(() {
          _result = "Error: ${response.statusCode}\n${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        _result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Disease Detector',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        // Make content scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _image!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.green,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pick Image from Camera',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Pick Image from Gallery',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
