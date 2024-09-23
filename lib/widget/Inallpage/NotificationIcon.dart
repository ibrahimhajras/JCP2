import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final Size size;
  final bool check;
  final VoidCallback onTap;

  const NotificationIcon({
    Key? key,
    required this.size,
    required this.check,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: size.width * 0.1,
        width: size.width * 0.1,
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 246, 246, 0.26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            check
                ? 'assets/images/notification-on.png'
                : 'assets/images/notification-off.png',
          ),
        ),
      ),
    );
  }
}
