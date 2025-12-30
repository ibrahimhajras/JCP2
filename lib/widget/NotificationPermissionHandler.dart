import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/style/colors.dart';

class NotificationPermissionHandler {
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      // Already granted, no action needed.
      return;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      // Permission has been denied or permanently denied.
      // Show custom dialog with "Go to Settings".
      _showSettingsDialog(context);
    } else {
      // status is notDetermined (never asked).
      // Show explanation dialog first.
      _showExplanationDialog(context);
    }
  }

  static void _showExplanationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: "تفعيل التنبيهات",
          size: 18,
          weight: FontWeight.bold,
        ),
        content: CustomText(
          text: "يرجى تفعيل التنبيهات للحصول على آخر التحديثات والطلبات الجديدة فور وصولها.",
          size: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(text: "لاحقاً", color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
                alert: true,
                badge: true,
                sound: true,
              );
              
              if (settings.authorizationStatus == AuthorizationStatus.denied) {
                // User denied it in the system dialog.
                // Next time they click, it will trigger the settings dialog.
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: red),
            child: CustomText(text: "تفعيل", color: Colors.white),
          ),
        ],
      ),
    );
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: "التنبيهات معطلة",
          size: 18,
          weight: FontWeight.bold,
        ),
        content: CustomText(
          text: "التنبيهات معطلة من إعدادات النظام. يرجى تفعيلها من الإعدادات لاستلام التحديثات.",
          size: 16,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(text: "إلغاء", color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: red),
            child: CustomText(text: "الإعدادات", color: Colors.white),
          ),
        ],
      ),
    );
  }
}
