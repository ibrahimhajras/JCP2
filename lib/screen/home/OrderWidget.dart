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
import 'package:jcp/provider/OrderFetchProvider.dart';

class OrderWidget extends StatefulWidget {
  const OrderWidget({super.key});

  @override
  State<OrderWidget> createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool check = true;
  bool check2 = false;
  late Future<void> _ordersFuture = Future.value();

  Future<void> fetchOrdersForUser(BuildContext context, String userId) async {
    final url = Uri.parse('https://jordancarpart.com/Api/getordersofuser.php');
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final fetchProvider = Provider.of<OrderFetchProvider>(context, listen: false);

    try {
      fetchProvider.setState(FetchState.loading);

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
          orderProvider.setOrders(orders);

          if (mounted) {  // Check if still mounted before calling setState
            fetchProvider.setState(FetchState.loaded);
          }
          print('Orders updated successfully: ${orders.length} orders');
        } else {
          if (mounted) {  // Check if still mounted before calling setState
            fetchProvider.setState(FetchState.error);
          }
          print('Failed to load orders. Response: ${responseData['message']}');
        }
      } else {
        if (mounted) {  // Check if still mounted before calling setState
          fetchProvider.setState(FetchState.error);
        }
        print('Failed to load orders. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {  // Check if still mounted before calling setState
        fetchProvider.setState(FetchState.error);
      }
      print('Error fetching orders: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _ordersFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkForNotifications(); // Wait for the notification check to complete
    await Future.delayed(Duration.zero);  // Wait until the next frame
    final user = Provider.of<ProfileProvider>(context, listen: false);
    await fetchOrdersForUser(context, user.user_id);  // Fetch orders for the user
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

    if (mounted) {  // Ensure the widget is still in the widget tree
      setState(() {
        check2 = hasUnread;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fetchProvider = Provider.of<OrderFetchProvider>(context);
    return Container(
      child: Column(
        children: [
          _buildHeader(size),
          Container(
            height: size.height * 0.7,
            child: FutureBuilder(
              future: _ordersFuture,  // This will now have a value
              builder: (context, snapshot) {
                if (fetchProvider.state == FetchState.loading) {
                  return Center(child: RotatingImagePage());
                } else if (fetchProvider.state == FetchState.error) {
                  return Center(child: Text('لا يوجد طلبات'));
                } else {
                  return Consumer<OrderProvider>(
                    builder: (context, orderProvider, child) {
                      return ListView.builder(
                        itemCount: orderProvider.orders.length,
                        itemBuilder: (context, index) {
                          OrderModel order = orderProvider.orders[index];
                          return OrderViewWidget(order: order);
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
}
