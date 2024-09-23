import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  Timer? _timer;

  void startNotificationCheck(String userId) {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchNotifications(userId);
    });
  }

  void stopNotificationCheck() {
    _timer?.cancel();
  }

  Future<void> fetchNotifications(String userId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/notifications.php?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> notifications = responseData['data'];
          for (var notification in notifications) {
            _createNotification(notification);
            print(notifications);
          }
          _storeNotifications(notifications);
          print(notifications);
        }
      } else {
        print(
            'Failed to fetch notifications. Status code: ${response.statusCode}');
        print("3");

      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void _createNotification(Map<String, dynamic> notification) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notification['id'],
        channelKey: 'basic_key',
        title: 'Notification',
        body: notification['desc'],
        bigPicture: "asset://assets/images/app_logo.png",
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }

  Future<void> _storeNotifications(List<dynamic> notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    for (var notification in notifications) {
      storedNotifications.add(jsonEncode({
        'id': notification['id'],
        'message': notification['desc'],
        'isRead': false,
      }));
    }

    await prefs.setStringList('notifications', storedNotifications);
    print("Notifications stored successfully in SharedPreferences.");
  }
}
