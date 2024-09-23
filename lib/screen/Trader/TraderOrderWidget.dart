import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/style/colors.dart';
import 'package:provider/provider.dart';

import '../../provider/ProfileProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomButton.dart';

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/colors.dart';
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomButton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TraderOrderWidget extends StatefulWidget {
  final String user_id;

  TraderOrderWidget(this.user_id, {Key? key}) : super(key: key);

  @override
  State<TraderOrderWidget> createState() => _TraderOrderWidgetState();
}

class _TraderOrderWidgetState extends State<TraderOrderWidget> {
  late Future<List<dynamic>> futureOrders;
  bool hasNewNotification = false; // الحالة للإشعارات الجديدة

  @override
  void initState() {
    super.initState();
    futureOrders = fetchOrders();
    _checkForNotifications(); // فحص الإشعارات عند تهيئة الصفحة
  }

  Future<void> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> notificationList =
    notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnread =
    notificationList.any((notification) => notification['isRead'] == false);

    setState(() {
      hasNewNotification = hasUnread;
    });
  }

  Future<List<dynamic>> fetchOrders() async {
    try {
      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/showallordersoftrader.php?trader_id=${widget.user_id}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final List<dynamic> orders = responseData['orders'];
          if (mounted) {
            setState(() {
              futureOrders = Future.value(orders);
            });
          }

          return orders;
        } else {
          ('Failed to load orders: ${responseData['message']}');
          return [];
        }
      } else {
        ('لا يوجد طلبيات');
        return [];
      }
    } catch (e) {
      if (mounted) {
        setState(() {});
      }
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> orderDetails = json.decode(response.body);
      return orderDetails;
    } else {
      throw Exception('Failed to load order details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      child: Column(
        children: [
          Container(
            height: size.height * 0.2,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.05,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationPage(),
                                  )).then((_) {
                                _checkForNotifications();
                              });
                            },
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(246, 246, 246, 0.26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Image.asset(
                                  hasNewNotification
                                      ? 'assets/images/notification-on.png'
                                      : 'assets/images/notification-off.png',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(246, 246, 246, 0.26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.menu,
                              color: Color.fromRGBO(246, 246, 246, 1),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "الطلبيات",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureOrders,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load orders'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No orders available'));
                } else {
                  return ListView(
                    padding: EdgeInsets.all(8.0),
                    children: snapshot.data!.map((order) {
                      return GestureDetector(
                        onTap: () async {
                          try {
                            final orderDetails = await fetchOrderDetails(
                                order['order_id'].toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TraderOrderDetailsPage(
                                    orderDetails: orderDetails),
                              ),
                            );
                          } catch (e) {
                            // Handle error
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Failed to load order details')),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 20),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order['time']}', // Display the date
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'رقم الطلب : ${order['order_id']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// باقي الكود كما هو

class TraderOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  TraderOrderDetailsPage({required this.orderDetails});

  @override
  State<TraderOrderDetailsPage> createState() => _TraderOrderDetailsPageState();
}

class _TraderOrderDetailsPageState extends State<TraderOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    String id = profileProvider.getuser_id();
    print(id);
    print(widget.orderDetails);
    final hdr = widget.orderDetails['hdr'] != null &&
            widget.orderDetails['hdr'].isNotEmpty
        ? widget.orderDetails['hdr'][0]
        : {};
    final items = (widget.orderDetails['items'] ?? [])
        .where((item) => item['user_id'].toString() == id)
        .toList();

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: size.height * 0.2,
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [Colors.red, Colors.redAccent],
              ),
              image: DecorationImage(
                image: AssetImage("assets/images/card.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.05,
                    left: 10,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(246, 246, 246, 0.26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(246, 246, 246, 0.26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.menu,
                              color: Color.fromRGBO(246, 246, 246, 1),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: size.width * 0.3,
                    ),
                    Text(
                      "تفاصيل الطلب",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Body of Order Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hdr.isNotEmpty) ...[
                    const Text(
                      'المركبة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                hdr["Enginetype"].toString(), // عرض نوع المحرك
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black), // تنسيق النص
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hdr["Enginecategory"].toString(),
                                // عرض فئة المحرك
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hdr["Fueltype"].toString(), // عرض نوع الوقود
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hdr["Engineyear"].toString(), // عرض سنة المحرك
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                hdr["Enginesize"].toString(), // عرض حجم المحرك
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '  ${hdr['orderId']}   : رقم الطلب  ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ] else
                    const Text(
                      'No order details available',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: items.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildTableHeaderCell('الكفالة'),
                                      _buildTableHeaderCell('الحالة'),
                                      _buildTableHeaderCell('السعر'),
                                      _buildTableHeaderCell('اسم القطعة'),
                                    ],
                                  ),
                                ),

                                // Items Rows
                                for (var item in items)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildWarrantyIcon(context, item),
                                        _buildTableCell(item['itemType'] ?? ''),
                                        _buildTableCell(
                                            item['price']?.toString() ?? ''),
                                        _buildTableCell(item['itemName'] ?? ''),
                                      ],
                                    ),
                                  ),

                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          CustomText(
                                            text: "دينار اردني  ",
                                            size: 18,
                                          ),
                                          CustomText(
                                            text: "${hdr['totalCost']}",
                                            size: 18,
                                          ),
                                          CustomText(
                                            text: "  المجموع",
                                            color: red,
                                            weight: FontWeight.w900,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                                CustomButton(
                                  text: 'تم',
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Text(
                              'No items available',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTableHeaderCell(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildWarrantyIcon(BuildContext context, var item) {
    return IconButton(
      icon: Icon(Icons.info_outline, color: Colors.green, size: 30),
      onPressed: () {
        _showWarrantyDialog(context, item);
      },
    );
  }

  void _showWarrantyDialog(BuildContext context, var item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 7,
                    color: words, // تأكد من تعريف المتغير `words`
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: item['mark'] ?? "غير محدد",
                            color: words,
                          ),
                          CustomText(
                            text: " : العلامة التجارية",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "${item['itemPrice'] ?? 'غير محدد'}",
                            // عرض السعر
                            color: words,
                          ),
                          CustomText(
                            text: " : السعر",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "شهر",
                                color: words,
                              ),
                              SizedBox(width: 2),
                              CustomText(
                                text: "${item['itemWarranty'] ?? 'غير محدد'}",
                                // مدة الكفالة
                                color: words,
                              ),
                            ],
                          ),
                          CustomText(
                            text: " : مدة الكفالة",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: item['itemNote'].isEmpty
                                ? "لا يوجد"
                                : item['itemNote'], // الملاحظات
                            color: words,
                          ),
                          CustomText(
                            text: " : الملاحظات",
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (item['itemImg'] != null && item['itemImg'].isNotEmpty)
                        _buildImageFromBase64(item['itemImg'])
                      else
                        CustomText(
                          text: "لا يوجد صورة",
                          color: words,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageFromBase64(String base64Image) {
    try {
      Uint8List decodedImage = base64Decode(base64Image);
      return Image.memory(
        decodedImage,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Text(
        'بيانات الصورة غير صالحة',
        style: TextStyle(color: Colors.red),
      );
    }
  }
}
