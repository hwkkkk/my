import 'package:flutter/material.dart';
import 'package:ai_practice/third.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class SecondScreen extends StatefulWidget {
  final Socket socket;

  const SecondScreen({Key? key, required this.socket}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "카메라",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(100, 100),
                    elevation: 20.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "갤러리",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(100, 100),
                    elevation: 20.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BERSERK'),
        titleTextStyle: TextStyle(color: Colors.black),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '사진을 입력하세요',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            _image == null
                ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black54,
                  width: 4.0,
                ),
              ),
              child: IconButton(
                icon: Icon(Icons.add),
                color: Colors.black54,
                iconSize: 60,
                onPressed: () {
                  _showMyDialog(context);
                },
              ),
            )
                : CircleAvatar(
              radius: 80,
              backgroundImage: FileImage(_image!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("check");
                if (_image != null) {
                  List<int> imageBytes = _image!.readAsBytesSync();
                  String base64Image = base64Encode(imageBytes);
                  widget.socket.write(base64Image.length.toString().padLeft(16, '0'));
                  widget.socket.write(base64Image);
                  widget.socket.flush();
                  print("Image sent to server");
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThirdScreen(socket: widget.socket)),
                );
              },
              child: Text(
                "완료하기",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                fixedSize: Size(200, 50),
                elevation: 20.0,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
