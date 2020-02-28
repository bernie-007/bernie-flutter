import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';

enum GenderEnum { both, men, women }

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {

  int distanceValue = 160;
  int ageValue = 48;
  GenderEnum gender = GenderEnum.both;
  GenderEnum parentGender = GenderEnum.both;

  showGenderEditAlert() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double _height = MediaQuery.of(context).size.height;
            double _width = MediaQuery.of(context).size.width;
            return AlertDialog(
              title: Text(
                'Who be shown you',
                style: TextStyle(
                  color: myColor.primaryColor
                ),
              ),
              content: Container(
                width: _width,
                height: _height * 0.34,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Both of women and men'),
                      leading: Radio(
                        value: GenderEnum.both,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Only men'),
                      leading: Radio(
                        value: GenderEnum.men,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Only women'),
                      leading: Radio(
                        value: GenderEnum.women,
                        groupValue: gender,
                        activeColor: Colors.pink,
                        onChanged: (GenderEnum value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'No',
                    style: TextStyle(
                      color: myColor.primaryColorLight,
                      fontSize: _height * 0.018
                    )
                  ),
                ),
                FlatButton(
                  onPressed: () {
                    super.setState(() {
                      parentGender = gender;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: myColor.primaryColorLight,
                      fontSize: _height * 0.018
                    )
                  ),
                )
              ],
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Setting',
          style: TextStyle(
            color: myColor.blueColorLight,
            fontSize: height * 0.023
          ),
        ),
      ),
      body: Container(
        color: myColor.primaryColorLight,
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Container(
              color: myColor.primaryColorLight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.12,
                      vertical: height * 0.021
                    ),
                    width: width,
                    height: height * 0.08,
                    color: myColor.blueColorDark,
                    child: Text(
                      'discover settings',
                      style: TextStyle(
                        fontSize: height * 0.018,
                        color: myColor.primaryTextColor
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    color: myColor.primaryColorLight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01,
                        vertical: width * 0.032
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.near_me,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'distance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.directions_walk,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Slider(
                                min: 0,
                                max: 160,
                                divisions: 160,
                                activeColor: Colors.blue,
                                inactiveColor: Colors.grey,
                                label: distanceValue.toString() + ' km',
                                onChanged: (value) {
                                  setState(() {
                                    distanceValue = value.toInt();
                                  });
                                },
                                value: distanceValue.toDouble(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.airplanemode_active,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    color: myColor.primaryColorLight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01,
                        vertical: width * 0.032
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.people,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'age',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.child_care,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child: Slider(
                                min: 18,
                                max: 48,
                                divisions: 30,
                                activeColor: Colors.orange,
                                inactiveColor: Colors.grey,
                                label: ageValue.toString() + ' years',
                                onChanged: (value) {
                                  setState(() {
                                    ageValue = value.toInt();
                                  });
                                },
                                value: ageValue.toDouble(),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Icon(
                                Icons.nature_people,
                                color: myColor.primaryTextColor,
                                size: height * 0.02,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 8.0,
                    color: myColor.primaryColorLight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.01,
                        vertical: width * 0.032
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent,
                            borderRadius: BorderRadius.circular(10.0)
                          ),
                          child: Icon(
                            Icons.pregnant_woman,
                            color: Colors.white,
                            size: height * 0.026,
                          ),
                        ),
                        title: Text(
                          'show me',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: height * 0.021,
                            color: myColor.blueColorDark
                          ),
                        ),
                        subtitle: GestureDetector(
                          onTap: () => showGenderEditAlert(),
                          child: Text(
                            parentGender == GenderEnum.both ? 'Both of Women and Men' : parentGender == GenderEnum.men ? 'Only Men' : 'Only Women',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: height * 0.016,
                              color: myColor.primaryTextColor
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}