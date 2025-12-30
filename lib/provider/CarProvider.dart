import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CarProvider with ChangeNotifier {
  List<String> carNames = [];
  List<String> categories = ['الفئة'];
  String? selectedCar;
  String? userId;
  bool isChassisRequired = false; // لتخزين حالة رقم الشاصي للفئة المختارة

  Future<void> fetchCars(String userId) async {
    this.userId = userId;
    try {
      final response = await http.get(
          Uri.parse('https://jordancarpart.com/Api/get_allowed_cars.php?user_id=$userId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          carNames = ['المركبة'] + List<String>.from(data['data']);
          notifyListeners();
        } else {
          carNames = ['المركبة'];
          notifyListeners();

        }
      }
    } catch (e) {

      carNames = ['المركبة'];
      notifyListeners();
    }
  }

  // تحديث fetchCategories لتستقبل user_id
  Future<void> fetchCategories(String carName) async {
    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse('https://jordancarpart.com/Api/get_allowed_categories2.php?car_name=$carName&user_id=$userId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> categoriesData = data['data'];
          categories = ['الفئة'] + categoriesData.map((cat) => cat['category_name'].toString()).toList();
          notifyListeners();
        } else {
          categories = ['الفئة'];
          notifyListeners();

        }
      }
    } catch (e) {
      categories = ['الفئة'];
      notifyListeners();
    }
  }

  Future<void> checkChassisRequirement(String carName, String categoryName) async {
    if (userId == null) return;

    try {
      final response = await http.get(
          Uri.parse('https://jordancarpart.com/Api/get_allowed_categories2.php?car_name=$carName&user_id=$userId')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          List<dynamic> categoriesData = data['data'];
          var selectedCategory = categoriesData.firstWhere(
                  (cat) => cat['category_name'] == categoryName,
              orElse: () => {'is_chassis_required': 0}
          );
          isChassisRequired = selectedCategory['is_chassis_required'] == 1 ||
              selectedCategory['is_chassis_required'] == '1';
          notifyListeners();
        }
      }
    } catch (e) {
      isChassisRequired = false;
      notifyListeners();
    }
  }

  void selectCar(String carName) {
    selectedCar = carName;
    isChassisRequired = false; // إعادة تعيين عند تغيير السيارة
    notifyListeners();
    if (carName != 'المركبة') {
      fetchCategories(carName);
    }
  }

  void reset() {
    carNames = [];
    categories = ['الفئة'];
    selectedCar = null;
    userId = null;
    isChassisRequired = false;
    notifyListeners();
  }
}