import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/modules/flushbar.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matching_tantan_app/api/api.dart';

class SelectImageScreen extends StatefulWidget {
  @override
  _SelectImageScreenState createState() => _SelectImageScreenState();
}

class _SelectImageScreenState extends State<SelectImageScreen> {
  String userId;
  
  double width;
  double height;
  
  File imageFile;
  String base64Image;
  String fileName;
  int status = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  selectImage(BuildContext context) async {
    try {
      var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFile = picture;
        base64Image = base64Encode(imageFile.readAsBytesSync());
        status = 100;
      });
    } catch (e) {
      print('Image invalid');
    }
  }

  uploadImage(context) async {
    if( status == 100 ) {
      setState(() {
        status = 300;
      });
      fileName = basename(imageFile.path);
      var data = {
        'image': base64Image,
        'name': fileName,
        'userId': userId,
      };

      var response = await Api().postData(data, 'uploadPicture.php');
      var res = json.decode(response.body);
      setState(() {
        status = res['status'];
        // snack bar
        showStatusAlert(context, status);
      });
    }
  }

  showStatusAlert(context, status) {
    String title;
    String message;
    Icon icon;
    Color color;
    if( status == 0 ) {
      title = 'Warning!';
      message = 'Please select your picture to upload.';
      icon = Icon(Icons.warning, color: Colors.white);
      color = Colors.orange[300];
    } else if( status == 200 ) {
      title = 'Success!';
      message = 'Your picture has been uploaded successfully.';
      icon = Icon(Icons.check, color: Colors.white);
      color = Colors.green[300];
    } else if( status == 400 ) {
      title = 'Failed!';
      message = 'Sorry, uploading your picture has been failed.';
      icon = Icon(Icons.error, color: Colors.white);
      color = Colors.red[300];
    }
    
    FlushBar flushbar = new FlushBar(
      context: context, 
      title: title, 
      message: message, 
      icon: icon, 
      color: color
    );
    flushbar.flushbar();
  }

  startMatch(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('photo', fileName);
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/Home');
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      backgroundColor: myColor.primaryColor,
      body: Container(
        padding: EdgeInsets.only(
          left: width * 0.021,
          right: width * 0.021
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: width * 0.958,
              height: height * 0.13,
              decoration: BoxDecoration(
                color: myColor.primaryColorLight,
                borderRadius: BorderRadius.circular(20.0)
              ),
              child: Center(
                child: Text(
                  'Profile Picture',
                  style: TextStyle(
                    fontSize: height * 0.028,
                    color: myColor.blueColorLight,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: width * 0.68,
                height: height * 0.36,
                margin: EdgeInsets.only(top: height * 0.1),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: myColor.primaryColorLight,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: imageFile == null
                  ? SizedBox.shrink()
                  : Image.file(imageFile, fit: BoxFit.cover),
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.only(
                  top: height * 0.068
                ),
                width: width * 0.42,
                height: height * 0.068,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50.0),
                  color: myColor.primaryColorLight,
                ),
                child: GestureDetector(
                  onTap: () => selectImage(context),
                  child: Center(
                    child: Text(
                      'Select Picture',
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: myColor.primaryTextColor
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: MaterialButton(
        minWidth: width,
        height: height * 0.065,
        color: Colors.white70,
        child: Text(
          status == 200 
          ? 'Start match' 
          : status == 400 
          ? 'Try again!' 
          : status == 100 || status == 0 
          ? 'Upload'
          : 'Uploading',
          style: TextStyle(
            color: myColor.primaryColor,
            fontSize: height * 0.018
          ),
        ),
        onPressed: () {
          if( status == 200 ) startMatch(context);
          else if( status == 100 || status == 400 ) uploadImage(context);
          else if( status == 0 ) showStatusAlert(context, status);
        },
      ),
    );
  }
}