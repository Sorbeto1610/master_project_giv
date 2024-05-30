import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'dart:ui' as ui;
import 'dart:async';  // Importer dart:async pour Completer

class FaceDetectionPage extends StatefulWidget {
  final Uint8List imageData;

  FaceDetectionPage({required this.imageData});

  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late FaceDetector _faceDetector;
  List<Face> _faces = [];
  bool _isProcessing = false;
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _faceDetector = GoogleMlKit.vision.faceDetector();
    _loadImage();
  }

  Future<void> _loadImage() async {
    print("Loading image...");
    try {
      final Completer<ui.Image> completer = Completer<ui.Image>();
      ui.decodeImageFromList(widget.imageData, (ui.Image img) {
        setState(() {
          _image = img;
        });
        completer.complete(img);
      });
      await completer.future;
      print("Image loaded successfully.");
      _detectFaces();
    } catch (e) {
      print("Error loading image: $e");
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _detectFaces() async {
    if (_image == null) {
      print("No image to process.");
      return;
    }
    setState(() {
      _isProcessing = true;
    });
    try {
      final inputImage = InputImage.fromBytes(
        bytes: widget.imageData,
        inputImageData: InputImageData(
          size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
          imageRotation: InputImageRotation.rotation0deg, // Utiliser la valeur correcte pour aucune rotation
          inputImageFormat: InputImageFormat.BGRA8888, // Utiliser le format correct
          planeData: [
            InputImagePlaneMetadata(
              bytesPerRow: _image!.width,
              height: _image!.height,
              width: _image!.width,
            ),
          ],
        ), metadata: null,
      );

      final faces = await _faceDetector.processImage(inputImage);
      print("Faces detected: ${faces.length}");

      setState(() {
        _faces = faces;
        _isProcessing = false;
      });
    } catch (e) {
      print("Error detecting faces: $e");
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détection de visage"),
      ),
      body: Center(
        child: _isProcessing
            ? CircularProgressIndicator()
            : _image == null
            ? Text("Chargement de l'image...")
            : Stack(
          children: [
            Image.memory(widget.imageData),
            CustomPaint(
              painter: FacePainter(_image!, _faces),
            ),
          ],
        ),
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (Face face in faces) {
      canvas.drawRect(face.boundingBox, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
