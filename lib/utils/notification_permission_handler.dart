import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../style/colors.dart' as app_colors;

class NotificationPermissionHandler {
  /// Checks and requests notification permissions following Apple's guidelines.
  /// 
  /// 1. Only shows system dialog if never requested.
  /// 2. Shows a custom explanation dialog (Soft Prompt) before requesting.
  /// 3. If denied/permanently denied, shows a custom dialog to open settings.
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isGranted) {
      return;
    }

    if (status.isDenied) {
      // Status is denied, meaning it hasn't been requested or the user said no but can be asked again.
      // On iOS, this is the state before the system dialog is shown for the first time.
      bool? userAcceptedSoftPrompt = await _showSoftPrompt(context);
      
      if (userAcceptedSoftPrompt == true) {
        // Trigger system dialog
        PermissionStatus newStatus = await Permission.notification.request();
        
        // If the status is still denied or permanently denied after the request, 
        // it means they rejected the system dialog. 
        // We don't necessarily show the settings dialog immediately here unless requested.
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      // On iOS, once the user says "Don't Allow" in the system dialog, it becomes permanently denied.
      await _showSettingsDialog(context);
    }
  }

  static Future<bool?> _showSoftPrompt(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "تفعيل التنبيهات",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active, size: 50, color: app_colors.red),
              const SizedBox(height: 15),
              const Text(
                "يرجى تفعيل التنبيهات لتبقى على اطلاع بآخر تحديثات طلباتك والعروض الحصرية.",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("ليس الآن", style: TextStyle(color: Colors.grey, fontFamily: 'Tajawal')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("تفعيل", style: TextStyle(color: Colors.white, fontFamily: 'Tajawal')),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            "التنبيهات معطلة",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "لقد قمت بتعطيل التنبيهات مسبقاً. يرجى تفعيلها من إعدادات الهاتف لتلقي التحديثات.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("إلغاء", style: TextStyle(color: Colors.grey, fontFamily: 'Tajawal')),
            ),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: app_colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("الإعدادات", style: TextStyle(color: Colors.white, fontFamily: 'Tajawal')),
            ),
          ],
        );
      },
    );
  }
}
