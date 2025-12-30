import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import '../../../screen/home/homeuser.dart';
import '../../../style/colors.dart';
import '../../RotatingImagePage.dart';

class OrderDetailsPage_Greenprivate extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;

  const OrderDetailsPage_Greenprivate({
    Key? key,
    required this.orderData,
    required this.items,
  }) : super(key: key);

  @override
  State<OrderDetailsPage_Greenprivate> createState() => _OrderDetailsPage_GreenprivateState();
}

class _OrderDetailsPage_GreenprivateState extends State<OrderDetailsPage_Greenprivate> {

  @override
  void initState() {
    // TODO: implement initState




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
            SizedBox(height: size.height * 0.01),
            _buildSectionTitle("المركبة"),
            SizedBox(height: size.height * 0.01),
            _buildVehicleInfo(),
            SizedBox(height: size.height * 0.02),
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
          ],
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
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: Center(
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: RotatingImagePage()); // عرض تحميل متحرك
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Center(
                      child: CustomText(
                        text: 'خطأ في تحميل الصورة',
                        size: 16,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
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

  List<Widget> _buildSelectedItemsList(Size size) {
    return widget.items.map<Widget>((item) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.04, vertical: size.height * 0.01),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDetailRow("اسم العنصر", item["itemname"].toString(), size),
            _buildDetailRow("رابط العنصر", item["itemlink"].toString(), size),
            SizedBox(height: size.height * 0.04),
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
                  "${item["itemimg64"]}",
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
          _buildDetailRow("الملاحظات", "${widget.orderData["additionalNote"]}", size),
          _buildDetailRow("وقت التوصيل", "${widget.orderData["deliveryTime"]}", size),
          _buildDetailRow("تكلفة الجمارك", "${widget.orderData["customs"]}", size),
          _buildDetailRow("سعر القطعة", "${widget.orderData["productCost"]}", size),
          _buildDetailRow("تاريخ الطلب", "${widget.orderData["timeorder"]}", size),
          _buildDetailRow("رقم الطلب", "${widget.orderData["orderid"]}", size),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, Size size) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              text: value,
              color: words,
              size: size.height * 0.018,
            ),
          ),
          SizedBox(width: size.width * 0.02),
          CustomText(
              text: title,
              weight: FontWeight.bold,
              color: Colors.black,
              size: size.height * 0.02,
              textAlign: TextAlign.left),
        ],
      ),
    );
  }

}
