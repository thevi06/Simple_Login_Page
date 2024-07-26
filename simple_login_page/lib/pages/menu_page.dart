// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_login_page/pages/second_page.dart';
import 'dart:io';
import 'login_page.dart';
import 'sketch_page.dart';
import 'strength_page.dart'; // Import the StrengthPage

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  File? _image;
  String? _imageType; // 'Imported' or 'Captured'

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecondPage(),
                    ),
                  );
                },
                child: const Text('Draw'),
              ),
              ElevatedButton(
                onPressed: () {
                  _captureImage(context);
                },
                child: const Text('Capture'),
              ),
              ElevatedButton(
                onPressed: () {
                  _importFromDevice(context);
                },
                child: const Text('Import from Device'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SketchPage()),
                  );
                },
                child: const Text('Sketch'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _captureImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
        _imageType = 'Captured';
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StrengthPage(
            image: _image!,
            imageType: _imageType!,
          ),
        ),
      );
    }
  }

  void _importFromDevice(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _image = File(pickedFile.path);
        _imageType = 'Imported';
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StrengthPage(
            image: _image!,
            imageType: _imageType!,
          ),
        ),
      );
    }
  }
}
