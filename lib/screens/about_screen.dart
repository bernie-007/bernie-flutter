import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'About Ylike',
          style: TextStyle(
            color: myColor.blueColorLight,
            fontSize: height * 0.023,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.2,
          vertical: height * 0.1
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              'Ylike',
              style: TextStyle(
                color: myColor.blueColorDark,
                fontSize: height * 0.022,
                fontWeight: FontWeight.w800
              ),
            ),
            Text(
              'v1.0.1',
              style: TextStyle(
                color: Colors.grey,
                fontSize: height * 0.02,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}