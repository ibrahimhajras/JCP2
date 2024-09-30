import 'package:flutter/material.dart';
import 'package:jcp/model/JoinTraderModel.dart';

class ProfileTraderProvider with ChangeNotifier {
  JoinTraderModel? _trader;

  JoinTraderModel? get trader => _trader;

  // تحديث بيانات التاجر
  void setTrader(JoinTraderModel trader) {
    _trader = trader;
    notifyListeners(); // تحديث المستمعين عند تغيير البيانات
  }

  // إعادة تعيين بيانات التاجر (تسجيل خروج أو مسح البيانات)
  void clearTrader() {
    _trader = null;
    notifyListeners();
  }
}
