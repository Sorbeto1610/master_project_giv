import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'dart:typed_data';
import 'package:master_project_giv/imageValidation.dart';  // New page to display the selected image
import 'package:master_project_giv/faceDetectionPage.dart';  // Import face detection page

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
      });
    }
  }

  Future<void> _onDrop(dynamic event) async {
    final imageBytes = await _controller?.getFileData(event);
    setState(() {
      _imageData = imageBytes;
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImageFromGallery,
                    child: Text("Select Image from Gallery"),
                  ),
                  if (_imageData != null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceDetectionPage(imageData: _imageData!),
                          ),
                        );
                      },
                      child: Text("Appliquer la détection de visage"),
                    ),
                ],
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
                  if (_imageData != null)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FaceDetectionPage(imageData: _imageData!),
                              ),
                            );
                          },
                          child: Text("Appliquer la détection de visage"),
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
