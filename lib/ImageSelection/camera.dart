import 'dart:ui';  // Ajoutez cette ligne pour inclure ImageFilter
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
  bool _isCameraDisposed = false;

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
        _isCameraDisposed = false;
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
      setState(() {
        _isCameraDisposed = true;
      });
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
          _errorMessage != null
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

              if (snapshot.connectionState == ConnectionState.done && !_isCameraDisposed) {
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
                              _buildCustomButton(
                                context,
                                text: 'Appliquer la détection de visage',
                                icon: Icons.face,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FaceDetectionPage(imageData: _capturedPhotoData!),
                                    ),
                                  );
                                },
                              ),
                              _buildCustomButton(
                                context,
                                text: 'Reprendre une photo',
                                icon: Icons.camera,
                                onPressed: () {
                                  setState(() {
                                    _capturedPhotoData = null;
                                  });
                                  _resetCamera(); // Réinitialiser la caméra
                                },
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
        ],
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, {required String text, required IconData icon, required VoidCallback onPressed}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.3), // Couleur de fond avec transparence
            foregroundColor: Colors.white, // Couleur du texte et de l'icône
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Ajuster la taille du bouton
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Coins arrondis
            ),
            textStyle: TextStyle(fontSize: 18), // Taille du texte
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 24), // Icône
          label: Text(text),
        ),
      ),
    );
  }
}
