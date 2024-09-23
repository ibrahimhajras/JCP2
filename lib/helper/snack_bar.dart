import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';

import '../style/custom_text.dart';

void showSnack(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: white,
      elevation: 10,
      content: Center(
        child: CustomText(
          text: text,
          color: red,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.825),
      duration: Duration(seconds: 3),
    ),
  );
}

void showSnackButton(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: white,
      elevation: 10,
      content: Center(
        child: CustomText(
          text: text,
          color: red,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.65),
      duration: Duration(seconds: 1),
    ),
  );
}
