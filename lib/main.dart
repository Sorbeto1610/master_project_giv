import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_core/firebase_core.dart'; // Importer Firebase
// import 'package:firebase_analytics/firebase_analytics.dart'; // Importer Firebase Analytics
import 'ImageSelection/gallery.dart';
import 'ImageSelection/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBHXurMIXMTZCNw6sW0sJ2quoHg5wzF-oQ",
      authDomain: "givmasterproject.firebaseapp.com",
      projectId: "givmasterproject",
      storageBucket: "givmasterproject.appspot.com",
      messagingSenderId: "618848783949",
      appId: "1:618848783949:web:7e5826ab19aaa9a8b61604",
      measurementId: "G-Q6V80E651X",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Main Page',
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
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
              double screenWidth = constraints.maxWidth;
              bool isPhone = screenWidth < 600;

              return Column(
                children: [
                  SizedBox(height: kToolbarHeight), // Espace pour l'AppBar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EGA Detection',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Emotions, Gender and Age Detection Application and Tool',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: isPhone
                          ? _buildMobileLayout(context)
                          : _buildDesktopLayout(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Créé par DAGHER Irene, CHABREDIER Gabriel et GOBERT Valentine  ',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCustomButton(
          context,
          text: 'Gallery Selection',
          icon: Icons.photo_library,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageSelectionPage()),
            );
          },
        ),
        SizedBox(height: 20), // Espacement entre les boutons
        _buildCustomButton(
          context,
          text: 'Take a Picture',
          icon: Icons.camera_alt,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCustomButton(
          context,
          text: 'Gallery Selection',
          icon: Icons.photo_library,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ImageSelectionPage()),
            );
          },
        ),
        SizedBox(width: 20), // Espacement entre les boutons
        _buildCustomButton(
          context,
          text: 'Take a Picture',
          icon: Icons.camera_alt,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraPage()),
            );
          },
        ),
      ],
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
