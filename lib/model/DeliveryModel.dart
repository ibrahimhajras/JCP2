class DeliveryModel {
  double? _cost;
  bool? _active;

  double get cost => _cost!;
  bool get active => _active!;

  DeliveryModel.fromJson(json) {
    _cost = double.parse(json['cost'].toString());
    _active = json['active'];
  }

  DeliveryModel.data({
    bool? active,
    double? cost,
  }) {
    this._active = active;
    this._cost = cost;
  }
  Map<String, Object?> toMap() => {
    "cost": _cost,
    "active": _active,
  };
}
