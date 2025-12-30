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
  final int? maxLines; // الحد الأقصى لعدد الأسطر
  final TextOverflow? overflow; // طريقة التعامل مع النص الطويل

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
    this.maxLines, // 🆕 معامل اختياري لتحديد عدد الأسطر
    this.overflow, // 🆕 معامل اختياري لتحديد كيفية التعامل مع النص الطويل
  });

  @override
  Widget build(BuildContext context) {
    // ✅ **تثبيت حجم الخط وعدم تأثره بإعدادات النظام**
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0, // ✅ تثبيت مقياس النص
        boldText: false,      // ✅ منع النص العريض من النظام
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? black,
          fontWeight: weight ?? FontWeight.w500,
          fontFamily: "Tajawal",
          fontSize: size ?? 16,
          letterSpacing: letters == true ? 2.0 : 0,
          decoration: decoration,
          decorationThickness: decorationThickness ?? 1.5,
          decorationColor: decorationColor ?? color, // لون الخط السفلي مطابق للون النص
          height: 1.2, // ✅ ارتفاع ثابت للسطر
        ),
        textAlign: textAlign ?? TextAlign.center,
        textDirection: textDirection ?? TextDirection.ltr,
        maxLines: maxLines, // 🆕 يسمح بتحديد الحد الأقصى للأسطر (افتراضيًا غير محدد)
        overflow: overflow, // 🆕 يسمح بتحديد طريقة إظهار النص الطويل (افتراضيًا غير محدد)
        textScaleFactor: 1.0, // ✅ ضمان إضافي لتثبيت الحجم
      ),
    );
  }
}

// ✅ **أحجام خط ثابتة يمكن استخدامها**
class AppFontSizes {
  static const double tiny = 10;
  static const double small = 12;
  static const double medium = 14;
  static const double large = 16;
  static const double title = 18;
  static const double headline = 20;
  static const double display = 24;
  static const double hero = 28;
  static const double massive = 32;
}