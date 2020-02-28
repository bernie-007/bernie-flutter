import 'package:flutter/material.dart';
import 'package:share/share.dart';

class SideMenu extends StatelessWidget {

  final String name;
  final String photo;

  SideMenu(this.name, this.photo);

  void invitePeople(BuildContext context) {
    final RenderBox box = context.findRenderObject();
    final String text = 'share';

    Share.share(
      text,
      subject: 'subject',
      sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size
    );
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(0.0),
      color: Colors.black54,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: width * 0.1, right: width * 0.3),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  photo != null ? Container(
                    width: 150.0,
                    height: 150.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage('http://68.183.93.26/images/$photo', scale: 0.5)
                      ),
                    ),
                  ) : SizedBox.shrink(),
                  SizedBox(height: height* 0.01),
                  Text(name == null ? '' : name, style: TextStyle(color: Colors.white, fontSize: width * 0.04))
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: width * 0.3, right: width * 0.3),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    minWidth: width * 0.6,
                    height: height * 0.06,
                    child: Text("Home", style: TextStyle(color: Colors.white, fontSize: height * 0.02)),
                    highlightColor: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  MaterialButton(
                    minWidth: width * 0.6,
                    height: height * 0.06,
                    child: Text("Matches", style: TextStyle(color: Colors.white, fontSize: height * 0.02)),
                    highlightColor: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/Match');
                    },
                  ),
                  MaterialButton(
                    minWidth: width * 0.6,
                    height: height * 0.06,
                    child: Text("Settings", style: TextStyle(color: Colors.white, fontSize: height * 0.02)),
                    highlightColor: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/Setting');
                    },
                  ),
                  MaterialButton(
                    minWidth: width * 0.6,
                    height: height * 0.06,
                    child: Text("Help", style: TextStyle(color: Colors.white, fontSize: height * 0.02)),
                    highlightColor: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/Help');
                    },
                  ),
                  MaterialButton(
                    minWidth: width * 0.6,
                    height: height * 0.06,
                    child: Text("Invite", style: TextStyle(color: Colors.white, fontSize: height * 0.02)),
                    highlightColor: Theme.of(context).primaryColor,
                    splashColor: Theme.of(context).primaryColor,
                    onPressed: () {
                      invitePeople(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}