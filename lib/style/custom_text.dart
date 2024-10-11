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
  final TextDecoration? decoration;
  final double? decorationThickness; // سماكة الخط السفلي
  final Color? decorationColor; // لون الخط السفلي

  CustomText({
    super.key,
    required this.text,
    this.color,
    this.weight,
    this.size,
    this.textAlign,
    this.letters,
    this.textDirection,
    this.decoration,
    this.decorationThickness,
    this.decorationColor,
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
        decoration: decoration,
        decorationThickness: decorationThickness ?? 1.5,
        decorationColor:
            decorationColor ?? color, // لون الخط السفلي مطابق للون النص
      ),
      textAlign: textAlign ?? TextAlign.center,
      textDirection: textDirection ?? TextDirection.ltr,
    );
  }
}
