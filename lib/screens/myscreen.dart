import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'package:matching_tantan_app/modules/flushbar.dart';
import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/color_model.dart';

class MyScreen extends StatefulWidget {
  @override
  _MyScreenState createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with WidgetsBindingObserver {

  int currentIndex = 2;
  String userId;
  String name;
  String photo;

  String locationName;
  String countryCode;
  double latitude;
  double longitude;

  File imageFile;
  String base64Image;
  String fileName;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      var lat = currentLocation.latitude;
      var lng = currentLocation.longitude;
      setState(() {
        latitude = lat;
        longitude = lng;
      });
      final coordinates = new Coordinates(lat, lng);
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      setState(() {
        countryCode = address.first.countryCode;
        locationName = address.first.featureName;
      });
    } catch(e) {
      print(e);
    }
  }

  getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      name = prefs.getString('name');
      photo = prefs.getString('photo');
    });
  }

  Future openGallery(BuildContext context) async {
    try {
      var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        imageFile = picture;
        base64Image = base64Encode(imageFile.readAsBytesSync());
        uploadImage(context);
      });
    } catch (e) {
      print('>>>Invalid Image');
    }
  }

  uploadImage(context) async {
    fileName = basename(imageFile.path);
    var data = {
      'image': base64Image,
      'name': fileName,
      'userId': userId,
    };

    var response = await Api().postData(data, 'uploadPicture.php');
    var res = json.decode(response.body);
    setState(() {
      var status = res['status'];
      // snack bar
      showStatusAlert(context, status);
    });
  }

  setUsersPhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('photo', fileName);
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
      setUsersPhoto();
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
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/MyScreen');
  }

  void logout(context) async {
    var data = {
      "userId": userId
    };
    var apiUrl = "logout.php";
    var result = await Api().postData(data, apiUrl);
    var response = json.decode(result.body);
    if (response["status"] == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('name');
      await prefs.remove('timeZone');
      await prefs.remove('photo');
      Navigator.popUntil(context, ModalRoute.withName('/Home'));
      Navigator.of(context).pushReplacementNamed('/StartWithPhone');
    } else if (response["status"] == 400) {
      String title = 'Error!';
      String message = 'Something went wrong.';
      Icon icon = Icon(Icons.error, color: Colors.white);
      Color color = Colors.red[300];
      
      FlushBar flushbar = new FlushBar(
        context: context, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    }
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/Home');
        return ;
      },
      child: Scaffold(
        backgroundColor: myColor.primaryColor,
        body: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              color: myColor.primaryColor,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        width: width,
                        height: height * 0.33,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                          ),
                          image: DecorationImage(
                            image: NetworkImage('http://68.183.93.26/images/$photo'),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                      Container(
                        width: width,
                        height: height * 0.33,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: height * 0.16
                          ),
                          child: Text(
                            name == null ? '?' : name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: height * 0.023
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: () => openGallery(context),
                          child: Container(
                            margin: EdgeInsets.only(top: height * 0.25),
                            padding: EdgeInsets.all(8.0),
                            width: width * 0.23,
                            height: height * 0.12,
                            color: Colors.orange,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage('http://68.183.93.26/images/$photo'),
                                  fit: BoxFit.cover
                                )
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: height * 0.1),
                  Card(
                    elevation: 8.0,
                    color: myColor.primaryColorLight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01,
                        vertical: width * 0.02
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.location_on,
                          color: Colors.cyan,
                          size: height * 0.033,
                        ),
                        title: Text(
                          locationName != null ? '$locationName' : '?',
                          style: TextStyle(
                            fontSize: height * 0.023,
                            color: myColor.blueColorDark
                          ),
                        ),
                        trailing: countryCode != null ? Container(
                          width: width * 0.082,
                          height: height * 0.043,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              image: NetworkImage('http://68.183.93.26/images/flag-png/${countryCode.toLowerCase()}.png'),
                            )
                          ),
                        ) : Text(
                          '?',
                          style: TextStyle(
                            color: myColor.primaryTextColor,
                            fontSize: height * 0.021,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.023),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/Profile'),
                    child: Card(
                      color: myColor.primaryColorLight,
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.contacts,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/Setting'),
                    child: Card(
                      color: myColor.primaryColorLight,
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/UpdatePassword'),
                    child: Card(
                      color: myColor.primaryColorLight,
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.security,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'Security',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => logout(context),
                    child: Card(
                      color: myColor.primaryColorLight,
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.power_settings_new,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'Power Off',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/Help'),
                    child: Card(
                      elevation: 8.0,
                      color: myColor.primaryColorLight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.indigoAccent,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.help,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'Help Center',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/About'),
                    child: Card(
                      elevation: 8.0,
                      color: myColor.primaryColorLight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.01,
                          vertical: width * 0.032
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Icon(
                              Icons.info,
                              color: Colors.white,
                              size: height * 0.03,
                            ),
                          ),
                          title: Text(
                            'About Ylike',
                            style: TextStyle(
                              fontSize: height * 0.021,
                              color: myColor.primaryTextColor
                            ),
                          ),
                          trailing: Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white70,
                            size: height * 0.042,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/Home');
                break;
              case 1:
                Navigator.of(context).pushReplacementNamed('/Message');
                break;
              case 2:
                break;
            }
          },
          currentIndex: currentIndex,
          elevation: 6.0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: myColor.primaryTextColor,
          items: <BottomNavigationBarItem> [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: myColor.primaryColorLight,
                size: height * 0.03,
              ),
              activeIcon: Icon(
                Icons.home,
                color: myColor.primaryColorLight,
                size: height * 0.04,
              ),
              title: Text(
                'ylike',
                style: TextStyle(
                  color: myColor.primaryColor,
                  fontSize: height * 0.016,
                  fontWeight: FontWeight.w700
                ),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.chat,
                color: myColor.primaryColorLight,
                size: height * 0.03,
              ),
              activeIcon: Icon(
                Icons.chat,
                color: myColor.primaryColorLight,
                size: height * 0.04,
              ),
              title: Text(
                'chat',
                style: TextStyle(
                  color: myColor.primaryColor,
                  fontSize: height * 0.016,
                  fontWeight: FontWeight.w700
                ),
              )
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.face,
                color: myColor.primaryColorLight,
                size: height * 0.03,
              ),
              activeIcon: Icon(
                Icons.face,
                color: myColor.primaryColorLight,
                size: height * 0.04,
              ),
              title: Text(
                'me',
                style: TextStyle(
                  color: myColor.primaryColor,
                  fontSize: height * 0.016,
                  fontWeight: FontWeight.w700
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}