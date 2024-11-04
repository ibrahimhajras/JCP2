import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../NotificationService.dart';
import '../../../style/colors.dart';
import '../../RotatingImagePage.dart';

class OrderDetailsPage_OrangePrivate extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;
  final String carid;

  const OrderDetailsPage_OrangePrivate({
    super.key,
    required this.orderData,
    required this.items,
    required this.carid,
  });

  @override
  _OrderDetailsPageState_OrangePrivate createState() =>
      _OrderDetailsPageState_OrangePrivate();
}

class _OrderDetailsPageState_OrangePrivate
    extends State<OrderDetailsPage_OrangePrivate> {
  @override
  void initState() {
    // TODO: implement initState
    print(widget.items);
    super.initState();
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
                      // Adjust padding to move "اسم القطعة"
                      child: _buildSectionTitle("اسم القطعة"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 50.0),
                  // Adjust padding to move the icon
                  child: IconButton(
                    onPressed: () {
                      if (widget.items.isNotEmpty &&
                          widget.items[0]['itemimg64'] != null &&
                          widget.items[0]['itemimg64'].isNotEmpty) {
                        _showImageDialog(widget.items[0]['itemimg64']);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('لا توجد صورة لهذا العنصر')),
                        );
                      }
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
            MaterialButton(
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
            ),
          ],
        ),
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
              CustomText(
                color: Color(0xFF8D8D92),
                text: widget.carid,
                letters: true,
              )
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
    String fullUrl = "https://jordancarpart.com$imageUrl";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: fullUrl.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CustomText(
                        text:
                            "الملاحظات:  ${widget.orderData['additionalNote']}" ??
                                '',
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                    Image.network(
                      fullUrl,
                      height: 250,
                      width: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text('فشل في تحميل الصورة');
                      },
                    ),
                  ],
                )
              : Text('لا توجد صورة متاحة'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [primary1, primary2, primary3],
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
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
    int orderId = int.tryParse(widget.orderData['orderid']) ?? 0;
    print(orderId);
    if (orderId != 0) {
      await updateOrderState(context, orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل في تأكيد الطلب، رقم الطلب غير صالح'),
      ));
    }
  }
}

Future<void> updateOrderState(BuildContext context, int orderId) async {
  final url = Uri.parse(
      'https://jordancarpart.com/Api/updateState.php?state=3&id=$orderId');
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(child: RotatingImagePage());
    },
  );
  try {
    final response = await http.get(url);
    Navigator.of(context).pop();
    print("response response response" + response.body.toString());
    if (response.statusCode == 200) {
      NotificationService().showNotification(
          id: 0,
          title: 'تم تأكيد طلبك بنجاح',
          body:
              'طلب رقم $orderId تم تأكيده بنجاح. سوف يتم التواصل معك قريباً.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      List notificationList = notifications.map((notification) {
        return jsonDecode(notification);
      }).toList();

      void addNotification(String message, String type) {
        notificationList.add({
          'message': message,
          'type': type,
          'isRead': false,
        });
      }

      addNotification(' ${orderId} تم تأكيد طلب رقم  ', "تأكيد");
      List<String> updatedNotifications = notificationList
          .map((notification) => jsonEncode(notification))
          .toList();
      await prefs.setStringList('notifications', updatedNotifications);

      print("Notifications stored successfully in SharedPreferences.");

      print("Notification stored successfully in SharedPreferences.");
    } else {
      throw Exception('Failed to update order state');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ أثناء تحديث حالة الطلب: $e')),
    );
  }
}
