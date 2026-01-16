import 'package:flutter/material.dart';
import '../../style/custom_text.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget notificationIcon;
  final Widget menuIcon;

  const CustomHeader({
    Key? key,
    required this.title,
    this.subtitle,
    required this.notificationIcon,
    required this.menuIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          double textScaleFactor = MediaQuery.of(context).textScaleFactor;
          bool isNormal = textScaleFactor <= 1;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color(0xFFB02D2D),
                  Color(0xFFC41D1D),
                  Color(0xFF7D0A0A),
                ],
                stops: [0.1587, 0.3988, 0.9722],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      notificationIcon,
                      menuIcon,
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomText(
                    text: title,
                    color: Colors.white,
                    size: 20,
                    weight: FontWeight.bold,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: CustomText(
                        text: subtitle!,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}