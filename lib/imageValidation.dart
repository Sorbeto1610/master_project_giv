import 'package:flutter/material.dart';
import 'dart:typed_data';  // To handle image data

class ImageDisplayPage extends StatelessWidget {
  final Uint8List imageData;

  ImageDisplayPage({required this.imageData});  // Pass the image data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display Image"),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),  // Red cross icon
            onPressed: () {
              Navigator.pop(context);  // Return to the previous page
            },
          ),
        ],
      ),
      body: Center(
        child: Image.memory(
          imageData,
          fit: BoxFit.contain,  // Keep the image within bounds
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
