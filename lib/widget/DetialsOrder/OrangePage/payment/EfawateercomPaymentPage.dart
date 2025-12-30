import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../screen/home/homeuser.dart';
import '../../../Inallpage/showConfirmationDialog.dart';
import '../../../RotatingImagePage.dart';

class EfawateercomPaymentPage extends StatefulWidget {
  final int billId;

  const EfawateercomPaymentPage({
    super.key,
    required this.billId,
  });

  @override
  _EfawateercomPaymentPageState createState() =>
      _EfawateercomPaymentPageState();
}

class _EfawateercomPaymentPageState extends State<EfawateercomPaymentPage> {
  String amount = "";

  @override
  void initState() {
    super.initState();
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary1, primary2, primary3]),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              text: "طريقة الدفع",
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
                icon: Icon(Icons.arrow_forward_ios_rounded, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(size),
            SizedBox(height: size.height * 0.05),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildInfoRow(
                  "اختر من فئة المفوتر",
                  "تجارة وخدمات",
                ),
                Divider(height: 30),
                _buildInfoRow(
                  "اسم المفوتر",
                  "شركة بيت المهندسين لتسويق قطع السيارات",
                ),
                Divider(height: 30),
                _buildInfoRow(
                  "الخدمة",
                  "دفع فاتورة",
                ),
                Divider(height: 30),
                _buildInfoRow(
                  "رقم الفاتورة",
                  widget.billId.toString(),
                  valueColor: green,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.05),
            MaterialButton(
              onPressed: () async {
                _checkPaymentStatus();
              },
              height: 55,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "تم الدفع",
                color: white,
                size: 18,
                weight: FontWeight.bold,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: title,
            size: 14,
            color: Colors.black,
            textAlign: TextAlign.center,
            weight: FontWeight.w700,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: words.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: CustomText(
              text: value,
              size: 16,
              color: valueColor ?? Colors.black38,
              textAlign: TextAlign.center,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: RotatingImagePage()),
        ),
      );

      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/Bills/check_bill_status.php?bill_id=${widget.billId}'),
      );

      Navigator.of(context).pop();



      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final billStatus = data['bill_status'];

          if (billStatus == 'BillNew') {
            showConfirmationDialog(
              context: context,
              message: 'لم يتم الدفع يرجى إتمام عملية الدفع أولاً',
              confirmText: 'حسنًا',
              onConfirm: () {},
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(page: 2),
              ),
                  (route) => false,
            );
          }
        } else {
          showConfirmationDialog(
            context: context,
            message: 'حدث خطأ أثناء التحقق من حالة الدفع.',
            confirmText: 'حسنًا',
            onConfirm: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(page: 2),
                ),
                    (route) => false,
              );
            },
          );
        }
      } else {
        showConfirmationDialog(
          context: context,
          message: 'خطأ في الاتصال بالخادم. يرجى المحاولة مرة أخرى.',
          confirmText: 'حسنًا',
          onConfirm: () {},
        );
      }
    } catch (e) {
      Navigator.of(context).pop();


      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
        confirmText: 'حسنًا',
        onConfirm: () {},
      );
    }
  }
}
