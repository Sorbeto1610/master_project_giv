import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:typed_data';
import 'package:master_project_giv/imageValidation.dart';  // New page to display the selected image

class ImageSelectionPage extends StatefulWidget {
  @override
  _ImageSelectionPageState createState() => _ImageSelectionPageState();
}

class _ImageSelectionPageState extends State<ImageSelectionPage> {
  Uint8List? _imageData;
  DropzoneViewController? _controller;

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageBytes;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDisplayPage(imageData: _imageData!),
          ),
        );
      });
    }
  }

  Future<void> _onDrop(dynamic event) async {
    final imageBytes = await _controller?.getFileData(event);
    setState(() {
      _imageData = imageBytes;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageDisplayPage(imageData: _imageData!),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Image"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {  // Mobile view
            return Center(
              child: ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text("Select Image from Gallery"),
              ),
            );
          } else {  // Desktop view
            return Center(
              child: Stack(
                children: [
                  Container(
                    width: constraints.maxWidth - 100,
                    height: constraints.maxHeight - 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],  // Background color
                    ),
                    clipBehavior: Clip.antiAlias,  // Proper clipping for rounded corners
                    child: DropzoneView(
                      onCreated: (controller) {
                        _controller = controller;
                      },
                      onDrop: _onDrop,
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _pickImageFromGallery,
                    child: Container(
                      color: Colors.transparent,  // Allow drag-and-drop
                      width: constraints.maxWidth - 100,
                      height: constraints.maxHeight - 80,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.blue[800],  // Icon color
                          ),
                          Text(
                            "Glisser-déposer une image ici",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
