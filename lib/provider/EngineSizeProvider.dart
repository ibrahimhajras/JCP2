import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EngineSizeProvider extends ChangeNotifier {
  List<String> _engineSizes = [];
  bool _isLoading = false;
  String _error = '';

  List<String> get engineSizes => _engineSizes;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchEngineSizes() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/get_engine_sizes.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _engineSizes = List<String>.from(data['data'].map((item) => item['engine_size']));
        } else {
          _error = 'فشل في جلب أحجام المحرك: ${data['message']}';
        }
      } else {
        _error = 'خطأ في الاتصال بالخادم';
      }
    } catch (e) {
      _error = 'خطأ: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _engineSizes = [];
    _error = '';
    _isLoading = false;
    notifyListeners();
  }
}