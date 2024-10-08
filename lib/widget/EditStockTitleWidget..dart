import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';

import '../../style/custom_text.dart';

class EditStockTitleWidget extends StatelessWidget {
  const EditStockTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: size.width * 0.18,
          height: 40,
          child: Center(
            child: CustomText(
              text: "تعديل",
              size: 12,
            ),
          ),
        ),
        Container(
          width: size.width * 0.16,
          height: 40,
          child: Center(
            child: CustomText(
              text: "الحالة",
              weight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          width: size.width * 0.18,
          height: 40,
          child: Center(
            child: CustomText(
              text: "السعر",
              weight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          width: size.width * 0.18,
          height: 40,
          child: Center(
            child: CustomText(
              text: "الكمية",
              weight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          width: size.width * 0.2,
          height: 40,
          child: Center(
            child: CustomText(
              color: white,
              text: "الكمية",
              weight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
