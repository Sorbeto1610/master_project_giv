import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:async';

class FaceDetectionPage extends StatefulWidget {
  final Uint8List imagesData;

  FaceDetectionPage({required this.imagesData});

  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  bool _isProcessing = false;
  ui.Image? _image;
  List<List<double>> _faces = [];
  List<String> _agePredictions = [];
  List<String> _genderPredictions = [];
  List<String> _emotionPredictions = []; // Added emotion predictions

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final Completer<ui.Image> completer = Completer<ui.Image>();
      ui.decodeImageFromList(widget.imagesData, (ui.Image img) {
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
      print("Error loading image: $e");
    }
  }

  Future<void> _sendImageForProcessing() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5001/process-image'),  // Use your local IP address and correct port
      );
      request.files.add(
        http.MultipartFile.fromBytes('image', widget.imagesData, filename: 'image.jpg'),
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
            _agePredictions = List<String>.from(responseJson['predictions'].map((pred) => pred['age']));
            _genderPredictions = List<String>.from(responseJson['predictions'].map((pred) => pred['gender']));
            _emotionPredictions = List<String>.from(responseJson['predictions'].map((pred) => pred['emotion']));  // Store the emotion predictions
            _isProcessing = false;
          });
          completer.complete(img);
        });
        await completer.future;
      } else {
        setState(() {
          _isProcessing = false;
        });
        print("Error in response: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      print("Error sending image for processing: $e");
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
          Positioned.fill(
            child: Image.asset(
              'IMG_2565.jpeg',  // Relative path of the image
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: _isProcessing
                ? CircularProgressIndicator()
                : _image == null
                ? Text("Loading image...")
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: _image!.width / _image!.height,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _image!.width.toDouble(),
                        height: _image!.height.toDouble(),
                        child: CustomPaint(
                          size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
                          painter: FacePainter(_image!, _faces, _agePredictions, _genderPredictions, _emotionPredictions),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
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
  final List<String> agePredictions;
  final List<String> genderPredictions;
  final List<String> emotionPredictions;

  FacePainter(this.image, this.faces, this.agePredictions, this.genderPredictions, this.emotionPredictions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());

    for (int i = 0; i < faces.length; i++) {
      var face = faces[i];
      final rect = Rect.fromLTWH(
        face[0],
        face[1],
        face[2],
        face[3],
      );
      canvas.drawRect(rect, paint);

      // Draw age, gender, and emotion prediction text
      final textSpan = TextSpan(
        text: 'Age: ${agePredictions[i]}, Gender: ${genderPredictions[i]}, Emotion: ${emotionPredictions[i]}',
        style: TextStyle(color: Colors.red, fontSize: 20),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: size.width,
      );
      textPainter.paint(canvas, Offset(face[0], face[1] - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
