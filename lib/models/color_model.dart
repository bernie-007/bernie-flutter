import 'package:flutter/material.dart';

class ColorGroup {

  final Color primaryColor;
  final Color primaryColorLight;
  final Color blueColorLight;
  final Color blueColorDark;
  final Color darkColorGrey;
  final Color primaryTextColor;
  final Color errorColor;

  ColorGroup({
    this.primaryColor,
    this.primaryColorLight,
    this.blueColorLight,
    this.blueColorDark,
    this.darkColorGrey,
    this.primaryTextColor,
    this.errorColor,
  });
}

final ColorGroup myColor = ColorGroup(
  primaryColor: Color.fromRGBO(31, 44, 62, 1.0),
  primaryColorLight: Color.fromRGBO(41, 58, 76, 1.0),
  blueColorLight: Color.fromRGBO(163, 205, 255, 1.0),
  blueColorDark:Color.fromRGBO(96, 126, 153, 1.0),
  darkColorGrey: Color.fromRGBO(103, 112, 124, 1.0),
  primaryTextColor: Color.fromRGBO(218, 219, 222, 1.0),
  errorColor: Colors.red
);