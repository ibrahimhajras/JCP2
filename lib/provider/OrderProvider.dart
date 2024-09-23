import 'package:flutter/material.dart';
import 'package:jcp/model/OrderModel.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];

  List<OrderModel> get orders => _orders;

  void setOrders(List<OrderModel> newOrders) {
    _orders = newOrders;
    notifyListeners();
  }

  void addOrder(OrderModel order) {
    _orders.add(order);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
