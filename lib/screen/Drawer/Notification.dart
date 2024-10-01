import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../widget/Inallpage/CustomHeader.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNotifications(); // تأكد من استدعاء هذه الوظيفة هنا
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        } else {}
      } else {}
    } catch (e) {}
  }

  Future<void> _storeNotifications(List<dynamic> notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

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

    List<String> currentStoredNotifications =
        prefs.getStringList('notifications') ?? [];
    print("Current stored notifications: $currentStoredNotifications");
  }

  Stream<List<Map<String, dynamic>>> _notificationStream() async* {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    while (true) {
      List<Map<String, dynamic>> updatedNotifications =
          storedNotifications.map((notification) {
        Map<String, dynamic> notificationMap =
            Map<String, dynamic>.from(jsonDecode(notification));
        notificationMap['isRead'] = true; // مثال على تعديل البيانات
        return notificationMap;
      }).toList();

      // إعادة النتائج عن طريق yield
      yield updatedNotifications;

      // يمكنك ضبط التحديث بعد فترة زمنية معينة إذا لزم الأمر
      await Future.delayed(
          Duration(seconds: 5)); // على سبيل المثال، تحديث كل 5 ثوانٍ
    }
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    if (storedNotifications.isNotEmpty) {
      print(
          "Loaded notifications from SharedPreferences: $storedNotifications");
    } else {
      print("No notifications found.");
    }

    List<Map<String, dynamic>> updatedNotifications =
        storedNotifications.map((notification) {
      Map<String, dynamic> notificationMap =
          Map<String, dynamic>.from(jsonDecode(notification));

      // تحديث حالة الإشعار عند تحميله
      notificationMap['isRead'] = true;
      return notificationMap;
    }).toList();

    // تحقق من محتويات الإشعارات بعد فك الترميز
    print("Decoded notifications: $updatedNotifications");

    setState(() {
      notifications = updatedNotifications;
    });

    // تحديث الإشعارات في SharedPreferences
    List<String> updatedNotificationsString = updatedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();
    await prefs.setStringList('notifications', updatedNotificationsString);
  }

  Future<void> _deleteNotification(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      notifications.removeAt(index);
    });

    List<String> updatedNotificationsString =
        notifications.map((notification) => jsonEncode(notification)).toList();

    if (updatedNotificationsString.isNotEmpty) {
      await prefs.setStringList('notifications', updatedNotificationsString);
    } else {
      await prefs
          .remove('notifications'); // احذف المفتاح إذا لم يكن هناك إشعارات
    }
    print("Notification deleted successfully.");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          SizedBox(height: size.height * 0.01),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notificationStream(), // الربط مع الدالة التي تعيد stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: RotatingImagePage());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: "لا توجد إشعارات جديدة",
                      color: Colors.grey,
                      size: size.height * 0.02,
                    ),
                  );
                }

                // عرض الإشعارات
                List<Map<String, dynamic>> notifications = snapshot.data!;
                return _buildNotificationList(notifications, size);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return CustomHeader(
      size: size,
      title: "الإشعارات",
      notificationIcon: SizedBox.shrink(),
      menuIcon: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          color: white,
          size: size.width * 0.06,
        ),
      ),
    );
  }

  Widget _buildNotificationList(
      List<Map<String, dynamic>> notifications, Size size) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationCard(
            notifications[notifications.length - 1 - index], index, size);
      },
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, int index, Size size) {
    RegExp regExp = RegExp(r"\d+");
    String message = notification['message'] ?? " ";
    Iterable<Match> matches = regExp.allMatches(message);
    String number = matches.isNotEmpty ? matches.first.group(0) ?? "" : "";
    String messageWithoutNumber = message
        .replaceFirst(number, '') // إزالة الرقم
        .replaceAll(':', '') // إزالة علامة ":"
        .trim(); // إزالة المسافات الزائدة

    return Card(
      color: white,
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
        horizontal: size.width * 0.04,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(size.width * 0.03),
      ),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.02,
          horizontal: size.width * 0.04,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$messageWithoutNumber ",
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: number, // عرض الرقم
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                          fontWeight: FontWeight.bold,
                          color: notification['type'] == "تأكيد"
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification['type'] == "تأكيد"
                    ? Colors.green
                    : Colors.orange,
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                notification['type'] == "تأكيد"
                    ? "assets/images/green.png"
                    : "assets/images/orange.png",
                width: size.width * 0.09,
                height: size.height * 0.04,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildMessageWithColoredNumbers(List<String> messageParts,
      List<String> numbers, Color numberColor, double fontSize) {
    List<TextSpan> spans = [];
    for (int i = 0; i < messageParts.length; i++) {
      // أضف الجزء النصي
      spans.add(TextSpan(text: messageParts[i]));
      // أضف الرقم بلون مختلف إذا كان موجوداً
      if (i < numbers.length) {
        spans.add(TextSpan(
          text: numbers[i],
          style: TextStyle(
            color: numberColor, // اللون المخصص للأرقام بناءً على نوع الإشعار
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ));
      }
    }
    return spans;
  }
}
