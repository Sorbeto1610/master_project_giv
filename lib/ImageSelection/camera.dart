import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';
import 'package:master_project_giv/imageValidation.dart';
import 'package:master_project_giv/liveFaceDetection.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  Uint8List? _capturedPhotoData;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;
    } catch (e) {
      print("Erreur lors de l'initialisation de la caméra : $e");
    }
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_initializeControllerFuture != null) {
      await _initializeControllerFuture;
      final photo = await _cameraController.takePicture();
      final photoData = await photo.readAsBytes();
      setState(() {
        _capturedPhotoData = photoData;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDisplayPage(imageData: _capturedPhotoData!),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prendre une photo"),
        actions: [
          IconButton(
            icon: Icon(Icons.camera, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LiveFaceDetectionPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 20),
                  Text("En attente de l'autorisation de la caméra..."),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: FloatingActionButton(
                        onPressed: _takePhoto,
                        child: Icon(Icons.camera),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 20),
                Text("Erreur lors de l'initialisation de la caméra."),
              ],
            ),
          );
        },
      ),
    );
  }
}
