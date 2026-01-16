import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Inallpage/showConfirmationDialog.dart' show showConfirmationDialog;

class Update {
  static Future<void> checkAndUpdate(BuildContext context) async {
    bool isMaintenanceMode = await checkMaintenanceStatus();
    final prefs = await SharedPreferences.getInstance();
    String? savedPhone = prefs.getString('phone')?.replaceAll('+962', '');

    if (savedPhone == "781771234" || savedPhone == "0781771234") {
      return; // ما يعمل أي popup
    }

    if (isMaintenanceMode) {
      _showMaintenanceDialog(context);
      return;
    }

    String? localVersion = await getLocalVersion();
    String? serverVersion = await getServerVersion();

    if (localVersion != null &&
        serverVersion != null &&
        localVersion.trim() != serverVersion.trim()) {
      showConfirmationDialog(
        context: context,
        message:
            "يوجد تحديث جديد للتطبيق. يرجى التحديث للاستفادة من الميزات الجديدة",
        confirmText: "حدّث الآن",
        onConfirm: () {
          final url = Platform.isAndroid
              ? "https://play.google.com/store/apps/details?id=com.zaid.Jcp.car"
              : "https://apps.apple.com/app/id6737844846";
          launchUrl(Uri.parse(url));
        },
        cancelText: "أغلاق",
        onCancel: () {
          exit(0);
        },
        preventDismissal: true,
      );
    }
  }

  static Future<bool> checkMaintenanceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/admin/maintenance_check.php'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['maintenance_mode'] == true ||
              data['maintenance_mode'] == 1;
        }
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static void _showMaintenanceDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction,
                  size: 60,
                  color: red,
                ),
                SizedBox(height: 15),
                Text(
                  "التطبيق تحت الصيانة حالياً",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal",
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "نعتذر عن الإزعاج نحن نعمل على تحسين الخدمة\nيرجى المحاولة لاحقاً",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Tajawal",
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  " 🛠️ شكراً لصبركم",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "Tajawal",
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    exit(0); // إغلاق التطبيق
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  ),
                  child: Text(
                    "إغلاق التطبيق",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Tajawal",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<String?> getLocalVersion() async {
    try {
      final String buildVersion = await rootBundle.loadString(
        'assets/version.txt',
      );
      return buildVersion.trim();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getServerVersion() async {
    final url = Uri.parse('https://jordancarpart.com/Api/getversion.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['version'] != null) {
          return data['version']['mobileversion'].toString();
        }
      }
    } catch (e) {}
    return null;
  }
}
