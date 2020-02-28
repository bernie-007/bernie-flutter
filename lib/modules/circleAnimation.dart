import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matching_tantan_app/models/color_model.dart';

class CircleAnimation extends CustomPainter {

  CircleAnimation();

  @override
  void paint(Canvas canvas, Size size) {

    Paint outerCircle = Paint()
      ..strokeWidth = min(size.width / 3, size.height/3)
      ..color = myColor.blueColorLight
      ..style = PaintingStyle.stroke;

    Paint completeArc1 = Paint()
      ..strokeWidth = min(size.width / 3, size.height/3)
      ..color = Colors.black38
      ..style = PaintingStyle.stroke;

    Paint completeArc2 = Paint()
      ..strokeWidth = min(size.width / 3, size.height/3)
      ..color = Colors.white30
      ..style = PaintingStyle.stroke;

    Offset center = Offset(size.width/2, size.height/2);
    double radius = min(size.width/3.2, size.height/3.2);

    canvas.drawCircle(center, radius, outerCircle);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 0, 2*pi/3, false, completeArc1);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), 2*pi/3, 2*pi/3, false, completeArc2);
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}