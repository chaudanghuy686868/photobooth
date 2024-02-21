import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photobooth_section1/screens/screen5.dart';
import 'package:photobooth_section1/screens/screen6.dart';
import 'package:photobooth_section1/screens/screen7.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:photobooth_section1/screens/screen3.dart';

import '../palatter.dart';
import '../widgets/background-image.dart';

class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  State<StatefulWidget> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  late VideoPlayerController _controller;
  String _storedUserValue = '';

  static const MaterialColor black = MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0x00000000),
      100: Color(0x00000000),
      200: Color(0x00000000),
      300: Color(0x00000000),
      400: Color(0x00000000),
      500: Color(0x00000000),
      600: Color(0x00000000),
      700: Color(0x00000000),
      800: Color(0x00000000),
      900: Color(0x00000000),
    },
  );

  @override
  void initState() {
    _loadStoredValue();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    //_controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: black,
      ),
      // standard dark theme
      darkTheme: ThemeData.dark(),

      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            BackGroundImage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/template/text_screen2_new.png',
                )
              ],
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    child: SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 0.0, top: 150.0),
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 50.0,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 1000,
                                  height: 500,
                                  //color: Colors.green[200],
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 480,
                                        //height: 270,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          //color: Colors.green[200],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.asset(
                                            'assets/images/screen2.gif',
                                            width: 250,
                                            //height: 270,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 30,
                                        height: 225,
                                        //color: Colors.blue[200],
                                      ),
                                      Container(
                                        width: 480,
                                        //height: 270,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: Colors.green[200],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: Image.asset(
                                            'assets/images/screen2.gif',
                                            width: 250,
                                            //height: 275,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            RawMaterialButton(
                              onPressed: () {
                                AudioPlayer()
                                    .play(AssetSource('audio/button.mp3'));
                                Navigator.push(
                                  context,
                                  // MaterialPageRoute(
                                  //     builder: (context) => Screen7(
                                  //         imgUrl: 'assets/template/screen1.png',
                                  //         imgUrlTarget:
                                  //             'assets/template/screen2.gif')),
                                  MaterialPageRoute(builder: (context) => Screen3()),
                                  //MaterialPageRoute(builder: (context) => Screen5(image: '',)),
                                  //MaterialPageRoute(builder: (context) => Screen6(imgUrl: 'assets/images/test1.png', effectName: '3dcartoon-man',)),
                                );
                              },
                              elevation: 2.0,
                              fillColor: Colors.teal.withOpacity(0.8),
                              child: Icon(
                                Icons.arrow_forward_ios_sharp,
                                size: 55.0,
                              ),
                              padding: EdgeInsets.all(30.0),
                              shape: CircleBorder(
                                side: BorderSide(
                                  color: Colors.white,
                                  width: 5,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/template/screen2_below_text.png',
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _loadStoredValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('username'));

    setState(() {
      _storedUserValue = prefs.getString('username') ?? '';
    });
  }

  _getVideoBackground() {
    var visible;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 1000),
      child: VideoPlayer(_controller),
    );
  }

  _getBackgroundColor() {
    return Container(
      color: Colors.black,
    );
  }

  _getContent(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        const SizedBox(
          height: 50.0,
        ),
        /*
        const Image(
          image: AssetImage("assets/images/logo.png"),
          width: 150.0,
        ),
         */
        const Text(
          "MONGTAMEDIA",
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
        const Text(
          "Photo - Booth",
          style: TextStyle(color: Colors.white, fontSize: 40),
        ),
        Container(
          margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 40.0),
          alignment: Alignment.center,
          child: const Text(
            "View and share videos of current ocean conditions.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        const Spacer(),
        ..._getLoginButtons(context)
      ],
    );
  }

  _getLoginButtons(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(left: 20, right: 20),
        height: 80,
        width: 200,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Get Photo',
              style: kBodyText,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screen3()),
              //MaterialPageRoute( builder: (context) => const TakePictureScreen()),
              // MaterialPageRoute(
              //     builder: (context) => Screen7(
              //         imgUrl: 'assets/images/test1.png',
              //         imgUrlTarget: 'assets/template/screen2.gif')),
            );
          },
        ),
      ),
      Container(
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
        height: 80,
        width: 200,
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.grey.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Photo List',
              style: kBodyText,
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Screen3()),
            );
          },
        ),
      ),
    ];
  }
}
