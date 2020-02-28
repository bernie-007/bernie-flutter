import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class YlikeNotification {

  final String title;
  final String message;

  YlikeNotification({this.title, this.message, Key key});

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  initNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final settingsAndroid = AndroidInitializationSettings('ic_launcher');
    final settingsIos = IOSInitializationSettings();
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(settingsAndroid, settingsIos)
    );
  }

  showNotification() async {
    // var scheduledNotificationDateTime =
    //   new DateTime.now().add(new Duration(seconds: 5));
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
    111112, this.title, this.message, platformChannelSpecifics,
    payload: 'item x');
  //   await flutterLocalNotificationsPlugin.schedule(
  //     122233,
  //     this.title,
  //     this.message,
  //     scheduledNotificationDateTime,
  //     platformChannelSpecifics);
  }
}