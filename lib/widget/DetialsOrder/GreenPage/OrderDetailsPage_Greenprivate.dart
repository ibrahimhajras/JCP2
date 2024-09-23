import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import '../../../style/colors.dart';

class OrderDetailsPage_Greenprivate extends StatelessWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;

  const OrderDetailsPage_Greenprivate({
    Key? key,
    required this.orderData,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(size, context),
              SizedBox(height: 16),
              _buildSectionTitle("العناصر المختارة"),
              ..._buildSelectedItemsList(),
              SizedBox(height: 16),
              _buildSectionTitle("تفاصيل الطلب"),
              _buildOrderDetails(),
              SizedBox(height: 16),
              _buildSectionTitle("المجموع الكلي"),
              _buildTotalCost(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Colors.black!, Colors.grey!],
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/card.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              text: "تفاصيل الطلب",
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedItemsList() {
    return items.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildDetailRow("اسم العنصر:", item["itemname"].toString()),
              _buildDetailRow("رابط العنصر:", item["itemlink"].toString()),
              SizedBox(height: 10),
              if (item["itemimg64"] != null && item["itemimg64"].isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.memory(
                    base64Decode(item["itemimg64"]),
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Text("لا توجد صورة"),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildOrderDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("رقم الطلب:", "${orderData["orderid"]}"),
            _buildDetailRow("تاريخ الطلب:", "${orderData["timeorder"]}"),
            _buildDetailRow("سعر القطعه:", "${orderData["productCost"]}"),
            _buildDetailRow(": تكيفه الجمارك", "${orderData["customs"]}"),
            _buildDetailRow("وقت التوصيل:", "${orderData["deliveryTime"]}"),
            _buildDetailRow("الملاحضات:", "${orderData["additionalNote"]}"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCost() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                "المجموع الكلي:", "${orderData["totalCost"]} دينار"),
          ],
        ),
      ),
    );
  }
}
