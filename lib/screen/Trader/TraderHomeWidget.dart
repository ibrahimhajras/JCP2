import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jcp/provider/ProductProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Trader/FullStockTrader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;

class TraderHomeWidget extends StatefulWidget {
  const TraderHomeWidget({super.key});

  @override
  State<TraderHomeWidget> createState() => _TraderHomeWidgetState();
}

class _TraderHomeWidgetState extends State<TraderHomeWidget> {
  late Future<List<dynamic>> futureOrders;
  int totalOrders = 0;
  int totalOrdersday = 0;
  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);
      final user = Provider.of<ProfileProvider>(context, listen: false);
      productProvider.loadProducts(user.user_id);
      fetchOrders(user.user_id, 1);
      fetchOrders(user.user_id, 2);
    });
    _checkForNotifications();
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

  Future<List<dynamic>> fetchOrders(String user_id, int flag) async {
    final response = await http.get(Uri.parse(
        'https://jordancarpart.com/Api/showallordersoftrader.php?trader_id=${user_id}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success']) {
        final List<dynamic> orders = responseData['orders'];

        if (flag == 1) {
          setState(() {
            totalOrders = orders.length;
          });
          return orders;
        } else if (flag == 2) {
          final DateTime now = DateTime.now();
          final List<dynamic> filteredOrders = orders.where((order) {
            DateTime orderTime = DateTime.parse(order['time']);
            Duration difference = now.difference(orderTime);
            return difference.inHours < 24;
          }).toList();
          setState(() {
            totalOrdersday = filteredOrders.length;
          });
          return filteredOrders;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileProvider>(context);
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Container(
        height: size.height * 0.8,
        child: Column(
          children: [
            _buildTopBanner(size, user),
            Container(
              height: size.height * 0.6,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProductOrderCard(size, user),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StockViewPage()),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomText(
                            text: "كامل المخزن",
                            color: red,
                            textDirection: TextDirection.rtl,
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 80,
                              height: 1.5,
                              color: red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(Size size, ProfileProvider user) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/card.png"),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFFB02D2D),
            Color(0xFFC41D1D),
            Color(0xFF7D0A0A),
          ],
          stops: [0.1587, 0.3988, 0.9722],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.05,
              left: 10,
              right: 10,
            ),
            child: _buildTopBar(),
          ),
          Center(
            child: CustomText(
              text: user.name,
              color: Color.fromRGBO(255, 255, 255, 1),
              size: 22,
              weight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
          child: hasNewNotification
              ? _buildIconBox("assets/images/notification-on.png")
              : _buildIconBox("assets/images/notification-off.png"),
        ),
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openEndDrawer();
          },
          child: _buildIconBox(Icons.menu),
        ),
      ],
    );
  }

  Widget _buildIconBox(dynamic icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Color.fromRGBO(246, 246, 246, 0.26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: icon is String
            ? Image.asset(icon)
            : Icon(icon, color: Color.fromRGBO(246, 246, 246, 1)),
      ),
    );
  }

  Widget _buildProductOrderCard(Size size, ProfileProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        height: 175,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/card-1.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                child: _buildProductOrderInfo(size),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: _buildUserInfo(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductOrderInfo(Size size) {
    return Container(
      width: size.width * 0.8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        text: "${productProvider.totalCheckboxDataItems}",
                        textDirection: TextDirection.rtl,
                        color: white,
                      ),
                    ),
                    SizedBox(width: 12),
                    CustomText(
                      text: "مجموع القطع",
                      textDirection: TextDirection.rtl,
                      color: white,
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                text: totalOrders.toString(), // Placeholder for order total
                textDirection: TextDirection.rtl,
                color: white,
              ),
              SizedBox(width: 5),
              CustomText(
                text: "مجموع الطلبات",
                textDirection: TextDirection.rtl,
                color: white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(ProfileProvider user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: user.name,
                textDirection: TextDirection.rtl,
                color: white,
                weight: FontWeight.w700,
                size: 20,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: totalOrdersday.toString(),
                    textDirection: TextDirection.rtl,
                    color: white,
                  ),
                  SizedBox(width: 15),
                  CustomText(
                    text: "عدد الطلبات اليومية",
                    textDirection: TextDirection.rtl,
                    color: white,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 15),
        Image.asset("assets/images/13.png", height: 75, fit: BoxFit.fill),
      ],
    );
  }
}
