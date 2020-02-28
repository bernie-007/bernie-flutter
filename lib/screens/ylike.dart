import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share/share.dart';

import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/modules/circleAnimation.dart';

class Ylike extends StatefulWidget {

  final String photo;
  final User user;
  final bool isLoading;

  Ylike({this.photo, this.user, this.isLoading, Key key}) : super(key: key);

  @override
  _YlikeState createState() => _YlikeState();
}

class _YlikeState extends State<Ylike> with SingleTickerProviderStateMixin {

  int currentIndex = 0;
  AnimationController progressController;
  Animation animation;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    animation = Tween<double>(begin: 0, end: 2).animate(progressController)..addListener(() {
      if (mounted) {
        setState(() {
        });
      }
    });
    progressController.forward();
    progressController.repeat();
  }

  @override
  void dispose() {
    progressController.dispose();
    super.dispose();
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
          'Ylike',
          style: TextStyle(
            fontSize: height * 0.023,
            color: myColor.blueColorLight,
            fontWeight: FontWeight.bold
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (!widget.isLoading && widget.user == null) {
                Navigator.pushReplacementNamed(context, '/Home');
              }
            },
            icon: Icon(Icons.refresh),
            iconSize: height * 0.026,
            color: myColor.blueColorLight,
          )
        ],
        backgroundColor: myColor.primaryColor,
      ),
      body: Container(
        color: myColor.primaryColorLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Stack(
                children: <Widget> [
                  Container(
                    child: Transform.rotate(
                      angle: animation.value * pi,
                      child: CustomPaint(
                        foregroundPainter: CircleAnimation(),
                        child: Container(
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: widget.photo != null ? CircleAvatar(
                      radius: min(width/5.2, height/5.2),
                      backgroundColor: myColor.primaryColor,
                      backgroundImage: NetworkImage('http://68.183.93.26/images/${widget.photo}'),
                    ) : SizedBox.shrink(),
                  ),
                ]
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.023,
                      left: width * 0.1,
                      right: width * 0.1
                    ),
                    child: Center(
                      child: !widget.isLoading && widget.user == null ? Text(
                        'There is no new ones near by you.',
                        style: TextStyle(
                          color: myColor.primaryTextColor,
                          fontSize: height * 0.019,
                          fontWeight: FontWeight.w400
                        ),
                      ) : SizedBox.shrink(),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.063,
                      bottom: height * 0.033,
                      left: width * 0.2,
                      right: width * 0.2
                    ),
                    child: RaisedButton(
                      onPressed: () => invitePeople(context),
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.088,
                        vertical: height * 0.01
                      ),
                      color: myColor.primaryColor,
                      elevation: 8.0,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.share,
                            color: Colors.white70,
                            size: height * 0.03,
                          ),
                          Text(
                            'Invite People',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              fontSize: height * 0.026
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).pushNamed('/Message');
              break;
            case 2:
              Navigator.of(context).pushNamed('/MyScreen');
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

  void invitePeople(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    final String text = 'share';

    Share.share(
      text,
      subject: 'subject',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
    );
  }
}