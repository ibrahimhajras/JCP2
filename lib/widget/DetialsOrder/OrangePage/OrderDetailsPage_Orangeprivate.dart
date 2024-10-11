import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';
import '../../../style/colors.dart';

class OrderDetailsPage_OrangePrivate extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final List<Map<String, dynamic>> items;

  const OrderDetailsPage_OrangePrivate({
    super.key,
    required this.orderData,
    required this.items,
  });

  @override
  _OrderDetailsPageState_OrangePrivate createState() =>
      _OrderDetailsPageState_OrangePrivate();
}

class _OrderDetailsPageState_OrangePrivate
    extends State<OrderDetailsPage_OrangePrivate> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(size),
            SizedBox(height: 15),
            _buildItemsList(),
            SizedBox(height: 15),
            _buildOrderInfo(),
            SizedBox(height: 30),
            SizedBox(height: 16),
            Divider(height: 2),
            _buildFooterSummary(),
            SizedBox(height: 16),
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

  Widget _buildItemsList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        return Card(
          color: grey,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['itemname'] ?? '',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(width: 30),
                    Text(
                      item['itemlink'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (item['itemimg64'] != null &&
                        item['itemimg64'].isNotEmpty) {
                      _showImageDialog(item['itemimg64']);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('لا توجد صورة لهذا العنصر')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                  ),
                  child: Text('عرض الصورة'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showImageDialog(String imageUrl) {
    String fullUrl = "https://jordancarpart.com$imageUrl";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: fullUrl.isNotEmpty
              ? Image.network(
                  fullUrl,
                  height: 250,
                  width: 350,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Text('فشل في تحميل الصورة');
                  },
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
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: "رقم الطلب: ${widget.orderData['orderid']}",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          SizedBox(height: 8),
          CustomText(
            text: "تاريخ الطلب: ${widget.orderData['timeorder']}",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          CustomText(
            text: "تكلفة المنتج: ${widget.orderData['productCost']} دينار",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          CustomText(
            text: "الجمارك: ${widget.orderData['customs']} دينار",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          CustomText(
            text: "التكلفة الكلية: ${widget.orderData['totalCost']} دينار",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          CustomText(
            text: "وقت التوصيل: ${widget.orderData['deliveryTime']}يوم ",
            size: 16,
            color: Colors.black,
          ),
          SizedBox(height: 8),
          CustomText(
            text: "ملاحظات إضافية: ${widget.orderData['additionalNote']}",
            size: 16,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSummary() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار اردني",
                size: 18,
              ),
              CustomText(
                text: " ${widget.orderData['totalCost']}", // التكلفة الكلية
                size: 18,
              ),
            ],
          ),
          CustomText(
            text: "  المجموع",
            color: red,
            weight: FontWeight.w900,
            size: 18,
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

  try {
    final response = await http.get(url);
    print("response response response" + response.body.toString());
    if (response.statusCode == 200) {
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
