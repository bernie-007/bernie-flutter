import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/chat_model.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/screens/chat_screen.dart';

class ChatList extends StatefulWidget {

  final String userId;
  ChatList({this.userId, Key key}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  List<Chat> chats = [];

  @override
  void initState() {
    super.initState();
    getChatList();
  }

  getChatList() async {
    var data = {
      'userId': widget.userId
    };
    var apiUrl = 'getChatList.php';
    var response = await Api().postData(data, apiUrl);
    var res = json.decode(response.body);
    if( res['status'] == 200 )
      makeChatContacts(res['data']);
      // print(res['data']);
  }

  makeChatContacts(data) {
    for (var item in data) {
      var userJson = {
        'id': item['id'],
        'name': item['name'],
        'photo': item['photo'],
        'timeZone': item['timeZone']
      };
      User user = User.fromJson(userJson);
      var chatJson = {
        'user': user,
        'text': item['text'],
        'pending': item['pending']
      };
      Chat chat = Chat.fromJson(chatJson);
      chats.add(chat);
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
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final Chat chat = chats[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(user: chat.user)
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
                            chat.user.imageUrl != null ? CircleAvatar(
                              radius: height * 0.04,
                              backgroundImage: NetworkImage('http://68.183.93.26/images/${chat.user.imageUrl}'),
                            ) : SizedBox.shrink(),
                            SizedBox(width: width * 0.06),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  chat.user.name, 
                                  style: TextStyle(
                                    color: myColor.blueColorLight,
                                    fontSize: height * 0.018,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                Container(
                                  width: width * 0.45,
                                  child: Text(
                                    chat.text == null ? '' : chat.text,
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
                        Column(
                          children: <Widget>[
                            chat.pending != null ? Container(
                              width: width * 0.12,
                              height: height * 0.028,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(30.0)
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${chat.pending}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.014,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ) : SizedBox.shrink(),
                          ],
                        )
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