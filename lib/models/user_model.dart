class User {
  final String id;
  final String name;
  final String imageUrl;
  final String timeZone;

  User({
    this.id,
    this.name,
    this.imageUrl,
    this.timeZone,
  });

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      imageUrl = json['photo'],
      timeZone = json['timeZone'];
}
