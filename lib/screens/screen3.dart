import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_section1/models/image_model.dart';
import 'package:photobooth_section1/palatter.dart';
import 'package:photobooth_section1/screens/screen4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class Screen3 extends StatefulWidget {
  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  late CameraController _controller;
  late List<CameraDescription> cameras;
  bool isCameraReady = false;

  List<ImageModel> savedImages = [];
  File? _imageFile;
  String userDirPath = '';

  int _countdown = 6;
  late Timer _timer;
  bool startCount = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    _controller = CameraController(cameras[0], ResolutionPreset.ultraHigh);
    await _controller.initialize();

    if (!mounted) return;

    setState(() {
      isCameraReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_countdown == 0) {
        timer.cancel();
        takePhoto();
        _countdown = 6;
        startCount = false;
      } else {
        setState(() {
          _countdown--;
          startCount = true;
        });
      }
    });
  }

  /**
   * Create folder inside root directory
   * 
   * Snap photo -> go to 'myphotos/{userID}/Temp'
   * Crop photo(s) -> save to 'myphotos/{userID}/User'
   * If photos reach (4) -> go to Screen4
   * If user choose photo -> go into 'myphotos/{userID}/Target'
   * If photo apply AI -> go to Result with format 'myphotos/{userID}/Result/{Effect-ID}.png'
   */
  void takePhoto() async {
    if (_controller.value.isInitialized) {
      try {
        // Capture photo
        final XFile file = await _controller.takePicture();

        // Get directory to save
        Directory current = Directory.current;

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Parent folder
        final String internalFolder = path.join(current.path, 'myphotos');
        await Directory(internalFolder).create(recursive: true);

        // User folder
        DateTime now = DateTime.now();
        String _username = DateFormat('yyyyMMddkk').format(now);
        await prefs.setString("username", _username);

        final String userDir = path.join(internalFolder, _username);
        await Directory(userDir).create(recursive: true);

        setState(() {
          userDirPath = userDir;
        });

        // Temp folder
        final String tempUserDir = path.join(userDir, 'Temp');
        await Directory(tempUserDir).create(recursive: true);

        // Save photo
        final String userPath =
            path.join(tempUserDir, path.basename(file.path));
        await File(file.path).copy(userPath);

        setState(() {
          _imageFile = File(userPath);
        });

        _cropPhoto();
      } catch (e) {
        print("Error taking photo: $e");
      }
    }
  }

  Future<void> _cropPhoto() async {
    if (_imageFile == null) {
      return;
    }

    final image = img.decodeImage(await _imageFile!.readAsBytes())!;
    var cropSize = min(image.width, image.height);
    int offsetX = (image.width - cropSize) ~/ 2;
    int offsetY = (image.height - cropSize) ~/ 2;

    final croppedImage = img.copyCrop(image, offsetX, offsetY, 640, 628);

    // Temp folder
    final String tempUserDir = path.join(userDirPath, 'User');
    await Directory(tempUserDir).create(recursive: true);

    // Save photo
    int userPhotoId = savedImages.length + 1;
    final String userPath =
        path.join(tempUserDir, 'user_photo_$userPhotoId.jpg');
    File(userPath).writeAsBytesSync(img.encodeJpg(croppedImage));

    final ImageModel savedImage = ImageModel(
      id: userPhotoId,
      title: 'user_photo_$userPhotoId',
      imgUrl: userPath,
    );

    setState(() {
      savedImages.add(savedImage);
    });

    if (savedImages.length >= 4) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Screen4(
                    images: savedImages,
                  )));
    }
  }

  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return Container();
    }

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image(
              image: AssetImage('assets/template/theme.png'),
              fit: BoxFit.cover,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      text: '인공지능',
                      style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent,
                          fontFamily: 'GulyFont'),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' 은 어떻게 나를 바꾸어 줄까요?',
                          style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'GulyFont'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Rounded Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 200),
                            height: 483,
                            width: 841,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: CameraPreview(_controller),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 200, top: 10),
                              child: startCount
                                  ? Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      child: Text(
                                        '$_countdown',
                                        style: TextStyle(
                                            fontSize: 50,
                                            color: Colors.white,
                                            fontFamily: 'GulyFont'),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: 10, top: startCount ? 300 : 390),
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () {
                                // Trigger start countdown
                                startTimer();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 20),
                                child: Text('촬영',
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.black,
                                        fontFamily: 'GulyFont')),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}