import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class ImageDisplayPage extends StatefulWidget {
  final Uint8List imageData;

  ImageDisplayPage({required this.imageData});

  @override
  _ImageDisplayPageState createState() => _ImageDisplayPageState();
}

class _ImageDisplayPageState extends State<ImageDisplayPage> {
  List<Face> _faces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectFaces();
  }

  Future<void> _detectFaces() async {
    final inputImage = InputImage.fromBytes(
      bytes: widget.imageData,
      inputImageData: _buildMetaData(),
    );
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final faces = await faceDetector.processImage(inputImage);
    setState(() {
      _faces = faces;
      _isLoading = false;
    });
  }

  InputImageData _buildMetaData() {
    return InputImageData(
      size: Size(480, 640),
      imageRotation: InputImageRotation.rotation0deg,
      inputImageFormat: InputImageFormat.nv21,
      planeData: [
        InputImagePlaneMetadata(
          bytesPerRow: 480,
          height: 640,
          width: 480,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Display Image"),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Stack(
          children: [
            Image.memory(
              widget.imageData,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
            ..._faces.map((face) => Positioned(
              left: face.boundingBox.left,
              top: face.boundingBox.top,
              width: face.boundingBox.width,
              height: face.boundingBox.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
