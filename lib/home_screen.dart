import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

late List<CameraDescription> _cameras; // how many cameras present in the device and camera details stored

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late CameraController cameraController;

  XFile? pickedImage;
  String? imageUrl;
  String? fileName;

  /// Image pick from gallery
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
                    log(pickedImage!.path);

                    if (pickedImage == null) {
                      return;
                    }

                    fileName = DateTime.now().millisecondsSinceEpoch.toString();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(_cameras[0], ResolutionPreset.high);

    cameraController.initialize().then((_) {
      if(!mounted){

      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraPreview(cameraController),
    );
  }
}
