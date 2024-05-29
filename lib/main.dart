import 'package:flutter/material.dart';
import 'package:master_project_giv/ImageSelection/camera.dart';
import 'package:master_project_giv/ImageSelection/gallery.dart';
import 'package:master_project_giv/liveFaceDetection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Face Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        '/camera': (context) => CameraPage(),
        '/gallery': (context) => ImageSelectionPage(),
        '/live_face_detection': (context) => LiveFaceDetectionPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/gallery');
              },
              child: Text('Select Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              child: Text('Take Photo with Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/live_face_detection');
              },
              child: Text('Live Face Detection'),
            ),
          ],
        ),
      ),
    );
  }
}
