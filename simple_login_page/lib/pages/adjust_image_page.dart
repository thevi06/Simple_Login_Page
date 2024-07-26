// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';

class AdjustImagePage extends StatelessWidget {
  final File image;

  AdjustImagePage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adjust Image'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              try {
                // Save the adjusted image to the gallery
                await _saveImageToGallery(image);
                // Navigate back to the MenuPage
                Navigator.pop(context);
              } catch (e) {
                // Handle any errors that occur during the save or navigation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error saving image: $e')
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: image == null
            ? const Text('No image selected.')
            : Image.file(image),
      ),
    );
  }

  Future<void> _saveImageToGallery(File image) async {
    final bytes = await image.readAsBytes();
    final result = await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));
    print(result); // This will print the path where the image is saved
  }
}
