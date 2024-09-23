import 'package:flutter/material.dart';

class DeliveryModelOrange with ChangeNotifier {
  int _deliveryCost = 0;

  int get deliveryCost => _deliveryCost;

  void updateDeliveryCost(String deliveryOption,
      {int deliveryNormalCost = 0, int deliveryNowCost = 0}) {
    switch (deliveryOption) {
      case 'فوري':
        _deliveryCost = deliveryNowCost; // Use deliveryNowCost for "فوري"
        break;
      case '24 ساعة':
        _deliveryCost =
            deliveryNormalCost; // Use deliveryNormalCost for "24 ساعة"
        break;
      case 'استلام من المحل':
        _deliveryCost = 0; // No delivery cost for "استلام من المحل"
        break;
      default:
        _deliveryCost = 0;
        break;
    }
    notifyListeners();
  }

  void clear() {
    _deliveryCost = 0;
    notifyListeners(); // إبلاغ المستمعين بالتغيير
  }
}
