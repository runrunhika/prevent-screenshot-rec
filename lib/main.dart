import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = ScreenshotController();
  bool isSecureMode = false;

  @override
  Widget build(BuildContext context) {
    final text = "Secure Mode: ${isSecureMode ? 'ON' : 'OFF'}";

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(32),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: Size.fromHeight(64),
              textStyle: TextStyle(fontSize: 20)),
          child: Text(text),
          onPressed: () async {
            final image = await controller.capture();
            setState(() {
              isSecureMode = !isSecureMode;
            });

            if (isSecureMode) {
              //Block Screenshots
              FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
            } else {
              //Allow Screenshots
              FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);

              saveImage(image!);
            }
          },
        ),
      ),
    );
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'screenshot_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);

    return result['filePath'];
  }
}
