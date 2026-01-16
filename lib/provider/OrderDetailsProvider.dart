import 'package:flutter/material.dart';

class OrderDetailsProvider extends ChangeNotifier {
  List<int> _selectedPrices = [];
  double _selectedDeliveryCost = 0.0;

  double get totalCost =>
      _selectedPrices.fold(0, (sum, price) => sum + price) +
          _selectedDeliveryCost;

  List<int> get selectedPrices => _selectedPrices;

  double get selectedDeliveryCost => _selectedDeliveryCost;

  void togglePrice(int price) {
    if (_selectedPrices.contains(price)) {
      _selectedPrices.remove(price);
    } else {
      _selectedPrices.add(price);
    }
    notifyListeners();
  }

  void setDeliveryCost(double cost) {
    _selectedDeliveryCost = cost;
    notifyListeners();
  }

  void clear() {
    _selectedPrices.clear();  // مسح جميع الأسعار المختارة
    _selectedDeliveryCost = 0.0;  // إعادة تعيين تكلفة التوصيل
    notifyListeners();  // إبلاغ الـ Widgets بالتحديث
  }
}
