import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/modules/flushbar.dart';

double width;
double height;
enum GenderEnum { both, men, women }

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int ageValue = 48;
  int distanceValue = 160;
  double minAge = 18;
  double maxAge = 48;
  double minDistance = 1;
  double maxDistance = 160;
  String userId;
  String countryCode;
  String locationName;
  GenderEnum gender = GenderEnum.both;
  GenderEnum parentGender = GenderEnum.both;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    getCurrentLocation();
    getSetting();
  }

  getCurrentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    var latitude;
    var longitude;

    try {
      currentLocation = await location.getLocation();
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
      final coordinates = new Coordinates(latitude, longitude);
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = address.first;
      countryCode = first.countryCode;
      locationName = first.featureName;
    } catch(e) {
      if(e.code == 'PERMISSION_DENIED') {
        print('permission denied');
      }
    }
  }

  getSetting() async {
    var data = {
      'userId': userId
    };
    var apiUrl = 'getSetting.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    if( res['status'] == 200 ) {
      var setting = res['data'];
      setState(() {
        ageValue = int.parse(setting['age']);
        distanceValue = int.parse(setting['distance']);
        gender = int.parse(setting['showMe']) == 0 ? GenderEnum.both : int.parse(setting['showMe']) == 1 ? GenderEnum.men : GenderEnum.women;
      });
    } else {
      print('your setting is failed');
    }
  }

  editSetting(context) async {
    int genderIntVal = 
      parentGender == GenderEnum.both ? 0 : parentGender == GenderEnum.men ? 1 : 2;
    var data = {
      'distance': distanceValue.toString(),
      'age': ageValue.toString(),
      'gender': genderIntVal.toString(),
      'userId': userId
    };
    var apiUrl = 'editSetting.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    if( res['status'] == 200 ) {
      String title = 'Success!';
      String message = 'Your setting has been updated successfully.';
      Icon icon = Icon(Icons.check, color: Colors.white);
      Color color = Colors.green[300];
      FlushBar flushbar = new FlushBar(
        context: context,
        title: title,
        message: message,
        icon: icon,
        color: color
      );
      flushbar.flushbar();
    } else {
      String title = 'Failed!';
      String message = 'Sorry, setting has been failed.';
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

  showGenderEditAlert() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double _height = MediaQuery.of(context).size.height;
            double _width = MediaQuery.of(context).size.width;
            return AlertDialog(
              title: Text(
                'Who be shown you',
                style: TextStyle(
                  color: myColor.primaryColor
                ),
              ),
              content: Container(
                width: _width,
                height: _height * 0.34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Both of women and men'),
                      leading: Radio(
                        value: GenderEnum.both,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Only men'),
                      leading: Radio(
                        value: GenderEnum.men,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Only women'),
                      leading: Radio(
                        value: GenderEnum.women,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: myColor.primaryColorLight,
                      fontSize: _height * 0.018
                    )
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    super.setState(() {
                      parentGender = gender;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: myColor.primaryColorLight,
                      fontSize: _height * 0.018
                    )
                  ),
                )
              ],
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Setting',
          style: TextStyle(
            color: myColor.blueColorLight,
            fontSize: height * 0.023
          ),
        ),
      ),
      body: Container(
        color: myColor.primaryColorLight,
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              color: myColor.primaryColorLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.12,
                      vertical: height * 0.021
                    ),
                    width: width,
                    height: height * 0.08,
                    color: myColor.blueColorDark,
                    child: Text(
                      'discover settings',
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: myColor.primaryTextColor
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    color: myColor.primaryColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01,
                        vertical: width * 0.032
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'my current location',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: Text(
                          locationName == '' || locationName == null
                          ? '?'
                          : locationName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: myColor.primaryTextColor,
                            fontSize: height * 0.016
                          ),
                        ),
                        trailing: Text(
                          countryCode == '' || countryCode == null
                          ? '?'
                          : countryCode,
                          style: TextStyle(
                            fontSize: height * 0.018,
                            color: myColor.darkColorGrey
                          )
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.07),
                  Card(
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
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.near_me,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'distance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.directions_walk,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Slider(
                                min: minDistance,
                                max: maxDistance,
                                divisions: 160,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey,
                                label: distanceValue.toString() + ' km',
                                onChanged: (value) {
                                  setState(() {
                                    distanceValue = value.toInt();
                                  });
                                },
                                value: distanceValue.toDouble(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.airplanemode_active,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
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
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'age',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.child_care,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Slider(
                                min: minAge,
                                max: maxAge,
                                divisions: 30,
                                activeColor: Colors.orange,
                                inactiveColor: Colors.grey,
                                label: ageValue.toString() + ' years',
                                onChanged: (value) {
                                  setState(() {
                                    ageValue = value.toInt();
                                  });
                                },
                                value: ageValue.toDouble(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.nature_people,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
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
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.pregnant_woman,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'show me',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: GestureDetector(
                          onTap: () => showGenderEditAlert(),
                          child: Text(
                            parentGender == GenderEnum.both ? 'Both of Women and Men' : parentGender == GenderEnum.men ? 'Only Men' : 'Only Women',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: height * 0.016,
                              color: myColor.primaryTextColor
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.1),
                  Center(
                    child: RaisedButton(
                      onPressed: () => editSetting(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.116,
                        vertical: height * 0.013
                      ),
                      elevation: 6.0,
                      color: myColor.primaryColor,
                      child: Text(
                        'save',
                        style: TextStyle(
                          color: myColor.primaryTextColor,
                          fontSize: height * 0.021
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}