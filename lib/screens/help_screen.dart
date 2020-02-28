import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Help Center',
          style: TextStyle(
            color: myColor.blueColorLight,
            fontSize: height * 0.023,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [myColor.primaryColorLight, myColor.primaryColor]
          )
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.02,
          vertical: height * 0.043
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23.0)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: height * 0.03,
                  left: width * 0.1,
                  right: width * 0.1
                ),
                child: Center(
                  child: Text(
                    'How to use Ylike:',
                    style: TextStyle(
                      color: myColor.primaryColor,
                      fontSize: height * 0.03,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.012,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'Ylike will suggest peopple nearby. You can adjust this distance in your search settings. Once a profile is presented to you, you have two options:',
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.018
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.018,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'Swipe right to like',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: height * 0.023,
                    fontWeight: FontWeight.w600
                  )
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.01,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'If you like what you see, swipe right. They won\'t know you liked them unless they like you back. Ylike is completely anonymous and rejection-free',
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.018
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.018,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'Swipe left to pass',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: height * 0.023,
                    fontWeight: FontWeight.w600
                  )
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.01,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'Swiping left means you\'re not interested in that person. They won\'t be shown to you again, and won\'t know that you swiped on them either.',
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.018
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.018,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'You\'ve got a match!',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: height * 0.023,
                    fontWeight: FontWeight.w600
                  )
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.01,
                  horizontal: width * 0.02
                ),
                child: Text(
                  'Someone you liked has liked you back. Congratulations, you\'ve got a match! Now you can start chatting. Good luck! :)',
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.018
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}