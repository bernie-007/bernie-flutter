import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/models/matcher_model.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/screens/chat_screen.dart';

class FavoriteList extends StatefulWidget {

  final String userId;
  FavoriteList({this.userId, Key key}) : super(key: key);

  @override
  _FavoriteListState createState() => _FavoriteListState();
}

class _FavoriteListState extends State<FavoriteList> {

  List<Matcher> matches = [];

  @override
  void initState() {
    super.initState();
    getMatches();
  }

  getMatches() async {
    var data = {
      'userId': widget.userId
    };

    var apiUrl = 'getMatches.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    if( res['status'] == 200 ) {
      makeMatchList(res['data']);
    }
  }

  makeMatchList(data) {
    for (var item in data) {
      var userJson = {
        'id': item['id'],
        'name': item['name'],
        'photo': item['photo'],
        'timeZone': item['timeZone']
      };
      User user = User.fromJson(userJson);
      var matcherJson = {
        'matcher': user,
        'time': item['time']
      };
      Matcher matcher = Matcher.fromJson(matcherJson);
      matches.add(matcher);
    }
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      child: Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: myColor.primaryColorLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0)
            ),
            child: ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                var match = matches[index];
                var matcher = match.matcher;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(user: matcher)
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(top: height * 0.005, bottom: height * 0.005, right: width * 0.013, left: width * 0.013),
                    padding: EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.023),
                    decoration: BoxDecoration(
                      color: myColor.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(30.0))
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            matcher.imageUrl != null ? CircleAvatar(
                              radius: height * 0.04,
                              backgroundImage: NetworkImage('http://68.183.93.26/images/${matcher.imageUrl}'),
                            ) : SizedBox.shrink(),
                            SizedBox(width: width * 0.06),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  matcher.name, 
                                  style: TextStyle(
                                    color: myColor.blueColorLight,
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Container(
                                  width: width * 0.45,
                                  child: Text(
                                    '${match.time} added',
                                    style: TextStyle(
                                      color: myColor.primaryTextColor,
                                      fontSize: height * 0.018,
                                      fontWeight: FontWeight.w600
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}