import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/modules/flushbar.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  TextEditingController nameController = new TextEditingController();
  DateTime dateTime = DateTime.now();
  String userId;
  String fullName = '';
  String birthday = '';
  String parseBirthday = '';
  String gender = '';
  int year;
  int month;
  int day;
  int curYear = DateTime.now().year;
  int curMonth = DateTime.now().month;
  int curDay = DateTime.now().day;

  String locationName;
  String countryCode;
  double latitude;
  double longitude;

  showBirthdayEditAlert() {
    var dateAry = birthday.split('/');
    year = int.parse(dateAry[2]);
    month = int.parse(dateAry[1]);
    day = int.parse(dateAry[0]);
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        double _height = MediaQuery.of(context).size.height;
        double _width = MediaQuery.of(context).size.width;
        return AlertDialog(
          title: Text(
            'Choose your birth of date',
            style: TextStyle(
              color: myColor.primaryColor
            ),
          ),
          content: Container(
            width: _width,
            height: _height * 0.43,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    onPressed: () {
                      if (dateTime != null) {
                        setState(() {
                          year = dateTime.year;
                          month = dateTime.month;
                          day = dateTime.day;
                          birthday = '$day/$month/$year';
                          parseBirthday = '$year-$month-$day';
                        });
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: myColor.primaryColorLight,
                        fontSize: _height * 0.018
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _height * 0.33,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    maximumYear: DateTime.now().year-18,
                    initialDateTime: birthday == '' ? DateTime(curYear-18, curMonth, curDay) : DateTime(year, month, day),
                    onDateTimeChanged: (_dateTime) {
                      var _year = _dateTime.year;
                      var _month = _dateTime.month;
                      var _day = _dateTime.day;
                      if (_year == DateTime.now().year - 18) {
                        if (_month >= DateTime.now().month) {
                          _month = DateTime.now().month;
                          if (_day > DateTime.now().day) {
                            _day = DateTime.now().day;
                          }
                        }
                      }
                      dateTime = DateTime(_year, _month, _day);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    getUserProfile();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      var lat = currentLocation.latitude;
      var lng = currentLocation.longitude;
      final coordinates = new Coordinates(lat, lng);
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      setState(() {
        latitude = lat;
        longitude = lng;
        countryCode = address.first.countryCode;
        locationName = address.first.featureName;
      });
    } catch(e) {
      print(e);
    }

  }

  void getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    var data = {
      'userId': userId,
    };
    var apiUrl = 'getProfile.php';
    var response = await Api().postData(data, apiUrl);
    var result = json.decode(response.body);

    if (result['status'] == 200) {
      var data = result['data'];
      setState(() {
        birthday = data['birthday'];
        parseBirthday = data['parseBirthday'];
        fullName = data['fullName'];
        nameController.text = fullName;
        gender = data['gender'];
      });
    } else if (result['status'] == 400) {
      setState(() {
        birthday = '?';
        parseBirthday = '?';
        fullName = '?';
        gender = '?';
      });
      Navigator.of(context).pushReplacementNamed('/Contact');
    }
  }

  updateProfile() async {
    if (locationName == null || locationName == '') {
      String title = 'Warning!';
      String message = 'We can\'t confirm your current location.';
      Icon icon = Icon(Icons.warning, color: Colors.white);
      Color color = Colors.orange[300];
      
      FlushBar flushbar = new FlushBar(
        context: context, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    } else if (fullName == '' || fullName == null || fullName == '?') {
      String title = 'Warning!';
      String message = 'Please enter your fullname.';
      Icon icon = Icon(Icons.warning, color: Colors.white);
      Color color = Colors.orange[300];
      
      FlushBar flushbar = new FlushBar(
        context: context, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    } else {
      var data = {
        'userId': userId,
        'fullName': fullName,
        'birthday': parseBirthday,
        'locationName': locationName,
        'countryCode': countryCode,
        'lat': latitude.toString(),
        'lng': longitude.toString()
      };
      var apiUrl = 'updateProfile.php';
      var response = await Api().postData(data, apiUrl);
      var result = json.decode(response.body);
      String title;
      String message;
      Icon icon;
      Color color;
      var status = result['status'];
      if (status == 200) {
        resetUserData();
        title = 'Success!';
        message = 'Your profile has been updated successfully.';
        icon = Icon(Icons.check, color: Colors.white);
        color = Colors.green[300];
      } else if (status == 400) {
        title = 'Failed!';
        message = 'Sorry, occured some errors on updating.';
        icon = Icon(Icons.error, color: Colors.white);
        color = Colors.red[300];
      } else if (status == 300) {
        title = 'Error!';
        message = 'You can\'t update your profile. Just only need to create profile to start match.';
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
  }

  resetUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', fullName);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/MyScreen');
        return ;
      },
      child: Scaffold(
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
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: height * 0.028,
                      color: myColor.blueColorLight,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Container(
                width: width * 0.958,
                height: height * 0.85,
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: width * 0.958,
                      height: height * 0.1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.info_outline,
                            color: myColor.darkColorGrey,
                            size: height * 0.023,
                          ),
                          SizedBox(width: width * 0.023),
                          Text(
                            'Personal Information',
                            style: TextStyle(
                              color: myColor.darkColorGrey,
                              fontSize: height * 0.017
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: width * 0.7,
                      child: TextField(
                        controller: nameController,
                        style: TextStyle(
                          fontSize: height * 0.023,
                          color: myColor.primaryTextColor
                        ),
                        cursorColor: myColor.blueColorDark,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: myColor.primaryColor,
                              style: BorderStyle.solid
                            ),
                            borderRadius: BorderRadius.circular(20.0)
                          ),
                          prefixIcon: Icon(
                            Icons.person, 
                            size: height * 0.026, 
                            color: myColor.darkColorGrey
                          ),
                          prefixStyle: TextStyle(
                            fontSize: height * 0.023,
                            fontWeight: FontWeight.bold,
                          ),
                          hintText: 'Enter your fullname',
                          hintStyle: TextStyle(
                            color: myColor.darkColorGrey,
                            fontSize: height * 0.021
                          ),
                          fillColor: myColor.primaryColorLight,
                          filled: true,
                        ),
                        textCapitalization: TextCapitalization.words,
                        onChanged: (value) {
                          setState(() {
                            fullName = value;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: height * 0.06),
                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //     horizontal: width * 0.033
                    //   ),
                    //   width: width * 0.892,
                    //   height: height * 0.088,
                    //   decoration: BoxDecoration(
                    //     color: myColor.primaryColorLight,
                    //     borderRadius: BorderRadius.circular(20.0)
                    //   ),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Container(
                    //         width: width * 0.3,
                    //         child: Text(
                    //           'Fullname',
                    //           style: TextStyle(
                    //             color: myColor.primaryTextColor,
                    //             fontSize: height * 0.021,
                    //             fontWeight: FontWeight.w600
                    //           ),
                    //         ),
                    //       ),
                    //       Container(
                    //         width: width * 0.5,
                    //         child: Text(
                    //           fullName == '' ? '?' : fullName,
                    //           textAlign: TextAlign.right,
                    //           style: TextStyle(
                    //             color: myColor.darkColorGrey,
                    //             fontSize: height * 0.016,
                    //             fontWeight: FontWeight.w700
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: height * 0.01),
                    GestureDetector(
                      onTap: () => showBirthdayEditAlert(),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.033
                        ),
                        width: width * 0.892,
                        height: height * 0.088,
                        decoration: BoxDecoration(
                          color: myColor.primaryColorLight,
                          borderRadius: BorderRadius.circular(20.0)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Birth of Date',
                              style: TextStyle(
                                color: myColor.primaryTextColor,
                                fontSize: height * 0.021,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              birthday == '' ? '?' : birthday,
                              style: TextStyle(
                                color: myColor.darkColorGrey,
                                fontSize: height * 0.016,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.033
                      ),
                      width: width * 0.892,
                      height: height * 0.088,
                      decoration: BoxDecoration(
                        color: myColor.primaryColorLight,
                        borderRadius: BorderRadius.circular(20.0)
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Gender',
                            style: TextStyle(
                              color: myColor.primaryTextColor,
                              fontSize: height * 0.021,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            gender == '0' ? '?' : gender == '1' ? 'Male' : 'Female',
                            style: TextStyle(
                              color: myColor.darkColorGrey,
                              fontSize: height * 0.016,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          width: width,
          height: height * 0.065,
          color: myColor.primaryTextColor,
          child: MaterialButton(
            onPressed: () => updateProfile(),
            child: Text(
              'Update Profile',
              style: TextStyle(
                color: myColor.primaryColor,
                fontSize: height * 0.023
              ),
            ),
          ),
        ),
      ),
    );
  }
}