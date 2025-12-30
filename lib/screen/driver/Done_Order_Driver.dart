import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class MyBottomNavigation extends StatefulWidget {
  @override
  _MyBottomNavigationState createState() => _MyBottomNavigationState();
}

class _MyBottomNavigationState extends State<MyBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Done_Order_Driver(page: 1),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Render selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          // Add more items as needed
        ],
      ),
    );
  }
}

class Done_Order_Driver extends StatefulWidget {
  var page;

  Done_Order_Driver({super.key, required this.page});

  @override
  State<Done_Order_Driver> createState() => _Done_Order_DriverState();
}

class _Done_Order_DriverState extends State<Done_Order_Driver> {
  bool check = true;

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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(size, context),
          Container(
            height: size.height * 0.7,
            child: StreamBuilder<List<Order>>(
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
                      child: NoDataScreen());
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      Order order =
                      orders[orders.length - 1 - index];
                      Map<String, dynamic> order2 = orders[orders.length - 1 - index].toJson();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                order: order,
                                screentype: 2,order2: order2,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: green, width: 2.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: order.orderTime,
                                    size: isnormal ? 8 : 8,
                                    weight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  CustomText(
                                    text: order.orderId.toString(),
                                    size: isnormal ? 18 : 16,
                                    weight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: " رقم الطلب"
                                        .toString()
                                        .replaceAll(':', ""),
                                    size: isnormal ? 18 : 16,
                                    color: Color(0xffA8A8A8),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: order.orderTime,
                                    size: isnormal ? 8 : 8,
                                    color: Colors.white,
                                  ),
                                  CustomText(
                                    text: order.traderDetails.length.toString(),
                                    size: isnormal ? 16 : 14,
                                    color: Colors.black,
                                    weight: FontWeight.w600,
                                  ),
                                  CustomText(
                                    text: " عدد الموردين"
                                        .toString()
                                        .replaceAll(':', ""),
                                    size: isnormal ? 18 : 16,
                                    color: Color(0xffA8A8A8),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.topLeft,
                                child: CustomText(
                                  text: order.orderTime,
                                  size: isnormal ? 16 : 14,
                                  color: Color(0xffA8A8A8),
                                ),
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
        ],
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return CustomHeader(
      title: "طلبيات منجزة",
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

  Future<List<Order>> fetchOrders2() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);

    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/delevery/get_delevery.php?state=1&persionid=' +
              user.user_id.toString()),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );


    if (response.statusCode == 200) {
      final utf8Response = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(utf8Response);

      return OrderResponse.fromMap(jsonResponse).data;
    } else {
      throw Exception("Failed to load orders");
    }
  }

  Stream<List<Order>> orderStream(BuildContext context, String userId) async* {
    while (true) {
      final orders = await fetchOrders2();
      yield orders;
      await Future.delayed(Duration(seconds: 3));
    }
  }
}

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Another Screen'));
  }
}
