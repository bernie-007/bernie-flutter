import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/screens/chat_screen.dart';

class SuperLikeContact extends StatefulWidget {

  final String userId;
  SuperLikeContact({this.userId, Key key}) : super(key: key);

  @override
  _SuperLikeContactState createState() => _SuperLikeContactState();
}

class _SuperLikeContactState extends State<SuperLikeContact> {

  List<User> superLikes = [];

  @override
  void initState() {
    super.initState();
    getSuperLikes();
  }

  getSuperLikes() async {
    var data = {
      'userId': widget.userId,
      'flag': '2'
    };
    var apiUrl = 'getFavorites.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    if( res['code'] == 200 ) {
      makeSuperLikeUsers(res['data']);
    }
  }

  makeSuperLikeUsers(supers) {
    for (var json in supers) {
      User userObj = User.fromJson(json);
      superLikes.add(userObj);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.06),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text(
                'Super Favorite Contacts', 
                style: TextStyle(
                  color: myColor.primaryTextColor, 
                  fontSize: width * 0.033, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: width * 0.001
                )
              ),
            ],
          ),
        ),
        Container(
          height: height * 0.13,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: superLikes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(user: superLikes[index])
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.008, horizontal: width * 0.03),
                      child: Column(
                        children: <Widget>[
                          superLikes[index].imageUrl != null ? CircleAvatar(
                            radius: width * 0.078,
                            backgroundImage: NetworkImage('http://68.183.93.26/images/${superLikes[index].imageUrl}'),
                          ) : SizedBox.shrink(),
                          SizedBox(height: height * 0.005),
                          Text(
                            superLikes[index].name,
                            style: TextStyle(
                              fontSize: height * 0.016,
                              color: Colors.white
                            ),
                          )
                        ]
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}