import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/modules/pusherSocket.dart';
import 'package:matching_tantan_app/screens/chat_screen.dart';
import 'package:matching_tantan_app/screens/ylike.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:matching_tantan_app/api/api.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  String userId, name, photo; // current user's information *id, *name, *photo
  double width, height; // device screen width, height
  Duration duration = const Duration(milliseconds: 300); // show or hide side menubar animation duration
  var users; // *
  User user; // *
  int currentBottomBarIndex = 0, currentUserIndex = 0;
  bool isGesture = false;
  double posX = 0, posY = 0; // distance of geolocation between first position and drag update position
  double fPosX = 0, fPosY = 0; // first geolocation when drag start
  double uPosT = 0, uPosB = 0, uPosL = 0, uPosR = 0;
  double favoriteOptValue = 0.0;
  double cancelOptValue = 0.0;
  double starOptValue = 0.0;
  int action = -1;

  bool isLoading = true; // status is on loading match data or not

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return isLoading || user == null
    ? Ylike(photo: photo, user: user, isLoading: isLoading)
    : Scaffold(
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
        backgroundColor: myColor.primaryColor,
      ),
      body: Container(
        color: myColor.primaryColorLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Stack(
                children: <Widget>[
                  (currentUserIndex+1) < users.length 
                  ? people(context, currentUserIndex+1)
                  : Container(),
                  currentUserIndex < users.length
                  ? people(context, currentUserIndex)
                  : Container(),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: toolBar(),
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
        currentIndex: currentBottomBarIndex,
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

  Widget people(BuildContext context, int index) {

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    double posT = height * 0.011, posB = height * 0.011,
          posL = width * 0.011, posR = width * 0.011;
    var person = users[index];
    return AnimatedPositioned(
      duration: Duration(milliseconds: 200),
      top: 0,
      bottom: 0,
      left: currentUserIndex <= index ? 0 : -width,
      right: currentUserIndex <= index ? 0 : width,
      child: GestureDetector(
        onHorizontalDragStart: (DragStartDetails details) {
          fPosX = details.globalPosition.dx;
          fPosY = details.globalPosition.dy;
          setState(() {
            isGesture = true;
          });
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          setState(() {
            isGesture = false;
            fPosX = 0;
            fPosY = 0;
            if (cancelOptValue == 1.0) {
              crossUser(person['id']);
            } else if (favoriteOptValue == 1.0) {
              favoriteUser(person['id']);
            } else if (starOptValue == 1.0) {
              superUser(person['id']);
            }
            cancelOptValue = 0.0;
            favoriteOptValue = 0.0;
            starOptValue = 0.0;
          });
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          setState(() {
            uPosT = posT - fPosY + details.globalPosition.dy;
            uPosB = posB + fPosY - details.globalPosition.dy;
            if (uPosT > posT) {
              uPosT = posT;
              uPosB = posB;
            }
            uPosL = posL - fPosX + details.globalPosition.dx;
            uPosR = posR + fPosX - details.globalPosition.dx;
            double dX = fPosX - details.globalPosition.dx;
            double dY = fPosY - details.globalPosition.dy;
            double tanValue;
            // calculate tan()
            if (dY < 0) dY = (-1) * dY;
            if (dX > 0) tanValue = dY / dX;
            else        tanValue = dX / dY;
            // compare tan() value to guess action
            if (dX > width/8 || dY > height/8 || dX < -width/8) {
              if (tanValue <= tan(3*pi/8) && tanValue >= 0) {
                favoriteOptValue = 0.0;
                starOptValue = 0.0;
                action = 0;
                cancelOptValue = (3 * pow((pow(dX, 2) + pow(dY, 2)), 1/2)) / width;
                if (cancelOptValue > 1.0) {
                  cancelOptValue = 1.0;
                }
              } else if ((tanValue > tan(3*pi/8) || tanValue >= -tan(pi/8)) && dY > 0) {
                cancelOptValue = 0.0;
                favoriteOptValue = 0.0;
                action = 2;
                starOptValue = (4 * pow((pow(dX, 2) + pow(dY, 2)), 1/2)) / height;
                if (starOptValue > 1.0) {
                  starOptValue = 1.0;
                }
              } else {
                cancelOptValue = 0.0;
                starOptValue = 0.0;
                action = 1;
                favoriteOptValue = (3 * pow((pow(dX, 2) + pow(dY, 2)), 1/2)) / width;
                if (favoriteOptValue > 1.0) {
                  favoriteOptValue = 1.0;
                }
              }
            }
          });
        },
        child: Stack(
          children: <Widget>[
            Positioned(
              top: isGesture && currentUserIndex == index ? uPosT : posT,
              bottom: isGesture && currentUserIndex == index ? uPosB : posB,
              left: isGesture && currentUserIndex == index ? uPosL : posL,
              right: isGesture && currentUserIndex == index ? uPosR : posR,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.013,
                      bottom: height * 0.013,
                      left: width * 0.02,
                      right: width * 0.02
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white,
                        image: DecorationImage(
                          image: NetworkImage('http://68.183.93.26/images/' + person['photo']),
                          fit: BoxFit.cover
                        )
                      ),
                    ),
                  ),
                  // favorite opacity mark
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.13,
                      vertical: height * 0.24
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Opacity(
                        opacity: currentUserIndex == index ? favoriteOptValue : 0.0,
                        child: Container(
                          width: width * 0.2,
                          height: width * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: width * 0.12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // don't like opacity mark
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.13,
                      vertical: height * 0.24
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: currentUserIndex == index ? cancelOptValue : 0.0,
                        child: Container(
                          width: width * 0.2,
                          height: width * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                          ),
                          child: Icon(
                            Icons.cancel,
                            size: width * 0.18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // super like opacity mark
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.13,
                      vertical: height * 0.24
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: currentUserIndex == index ? starOptValue : 0.0,
                        child: Container(
                          width: width * 0.2,
                          height: height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle
                          ),
                          child: Icon(
                            Icons.star,
                            color: Colors.white,
                            size: width * 0.13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.45,
                      bottom: height * 0.013,        
                      left: width * 0.02,
                      right: width * 0.02
                    ),
                    child: Container(
                      width: width * 0.96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0)
                        ),
                        color: Colors.black26,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: height * 0.015,
                              left: width * 0.068
                            ),
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Text(
                              person['name'] + ', ' + person['age'].toString(),
                              style: TextStyle(
                                color: myColor.primaryTextColor,
                                fontSize: height * 0.019,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.01),
                          Container(
                            margin: EdgeInsets.only(
                              left: width * 0.043
                            ),
                            padding: EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Text(
                              person['location_name'] + ', ' + person['distance'].toString() + ' km away',
                              style: TextStyle(
                                color: myColor.primaryTextColor,
                                fontSize: height * 0.016,
                                fontWeight: FontWeight.w700
                              ),
                            ),
                          )
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
    );
  }

  Widget toolBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: width * 0.062,
        right: width * 0.062,
        top: height * 0.066
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: min(width * 0.048, height * 0.048),
              child: IconButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await getUsers();
                },
                icon: Icon(Icons.refresh),
                iconSize: height * 0.027,
                color: Colors.blue,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: height * 0.008
            ),
            padding: EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: myColor.primaryColor,
              shape: BoxShape.circle
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: min(width * 0.052, height * 0.052),
              child: IconButton(
                onPressed: (){
                  crossUser(users[currentUserIndex]['id']);
                },
                icon: Icon(Icons.cancel),
                iconSize: height * 0.027,
                color: myColor.primaryColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: min(width * 0.063, height * 0.063),
              child: IconButton(
                onPressed: (){
                  superUser(users[currentUserIndex]['id']);
                },
                icon: Icon(Icons.star),
                iconSize: height * 0.04,
                color: Colors.orange,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: min(width * 0.049, height * 0.049),
              child: IconButton(
                onPressed: (){
                  favoriteUser(users[currentUserIndex]['id']);
                },
                icon: Icon(Icons.favorite),
                iconSize: height * 0.028,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  gotoChat(chater) {
    var jsonUser = {
      'id': chater['id'],
      'name': chater['name'],
      'photo': chater['photo']
    };
    User otherUser = User.fromJson(jsonUser);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: otherUser)));
  }

  getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
      name = prefs.getString('name');
      photo = prefs.getString('photo');
      getUsers();
      initPusher();
    });
  }

  initPusher() async {
    PusherSocket pusher = new PusherSocket(channelName: 'notification-channel', eventName: 'new-notification-$userId');
    await pusher.initPusher();
  }

  getUsers() async {
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
    } catch(e) {
      if(e.code == 'PERMISSION_DENIED') {
        // snack bar
        print('permission denied');
      }
    }
    
    var data = {
      'userId': userId,
      'latitude': currentLocation.latitude.toString(),
      'longitude': currentLocation.longitude.toString()
    };
    var apiUrl = 'getUsers.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    
    if( res['status'] == 200 ) {
      currentUserIndex = 0;
      users = res['data'];
      setState(() {
        isLoading = false;
        if (users.length == 0)
          user = null;
        else {
          user = User.fromJson(users[currentUserIndex]);
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // snack bar
    }
  }

  crossUser(favoriteId) {
    var data = {
      'userId': userId,
      'favoriteId': favoriteId,
      'flag': '0'
    };
    addLikeUser(data);
    getNextUser();
  }

  favoriteUser(favoriteId) {
    var data = {
      'userId': userId,
      'favoriteId': favoriteId,
      'flag': '1'
    };
    addLikeUser(data);
    getNextUser();
  }

  superUser(favoriteId) {
    var data = {
      'userId': userId,
      'favoriteId': favoriteId,
      'flag': '2'
    };
    addLikeUser(data);
    getNextUser();
  }

  addLikeUser(data) async {
    var apiUrl = 'addLikeUser.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    print(res);
  }

  getNextUser() {
    setState(() {
      currentUserIndex++;
      if (currentUserIndex < users.length) {
        user = User.fromJson(users[currentUserIndex]);
      } else {
        isLoading = true;
        getUsers();
      }
    });
  }
}