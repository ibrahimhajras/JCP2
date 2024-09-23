import 'package:flutter/material.dart';

import 'custom_text.dart';

class TopPageWidget extends StatefulWidget {
  final String title;
  TopPageWidget({Key? key, required this.title}) : super(key: key);

  @override
  State<TopPageWidget> createState() => _TopPageWidgetState();
}

class _TopPageWidgetState extends State<TopPageWidget> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.25,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color.fromRGBO(176, 45, 45, 1),
            Color.fromRGBO(195, 29, 29, 1),
            Color.fromRGBO(125, 10, 10, 1),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              text: "الطلبات",
              color: Color.fromRGBO(255, 255, 255, 1),
              size: 25,
            ),
          ],
        ),
      ),
    );
  }
}
