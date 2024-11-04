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
              SizedBox(height: size.height * 0.02),
              _buildSectionTitle("العناصر المختارة", size),
              ..._buildSelectedItemsList(size),
              SizedBox(height: size.height * 0.02),
              _buildSectionTitle("تفاصيل الطلب", size),
              _buildOrderDetails(size),
              SizedBox(height: size.height * 0.02),
              _buildTotalCost(size),
              SizedBox(height: size.height * 0.02),
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
          colors: [Colors.black, Colors.grey],
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
              size: size.height * 0.03,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.04),
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

  Widget _buildSectionTitle(String title, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Align(
        alignment: Alignment.centerRight,
        child: CustomText(
          text: title,
          size: size.height * 0.025,
          weight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  List<Widget> _buildSelectedItemsList(Size size) {
    return items.map<Widget>((item) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04, vertical: size.height * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDetailRow("اسم العنصر", item["itemname"].toString(), size),
            _buildDetailRow("رابط العنصر", item["itemlink"].toString(), size),
            SizedBox(height: size.height * 0.01),
            if (item["itemimg64"] != null && item["itemimg64"].isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size.width * 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Image.network(
                  "https://jordancarpart.com${item["itemimg64"]}",
                  width: size.width * 0.4,
                  height: size.height * 0.2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Text('فشل في تحميل الصورة'));
                  },
                ),
              )
            else
              Text("لا توجد صورة"),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildOrderDetails(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04, vertical: size.height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow("الملاحظات", "${orderData["additionalNote"]}", size),
          _buildDetailRow("وقت التوصيل", "${orderData["deliveryTime"]}", size),
          _buildDetailRow("تكلفة الجمارك", "${orderData["customs"]}", size),
          _buildDetailRow("سعر القطعة", "${orderData["productCost"]}", size),
          _buildDetailRow("تاريخ الطلب", "${orderData["timeorder"]}", size),
          _buildDetailRow("رقم الطلب", "${orderData["orderid"]}", size),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        children: [
          CustomText(
              text: title,
              weight: FontWeight.bold,
              color: Colors.black,
              size: size.height * 0.02,
              textAlign: TextAlign.left),
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: CustomText(
              text: value,
              color: Colors.black87,
              size: size.height * 0.018,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCost(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
              "المجموع الكلي", "${orderData["totalCost"]} دينار", size),
        ],
      ),
    );
  }
}
