import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CountdownProvider with ChangeNotifier {
  Timer? _timer;
  String countdownText = "24 : 00 : 00";
  DateTime lastOrderTime = DateTime.now();
  Duration countdownDuration = Duration(hours: 24);

  void startCountdown(DateTime orderTime) {
    lastOrderTime = orderTime;
    _timer?.cancel();

    // 👇 تحديث فوري أولي
    _updateCountdown();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final remainingTime = lastOrderTime.add(countdownDuration).difference(now);

      if (remainingTime.isNegative) {
        _timer?.cancel();
        countdownText = "00 : 00 : 00";
      } else {
        countdownText = '${remainingTime.inHours.toString().padLeft(2, '0')} : '
            '${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')} : '
            '${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
      }

      _safeNotify();
    });
  }

  void startCountdownFrom(int seconds) {
    _timer?.cancel();

    countdownDuration = Duration(seconds: seconds);
    final endTime = DateTime.now().add(countdownDuration);

    // 👇 تحديث فوري أولي
    _updateCountdown();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remainingTime = endTime.difference(DateTime.now());

      if (remainingTime.isNegative) {
        _timer?.cancel();
        countdownText = "00 : 00 : 00";
      } else {
        countdownText =
        '${remainingTime.inHours.toString().padLeft(2, '0')} : '
            '${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')} : '
            '${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
      }

      _safeNotify();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final remainingTime = lastOrderTime.add(countdownDuration).difference(now);

    if (remainingTime.isNegative) {
      countdownText = "00 : 00 : 00";
    } else {
      countdownText = '${remainingTime.inHours.toString().padLeft(2, '0')} : '
          '${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')} : '
          '${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    _safeNotify();
  }

  // ✅ دالة آمنة لاستدعاء notifyListeners بعد انتهاء البناء
  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  bool get isCountdownFinished {
    final now = DateTime.now();
    final remainingTime = lastOrderTime.add(countdownDuration).difference(now);
    return remainingTime.isNegative;
  }

  int get remainingSeconds {
    final now = DateTime.now();
    final remainingTime = lastOrderTime.add(countdownDuration).difference(now);
    return remainingTime.isNegative ? 0 : remainingTime.inSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
