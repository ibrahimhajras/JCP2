class OrderModel {
  final int id;
  final String carId;
  final String time;
  final int type;
  final int state;

  OrderModel({
    required this.id,
    required this.carId,
    required this.time,
    required this.type,
    required this.state,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      carId: json['carid'],
      time: json['time'],
      type: json['type'],
      state: json['state'],
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, carId: $carId, time: $time, type: $type, state: $state)';
  }
}
