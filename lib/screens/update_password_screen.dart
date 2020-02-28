import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:matching_tantan_app/modules/flushbar.dart';
import 'package:matching_tantan_app/models/color_model.dart';

import 'package:matching_tantan_app/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePasswordScreen extends StatefulWidget {
  
  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  String userId;
  bool isLife = false;
  bool isUpdate = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
  }

  @override
  Widget build(BuildContext context) {
    
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: myColor.primaryColor,
      body: Column(
        children: <Widget>[
          Container(
            width: width * 0.958,
            height: height * 0.13,
            decoration: BoxDecoration(
              color: myColor.primaryColorLight,
              borderRadius: BorderRadius.circular(20.0)
            ),
            child: Center(
              child: Text(
                'Update Password',
                style: TextStyle(
                  fontSize: height * 0.028,
                  color: myColor.blueColorLight,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.2
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Current Password:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.024,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.01
            ),
            child: TextField(
              controller: oldPasswordController,
              onChanged: (value) {
                setState(() {
                  isUpdate = false;
                });
              },
              style: TextStyle(
                fontSize: height * 0.023,
                color: myColor.primaryTextColor
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_open, size: height * 0.026, color: myColor.darkColorGrey,),
                prefixStyle: TextStyle(
                  fontSize: height * 0.023,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Input your current password',
                hintStyle: TextStyle(
                  color: myColor.darkColorGrey,
                  fontSize: height * 0.021
                ),
                fillColor: myColor.primaryColorLight,
                filled: true,
              ),
              obscureText: true,
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.04
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'New Password:',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: myColor.darkColorGrey,
                    fontSize: height * 0.024,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: width * 0.04,
              right: width * 0.04,
              top: height * 0.01
            ),
            child: TextField(
              controller: newPasswordController,
              onChanged: (value) {
                setState(() {
                  isUpdate = false;
                });
              },
              style: TextStyle(
                fontSize: height * 0.023,
                color: myColor.primaryTextColor
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock, size: height * 0.026, color: myColor.darkColorGrey,),
                prefixStyle: TextStyle(
                  fontSize: height * 0.023,
                  fontWeight: FontWeight.bold,
                ),
                hintText: 'Input your new password',
                hintStyle: TextStyle(
                  color: myColor.darkColorGrey,
                  fontSize: height * 0.021
                ),
                fillColor: myColor.primaryColorLight,
                filled: true,
              ),
              obscureText: true,
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        width: width,
        height: height * 0.065,
        color: myColor.primaryTextColor,
        child: MaterialButton(
          onPressed: () {
            if (!isUpdate) {
              updatePassword(context);
            }
          },
          child: Text(
            !isUpdate
            ? 'Submit'
            : 'Submitting...',
            style: TextStyle(
              color: myColor.primaryColor,
              fontSize: height * 0.023
            ),
          ),
        ),
      ),
    );
  }

  void updatePassword(BuildContext context) async {
    if (userId == "" || userId == null) {
      // your session data has been destroyed
      String title = 'Error!';
      String message = 'Your session data has been destroyed.';
      Icon icon = Icon(Icons.error, color: Colors.white);
      Color color = Colors.red[300];
      
      FlushBar flushbar = new FlushBar(
        context: context, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    } else if (oldPasswordController.text == "" || newPasswordController.text == "") {
      // Invalid your input data
      String title = 'Error!';
      String message = 'Invalid your input data.';
      Icon icon = Icon(Icons.error, color: Colors.white);
      Color color = Colors.red[300];
      
      FlushBar flushbar = new FlushBar(
        context: context, 
        title: title, 
        message: message, 
        icon: icon, 
        color: color
      );
      flushbar.flushbar();
    } else {
      setState(() {
        isUpdate = true;
      });
      var data = {
        'userId': userId,
        'oldPassword': oldPasswordController.text,
        'newPassword': newPasswordController.text
      };
      var apiUrl = 'updatePassword.php';
      var result = await Api().postData(data, apiUrl);
      var response = json.decode(result.body);
      if (response['status'] == 200) {
        setState(() {
          isUpdate = false;
          oldPasswordController.text = "";
          newPasswordController.text = "";
        });
        String title = 'Success!';
        String message = 'Your password has been updated successfully.';
        Icon icon = Icon(Icons.check, color: Colors.white);
        Color color = Colors.green[300];
        
        FlushBar flushbar = new FlushBar(
          context: context, 
          title: title, 
          message: message, 
          icon: icon, 
          color: color
        );
        flushbar.flushbar();
      } else if (response['status'] == 300) {
        String title = 'Warning!';
        String message = 'The old password is incorrect.';
        Icon icon = Icon(Icons.warning, color: Colors.white);
        Color color = Colors.orange[300];
        
        FlushBar flushbar = new FlushBar(
          context: context, 
          title: title, 
          message: message, 
          icon: icon, 
          color: color
        );
        flushbar.flushbar();
        setState(() {
          isUpdate = false;
        });
      } else if (response["status"] == 400) {
        String title = 'Oops!';
        String message = 'Something went to wrong.';
        Icon icon = Icon(Icons.warning, color: Colors.white);
        Color color = Colors.orange[300];
        
        FlushBar flushbar = new FlushBar(
          context: context, 
          title: title, 
          message: message, 
          icon: icon, 
          color: color
        );
        flushbar.flushbar();
        setState(() {
          isUpdate = false;
        });
      }
    }
  }
}