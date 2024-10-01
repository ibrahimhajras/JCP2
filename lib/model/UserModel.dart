class UserModel {
  final String userId;
  final String phone;
  final String password;
  final String name;
  final String type;
  final String city;
  final DateTime createdAt; // Added created_at field
  final String token; // Added created_at field

  UserModel({
    required this.userId,
    required this.phone,
    required this.password,
    required this.name,
    required this.type,
    required this.city,
    required this.createdAt, // Added created_at field to constructor.
    required this.token, // Added created_at field to constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'].toString(),
      phone: json['phone'].toString(),
      password: json['password'].toString(),
      name: json['name'].toString(),
      type: json['type'].toString(),
      city: json['city'].toString(),
      createdAt: DateTime.parse(json['created_at']),
      token: json['token'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone': phone,
      'password': password,
      'name': name,
      'type': type,
      'city': city,
      'created_at': createdAt.toIso8601String(),
      'token': token,
    };
  }
}
