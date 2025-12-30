import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/RotatingImagePage.dart';

import '../../style/colors.dart';
import '../../style/custom_text.dart';

class PredictivePartsPage extends StatefulWidget {
  const PredictivePartsPage({Key? key}) : super(key: key);

  @override
  State<PredictivePartsPage> createState() => _PredictivePartsPageState();
}

class _PredictivePartsPageState extends State<PredictivePartsPage> {
  List<Map<String, String>> parts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchParts();
  }

  Future<void> fetchParts() async {
    final url = Uri.parse('https://jordancarpart.com/Api/getparts.php');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          parts = (data['data'] as List)
              .map((e) =>
          {
            'part_name_ar': e['part_name_ar'].toString(),
            'part_name_en': e['part_name_en'].toString(),
          })
              .toList();

          isLoading = false;
        });
      }
    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      body: isLoading
          ? Center(child: RotatingImagePage())
          : Column(
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
                    text: "الأسماء التنبؤية للقطع",
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
                      icon: Icon(Icons.arrow_forward_ios_rounded,
                          color: white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Expanded(
            child: ListView.builder(
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: InkWell(
                    onLongPress: () {
                      final arabic = part['part_name_ar'] ?? '';
                      Clipboard.setData(ClipboardData(text: arabic));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "تم نسخ اسم القطعة",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Tajawal"),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: red,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: CustomText(
                                text: part['part_name_ar'] ?? '',
                                textAlign: TextAlign.right,
                                weight: FontWeight.w500,
                                size: 14,
                              ),
                            ),
                            SizedBox(width: 4),
                            CustomText(
                              text: '.${index + 1}',
                              weight: FontWeight.bold,
                              size: 14,
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 32.0), // انزاحه شويه لليسار
                          child: CustomText(
                            text: part['part_name_en'] ?? '',
                            textAlign: TextAlign.left,
                            weight: FontWeight.w400,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
