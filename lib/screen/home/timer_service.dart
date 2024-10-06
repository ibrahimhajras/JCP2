import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jcp/NotificationService.dart';

// دالة startTimer
void startTimer() {
  Timer.periodic(const Duration(seconds: 20), (timer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    if (userId != null) {
      await fetchNotifications(userId);
      print('Notifications fetched successfully');
    } else {
      print("userId is null. Cannot fetch notifications.");
    }
  });
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
        await _storeNotifications(notifications);
        for (var notification in notifications) {
          _createNotification(notification);
        }
      } else {}
    } else {}
  } catch (e) {
    print("Error fetching notifications: $e");
  }
}

void _createNotification(Map<String, dynamic> notification) {
  NotificationService().showNotification(
    id: notification['id'],
    title: 'قطع سيارات الاردن',
    body: notification['desc'],
  );
}

Future<void> _storeNotifications(List<dynamic> notifications) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> storedNotifications = prefs.getStringList('notifications') ?? [];
  Set<String> existingIds =
      storedNotifications.map((n) => jsonDecode(n)['id'].toString()).toSet();
  for (var notification in notifications) {
    if (!existingIds.contains(notification['id'].toString())) {
      storedNotifications.add(jsonEncode({
        'id': notification['id'],
        'message': notification['desc'],
        'isRead': false,
      }));
    }
  }

  await prefs.setStringList('notifications', storedNotifications);
}