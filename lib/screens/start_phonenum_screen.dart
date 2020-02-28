import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:matching_tantan_app/modules/flushbar.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/modules/pusherSocket.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:matching_tantan_app/api/api.dart';

class StartPhoneNumScreen extends StatefulWidget {
  
  @override
  _StartPhoneNumScreenState createState() => _StartPhoneNumScreenState();
}

class _StartPhoneNumScreenState extends State<StartPhoneNumScreen> with WidgetsBindingObserver {
  String verificationId;
  String phoneCode = '';
  String countryCode = '';
  TextEditingController phoneNumController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool isLogin = false;
  String currentTimeZone;
  String simCardSerialNumber;
  PermissionGroup perm;
  bool isLife = false;
  static const platform = const MethodChannel("flutter.native/helper");

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
    initPusher();
  }

  initPusher() async {
    PusherSocket pusher =
      new PusherSocket(channelName: 'notification-channel', eventName: 'new-notification');
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
    try {
      currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    } catch (e) {}
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
        getSimSerialNumber();
      });
    } catch (e) {
      print(e);
    }
  }
  // get native area code of phone number
  Future<void> getSimSerialNumber() async {
    try {
      simCardSerialNumber = await platform.invokeMethod("getSimCardSerialNumber");
      if (simCardSerialNumber != '' && simCardSerialNumber != null) {
        checkStatus();
      }
    } on PlatformException catch (e) {
      simCardSerialNumber = '';
      print(e.message);
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
                'Phone Number',
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
              top: height * 0.28
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
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.015
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: width * 0.1),
                SizedBox(width: width * 0.1),
                Container(
                  width: width * 0.7,
                  child: TextField(
                    controller: passwordController,
                    style: TextStyle(
                      fontSize: height * 0.023,
                      color: myColor.primaryTextColor
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.vpn_key, size: height * 0.026, color: myColor.darkColorGrey,),
                      prefixStyle: TextStyle(
                        fontSize: height * 0.023,
                        fontWeight: FontWeight.bold,
                      ),
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(
                        color: myColor.darkColorGrey,
                        fontSize: height * 0.021
                      ),
                      fillColor: myColor.primaryColorLight,
                      filled: true,
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.46,
              right: width * 0.02,
              top: height * 0.028,
            ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/ForgotPassword'),
              child: Text(
                'forgot your password? :(',
                style: TextStyle(
                  fontSize: height * 0.018,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: width,
        height: height * 0.065,
        color: myColor.primaryTextColor,
        child: MaterialButton(
          onPressed: () => !isLogin ? loginWithPhone(context, 0) : {},
          child: Text(
            'Start with your phone',
            style: TextStyle(
              color: !isLogin ? myColor.primaryColor : Colors.black38,
              fontSize: height * 0.023
            ),
          ),
        ),
      ),
    );
  }

  void checkStatus() async {
    var data = {
      'simCardSerialNumber': simCardSerialNumber,
    };
    var apiUrl = 'checkStatus.php';
    var result = await Api().postData(data, apiUrl);
    var response = json.decode(result.body);
    if (response['status'] == 'online') {
      // user is online, login app automatically
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', response['userId']);
      await prefs.setString('timeZone', response['timeZone']);
      await prefs.setString('photo', response['photo']);
      await prefs.setString('name', response['name']);
      Navigator.pushReplacementNamed(context, '/Home');
    } else if (response['status'] == 'offline') {
      // user is offline
    }
  }

  void loginWithPhone(context1, verified) async {
    if (phoneCode == null || phoneCode == '') {
      String title = 'Warning!';
      String message = 'We can\'t confirm your current location.';
      Icon icon = Icon(Icons.warning, color: Colors.white);
      Color color = Colors.orange[300];
      
      FlushBar flushbar = new FlushBar(
        context: context1, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    } else if (phoneNumController.text == null || phoneNumController.text == '') {
      String title = 'Danger!';
        String message = 'Please input your phone number.';
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
    } else if (passwordController.text == null || passwordController.text == '') {
      String title = 'Danger!';
      String message = 'Please input security password.';
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
    } else if (simCardSerialNumber == "" || simCardSerialNumber == null) {
      String title = 'Danger!';
      String message = 'Please check your phone sim card.';
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
    } else {
      var data = {
        'phonecode': phoneCode,
        'phonenum': phoneNumController.text,
        'password': passwordController.text,
        'simCardSerialNumber': simCardSerialNumber,
        'timeZone': currentTimeZone,
        'verified': verified.toString()
      };

      var apiUrl = 'authUser.php';
      var res = await Api().postData(data, apiUrl);
      var result = json.decode(res.body);
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', result['userId'].toString());
      await prefs.setString('timeZone', currentTimeZone);

      if(result['message'] == 'contact') {
        Navigator.pushReplacementNamed(context, '/Contact');
      } else if(result['message'] == 'home') {
        await prefs.setString('name', result['name']);
        await prefs.setString('photo', result['photo']);
        Navigator.pushReplacementNamed(context, '/Home');
      } else if(result['message'] == 'photo') {
        await prefs.setString('name', result['name']);
        Navigator.pushReplacementNamed(context, '/UploadPicture');
      } else if(result['message'] == 'error') {
        String title = 'Danger!';
        String message = 'Something went wrong.';
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
      } else if (result['message'] == 'blocked') {
        String title = 'Danger!';
        String message = 'Sorry, your account has been blocked by admin.';
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
      } else if (result['message'] == 'verify' && verified != 2) {
        verifyPhone(context1);
      } else if (result['message'] == 'password') {
        String title = 'Warning!';
        String message = 'Password is incorrect.';
        Icon icon = Icon(Icons.warning, color: Colors.white);
        Color color = Colors.orange[300];
        
        FlushBar flushbar = new FlushBar(
          context: context1, 
          title: title, 
          message: message, 
          icon: icon, 
          color: color
        );
        flushbar.flushbar();
      }
    }
  }

  Future<void> verifyPhone(context1) async {
    if (phoneCode != '') {
      setState(() {
        isLogin = true;
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
        loginWithPhone(context1, 1);
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
          isLogin = false;
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
