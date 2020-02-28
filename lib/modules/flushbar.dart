// flush bar
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class FlushBar {
  
  final BuildContext context;
  final String title;
  final String message;
  final Color color;
  final Icon icon;
  
  FlushBar({this.context, this.title, this.message, this.color, this.icon});
  
  void flushbar() {
    Flushbar(
      title: title,
      message: message,
      icon: icon,
      duration: Duration(seconds: 5),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.TOP,      
    )..show(context);
  }
}