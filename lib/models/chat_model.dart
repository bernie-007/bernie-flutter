import 'package:matching_tantan_app/models/user_model.dart';

class Chat {
  final User user;
  final String text;
  final String pending;

  Chat({
    this.user, 
    this.text, 
    this.pending
  });

  Chat.fromJson(Map<String, dynamic> json)
    : user = json['user'],
      text = json['text'],
      pending = json['pending'];
}