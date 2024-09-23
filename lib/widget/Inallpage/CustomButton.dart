import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double height;
  final double minWidth;
  final TextStyle textStyle;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.color = const Color.fromRGBO(195, 29, 29, 1),
    this.height = 50.0,
    this.minWidth = 150.0,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontFamily: "Tajawal",
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: height,
      minWidth: minWidth,
      color: color,
      child: Text(
        text,
        style: textStyle,
      ),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 120),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }
}
