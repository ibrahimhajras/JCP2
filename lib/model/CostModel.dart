import 'package:jcp/model/DeliveryModel.dart';

class CostModel {
  DeliveryModel? _normal;
  DeliveryModel? _now;
  DeliveryModel? _shop;

  DeliveryModel get normal => _normal!;
  DeliveryModel get now => _now!;
  DeliveryModel get shop => _shop!;

  CostModel.copy({
    DeliveryModel? normal,
    DeliveryModel? now,
    DeliveryModel? shop,
  }) {
    this._normal = normal;
    this._now = now;
    this._shop = shop;
  }

  Map<String, Object?> toMap() => {
    "normal": normal.toMap(),
    "now": now.toMap(),
    "shop": shop.toMap(),
  };
}
