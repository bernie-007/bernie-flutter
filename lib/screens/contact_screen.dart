import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/modules/flushbar.dart';

enum GenderEnum { unknown, male, female }

class ContactScreen extends StatefulWidget {

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {

  String userId;
  String countryCode;
  String locationName;
  double latitude;
  double longitude;
  DateTime dateTime = DateTime.now();
  TextEditingController nameController = new TextEditingController();
  String fullName = '';
  String birthday = '';
  String parseBirthday = '';
  GenderEnum gender = GenderEnum.unknown;
  GenderEnum parentGender = GenderEnum.unknown;
  int year;
  int month;
  int day;
  int curYear = DateTime.now().year;
  int curMonth = DateTime.now().month;
  int curDay = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    getUserId();
    getCurrentLocation();
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  showBirthdayEditAlert() {
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
                'Choose your gender',
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
                      title: const Text('Male'),
                      leading: Radio(
                        value: GenderEnum.male,
                        groupValue: gender,
                        activeColor: myColor.primaryColor,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Female'),
                      leading: Radio(
                        value: GenderEnum.female,
                        groupValue: gender,
                        activeColor: myColor.primaryColor,
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
                    if (gender != GenderEnum.unknown) {
                      super.setState(() {
                        parentGender = gender;
                      });
                      Navigator.of(context).pop();
                    }
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
              height: height * 0.799,
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
                  GestureDetector(
                    onTap: () => showGenderEditAlert(),
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
                            'Gender',
                            style: TextStyle(
                              color: myColor.primaryTextColor,
                              fontSize: height * 0.021,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            parentGender == GenderEnum.unknown ? '?' : gender == GenderEnum.male ? 'Male' : 'Female',
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
          onPressed: () => registerContact(context),
          child: Text(
            'Submit Profile',
            style: TextStyle(
              color: myColor.primaryColor,
              fontSize: height * 0.023
            ),
          ),
        ),
      ),
    );
  }

  registerContact(context) async {
    if( fullName == '?' || birthday == '?' || parentGender == GenderEnum.unknown
        || fullName == '' || birthday == '' ) {
      // snack bar
      String title = 'Warning!';
      String message = 'Please enter correct information.';
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
      if (countryCode == null || locationName == null) {
        String title = 'Warning!';
        String message = 'Sorry, we couldn\'t confirm your location. Please turn on location setting of your device.';
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
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'name': nameController.text,
          'birthday': parseBirthday,
          'address': locationName,
          'countryCode': countryCode,
          'gender': parentGender == GenderEnum.male ? '1' : '2'
        };
        var apiUrl = 'editProfile.php';
        var response = await Api().postData(data, apiUrl);
        
        if( response.body != 'error' ) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('name', nameController.text);
          Navigator.pushReplacementNamed(context, '/UploadPicture');
        } else {
          // snack bar
          String title = 'Error!';
          String message = 'Occured some errros when save your profile.';
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
    }
  }

  getCurrentLocation() async {
    LocationData currentLocation;
    var location = new Location();

    try {
      currentLocation = await location.getLocation();
      latitude = currentLocation.latitude;
      longitude = currentLocation.longitude;
      final coordinates = new Coordinates(latitude, longitude);
      var address = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = address.first;
      countryCode = first.countryCode;
      locationName = first.featureName;
    } on PlatformException catch(e) {
      if(e.code == 'PERMISSION_DENIED') {
        print('permission denied');
      }
    }
  }
}