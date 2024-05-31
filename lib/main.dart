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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EGA Detection',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Emotions, Gender and Age Detection Application and Tool',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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

              return Center(
                child: isPhone
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
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

  Widget _buildCustomButton(BuildContext context, {required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Couleur de fond
        foregroundColor: Colors.white, // Couleur du texte
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Ajuster la taille du bouton
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Coins arrondis
        ),
        textStyle: TextStyle(fontSize: 18), // Taille du texte
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
