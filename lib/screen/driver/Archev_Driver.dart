import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/driver/archivedetails.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/ProfileProvider.dart';
import '../../../screen/Drawer/Notification.dart';
import '../../../style/colors.dart';
import '../../model/Delevery/Orders.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/Inallpage/NotificationIcon.dart';
import 'NoDataScreen.dart';
import 'OrderDetailsScreen.dart';

class Archev_Driver extends StatefulWidget {
  var page;

  Archev_Driver({super.key, required this.page});

  @override
  State<Archev_Driver> createState() => _Archev_DriverState();
}

class _Archev_DriverState extends State<Archev_Driver> {
  bool check = true;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkForNotifications();
  }

  Future<bool> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    List<Map<String, dynamic>> notificationList =
    notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnreadNotifications =
    notificationList.any((notification) => notification['isRead'] == false);

    setState(() {
      check = hasUnreadNotifications;
    });

    return hasUnreadNotifications;
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    bool isnormal = textScaleFactor <= 1;

    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Column(
      children: [
        _buildHeader(size, context),
        Expanded(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.7,
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: orderStream(context, user.user_id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: RotatingImagePage());
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      height: MediaQuery.of(context).size.width,
                      child: NoDataScreen(),
                    );
                  } else {
                    final orders = snapshot.data!;
                    return ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        String orderStatus =
                        (order['paymethod']?.toLowerCase() == "cash")
                            ? "غير مدفوع"
                            : (order['paymethod']?.toLowerCase() == "visa")
                            ? "مدفوع"
                            : "غير محدد";

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Archivedetails(orderData: order) // ✅ الحل الصحيح
                              ),
                            );

                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.height * 0.01),
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.height * 0.01),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: orange, width: 3),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: order['order_time'], // عرض التاريخ
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: Color(0xffA8A8A8),
                                    ),
                                    CustomText(
                                      text: order['orderid'].toString(),
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    CustomText(
                                      text: "رقم الطلب",
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: Color(0xffA8A8A8),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: order['order_time'],
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: white,
                                    ),
                                    CustomText(
                                      text: order['trader_details']
                                          .length
                                          .toString(),
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    CustomText(
                                      text: "عدد الموردين",
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color: Color(0xffA8A8A8),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text:
                                      (order['trader_details'].isNotEmpty &&
                                          order['trader_details'][0]
                                          ['doneorder'] ==
                                              0)
                                          ? "غير جاهز"
                                          : "جاهز",
                                      size: isnormal ? 16 : 14,
                                      weight: FontWeight.bold,
                                      color:
                                      (order['trader_details'].isNotEmpty &&
                                          order['trader_details'][0]
                                          ['doneorder'] ==
                                              0)
                                          ? red
                                          : green,
                                    ),
                                    Center(
                                      child: CustomText(
                                        text: orderStatus,
                                        size: isnormal ? 16 : 14,
                                        weight: FontWeight.bold,
                                        color: orderStatus == "مدفوع"
                                            ? green
                                            : red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return CustomHeader(
      title: "كبسة أرشفة",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildNotificationIcon(Size size) {
    return NotificationIcon(
      size: size,
      check: check,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(),
          ),
        ).then((_) {
          _checkForNotifications();
        });
      },
    );
  }

  Widget _buildMenuIcon(BuildContext context, Size size) {
    return MenuIcon(
      size: size,
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchOrders2() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);
    String user1 = user.user_id;

    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/delevery/get_delevery.php?state=2&persionid=$user1'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final utf8Response = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(utf8Response);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        return List<Map<String, dynamic>>.from(jsonResponse['data']);
      }
    }

    throw Exception("فشل تحميل الطلبات");
  }

  Stream<List<Map<String, dynamic>>> orderStream(
      BuildContext context, String userId) async* {
    while (true) {
      final ordersData =
      await fetchOrders2(); // هذه البيانات بصيغة List<Map<String, dynamic>>
      yield ordersData; // تمرير البيانات كما هي دون تحويلها إلى كائنات Order
      await Future.delayed(Duration(seconds: 3));
    }
  }
}

class OrderResponse {
  final List<Order> data;

  OrderResponse({required this.data});

  factory OrderResponse.fromMap(Map<String, dynamic> map) {
    var ordersData = map['data'] ?? [];
    List<Order> ordersList =
    ordersData.map<Order>((item) => Order.fromMap(item)).toList();
    return OrderResponse(data: ordersList);
  }
}
