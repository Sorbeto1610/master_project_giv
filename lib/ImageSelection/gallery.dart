import 'dart:ui';  // Ajoutez cette ligne pour inclure ImageFilter
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
          LayoutBuilder(
            builder: (context, constraints) {
              bool isPhone = constraints.maxWidth < 600;

              double containerWidth = constraints.maxWidth * 0.5;
              double containerHeight = constraints.maxHeight * 0.5;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCustomButton(
                      context,
                      text: 'Select Image from Gallery',
                      icon: Icons.photo_library,
                      onPressed: _pickImageFromGallery,
                    ),
                    if (_imageData != null) ...[
                      SizedBox(height: 20),
                      _buildCustomButton(
                        context,
                        text: 'Appliquer la détection de visage',
                        icon: Icons.face,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FaceDetectionPage(imagesData: _imageData!), // Correct parameter
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _imageData!,
                          fit: BoxFit.cover,
                          width: containerWidth, // Largeur de l'image
                          height: containerHeight, // Hauteur de l'image
                        ),
                      ),
                    ],
                    if (!isPhone && _imageData == null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: containerWidth, // Largeur du conteneur
                            height: containerHeight, // Hauteur du conteneur
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2), // Couleur de fond avec transparence
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                DropzoneView(
                                  onCreated: (controller) {
                                    _controller = controller;
                                  },
                                  onDrop: _onDrop,
                                ),
                                if (_imageData == null)
                                  Positioned.fill(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: _pickImageFromGallery,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.image,
                                              size: 50, // Taille de l'icône
                                              color: Colors.blue[800],  // Couleur de l'icône
                                            ),
                                            Text(
                                              "Glisser-déposer une image ici",
                                              style: TextStyle(fontSize: 16, color: Colors.black), // Taille et couleur du texte
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
