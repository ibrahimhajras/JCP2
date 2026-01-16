import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  int _totalCheckboxDataItems = 0;

  List<Map<String, dynamic>> get products => _products;
  int get totalCheckboxDataItems => _totalCheckboxDataItems;

  Future<void> loadProducts(String userId) async {
    try {
      _calculateTotalPriceAmountAndCheckboxItems();
      notifyListeners();
    } catch (e) {
      
    }
  }

  Future<int> fetchTotalParts(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
      'http://jordancarpart.com/Api/get_total_parts.php?user_id=$userId&token=$token',
    );

    final response = await http.get(url);
    

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('total')) {
        return jsonResponse['total'] as int;
      } else {
        throw Exception('Key "total" not found in response: ${response.body}');
      }
    } else {
      throw Exception('Failed to load total. Status code: ${response.statusCode}');
    }
  }

  void _calculateTotalPriceAmountAndCheckboxItems() {
    _totalCheckboxDataItems = 0;
    for (var product in _products) {
      if (product.containsKey('checkboxData') &&
          product['checkboxData'] != null &&
          product['checkboxData'] is List) {
        _totalCheckboxDataItems += (product['checkboxData'] as List).length;
      }
    }
    notifyListeners(); // <- أضف هذا إذا لم يكن موجودًا
  }

}
