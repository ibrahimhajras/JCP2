class CommentModel {
  final String title;
  final String comment;
  final String name;
  final String address;
  final String uid;
  final String phone;
  final DateTime time;

  CommentModel({
    required this.title,
    required this.comment,
    required this.name,
    required this.address,
    required this.uid,
    required this.phone,
    required this.time,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      title: json['title'] as String,
      comment: json['comment'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      uid: json['uid'] as String,
      phone: json['phone'] as String,
      time: DateTime.parse(json['time'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'comment': comment,
      'name': name,
      'address': address,
      'uid': uid,
      'phone': phone,
      'time': time.toIso8601String(),
    };
  }
}
