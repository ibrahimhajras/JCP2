import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/model/OrderModel.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/widget/OrderViewWidget.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/ProfileProvider.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/update.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> with WidgetsBindingObserver {
  bool check = true;
  bool check2 = false;
  bool hasNewNotification = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  Stream<List<OrderModel>> orderStream(
      BuildContext context, String userId) async* {
    while (true) {
      final orders = await fetchOrdersForUser(context, userId);
      yield orders;
      await Future.delayed(Duration(seconds: 10));
    }
  }

  Future<List<OrderModel>> fetchOrdersForUser(
      BuildContext context, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
        'https://jordancarpart.com/Api/getordersofuser.php?user_id=$userId&token=$token');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<OrderModel> orders = (responseData['data'] as List<dynamic>)
              .map((order) => OrderModel.fromJson(order))
              .toList();

          return orders;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForNotifications();
    Update.checkAndUpdate(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Container(
      child: Column(
        children: [
          _buildHeader(size),
          Expanded(
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
                      return OrderViewWidget(
                        order: order,
                        onDeleted: () {
                          setState(() {});
                        },
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

  Widget _buildHeader(Size size) {
    return CustomHeader(
      title: "سجل الطلبات",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildNotificationIcon(Size size) {
    return GestureDetector(
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
        height: size.width * 0.1,
        width: size.width * 0.1,
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

    setState(() {
      hasNewNotification = hasUnread;
    });
  }
}
