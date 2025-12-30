import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';

import '../home/homeuser.dart';

class OurViewPage extends StatelessWidget {
  const OurViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.20,
              width: size.width,
              decoration: BoxDecoration(
                gradient:
                LinearGradient(colors: [primary1, primary2, primary3]),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "رؤيتنا",
                      color: Colors.white,
                      size: size.width * 0.06,
                    ),
                    SizedBox(width: size.width * 0.2),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon:
                        Icon(Icons.arrow_forward_ios_rounded, color: white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.01,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: CustomText(
                      text: "بسم الله الرحمن الرحيم",
                      textAlign: TextAlign.justify,
                      weight: FontWeight.w900,
                      size: 18,
                    ),
                  ),
                  CustomText(
                    text:
                    "أعزائي في فريق شركة بيت المهندسين لتسويق قطع السيارات",
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text:
                    "نحن نعتزم أن نكون الوجهة الرئيسية لكل من يبحث عن قطع السيارات، وذلك من خلال تقديم خدمات تفوق التوقعات وتحقيق رؤية مبتكرة في عالم تجارة قطع السيارات في الأردن",
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text:
                    "نحن نؤمن بأن العميل يجب أن يكون في قلب كل ما نقوم به، ولهذا السبب نسعى جاهدين لتقديم أفضل الأسعار وأعلى جودة لقطع السيارات، مع توفير مجموعة متنوعة من الخيارات لتناسب احتياجاتكم بالضبط.",
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text:
                    "من خلال شبكة اتصالاتنا الواسعة، نقدم خدمات الاستيراد من جميع أنحاء العالم لضمان توفير القطع غير المتوفرة في السوق المحلي، ونقوم بتوصيلها مباشرة إلى عتبات منازل عملائنا الكرام عبر شركائنا الاستراتيجيين.",
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text:
                    "شكرًا لثقتكم بنا، ونعدكم بأننا سنواصل العمل بجدية واجتهاد لتحقيق النجاح والارتقاء بخدماتنا إلى المستوى التالي.",
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text: "مع خالص التقدير",
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,

                  ),
                  SizedBox(height: size.height * 0.015),
                  CustomText(
                    text: " فريق شركة بيت المهندسين لتسويق قطع السيارات",
                    textAlign: TextAlign.justify,                    textDirection: TextDirection.rtl,

                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
