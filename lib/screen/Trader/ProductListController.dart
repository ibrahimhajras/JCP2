import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductListController {
  final ScrollController scrollController = ScrollController();
  List<Map<String, dynamic>> products = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  final int itemsPerPage = 20;

  void dispose() {
    scrollController.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchFilteredProducts({
    required String userId,
    String searchQuery = '',
    String category = '',
    String carName = '',
    String fuelType = '',
    String partCondition = '',
    int page = 1,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, String> params = {
      'user_id': userId,
      'token': token ?? '',
      'page': page.toString(),
      'limit': itemsPerPage.toString(),
      if (searchQuery.isNotEmpty) 'search': searchQuery,
      if (category.isNotEmpty) 'category': category,
      if (carName.isNotEmpty) 'car_name': carName,
      if (fuelType.isNotEmpty) 'fuel_type': fuelType,
      if (partCondition.isNotEmpty) 'condition': partCondition,
    };

    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/getproduct2.php')
            .replace(queryParameters: params),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {

      return [];
    }
  }
  Future<void> resetFilters({
    required String userId,
    String searchQuery = '',
    String category = '',
    String carName = '',
    String fuelType = '',
    String partCondition = '',
  }) async {
    // Reset pagination state
    currentPage = 1;
    hasMore = true;
    isLoading = false;

    // Clear existing products
    products.clear();

    // Load fresh data with new filters
    try {
      final newProducts = await fetchFilteredProducts(
        userId: userId,
        searchQuery: searchQuery,
        category: category,
        carName: carName,
        fuelType: fuelType,
        partCondition: partCondition,
        page: currentPage,
      );

      products.addAll(newProducts);
      hasMore = newProducts.length >= itemsPerPage;
    } catch (e) {

      // You might want to handle this error in your UI
    }
  }

  Future<void> loadMoreProducts({
    required String userId,
    String searchQuery = '',
    String category = '',
    String carName = '',
    String fuelType = '',
    String partCondition = '',
  }) async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    try {
      final newProducts = await fetchFilteredProducts(
        userId: userId,
        searchQuery: searchQuery,
        category: category,
        carName: carName,
        fuelType: fuelType,
        partCondition: partCondition,
        page: currentPage + 1,
      );

      if (newProducts.isNotEmpty) {
        currentPage++;
        products.addAll(newProducts);
        hasMore = newProducts.length >= itemsPerPage;
      } else {
        hasMore = false;
      }
    } catch (e) {

    } finally {
      isLoading = false;
    }
  }
}