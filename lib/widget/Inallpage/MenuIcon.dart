import 'package:flutter/material.dart';

class MenuIcon extends StatelessWidget {
  final Size size;
  final VoidCallback onTap; // حدث عند النقر

  const MenuIcon({
    Key? key,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // تمرير الوظيفة عند النقر
      child: Container(
        height: size.width * 0.1,
        width: size.width * 0.1,
        decoration: BoxDecoration(
          color: Color.fromRGBO(246, 246, 246, 0.26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Icon(
            Icons.menu,
            color: Color.fromRGBO(246, 246, 246, 1),
            size: size.width * 0.06, // حجم الأيقونة ديناميكي
          ),
        ),
      ),
    );
  }
}
