import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:matching_tantan_app/modules/flushbar.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/modules/pusherSocket.dart';

import 'package:matching_tantan_app/api/api.dart';

class ForgotPasswordScreen extends StatefulWidget {
  
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with WidgetsBindingObserver {
  String verificationId;
  String phoneCode = '';
  String countryCode = '';
  TextEditingController phoneNumController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  String currentTimeZone;
  PermissionGroup perm;
  bool isLife = false;
  bool isGot = false;
  bool isSuccess = false;
  bool isVerified = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    perm = PermissionGroup.locationAlways;
    checkPermission();
  }

  initPusher() async {
    PusherSocket pusher =
      new PusherSocket(channelName: 'notification-channel', eventName: 'new-notification-$phoneCode${phoneNumController.text}');
    await pusher.initPusher();
  }

  // check permission
  checkPermission() async {
    WidgetsBinding.instance.addObserver(this);
    //  get find permission status
    PermissionHandler()
        .checkPermissionStatus(perm)
        .then(updateStatus);
  }
  // if change app settings out of app
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isLife) {
      PermissionHandler()
          .checkPermissionStatus(perm)
          .then(updateStatus);
    }
  }
  // update status when change app settings
  void updateStatus(PermissionStatus status) {
    if (status != PermissionStatus.granted) {
      isLife = true;
      PermissionHandler()
          .requestPermissions([perm, PermissionGroup.storage, PermissionGroup.phone])
          .then(permissionRequested);
    } else {
      if (perm == PermissionGroup.locationAlways) {
        getPhoneCode();
      }
    }
  }
  // permission has been requested
  void permissionRequested(Map<PermissionGroup, PermissionStatus> statuses) {
    final status = statuses[perm];
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.disabled ||
        status == PermissionStatus.restricted) {
      PermissionHandler().openAppSettings();
    } else if (status == PermissionStatus.granted){
      updateStatus(status);
    }
  }
  // get country code of phone number
  getPhoneCode() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      var lat = currentLocation.latitude;
      var log = currentLocation.longitude;
      final coordinates = new Coordinates(lat, log);
      var address = await Geocoder.local.findAddressesFromCoordinates(
          coordinates);
      countryCode = address.first.countryCode;
      var data = {
        'countryCode': countryCode
      };
      var apiUrl = 'getPhoneCode.php';
      var response = await Api().postData(data, apiUrl);

      setState(() {
        phoneCode = response.body;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: myColor.primaryColor,
      body: Column(
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
                'Forgot Password',
                style: TextStyle(
                  fontSize: height * 0.028,
                  color: myColor.blueColorLight,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.32
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: width * 0.1,
                  child: countryCode != '' && countryCode != null ? Image(
                    image: NetworkImage('http://68.183.93.26/images/flag-png/${countryCode.toLowerCase()}.png'),
                    height: height * 0.02,
                  ) : SizedBox.shrink(),
                ),
                Container(
                  width: width * 0.1,
                  child: Text(
                    phoneCode == '' || phoneCode == null ? '?' : '+$phoneCode',
                    style: TextStyle(
                      fontSize: height * 0.018,
                      color: myColor.primaryTextColor
                    ),
                  ),
                ),
                Container(
                  width: width * 0.7,
                  child: TextField(
                    controller: phoneNumController,
                    onChanged: (value) {
                      setState(() {
                        isVerified = false;
                        isGot = false;
                        isSuccess = false;
                      });
                    },
                    style: TextStyle(
                      fontSize: height * 0.023,
                      color: myColor.primaryTextColor
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, size: height * 0.026, color: myColor.darkColorGrey,),
                      prefixStyle: TextStyle(
                        fontSize: height * 0.023,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(
                        color: myColor.darkColorGrey,
                        fontSize: height * 0.021
                      ),
                      fillColor: myColor.primaryColorLight,
                      filled: true,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: width,
        height: height * 0.065,
        color: myColor.primaryTextColor,
        child: MaterialButton(
          onPressed: () {
            if (isVerified && !isGot && !isSuccess) {
              initPusher();
              Timer(Duration(seconds: 5), () {
                if (mounted) getPassword(context);
              });
            } else if (isGot && isSuccess) {
              Navigator.pop(context);
            } else if (!isVerified) {
              verifyPhone(context);
            }
          },
          child: Text(
            !isVerified 
            ? 'Verify Phone'
            : !isGot
            ? 'Get Password'
            : isGot && !isSuccess
            ? 'Getting Password'
            : 'Go to Login',
            style: TextStyle(
              color: !isGot ? myColor.primaryColor : Colors.black38,
              fontSize: height * 0.023
            ),
          ),
        ),
      ),
    );
  }

  void getPassword(BuildContext context) async {
    setState(() {
      isGot = true;
    });
    var data = {
      'phoneNum': phoneNumController.text,
      'phoneCode': phoneCode
    };
    var apiUrl = 'forgotPassword.php';
    var result = await Api().postData(data, apiUrl);
    var response = json.decode(result.body);
    if (response['status'] == 200) {
      setState(() {
        isSuccess = true;
      });
      print("success");
    } else if (response['status'] == 400) {
      String title = 'Warning!';
      String message = 'This number doesn\'t exist.';
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
      setState(() {
        isSuccess = false;
      });
    }
  }

  Future<void> verifyPhone(context1) async {
    if (phoneCode != '') {
      setState(() {
        isGot = true;
      });
      final PhoneCodeAutoRetrievalTimeout retrievalTimeout = (String verId) {
        this.verificationId = verId;
        print('verify code1: $verId');
      };

      final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
        this.verificationId = verId;
        print('forceCodeResend: $forceCodeResend');
        print('verify code2: $verId');
      };

      final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
        print('verified');
        setState(() {
          isVerified = true;
        });
      };

      final PhoneVerificationFailed verificationFailed =
          (AuthException exception) {
        String title = 'Verification failed!';
        String message = 'Verification failed. Please enter your phone number.';
        Icon icon = Icon(Icons.error, color: Colors.white);
        Color color = Colors.red[300];
        
        FlushBar flushbar = new FlushBar(
          context: context1, 
          title: title, 
          message: message, 
          icon: icon, 
          color: color
        );
        flushbar.flushbar();
        setState(() {
          isGot = false;
        });
      };

      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+$phoneCode' + phoneNumController.text,
          codeAutoRetrievalTimeout: retrievalTimeout,
          codeSent: smsCodeSent,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verifiedSuccess,
          verificationFailed: verificationFailed);
    } else {
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
    }
  }
}
