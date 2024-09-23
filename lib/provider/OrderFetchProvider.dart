import 'package:flutter/material.dart';

enum FetchState { idle, loading, loaded, error }

class OrderFetchProvider with ChangeNotifier {
  FetchState _state = FetchState.idle;

  FetchState get state => _state;

  void setState(FetchState state) {
    _state = state;
    notifyListeners();
  }
}
