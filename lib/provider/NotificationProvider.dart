import 'package:flutter/foundation.dart';
import 'dart:async';

class NotificationProvider with ChangeNotifier {
  List<String> _notifications = [];

  final StreamController<List<String>> _notificationsStreamController =
      StreamController<List<String>>.broadcast();

  List<String> get notifications => _notifications;

  // getter للـ Stream
  Stream<List<String>> get notificationsStream =>
      _notificationsStreamController.stream;

  void addNotification(String notification) {
    _notifications.add(notification);
    _notificationsStreamController.sink.add(_notifications);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationsStreamController.close();
    super.dispose();
  }
}
