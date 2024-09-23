import 'package:flutter/material.dart';

import '../../style/colors.dart';
import '../../style/custom_text.dart';

class CustomHeader extends StatelessWidget {
  final Size size;
  final String title;
  final Widget notificationIcon;
  final Widget menuIcon;

  const CustomHeader({
    Key? key,
    required this.size,
    required this.title,
    required this.notificationIcon,
    required this.menuIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [primary1, primary2, primary3],
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/card.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.05,
              left: size.width * 0.03,
              right: size.width * 0.03,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                notificationIcon,
                menuIcon,
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Center(
            child: CustomText(
              text: title,
              color: Color.fromRGBO(255, 255, 255, 1),
              size: size.width * 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
