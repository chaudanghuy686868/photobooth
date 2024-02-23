import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photobooth_section1/screens/screen7.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

import '../palatter.dart';
import '../widgets/background-image.dart';

class Screen6 extends StatefulWidget {
  final String imgUrl;
  final String effectName;
  Screen6({required this.imgUrl, required this.effectName});
  @override
  _Screen6State createState() => _Screen6State();
}

class _Screen6State extends State<Screen6> {
  List payloadArr = [];
  List _items = [];
  List<ImgList> imgListAi = [];
  int cntImg = 0;
  String userImgPath = "";
  final ApiService apiService = ApiService();
  Uint8List resultImageUrl = Uint8List(0);
  List<String> aiImages = [];
  Map<String, dynamic> payload = {};
  bool doneAi = false;
  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String imgLoad = '';
  String imgProgressLoad = '';

  late bool _loading;
  late double _progressValue;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _progressValue = 0.0;
    imgProgressLoad = 'assets/images/load0.png';

    _loading = !_loading;
    _updateProgress();

    final string = widget.effectName;
    final strEffected = string.split('-');
    imgLoad = 'assets/images/screen6/${strEffected[0]}.png';

    // API call
    fetchDataAndSaveImage(widget.effectName);
  }

  @override
  void dispose() {
    //imgProgressLoad = 'assets/images/load0.png';;
    // ignore: avoid_print
    print('Dispose used');
    super.dispose();
  }

  String getRandomString(int length) {
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Future<void> getImagePath(String fileName) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _username = prefs.getString('username') ?? "";

    // Directory current = Directory.current;

    // // Parent folder
    // final String internalFolder = path.join(current.path, 'myphotos');
    // await Directory(internalFolder).create(recursive: true);

    // // User Dir
    // final String userDir = path.join(internalFolder, _username);
    // await Directory(userDir).create(recursive: true);

    // // Result folder
    // final String resultUserDir = path.join(userDir, 'Result');
    // await Directory(resultUserDir).create(recursive: true);

    // final String userPath = path.join(resultUserDir, fileName);
    // setState(() {
    //   aiImages.add(userPath);
    //   userImgPath = userPath;
    //   doneAi = true;
    // });
  }

  Future<void> readJson(String payloadFile) async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/ai/$payloadFile.json");
    final debugJson = jsonDecode(data);
    setState(() {
      payloadArr = debugJson;
    });
  }

  Future<Uint8List> _getImageBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
          'Failed to load image. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchDataAndSaveImage(String effectName) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int aiEffectIDSess = prefs.getInt('aiEffectIDSess') ?? 1;
      //String usrImgUrl = widget.imgUrl;
      //File imageFile = File(usrImgUrl);
      // DEBUG
      final String imgBase64 = widget.imgUrl;
      // final Uint8List bytes = await http.readBytes(Uri.parse(widget.imgUrl));
      if (imgBase64.isNotEmpty) {
        // final String imgBase64 = base64.encode(bytes);
        if (imgBase64.isNotEmpty) {
          String jsonString = await rootBundle
              .loadString("assets/ai/${widget.effectName}.json");
          payload = json.decode(jsonString);

          payload['alwayson_scripts']['ControlNet']['args'][0]['input_image'] =
              'data:image/jpeg;base64,' + imgBase64;

          print('call api');
          print(payload);

          final Map<String, dynamic> response =
              await apiService.postData(payload);

          if (response.isNotEmpty && response['images'] != null) {
            _items = response['images'];
            List<String> dynamicData = _items.cast<String>();
            final Uint8List imageData =
                base64Decode(dynamicData.firstOrNull ?? "");

            if (imageData.isNotEmpty) {
              String randomStr = getRandomString(5);
              String fileNameWithPath = '$aiEffectIDSess-${randomStr}.jpg';

              await ImageSaver.saveImage(fileNameWithPath, imageData);

              setState(() {
                resultImageUrl = imageData;
                cntImg++;
              });

              print('done');

              setState(() {
                // aiImages.add(String.fromCharCodes(imageData));
                // userImgPath = String.fromCharCodes(imageData);
                doneAi = true;
              });

              // getImagePath(fileNameWithPath);

              // imgListAi.add(getImagePath(fileNameWithPath) as ImgList);
            }
          }
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackGroundImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/template/text-screen6.png',
            )
          ],
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 150,
              ),
              SingleChildScrollView(
                child: SafeArea(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                    Container(
                      width: 1000,
                      height: 560,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            imgLoad.isEmpty
                                ? 'assets/images/welcome.png'
                                : imgLoad,
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      padding: EdgeInsets.all(12.0),
                      width: 1020,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _loading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 30,
                                    width: 1020,
                                    child: LinearProgressIndicator(
                                      minHeight: 20.0,
                                      backgroundColor: Colors.lightBlueAccent,
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.blue),
                                      value: _progressValue,
                                    ),
                                  ),
                                ),
                                // Text('${testStr}%'),
                                //외계인을 납치해 오는중...
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.asset(
                                  '${imgProgressLoad}',
                                  width: 1000,
                                  height: 70,
                                ),
                              ],
                            )
                          : Text("", style: TextStyle(fontSize: 25)),
                    ),
                  ],
                )),
              )
            ],
          ),
        ),
      ],
    );
  }

  // this function updates the progress value
  void _updateProgress() {
    const oneSec = const Duration(seconds: 1);
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.001;
        // we "finish" downloading here
        if (_progressValue == 0.005) {
          imgProgressLoad = 'assets/images/load1.png';
        }

        if (_progressValue >= 0.009) {
          imgProgressLoad = 'assets/images/load2.png';
        }
        if (_progressValue >= 0.014) {
          imgProgressLoad = 'assets/images/load3.png';
        }

        if (_progressValue.toStringAsFixed(1) == '2.0' || doneAi) {
          //_loading = false;
          t.cancel();
          print('Load 100% goto other screen');
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Screen7(
                      imgUrl: resultImageUrl,
                      //imgUrl: '',
                      imgUrlTarget: widget.imgUrl,
                    )),
          );
          return;
        }
      });
    });
  }
}

class ImageSaver {
  static Future<void> saveImage(String fileName, Uint8List imageData) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String _username = prefs.getString('username') ?? "";

    // Directory current = Directory.current;

    // // Parent folder
    // final String internalFolder = path.join(current.path, 'myphotos');
    // await Directory(internalFolder).create(recursive: true);

    // // User Dir
    // final String userDir = path.join(internalFolder, _username);
    // await Directory(userDir).create(recursive: true);

    // // Result folder
    // final String resultUserDir = path.join(userDir, 'Result');
    // await Directory(resultUserDir).create(recursive: true);

    // final String userPath = path.join(resultUserDir, fileName);
    // File(userPath).writeAsBytesSync(imageData);
  }
}

class ApiService {
  static const String apiUrl = 'http://localhost:7860/sdapi/v1/txt2img';

  Future<Map<String, dynamic>> postData(Map<String, dynamic> payload) async {
    final response = await http.post(Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: jsonEncode(payload));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed');
    }
  }
}

class ImgList {
  String imgUrl;
  //int id;
  ImgList({required this.imgUrl});
}
