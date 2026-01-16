import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart'
    show showConfirmationDialog;
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;
import '../../../provider/ProfileProvider.dart';
import '../../../screen/Drawer/Notification.dart';
import '../../../style/colors.dart';
import '../../model/Delevery/Orders.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/Inallpage/NotificationIcon.dart';
import 'NoDataScreen.dart';
import 'OrderDetailsScreen.dart';

class Home_Driver extends StatefulWidget {
  Home_Driver({super.key});

  @override
  State<Home_Driver> createState() => _Home_DriverState();
}

class _Home_DriverState extends State<Home_Driver> {
  bool check = true;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    checkAndUpdate(context);
    _checkForNotifications();
  }

  Future<String?> getLocalVersion() async {
    try {
      final String buildVersion =
          await rootBundle.loadString('assets/version.txt');
      return buildVersion.trim();
    } catch (e) {
      
      return null;
    }
  }

  Future<String?> getServerVersion() async {
    final url = Uri.parse('https://jordancarpart.com/Api/getversion.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['version']['mobileversion'].toString();
        }
      }
    } catch (e) {
      
    }
    return null;
  }

  Future<void> checkAndUpdate(BuildContext context) async {
    String? localVersion = await getLocalVersion();
    String? serverVersion = await getServerVersion();

    if (localVersion != null &&
        serverVersion != null &&
        localVersion != serverVersion) {
      showConfirmationDialog(
        context: context,
        message: "تم إصدار نسخة جديدة من التطبيق. يرجى التحديث الآن",
        confirmText: "تحديث الآن",
        onConfirm: () {
          launchUrl(Uri.parse(
              "https://play.google.com/store/apps/details?id=com.zaid.Jcp.car"));
        },
        cancelText: null,
        onCancel: null,
      );
    }
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

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(size, context),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "بحث",
                hintStyle: TextStyle(
                    fontFamily: "Tajawal",
                    fontSize: isnormal ? 18 : 16,
                    color: Color(0xffA8A8A8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Order>>(
              stream: orderStream(context, user.user_id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: RotatingImagePage());
                } else if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(child: NoDataScreen());
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      Order order = orders[orders.length - 1 - index];
                      Map<String, dynamic> order2 =
                          orders[orders.length - 1 - index].toJson();

                      List<Map<String, dynamic>> uniqueTraders = [];
                      Set<int> seenTraderIds = {};

                      for (var trader
                          in order.traderDetails.map((t) => t.toJson())) {
                        if (!seenTraderIds.contains(trader['trader_id'])) {
                          seenTraderIds.add(trader['trader_id']);
                          uniqueTraders.add(trader);
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          Map<String, dynamic> selectedOrder2 = order2;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                order: order,
                                screentype: 0,
                                order2: selectedOrder2,
                              ),
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
                                    text: order.orderTime,
                                    size: isnormal ? 16 : 14,
                                    weight: FontWeight.bold,
                                    color: Color(0xffA8A8A8),
                                  ),
                                  CustomText(
                                    text: order.orderId.toString(),
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
                                    text: uniqueTraders.length.toString(),
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
                                    text: order.traderDetails.isNotEmpty &&
                                            order.traderDetails.first
                                                    .doneorder ==
                                                0
                                        ? "غير جاهز"
                                        : "جاهز",
                                    size: isnormal ? 16 : 14,
                                    weight: FontWeight.bold,
                                    color: order.traderDetails.isNotEmpty &&
                                            order.traderDetails.first
                                                    .doneorder ==
                                                0
                                        ? red
                                        : green,
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
        ],
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return CustomHeader(
      title: "طلبيات جديدة",
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
    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/delevery/get_delevery.php?state=0&persionid=0'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final utf8Response = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(utf8Response);

      if (jsonResponse != null && jsonResponse['data'] != null) {
        return OrderResponse.fromMap(jsonResponse).data;
      } else {
        throw Exception("البيانات غير صحيحة أو فارغة");
      }
    } else {
      throw Exception("فشل تحميل الطلبات: ${response.statusCode}");
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
