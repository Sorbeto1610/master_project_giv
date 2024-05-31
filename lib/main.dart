import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_core/firebase_core.dart'; // Importer Firebase
//import 'package:firebase_analytics/firebase_analytics.dart'; // Importer Firebase Analytics
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
        measurementId: "G-Q6V80E651X"
    ),
  );
  runApp(MyApp());
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
        title: Text('Welcome'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;

          bool isPhone = screenWidth < 600;

          return isPhone
              ? _buildMobileLayout(context)
              : _buildDesktopLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageSelectionPage()),
              );
            },
            child: Center(
              child: Text(
                'Gallery Selection',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraPage()),
              );
            },
            child: Center(
              child: Text(
                'Take a Picture',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageSelectionPage()),
              );
            },
            child: Center(
              child: Text(
                'Gallery Selection',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CameraPage()),
              );
            },
            child: Center(
              child: Text(
                'Take a Picture',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
