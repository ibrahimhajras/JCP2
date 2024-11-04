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
      } else {
        print('Failed to fetch notifications: ${responseData['message']}');
      }
    } else {
      print('Failed to fetch notifications. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching notifications: $e");
  }
}

void _createNotification(Map<String, dynamic> notification) async {
  final notificationService = NotificationService(); // استخدم NotificationService
  String body = notification['desc'];

  // تعيين قيمة افتراضية للـ payload
  String payload = '/defaultPage'; // يمكن تعديل هذه القيمة حسب الحاجة

  // استخراج رقم الطلب من النص
  RegExp regex = RegExp(r'\d+');
  Match? match = regex.firstMatch(body);
  String? orderId = match?.group(0);

  // تحديد الـ payload بناءً على محتوى body
  if (body.contains('تم تسعير طلب خاص')) {
    payload = '/privatePricingOrder/$orderId';
  } else if (body.contains('تم تسعير طلب')) {
    payload = '/pricingOrder/$orderId';
  } else if (body.contains('استلام')) {
    payload = '/newOrder/$orderId';
  } else {
    payload = '/orderDetails/$orderId';
  }

  // عرض الإشعار مع الـ payload المحدد
  notificationService.showNotification(
    id: notification['id'],
    title: 'قطع سيارات الاردن',
    body: body,
    payLoad: payload,
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
