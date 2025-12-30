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
      // Native system dialog will not show up again on iOS.
      // Show custom dialog with "Go to Settings".
      _showSettingsDialog(context);
    } else {
      // status is notDetermined (never asked).
      // Show native system prompt directly.
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(
          text: "التنبيهات معطلة",
          size: 18,
          fontWeight: FontWeight.bold,
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
