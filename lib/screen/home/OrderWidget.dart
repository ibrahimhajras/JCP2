import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/model/OrderModel.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/widget/OrderViewWidget.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/ProfileProvider.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/Inallpage/NotificationIcon.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool check = true;
  bool check2 = false;

  Stream<List<OrderModel>> orderStream(
      BuildContext context, String userId) async* {
    while (true) {
      final orders = await fetchOrdersForUser(context, userId);
      yield orders;
      await Future.delayed(Duration(seconds: 10));
    }
  }

  // Method to fetch orders for a specific user
  Future<List<OrderModel>> fetchOrdersForUser(
      BuildContext context, String userId) async {
    final url = Uri.parse('https://jordancarpart.com/Api/getordersofuser.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<OrderModel> orders = (responseData['data'] as List<dynamic>)
              .map((order) => OrderModel.fromJson(order))
              .toList();
          return orders;
        } else {
          print('Failed to load orders. Response: ${responseData['message']}');
          return [];
        }
      } else {
        print('Failed to load orders. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Container(
      child: Column(
        children: [
          _buildHeader(size),
          Container(
            height: size.height * 0.7,
            child: StreamBuilder<List<OrderModel>>(
              stream: orderStream(context, user.user_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: RotatingImagePage());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(child: Text('لا يوجد طلبات'));
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      OrderModel order = orders[orders.length - 1 - index];
                      return OrderViewWidget(order: order);
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

  Widget _buildHeader(Size size) {
    return CustomHeader(
      size: MediaQuery.of(context).size,
      title: "سجل الطلبات",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildNotificationIcon(Size size) {
    return NotificationIcon(
      size: size,
      check: check2,
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

  Future<void> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> notificationList =
        notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnread =
        notificationList.any((notification) => notification['isRead'] == false);

    if (mounted) {
      setState(() {
        check2 = hasUnread;
      });
    }
  }
}
