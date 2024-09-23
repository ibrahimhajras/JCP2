import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ProductProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  int _totalCheckboxDataItems = 0;


  List<Map<String, dynamic>> get products => _products;
  int get totalCheckboxDataItems => _totalCheckboxDataItems;


  Future<void> loadProducts(String userId) async {
    try {
      _products = await fetchProducts(userId);
      _calculateTotalPriceAmountAndCheckboxItems();
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    final url = Uri.parse('http://jordancarpart.com/Api/getproduct2.php?user_id=$userId');
    final response = await http.get(
      url,
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load products: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load products. Status code: ${response.statusCode}');
    }
  }

  void _calculateTotalPriceAmountAndCheckboxItems() {
    _totalCheckboxDataItems = 0;
    for (var product in _products) {
      if (product.containsKey('checkboxData') && product['checkboxData'] != null && product['checkboxData'] is List) {
        _totalCheckboxDataItems += (product['checkboxData'].length as int);
      }
    }
  }
}
