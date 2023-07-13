import 'dart:developer';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

/// how many cameras present in a device and also stored the camera details.
late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? pickedImage;
  File? _image;
  String? fileName;
  String result = 'Result will shown here';

  late CameraController cameraController;

  /// Image pick from gallery or camera
  Future<void> imagePickerFunction() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick Image from'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Gallery'),
                  leading: const Icon(Icons.image),
                  onTap: () async {
                    pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    print(pickedImage!.path);
                    _image = File(pickedImage!.path);

                    setState(() {
                      _image;
                      doImageLabeling();
                    });

                    if (pickedImage == null) {
                      return;
                    }
                    //fileName = DateTime.now().millisecondsSinceEpoch.toString();
                  },
                ),
                ListTile(
                  title: const Text('Camera'),
                  leading: const Icon(Icons.camera_alt_outlined),
                  onTap: () async {
                    pickedImage = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    print(pickedImage!.path);
                    _image = File(pickedImage!.path);
                    setState(() {
                      _image;
                      doImageLabeling();
                    });
                    if (pickedImage == null) {
                      return;
                    }
                    //fileName = DateTime.now().millisecondsSinceEpoch.toString();
                  },
                ),
              ],
            ),
          );
        });
  }

  doImageLabeling() async {
    InputImage inputImage = InputImage.fromFile(_image!);

    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

    result = '';
    for (ImageLabel label in labels) {
      final String name = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result += "$name   ${confidence.toStringAsFixed(2)} \n";
    }
    setState(() {
      result;
    });
  }

  dynamic imageLabeler;

  @override
  void initState() {
    super.initState();

    /// confident prediction give if 50% +
    final ImageLabelerOptions options =
        ImageLabelerOptions(confidenceThreshold: 0.5);

    imageLabeler = ImageLabeler(options: options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      imagePickerFunction();
                    },
                    child: Container(
                      child: _image != null
                          ? Image.file(
                              _image!,
                              width: 335,
                              height: 495,
                              fit: BoxFit.fill,
                            )
                          : const SizedBox(
                              width: 340,
                              height: 330,
                              child: Icon(
                                Icons.camera_alt,
                                size: 100,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                child: Text(
                  result.toString(),
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
