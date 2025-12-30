import 'dart:convert';
import 'package:http/http.dart' as http;

class OtpRateLimiter {
  static const String _baseUrl = 'https://jordancarpart.com/Api';

  /// Check if phone number is allowed to request OTP
  static Future<Map<String, dynamic>> checkOtpLimit(String phone) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/check_otp_limit.php?phone=$phone');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'فشل التحقق من الحد المسموح',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال',
      };
    }
  }

  /// Log OTP send attempt
  static Future<Map<String, dynamic>> logOtpAttempt(String phone) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/log_otp_attempt.php');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'فشل تسجيل المحاولة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال',
      };
    }
  }

  /// Format remaining time in Arabic
  static String formatRemainingTime(int seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();

    String result = '\u200f';
    if (hours > 0) {
      result += '$hours ساعة';
    }
    if (minutes > 0) {
      if (hours > 0) result += ' و ';
      result += '$minutes دقيقة';
    }

    return result == '\u200f' ? 'أقل من دقيقة' : result;
  }
}
