import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/screens/about_screen.dart';

import 'package:matching_tantan_app/screens/chat_screen.dart';
import 'package:matching_tantan_app/screens/contact_screen.dart';
import 'package:matching_tantan_app/screens/favorite_screen.dart';
import 'package:matching_tantan_app/screens/forgot_password_screen.dart';
import 'package:matching_tantan_app/screens/help_screen.dart';
import 'package:matching_tantan_app/screens/home_screen.dart';
import 'package:matching_tantan_app/screens/message_screen.dart';
import 'package:matching_tantan_app/screens/myscreen.dart';
import 'package:matching_tantan_app/screens/profile.dart';
import 'package:matching_tantan_app/screens/select_image_screen.dart';
import 'package:matching_tantan_app/screens/setting_screen.dart';
import 'package:matching_tantan_app/screens/start_phonenum_screen.dart';
import 'package:matching_tantan_app/screens/update_password_screen.dart';
import 'package:matching_tantan_app/screens/update_picture.dart';
import 'screens/splash_screen.dart';
import 'package:matching_tantan_app/modules/pusherSocket.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matching App',
      debugShowCheckedModeBanner: false,
      home: StartPhoneNumScreen(),
      theme: ThemeData(
        primaryColor: myColor.primaryColor
      ),
      routes: <String, WidgetBuilder>{
        '/StartWithPhone': (BuildContext context) => new StartPhoneNumScreen(),
        '/ForgotPassword': (BuildContext context) => new ForgotPasswordScreen(),
        '/UpdatePassword': (BuildContext context) => new UpdatePasswordScreen(),
        '/Contact': (BuildContext context) => new ContactScreen(),
        '/UploadPicture': (BuildContext context) => new SelectImageScreen(),
        '/Home': (BuildContext context) => new HomeScreen(),
        '/Setting': (BuildContext context) => new SettingScreen(),
        '/Message': (BuildContext context) => new MessageScreen(),
        '/Chat': (BuildContext context) => new ChatScreen(),
        '/Match': (BuildContext context) => new FavoriteScreen(),
        '/MyScreen': (BuildContext context) => new MyScreen(),
        '/Help': (BuildContext context) => new HelpScreen(),
        '/About': (BuildContext context) => new AboutScreen(),
        '/Profile': (BuildContext context) => new Profile(),
        '/UpdatePicture': (BuildContext context) => new UpdatePicture()
      },
    );
  }
}

class MyAppScreen extends StatefulWidget {
  @override
  _MyAppScreenState createState() => _MyAppScreenState();
}

class _MyAppScreenState extends State<MyAppScreen> {

  bool isSplash = true;
  static String channel = 'notification-channel';
  static String event = 'new-notification';
  PusherSocket pusherSocket = new PusherSocket(channelName: channel, eventName: event);

  @override
  void initState() {
    super.initState();
    
    pusherSocket.initPusher();
  }

  @override
  Widget build(BuildContext context) {
    new Timer(Duration(seconds: 5), () {
      if (mounted)
        setState(() {
          isSplash = false;
        });
    });
    return isSplash ? SplashScreen() : StartPhoneNumScreen();
  }
}