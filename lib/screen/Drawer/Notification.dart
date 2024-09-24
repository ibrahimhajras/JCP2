import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/Inallpage/CustomHeader.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> updatedNotifications =
        storedNotifications.map((notification) {
      Map<String, dynamic> notificationMap =
          Map<String, dynamic>.from(jsonDecode(notification));

      if (!notificationMap['isRead']) {
        notificationMap['isRead'] = true;
      }
      return notificationMap;
    }).toList();

    setState(() {
      notifications = updatedNotifications;
    });

    // تحديث قائمة الإشعارات في SharedPreferences
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
    await prefs.setStringList('notifications', updatedNotificationsString);
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
          notifications.isNotEmpty
              ? _buildNotificationList(size)
              : Center(
                  child: CustomText(
                    text: "لا توجد إشعارات جديدة",
                    color: Colors.grey,
                    size: size.height * 0.02,
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

  Widget _buildNotificationList(Size size) {
    return Expanded(
      child: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index], index, size);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, int index, Size size) {
    RegExp regExp = RegExp(r"\d+");
    String message = notification['message'] ?? " ";
    Iterable<Match> matches = regExp.allMatches(message);
    String number = matches.isNotEmpty ? matches.first.group(0) ?? "" : "";

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
                        text: "تم تأكيد طلب رقم ",
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
