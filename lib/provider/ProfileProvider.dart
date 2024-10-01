import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  String user_id = '';
  String phone = '';
  String password = '';
  String name = '';
  String type = '';
  String city = '';
  DateTime _createdAt = DateTime.now(); // Added created_at field
  String token = '';

  String getcity() => city;

  void setcity(String city) {
    this.city = city;
    notifyListeners();
  }

  String getname() => name;

  void setname(String name) {
    this.name = name;
    notifyListeners();
  }

  String gettype() => type;

  void settype(String type) {
    this.type = type;
    notifyListeners();
  }

  String getpassword() => password;

  void setpassword(String password) {
    this.password = password;
    notifyListeners();
  }

  String getphone() => phone;

  void setphone(String phone) {
    this.phone = phone;
    notifyListeners();
  }

  String getuser_id() => user_id;

  void setuser_id(String user_id) {
    this.user_id = user_id;
    notifyListeners();
  }

  String gettoken() => token;

  void settoken(String token) {
    this.token = token;
    notifyListeners();
  }

  DateTime getcreatedAt() => _createdAt;

  void setcreatedAt(DateTime _createdAt) {
    this._createdAt = _createdAt;
    notifyListeners();
  }

  void resetFields() {
    setuser_id('');
    setphone('');
    setpassword('');
    setname('');
    settype('');
    setcity('');
    settoken('');
    setcreatedAt(DateTime.now());
    notifyListeners();
  }
}
