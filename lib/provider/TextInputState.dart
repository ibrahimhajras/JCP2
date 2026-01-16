import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';

class TextInputState extends ChangeNotifier {
  Color _borderColor = grey;

  Color get borderColor => _borderColor;

  void setBorderColor(Color color) {
    _borderColor = color;
    notifyListeners();
  }

  void clear() {
    _borderColor = grey;
    notifyListeners();
  }
}
