import 'dart:async';
import 'package:flutter/material.dart';

class CountdownProvider with ChangeNotifier {
  late Timer _timer;
  String countdownText = "24 : 00 : 00"; // نص افتراضي للعد التنازلي
  DateTime lastOrderTime = DateTime.now();
  Duration countdownDuration = Duration(hours: 24); // مدة العد التنازلي

  void startCountdown(DateTime orderTime) {
    lastOrderTime = orderTime;
    _updateCountdown(); // تحديث النص لأول مرة
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remainingTime =
          lastOrderTime.add(countdownDuration).difference(now);

      if (remainingTime.isNegative) {
        _timer.cancel();
        countdownText = "00 : 00 : 00"; // تحديث النص عندما ينتهي الوقت
        notifyListeners();
      } else {
        countdownText = '${remainingTime.inHours.toString().padLeft(2, '0')} : '
            '${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')} : '
            '${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
        notifyListeners(); // إشعار المستمعين بالتغيير
      }
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final remainingTime = lastOrderTime.add(countdownDuration).difference(now);
    countdownText = '${remainingTime.inHours.toString().padLeft(2, '0')} : '
        '${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')} : '
        '${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    notifyListeners(); // إشعار المستمعين بالتغيير
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
