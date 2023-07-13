import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// how many cameras present in a device and also stored the camera details
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
  late CameraController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = CameraController(_cameras[0], ResolutionPreset.high); // camera[0] for back-camera and camera[1] for front camera

    /// this portion state that whether we are camera access or not. Also is camera is busy?
    cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError(
      (Object e) {
        if (e is CameraException) {
          if (e.code == 'CameraAccessDenied') {
            print('User Denied Camera Access');
          } else {
            print('Handle Other Errors');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraPreview(cameraController),
    );
  }
}
