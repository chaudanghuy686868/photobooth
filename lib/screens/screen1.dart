import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_section1/screens/screen2.dart';
import 'package:stroke_text/stroke_text.dart';

class Screen1 extends StatelessWidget {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/template/text-screen1.png',
                )
              ],
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rounded Image
                  Container(
                    width: 890,
                    height: 580,
                    margin: const EdgeInsets.only(top: 330.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8.0),
                      //border: Border.all(color: Colors.white, width: 4),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage('assets/template/screen1.png')),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      AudioPlayer().play(AssetSource('audio/button.mp3'));
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Screen2()),
                      );
                    },
                    child: Container(
                      height: 170,
                      width: 270,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: AssetImage("assets/template/btn-screen1.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  /*
                  ElevatedButton(
                    onPressed: () {
                      AudioPlayer().play(AssetSource('audio/button.mp3'));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Screen2()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 18),
                      child: StrokeText(
                        text: "시작",
                        textStyle: TextStyle(
                          fontSize: 120,
                          color: Colors.red,
                          fontFamily: 'Gowun',
                        ),
                        strokeColor: Colors.black,
                        strokeWidth: 10,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  */
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
