import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';  // For Uint8List
import 'package:master_project_giv/imageValidation.dart';
import 'package:master_project_giv/faceDetectionPage.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  Uint8List? _capturedPhotoData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "Aucune caméra disponible.";
        });
        return;
      }
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;
      setState(() {
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de l'initialisation de la caméra : $e";
      });
    }
  }

  Future<void> _resetCamera() async {
    try {
      await _cameraController.dispose();
      await _initializeCamera();
    } catch (e) {
      setState(() {
        _errorMessage = "Erreur lors de la réinitialisation de la caméra : $e";
      });
    }
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
      final photoData = await photo.readAsBytes();  // Read the photo data
      setState(() {
        _capturedPhotoData = photoData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenAspectRatio = MediaQuery.of(context).size.width /
        MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Prendre une photo"),
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : FutureBuilder(
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
                    aspectRatio: screenAspectRatio,
                    child: _capturedPhotoData == null
                        ? CameraPreview(_cameraController)
                        : Image.memory(_capturedPhotoData!),
                  ),
                  if (_capturedPhotoData == null)
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
                    )
                  else
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Naviguer vers la page de détection de visage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FaceDetectionPage(imageData: _capturedPhotoData!),
                                ),
                              );
                            },
                            child: Text("Appliquer la détection de visage"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Réinitialiser l'état pour reprendre une nouvelle photo
                              setState(() {
                                _capturedPhotoData = null;
                              });
                              _resetCamera(); // Réinitialiser la caméra
                            },
                            child: Text("Reprendre une photo"),
                          ),
                        ],
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
