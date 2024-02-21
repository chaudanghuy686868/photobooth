import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_section1/models/image_model.dart';
import 'package:photobooth_section1/palatter.dart';
import 'package:photobooth_section1/screens/screen4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:stroke_text/stroke_text.dart';
import 'package:image_cropper/image_cropper.dart';

const _videoConstraints = VideoConstraints(
  facingMode: FacingMode(
    type: CameraType.user,
    constrain: Constrain.ideal,
  ),
  width: VideoSize(ideal: 320, maximum: 520),
  height: VideoSize(ideal: 280, maximum: 380),
);

class Screen3 extends StatefulWidget {
  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  bool isCameraReady = false;

  List<ImageModel> savedImages = [];
  File? _imageFile;
  String userDirPath = '';

  int _countdown = 3;
  late Timer _timer;
  bool startCount = false;
  bool okToTimer = true;

  int _cameraIndex = 0;
  int _cameraId = -1;
  bool _initialized = false;

  int _cntdown = 3;
  bool delayStartCnt = false;

  final _controller = CameraController(
      options: const CameraOptions(
    audio: AudioConstraints(),
    video: _videoConstraints,
  ));

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _delayTimer();
  }

  bool get _isCameraAvailable =>
      _controller.value.status == CameraStatus.available;

  Future<void> _play() async {
    if (!_isCameraAvailable) return;
    return _controller.play();
  }

  /// Initializes the camera on the device.
  Future<void> _initializeCamera() async {
    await _controller.initialize();
    await _play();
  }

  void _delayTimer() {
    const threeSec = const Duration(seconds: 2);
    _timer = Timer.periodic(threeSec, (Timer timer1) {
      if (_cntdown == 0) {
        timer1.cancel();
        startTimer();
      } else {
        setState(() {
          _cntdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startTimer() {
    const twoSec = const Duration(seconds: 2);
    _timer = Timer.periodic(twoSec, (Timer timer) {
      if (_countdown == 0) {
        timer.cancel();
        takePhoto();
        _countdown = 3;
        startCount = false;
        if (okToTimer) {
          AudioPlayer().play(AssetSource('audio/take_picture.mp3'));
          startTimer();
        }
      } else {
        setState(() {
          _countdown--;
          startCount = true;
        });
      }
    });
  }

  void takePhoto() async {
    try {
      if (savedImages.length > 2) {
        setState(() {
          okToTimer = false;
        });
        Timer(Duration(seconds: 5), () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Screen4(
                        images: savedImages,
                      )));
        });
      }

      // Capture photo
      final picture = await _controller.takePicture();

      int userPhotoId = savedImages.length + 1;
      final ImageModel savedImage = ImageModel(
        id: userPhotoId,
        title: 'user_photo_$userPhotoId',
        imgUrl: picture.data,
      );

      setState(() {
        savedImages.add(savedImage);
      });
    } catch (e) {
      print("Error taking photo: $e");
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

    final croppedImage = img.copyCrop(image, offsetX, offsetY, 500, 350);

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
      Timer(Duration(seconds: 5), () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Screen4(
                      images: savedImages,
                    )));
      });
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image(
              image: AssetImage('assets/images/bg_ver.png'),
              fit: BoxFit.cover,
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/template/up-arrow-screen3.png',
                          width: 100, //1000
                          height: 80,
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/template/up-text-screen3.png',
                          height: 40,
                        )
                      ],
                    ),
                  ),
                  Container(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    height: 200, //300
                    //color: Colors.white70,
                    margin: const EdgeInsets.only(
                      left: 10.0, //10
                      right: 10.0, //0
                      top: 10.0,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/template/text-screen3.png',
                          width: 972, //1000
                          height: 320,
                        )
                      ],
                    ),
                  ),
                  Container(
                    //color: Colors.deepOrangeAccent,
                    margin: const EdgeInsets.only(
                      left: 10.0,
                      right: 0.0,
                      top: 10.0,
                      bottom: 100,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 90),
                          // Rounded Image
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 5,
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    alignment: Alignment.center,
                                    margin: EdgeInsets.only(left: 0, top: 10),
                                    height: 635, //550
                                    width: 840, //690
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      child: AspectRatio(
                                        aspectRatio: 10.0 / 7.5, //5/4
                                        // aspectRatio: _previewSize!.width /_previewSize!.height,
                                        child: Camera(
                                          controller: _controller,
                                          placeholder: (_) => const SizedBox(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  (startCount || savedImages.isNotEmpty)
                                      ? Container(
                                          margin:
                                              EdgeInsets.only(left: 8, top: 20),
                                          alignment: Alignment.bottomCenter,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              AudioPlayer().play(AssetSource(
                                                  'audio/take_picture.mp3'));
                                              // Trigger start countdown
                                              startTimer();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 30),
                                              child: StrokeText(
                                                text: okToTimer
                                                    ? '$_countdown'
                                                    : "촬영",
                                                textStyle: TextStyle(
                                                  fontSize: 80,
                                                  color: Colors.black,
                                                  fontFamily: 'GulyFont',
                                                ),
                                                strokeColor: Colors.white,
                                                strokeWidth: 1,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                  width: 5,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              minimumSize: Size(280, 160),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          margin:
                                              EdgeInsets.only(left: 8, top: 20),
                                          alignment: Alignment.bottomCenter,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              AudioPlayer().play(AssetSource(
                                                  'audio/take_picture.mp3'));
                                              // Trigger start countdown
                                              startTimer();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 30),
                                              child: StrokeText(
                                                text: "촬영",
                                                textStyle: TextStyle(
                                                  fontSize: 80,
                                                  color: Colors.black,
                                                  fontFamily: 'GulyFont',
                                                ),
                                                strokeColor: Colors.white,
                                                strokeWidth: 5,
                                              ),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                  width: 5,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              minimumSize: Size(280, 160),
                                            ),
                                          ),
                                        ),
                                  /*
                                  Container(
                                    margin: EdgeInsets.only(left: 8, top: 20),
                                    alignment: Alignment.bottomCenter,
                                      child: ElevatedButton(
                                      onPressed: () {
                                        AudioPlayer().play(
                                            AssetSource('audio/take_picture.mp3'));
                                        // Trigger start countdown
                                        startTimer();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 30),
                                        child: (startCount || savedImages.isNotEmpty)
                                            ? StrokeText(
                                          text:
                                          okToTimer ? '$_countdown' : "촬영",
                                          textStyle: TextStyle(
                                            fontSize: 80,
                                            color: Colors.black,
                                            fontFamily: 'GulyFont',
                                          ),
                                          strokeColor: Colors.white,
                                          strokeWidth: 5,
                                        )
                                            : StrokeText(
                                          text: "촬영",
                                          textStyle: TextStyle(
                                            fontSize: 80,
                                            color: Colors.black,
                                            fontFamily: 'GulyFont',
                                          ),
                                          strokeColor: Colors.white,
                                          strokeWidth: 5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            width: 5,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  */
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.only(left: 30, top: 20),
                            height: 220,
                            width: 900,
                            //color: Colors.green[200],
                            alignment: Alignment.center,
                            child: ThumbnailGridView(
                              images: savedImages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/template/down-text-screen3.png',
                          height: 40,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        /*
        bottomNavigationBar: ThumbnailGridView(
          images: savedImages,
        ),

         */
      ),
    );
  }
}

class ThumbnailGridView extends StatelessWidget {
  final List<ImageModel> images;
  const ThumbnailGridView({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          Image imageSnap = Image.network(
            images[index].imgUrl,
            width: 200.0,
            height: 180.0,
            fit: BoxFit.cover,
          );
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Container(
                  width: 200.0,
                  height: 180.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageSnap.image,
                      fit: BoxFit.fill,
                    ),
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
