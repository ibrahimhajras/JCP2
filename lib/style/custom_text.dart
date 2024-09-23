import 'package:flutter/material.dart';
import '../style/colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;
  final TextAlign? textAlign;
  final bool? letters;
  final TextDirection? textDirection;

  CustomText({
    super.key,
    required this.text,
    this.color,
    this.weight,
    this.size,
    this.textAlign,
    this.letters,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? black,
        fontWeight: weight ?? FontWeight.w500,
        fontFamily: "Tajawal",
        fontSize: size ?? 16,
        letterSpacing: letters == true ? 2.0 : 0,
      ),
      textAlign: textAlign ?? TextAlign.center,
      textDirection: textDirection ?? TextDirection.ltr,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
