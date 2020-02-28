import 'package:matching_tantan_app/models/user_model.dart';

class Message {
  final User sender;
  final String time;
  final String text;
  final bool unRead;
  final int order;
  final String date;
  final String timeline;

  Message({
    this.sender,
    this.time,
    this.text,
    this.unRead,
    this.order,
    this.date,
    this.timeline,
  });

  Message.fromJson(Map<String, dynamic> json)
    : sender = json['sender'],
      time = json['time'],
      text = json['text'],
      unRead = json['unRead'],
      order = json['order'],
      date = json['date'],
      timeline = json['timeline'];
}

// YOU - current user
final User currentUser = User(
  id: '0',
  name: "mohamed",
  imageUrl: "assets/images/man1.jpg"
);

// users
final User user1 = User(
  id: '1',
  name: "isco1",
  imageUrl: "assets/images/man2.jpg"
);

final User user2 = User(
  id: '2',
  name: "isco2",
  imageUrl: "assets/images/man3.jpg"
);

final User user3 = User(
  id: '3',
  name: "isco3",
  imageUrl: "assets/images/man5.png"
);

final User user4 = User(
  id: '4',
  name: "isco4",
  imageUrl: "assets/images/man7.jpg"
);

final User user5 = User(
  id: '5',
  name: "isco5",
  imageUrl: "assets/images/man8.png"
);

final User user6 = User(
  id: '6',
  name: "isco6",
  imageUrl: "assets/images/woman1.jpg"
);

final User user7 = User(
  id: '7',
  name: "isco7",
  imageUrl: "assets/images/woman2.png"
);

final User user8 = User(
  id: '8',
  name: "isco8",
  imageUrl: "assets/images/woman3.jpg"
);

final User user9 = User(
  id: '9',
  name: "isco9",
  imageUrl: "assets/images/man1.jpg"
);

// Matche contacts
List<User> users = [user1, user2, user3, user4, user5, user6, user7, user8, user9];
List<User> favorites = [user3, user7, user8, user9];

List<Message> chats = [
  Message(sender: user2, text: 'Hi', time: '1st of Jan, 2020', unRead: false),
  Message(sender: user2, text: 'Hi', time: '1st of Jan, 2020', unRead: false),
  Message(sender: user1, text: 'Hi', time: '1st of Jan, 2020', unRead: false),
  Message(sender: user1, text: 'Hi', time: '1st of Jan, 2020', unRead: false),
];