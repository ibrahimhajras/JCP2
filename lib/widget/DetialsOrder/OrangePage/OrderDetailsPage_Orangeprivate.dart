import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/colors.dart';
import '../../FullScreenImageViewer.dart';
import '../../RotatingImagePage.dart';
import 'Pay.dart';

class OrderDetailsPage_OrangePrivate extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;
  final bool status;

  const OrderDetailsPage_OrangePrivate({
    super.key,
    required this.orderData,
    required this.items,
    required this.status,
  });

  @override
  _OrderDetailsPageState_OrangePrivate createState() =>
      _OrderDetailsPageState_OrangePrivate();
}

class _OrderDetailsPageState_OrangePrivate
    extends State<OrderDetailsPage_OrangePrivate> {
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  _buildSectionTitle("المركبة"),
                  _buildVehicleInfo(),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 100),
                            child: _buildSectionTitle("اسم القطعة"),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: IconButton(
                          onPressed: () {
                            _showImageDialog(widget.items[0]['itemimg64'] ?? "");
                          },
                          icon: Icon(
                            Icons.info_outline,
                            size: 24,
                            color: green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildVehicleInfo2(widget.items),
                  SizedBox(height: size.height * 0.07),
                  Divider(
                    height: 2,
                  ),
                  SizedBox(height: size.height * 0.01),
                  _buildOrderInfo(),
                  SizedBox(height: size.height * 0.07),
                  widget.status == true
                      ? MaterialButton(
                          onPressed: _handleConfirm,
                          height: 50,
                          minWidth: size.width * 0.9,
                          color: Color.fromRGBO(195, 29, 29, 1),
                          child: CustomText(
                            text: "تاكيد",
                            color: white,
                            size: 16,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        )
                      : Container(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfo2(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Column(
          children: items.map((item) {
            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomText(
                text: item['itemname'] ?? '',
                color: Colors.black,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    color: Color(0xFF8D8D92),
                    text: widget.orderData["Enginetype"].toString() +
                        "  " +
                        widget.orderData["Enginecategory"].toString() +
                        "  " +
                        widget.orderData["Fueltype"].toString() +
                        " " +
                        widget.orderData["Engineyear"].toString() +
                        "  " +
                        widget.orderData["Enginesize"].toString(),
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: title,
          size: 18,
          weight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullScreenImageViewer(imageUrl: imageUrl);
      },
    );
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
              text: "تفاصيل الطلب",
              color: Colors.white,
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(page: 2),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios_rounded, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildOrderInfoRow(
              "تكلفة المنتج", "${widget.orderData['productCost']}"),
          _buildOrderInfoRow(
              "تكلفة الشحن", "${widget.orderData['expierdtime']}"),
          _buildOrderInfoRow(
              "الضرائب والرسوم", "${widget.orderData['customs']}"),
          _buildOrderInfoRow("المجموع",
              "${widget.orderData['totalCost']} دينار اردني فقط لا غير",
              isTotal: true),
          _buildOrderInfoRow(
              "وقت التوصيل المتوقع", "${widget.orderData['deliveryTime']} يوم",
              color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildOrderInfoRow(String label, String value,
      {bool isTotal = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: value,
            size: 16,
            weight: isTotal ? FontWeight.normal : FontWeight.normal,
            color: isTotal ? Colors.black : color,
            textDirection: TextDirection.rtl,
          ),
          CustomText(
            text: label,
            size: 18,
            weight: isTotal ? FontWeight.normal : FontWeight.normal,
            color: isTotal ? red : red,
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  void _handleConfirm() async {
    int orderId = int.tryParse(widget.orderData['orderid'].toString()) ?? 0;
    if (orderId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رقم الطلب غير صالح')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: RotatingImagePage()),
    );

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final billData = {
        "order_id": widget.orderData['orderid'],
        "cust_name": widget.orderData['cust_name'] ?? "زبون خاص",
        "user_id": widget.orderData['userid'] ?? "0",
        "due_amount": widget.orderData['totalCost'],
        "service_type": "Pay_bill",
        "bill_type": "OneOff",
        "bill_status": "BillNew",
        "status": "order",
        "bill_category": "special",
        "token": token,
      };

      final billResponse = await http.post(
        Uri.parse('https://jordancarpart.com/Api/Bills/create_bill.php'),
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(billData),
      );

      Navigator.of(context).pop();

      final billResponseData = jsonDecode(billResponse.body);
      

      if (billResponse.statusCode == 200 &&
          billResponseData['success'] == true) {
        int billId = int.tryParse(billResponseData['bill_id'].toString()) ?? 0;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PayPage(
              orderId: orderId,
              billId: billId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          )),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى')),
      );
    }
  }

// void _handleConfirm() async {
//   int orderId = int.tryParse(widget.orderData['orderid']) ?? 0;
//   if (orderId == 0) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('رقم الطلب غير صالح')),
//     );
//     return;
//   }
//
//   final url = Uri.parse('https://jordancarpart.com/Api/updateState.php?state=3&id=$orderId');
//
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (context) => Center(child: RotatingImagePage()),
//   );
//
//   try {
//     final response = await http.get(url);
//     Navigator.of(context).pop();
//
//     if (response.statusCode == 200) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('تم تأكيد الطلب بنجاح')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('فشل في تأكيد الطلب')),
//       );
//     }
//   } catch (e) {
//     Navigator.of(context).pop();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('خطأ في الاتصال، حاول مرة أخرى')),
//     );
//   }
// }
}
