import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matching_tantan_app/modules/category.dart';
import 'package:matching_tantan_app/modules/chatList.dart';
import 'package:matching_tantan_app/modules/loadingShimmer.dart';
import 'package:matching_tantan_app/modules/superLikeContact.dart';

double width;
double height;

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {

  bool loading = true;
  bool isCollapsed = true;
  final Duration duration = const Duration(milliseconds: 300);
  String userId;
  String name;
  String photo;
  Timer time;
  int currentIndex = 1;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    name = prefs.getString('name');
    photo = prefs.getString('photo');
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    time = Timer(Duration(seconds: 3), () {
      if( mounted )
        setState(() {
          loading = false;
        });
    });

    return Scaffold(
      backgroundColor: myColor.primaryColorLight,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chat", 
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: height * 0.023)
        ),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Category(selectedIndex: 1),
          loading ? LoadingShimmer() : Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey[400],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)
                ),
              ),
              child: Column(
                children: <Widget>[
                  SuperLikeContact(userId: userId),
                  ChatList(userId: userId)
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/MyScreen');
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
    );
  }
}