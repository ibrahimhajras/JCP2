import 'package:flutter/material.dart';

class EditProductProvider extends ChangeNotifier {
  Map<int, bool> _isEditing = {};

  // التحقق مما إذا كان المنتج قيد التحرير
  bool isEditing(int productId) {
    return _isEditing[productId] ?? false;
  }

  // تبديل حالة التحرير للمنتج
  void toggleEdit(int productId) {
    _isEditing[productId] = !(_isEditing[productId] ?? false);
    notifyListeners();
  }

  // حفظ المنتج وإيقاف حالة التحرير
  void saveProduct(int productId) {
    _isEditing[productId] = false;
    notifyListeners();
  }

  // دالة لتصفير جميع المنتجات وحالة التحرير
  void clear() {
    _isEditing.clear();  // مسح جميع الحالات المخزنة
    notifyListeners();   // إبلاغ المستمعين بأن البيانات قد تغيرت
  }
}
