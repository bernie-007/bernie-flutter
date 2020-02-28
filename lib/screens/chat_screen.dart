import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matching_tantan_app/api/api.dart';
import 'package:matching_tantan_app/models/color_model.dart';
import 'package:matching_tantan_app/models/message_model.dart';
import 'package:matching_tantan_app/models/user_model.dart';
import 'package:matching_tantan_app/modules/pusherSocket.dart';
import 'package:shared_preferences/shared_preferences.dart';

double width;
double height;

class ChatScreen extends StatefulWidget {

  final User user;
  ChatScreen({this.user, Key key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = new TextEditingController();
  String connectionState;
  List<Message> messages = [];
  User currentUser;
  bool isSent = false;
  int order = 0;
  bool isDivide = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getChatChannel();
  }

  getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = {
      'id': prefs.getString('userId'),
      'name': prefs.getString('name'),
      'photo': prefs.getString('photo'),
      'timeZone': prefs.getString('timeZone'),
    };
    currentUser = User.fromJson(data);
    getMessageList();
  }

  getMessageList() async {
    var from = currentUser.id;
    var to = widget.user.id;
    var param = {
      'from': from.toString(),
      'to': to.toString(),
      'fromTimeZone': currentUser.timeZone
    };
    var apiUrl = 'getMessages.php';
    var response = await Api().postData(param, apiUrl);
    var res = json.decode(response.body);
    
    if( res['status'] == 'success' )
      makeMessageList(res['message']);
  }

  makeMessageList(res) {
    messages = [];
    for( var i = 0; i < res.length; i++ ) {
      var userJson = {
        'id': res[i]['from'],
        'name': res[i]['from'] == currentUser.id ? currentUser.name : widget.user.name,
        'photo': res[i]['from'] == currentUser.id ? currentUser.imageUrl : widget.user.imageUrl,
      };
      var sender = User.fromJson(userJson);
      var msgJson = {
        'sender': sender,
        'time': res[i]['created_at'],
        'text': res[i]['text'],
        'unRead': res[i]['unread'] == 1 ? true : false,
        'order': res[i]['order'],
        'date': res[i]['date'],
        'timeline': res[i]['timeline'],
      };
      Message message = Message.fromJson(msgJson);
      setState(() {
        messages.add(message);
      });
    }
  }

  sendMessage() async {
    print(currentUser.timeZone);
    print(widget.user.timeZone);
    setState(() {
      isSent = true;
    });
    if (messageController.text != '' && messageController != null) {
      var data = {
        'from': currentUser.id.toString(),
        'fromTimeZone': currentUser.timeZone,
        'to': widget.user.id.toString(),
        'toTimeZone': widget.user.timeZone,
        'text': messageController.text,
      };
      var apiUrl = "sendMessage.php";
      var response = await Api().postData(data, apiUrl);
      var res = json.decode(response.body);
      
      if (res['status'] == "success") {
        setState(() {
          getMessageList();
          messageController.text = '';
        });
      } else {
        setState(() {
          messageController.text = '';
        });
      }
    }
  }

  getChatChannel() async {
    String channelName = 'message-channel';
    String eventName = 'new-message';
    PusherSocket pusherSocket = new PusherSocket(channelName: channelName, eventName: eventName);
    await pusherSocket.getChannel().then((channel) async {
      await bindEvent(channel);
    });
  }

  bindEvent(channel) async {
    try {
      Timer(
        Duration(seconds: 3), 
        () async {
          await channel.bind('new-message-${currentUser.id}', (x) {
            if(mounted) {
              setState(() {
                getMessageList();
              });
            }
          });
        }
      );
    } catch (e) {
      print('error bind: ${e.toString()}');
    }
  }

  _buildMessage(message) {
    bool isMe;
    if (message.sender.id == currentUser.id) isMe = true;
    else isMe = false;

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: isMe ? EdgeInsets.only(
            top: height * 0.0033,
            bottom: height * 0.0033,
            left: width * 0.23,
            right: 0
          ) : EdgeInsets.only(
            top: height * 0.0033,
            bottom: height * 0.0033,
            right: width * 0.23
          ),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.063,
                vertical: height * 0.016
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: isMe ? Colors.black38 : Color.fromRGBO(255, 140, 0, 0.86)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: height * 0.0143,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: height * 0.008),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: height * 0.019,
                      color: Colors.white,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
          ),
        )    
      ],
    );
  }

  _buildComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.036, vertical: height * 0.023),
      width: width,
      color: Colors.blueGrey[100],
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: messageController,
              style: TextStyle(
                fontSize: height * 0.022
              ),
              decoration: InputDecoration(
                hintText: 'Enter a message here...',
              ),
              onChanged: (value) {
                if (value.length > 0) {
                  setState(() {
                    isSent = false;
                  });
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: height * 0.036,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (messageController.text != '' && messageController.text != null) {
                if (!isSent) {
                  sendMessage();
                }
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Scaffold(
      backgroundColor: myColor.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.user.name != null ? '${widget.user.name} - Message' : '? - Message',
          style: TextStyle(
            fontSize: height * 0.021,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.064,
                      right: width * 0.064,
                      bottom: height * 0.01
                    ),
                    child: Stack(
                      children: <Widget> [
                        chats.length != null ? ListView.builder(
                          reverse: true,
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            var length = messages.length;
                            var curIndex = length - index - 1;
                            Message message = messages[curIndex];
                            Message lastMessage;
                            if (index != 0) {
                              lastMessage = messages[curIndex + 1];
                            } else {
                              lastMessage = messages[curIndex];
                            }
                            if (order == 0 || order == message.order) {
                              isDivide = false;
                            } else if (order > message.order) {
                              isDivide = true;
                            }
                            if (curIndex > 0) {
                              order = message.order;
                            } else {
                              order = 0;
                            }
                            return Column(
                              children: <Widget>[
                                curIndex == 0
                                ? Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.01
                                  ),
                                  child: Center(
                                    child: Text(
                                      message.timeline,
                                      style: TextStyle(
                                        fontSize: height * 0.019,
                                        color: Colors.blue
                                      ),
                                    ),
                                  ),
                                ) : SizedBox.shrink(),
                                _buildMessage(message),
                                isDivide
                                ? Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: height * 0.01
                                  ),
                                  child: Center(
                                    child: Text(
                                      lastMessage.timeline,
                                      style: TextStyle(
                                        fontSize: height * 0.019,
                                        color: Colors.blue
                                      ),
                                    ),
                                  ),
                                ) : SizedBox.shrink(),
                              ],
                            );
                          },
                        ) : SizedBox.shrink(),
                      ]
                    ),
                  ),
                ),
              ),
            ),
            _buildComposer(),
          ],
        ),
      ),
    );
  }
}