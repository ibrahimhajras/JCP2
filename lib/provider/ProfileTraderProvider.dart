import 'package:flutter/material.dart';
import 'package:jcp/model/JoinTraderModel.dart';

class ProfileTraderProvider with ChangeNotifier {
  JoinTraderModel? _trader;

  JoinTraderModel? get trader => _trader;

  // تحديث بيانات التاجر
  void setTrader(JoinTraderModel trader) {
    _trader = trader;
    notifyListeners();
  }

  void clearTrader() {
    _trader = null;
    notifyListeners();
  }
}
