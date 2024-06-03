import 'dart:ui';  // Ajoutez cette ligne pour inclure ImageFilter
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:async';

class FaceDetectionPage extends StatefulWidget {
  final Uint8List imageData;

  FaceDetectionPage({required this.imageData});

  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  bool _isProcessing = false;
  ui.Image? _image;
  List<List<double>> _faces = [];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final Completer<ui.Image> completer = Completer<ui.Image>();
      ui.decodeImageFromList(widget.imageData, (ui.Image img) {
        setState(() {
          _image = img;
        });
        completer.complete(img);
      });
      await completer.future;
      _sendImageForProcessing();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _sendImageForProcessing() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5001/process-image'),  // Utilisez votre adresse IP locale et le port correct
      );
      request.files.add(
        http.MultipartFile.fromBytes('image', widget.imageData, filename: 'image.jpg'),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = jsonDecode(responseData);
        final base64Image = responseJson['image'].split(',')[1];
        final Uint8List decodedImage = base64.decode(base64Image);

        final Completer<ui.Image> completer = Completer<ui.Image>();
        ui.decodeImageFromList(decodedImage, (ui.Image img) {
          setState(() {
            _faces = List<List<double>>.from(responseJson['faces'].map((face) => List<double>.from(face)));
            _image = img;
            _isProcessing = false;
          });
          completer.complete(img);
        });
        await completer.future;
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Image d'arrière-plan
          Positioned.fill(
            child: Image.asset(
              'IMG_2565.jpeg', // Chemin relatif de l'image
              fit: BoxFit.cover,
            ),
          ),
          // Contenu de la page
          Center(
            child: _isProcessing
                ? CircularProgressIndicator()
                : _image == null
                ? Text("Loading image...")
                : AspectRatio(
              aspectRatio: _image!.width / _image!.height,
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: _image!.width.toDouble(),
                  height: _image!.height.toDouble(),
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
                        painter: FacePainter(_image!, _faces),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<List<double>> faces;

  FacePainter(this.image, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());

    for (var face in faces) {
      final rect = Rect.fromLTWH(
        face[0],
        face[1],
        face[2],
        face[3],
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
