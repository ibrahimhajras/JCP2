class JoinTraderModel {
  final String fName; // First Name
  final String lName; // Last Name
  final String store; // Store Name
  final String phone; // Phone Number
  final String full_address; // Full Address
  final List<dynamic> master; // List of master items (could be cars, items)
  final List<dynamic>
      parts_type; // List of parts types (like 'ميكانيك', 'بودي')
  final List<dynamic>
      activity_type; // List of activities (like 'تجاري', 'شركة')

  JoinTraderModel({
    required this.fName,
    required this.lName,
    required this.store,
    required this.phone,
    required this.full_address,
    required this.master,
    required this.parts_type,
    required this.activity_type,
  });

  // Optionally, you can add a factory constructor to initialize the model from JSON
  factory JoinTraderModel.fromJson(Map<String, dynamic> json) {
    return JoinTraderModel(
      fName: json['fName'] ?? '',
      lName: json['lName'] ?? '',
      store: json['store'] ?? '',
      phone: json['phone'] ?? '',
      full_address: json['full_address'] ?? '',
      master: json['master'] ?? [],
      parts_type: json['parts_type'] ?? [],
      activity_type: json['activity_type'] ?? [],
    );
  }

  // Optionally, you can add a method to convert the model back to JSON
  Map<String, dynamic> toJson() {
    return {
      'fName': fName,
      'lName': lName,
      'store': store,
      'phone': phone,
      'full_address': full_address,
      'master': master,
      'parts_type': parts_type,
      'activity_type': activity_type,
    };
  }
}
