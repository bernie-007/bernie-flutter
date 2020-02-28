import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';

double width;
double height;

class Category extends StatefulWidget {

  final int selectedIndex;

  Category({this.selectedIndex});

  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {

  List<String> submenus = ['Match', 'Chat'];

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;

    return Container(
      height: height * 0.1,
      color: myColor.primaryColorLight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: submenus.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: height * 0.03,
            ),
            child: GestureDetector(
              onTap: () {
                switch(index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/Match');
                    break;
                  case 1:
                    Navigator.pushReplacementNamed(context, '/Message');
                    break;
                  default:
                    Navigator.pushReplacementNamed(context, '/Message');
                }
              },
              child: Text(
                submenus[index],
                style: TextStyle(
                  color: index == widget.selectedIndex ? myColor.blueColorLight : myColor.blueColorDark,
                  fontSize: height * 0.023,
                  fontWeight: FontWeight.bold,
                  letterSpacing: width * 0.0005
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}