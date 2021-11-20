import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camera_screen.dart';


class cam_screen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const cam_screen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      home: CameraScreen(cameras: cameras),
    );
  }
}