import 'package:matching_tantan_app/models/user_model.dart';

class Matcher {
  final User matcher;
  final String time;

  Matcher({
    this.matcher, 
    this.time
  });

  Matcher.fromJson(Map<String, dynamic> json)
    : matcher = json['matcher'],
      time = json['time'];
}