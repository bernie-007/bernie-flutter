import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import 'localNotification.dart';

class PusherSocket {
  
  final String channelName;
  final String eventName;
  Channel channel;
  static String title;
  static String message;
  
  PusherSocket({this.channelName, this.eventName, Key key});

  Future<void> initPusher() async {
    try {
      await Pusher.init('982fdfab1791cf18a037', PusherOptions(cluster: "ap2"), enableLogging: true).then((onValue) {
        connectPusher();
      });
    } on PlatformException catch (e) {
      debugPrint('initPusher has some error: ${e.message}');
    }
  }

  connectPusher() {
    Pusher.connect(onConnectionStateChange: (x) async {
      debugPrint(x.currentState);
      if (x.currentState == 'CONNECTED') {
        await subScribeChannel();
      }
    }, onError: (e) {
      debugPrint('Failed connect to pusher: ${e.message}');
    });
  }

  Future<Channel> getChannel() async {
    Channel chatChannel;
    await Pusher.subscribe('${this.channelName}').then((newChannel) async {
      chatChannel = newChannel;
    });
    return chatChannel;
  }

  subScribeChannel() async {
    await Pusher.subscribe('${this.channelName}').then((value) async {
      channel = value;
      await bindEvent();
    });
  }

  bindEvent() async {
    await channel.bind('${this.eventName}', (x) async {
      // push notification
      debugPrint('channel - ${x.channel}');
      debugPrint('event - ${x.event}');
      if (x.data != null) {
        var data = json.decode(x.data);
        title = 'new notification';
        message = data['message'];
        debugPrint(title);
        debugPrint(message);
        YlikeNotification notification = new YlikeNotification(title: title, message: message);
        notification.initNotification();
        await notification.showNotification();
      }
    });
  }
}