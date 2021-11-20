import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:crop_image/crop_image.dart';

import 'package:flutter/src/widgets/image.dart' as ddd;
import 'package:image/image.dart';

import 'details.dart';


class GalleryScreen extends StatelessWidget {
  final File images;
  const GalleryScreen({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaznacz płytę',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Zaznacz płytę',images: images),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Gallery'),
  //     ),
  //     body: GridView.count(
  //       crossAxisCount: 3,
  //       mainAxisSpacing: 2,
  //       crossAxisSpacing: 2,
  //       children: images
  //           .map((image) => Image.file(image, fit: BoxFit.cover))
  //           .toList(),
  //     ),
  //   );
  // }
}

class MyHomePage extends StatefulWidget {
final String title;
final File images;
const MyHomePage({Key? key, required this.title, required this.images}) : super(key: key);

@override
_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = CropController(
    aspectRatio: 1,
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: CropImage(
          controller: controller,
          image: ddd.Image.file(widget.images),
        ),
      ),
    ),
    bottomNavigationBar: _buildButtons(),
  );

  Widget _buildButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName('/camera_screen'));
        },
      ),
      TextButton(
        onPressed: _finished,
        child: const Text('Done'),
      ),
    ],
  );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select aspect ratio'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> _finished() async {
    final image = await controller.croppedBitmap();
    var immageToDispaly = await controller.croppedImage();
    ByteData? data = await image.toByteData(format: ImageByteFormat.png);
    debugPrint(data!.lengthInBytes.toString());
    List<int> bytes = data!.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    var imagee = decodeImage(bytes)!;
    var thumbnail = copyResize(imagee, width: 250,height: 250);
    List<int> imageBytes = (encodePng(thumbnail));
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    print(" base64 image start ");
    debugPrint(base64Image);
    print(" base64 image end ");
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => details(baseImg: base64Image)));
    // await showDialog<bool>(
    //   context: context,
    //   builder: (context) {
    //     return SimpleDialog(
    //       contentPadding: const EdgeInsets.all(6.0),
    //       titlePadding: const EdgeInsets.all(8.0),
    //       title: const Text('Cropped image'),
    //       children: [
    //         Text('relative: ${controller.crop}'),
    //         Text('pixels: ${controller.cropSize}'),
    //         const SizedBox(height: 5),
    //         immageToDispaly,
    //         TextButton(
    //           onPressed: () => Navigator.push(
    //               context,
    //               MaterialPageRoute(
    //                   builder: (context) => details(baseImg: base64Image))),
    //           child: const Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
