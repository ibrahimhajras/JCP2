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
    return Card(
      color: grey,
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
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    notification['message'] ?? " ",
                    style: TextStyle(
                      fontSize: size.height * 0.02,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
}
