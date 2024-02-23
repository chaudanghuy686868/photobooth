import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:photobooth_section1/screens/screen1.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

class Screen7 extends StatefulWidget {
  // AI Image
  Uint8List imgUrl;
  //String imgUrl;
  String imgUrlTarget;
  Screen7({required this.imgUrl, required this.imgUrlTarget});

  @override
  State<Screen7> createState() => _Screen7State();
}

class _Screen7State extends State<Screen7> {
  // TODO: Upload to API and get the image link here
  //late String imgUrl = '';
  late String imgUrlTest = '';
  final ApiService apiService = new ApiService();

  @override
  void initState() {
    super.initState();
    AudioPlayer().play(AssetSource('audio/screen7.mp3'));
    _uploadImage();
  }

  Future<html.File> convertUint8ListToFile(
      Uint8List bytes, String fileName) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'web'
      ..download = fileName
      ..click();
    html.Url.revokeObjectUrl(url);

    final file = await html.FileUploadInputElement().files!.first;
    return file;
  }

  Future<void> _uploadImage() async {
    Random random = new Random();
    const availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    final randomString = List.generate(
            6, (index) => availableChars[random.nextInt(availableChars.length)])
        .join();

    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://128.199.205.168/api/upload/'));
      //print('Bat dua upload 1111 ');
      request.files.add(
        //await http.MultipartFile.fromPath('file', widget.imgUrl),
        await http.MultipartFile.fromBytes('file', widget.imgUrl,
            filename: "${randomString}_photo_result.jpg"),
      );
      //print('Bat dua upload 2222 ');
      final response = await request.send();
      //print('Upload thanh cong');
      //print(response.statusCode);
      if (response.statusCode == 200) {
        final jsonData = await http.Response.fromStream(response);
        final result = jsonDecode(jsonData.body) as Map<String, dynamic>;
        if (result.isNotEmpty) {
          setState(() {
            imgUrlTest = 'http://128.199.205.168/${result['image']}';
          });

          _printDataAndSaveImage(imgUrlTest);
        }
      } else {
        // Handle errors
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error uploaded');
    }
  }

  Future<void> _printDataAndSaveImage(String resultUrl) async {
    // Define the API endpoint and headers
    final apiUrl = Uri.parse('http://localhost:8000/api/generate-image/');
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': '*'
    };

    // Prepare the request body
    final requestBody = {
      "image_result_from_server": resultUrl,
      "image_selected": "C:/photoboothprint/myphotos/Result/result.png",
      "bkgrnd_image": "C:/photoboothprint/3a1.jpg",
      "star1_img": "C:/photoboothprint/star1.png",
      "star2_img": "C:/photoboothprint/star2.png",
      "generated_print_image_path": "C:/photoboothprint/print_image.jpg",
    };

    // Create the HTTP request
    final request = http.Request('POST', apiUrl)
      ..headers.addAll(headers)
      ..body = json.encode(requestBody);

    try {
      // Send the request and get the response
      final response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        final jsonData = await http.Response.fromStream(response);
        var decodedBody = utf8.decode(jsonData.bodyBytes);
        print("Handle print project");
        print(decodedBody);
      } else {
        print(response.reasonPhrase);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Widget build(BuildContext context) {
    Image imageSnap = Image.memory(
      widget.imgUrl,
    );

    // Image imageSnap = Image.network(
    //   widget.imgUrl,
    // );
    Uint8List imageShowBytes = base64Decode(widget.imgUrlTarget);

    Image imageSnapTarget = Image.memory(
      imageShowBytes,
      width: 490.0,
      height: 520.0,
      fit: BoxFit.cover,
    );

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            //Background Image
            Image(
              image: AssetImage('assets/images/bg_ver.png'),
              fit: BoxFit.cover,
            ),
            /*
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/template/text-screen7.png',
                )
              ],
            ),
*/
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/template/text-screen7.png',
                        width: 750,
                        height: 250,
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 600.0,
                            height: 610.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: AssetImage(
                                  'assets/template/screen7_layer_down.png',
/*
                                    'assets/template/screen7_layer_down.png',
*/
                                ), // Add your background image path
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 60.0,
                                ),
                                width: 580.0,
                                height: 510.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: imageSnapTarget
                                        .image, // Add your foreground image path

                                    //image: Image.memory(base64Decode(strbase64)).image,
                                    //image: AssetImage(widget.imgUrlTarget),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  // Rounded Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 600.0,
                            height: 610.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/template/screen7_layer_up.png'), // Add your background image path
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.only(
                                  top: 60.0,
                                ),
                                width: 580.0,
                                height: 510.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                  image: DecorationImage(
                                    image: imageSnap
                                        .image, // Add your foreground image path
                                    //image: AssetImage(widget.imgUrl),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      /*
                      Container(
                        margin: EdgeInsets.only(
                          left: 30,
                          top: 20,
                          bottom: 20,
                        ),
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          onPressed: () {
                            // Trigger start countdown
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Text('QR 전송',
                                style: TextStyle(
                                    fontSize: 35,
                                    color: Colors.white,
                                    fontFamily: 'GulyFont')),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                       */
                      Container(
                        width: 250.0,
                        height: 320.0,
                        margin: EdgeInsets.only(
                          left: 850,
                          top: 20,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          border: Border.all(
                            color: Colors.white,
                            width: 10,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/template/qr-big.png'), // Add your background image path
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(
                              // left: 20,
                              // right: 20,
                              top: 60,
                              // bottom: 20,
                            ),
                            child: ClipRRect(
                              // borderRadius:
                              //     BorderRadius.all(Radius.circular(10)),
                              child: AspectRatio(
                                aspectRatio: 0.6,
                                child: imgUrlTest.isNotEmpty
                                    ? QrImageView(
                                        data: imgUrlTest,
                                        version: QrVersions.auto,
                                        size: 180
                                        // backgroundColor: Colors.white,
                                        )
                                    : Container(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: Align(
          alignment: Alignment(-0.9, 1),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Screen1()),
              );
            },
            child: Container(
              height: 100,
              width: 250,
              /*
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                foregroundColor: Colors.pink,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Screen1()),
                  );
                },
                icon: Icon(Icons.arrow_back_sharp),
                label: Text(
                  '재시작',
                  style: TextStyle(
                    fontSize: 60,
                    fontFamily: 'Gowun',
                  ),
                ),
              ),

               */
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: AssetImage("assets/template/back-button.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  final String imageCardUrl;

  const ImageCard({Key? key, required this.imageCardUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(2.0),
      child: Column(
        children: [
          // Container(
          //   color: Colors.lightGreen,
          //   padding: EdgeInsets.all(8.0),
          //   child: Center(
          //     child: Text(
          //       '합성 결과',
          //       style: TextStyle(
          //         color: const Color.fromARGB(255, 255, 205, 202),
          //         fontSize: 18.0,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          Container(
            width: 320,
            height: 240,
            child: Image.file(
              File(imageCardUrl),
              fit: BoxFit.cover,
            ),
          )
        ],
      ),
    );
  }
}

class ApiService {
  static const String apiUrl = 'http://127.0.0.1:8000/api/generate-image';
  //"C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\test1.png"
  Future<Map<String, dynamic>> printData(Map<String, dynamic> resultUrl) async {
    final response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "image_selected": resultUrl,
          "bkgrnd_image":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\3a.jpg",
          "logo_image":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\h1.png",
          "hearth_image_1":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\h1.png",
          "hearth_image_2":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\h1.png",
          "banned_image":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\Banned-Transparent.png",
          "small_icon":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\Asset1.png",
          "kiss_icon":
              "C:\\Users\\26-MongTaaaMedia\\Desktop\\PhotoApp\\image-frame\\kiss.png",
          "generated_print_image_path":
              "C:\\flutter-printer\\tkinter_doc_printer\\print_image.jpg"
        }));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed');
    }
  }
}
