import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProductProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Trader/ImageRequestsPage.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/ProfileTraderProvider.dart' show ProfileTraderProvider;
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/update.dart';
import 'Outofstock.dart';
import 'PendingPartsPage.dart';

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
  int lengthItems = 0;
  bool _isInitialized = false;
  int total = 0;
  int pendingPartsCount = 0;
  bool isLoadingPendingParts = false;
  int imageRequestsCount = 0;
  bool isLoadingImageRequests = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      fetchOrders(user.user_id, 1);
      fetchOrders(user.user_id, 2);
      fetchLengthData(user.user_id);
      loadTraderInvitationsCount();
      loadImageRequestsCount();
      _checkForNotifications();
      _isInitialized = true;
    }
  }

  Future<int> fetchTotalParts(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
      'http://jordancarpart.com/Api/get_total_parts.php?user_id=$userId&token=$token',
    );

    final response = await http.get(url);
    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('total')) {
        return int.tryParse(jsonResponse['total'].toString()) ?? 0;
      } else {
        throw Exception('Key "total" not found in response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Exception parsing total: $e\nBody: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    Update.checkAndUpdate(context);
    Future.delayed(Duration.zero, () async {
      if (mounted) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final user = Provider.of<ProfileProvider>(context, listen: false);
        productProvider.loadProducts(user.user_id);

        int totalFetched = await fetchTotalParts(user.user_id);
        if (mounted) {
          setState(() {
            total = totalFetched;
          });
        }
      }
    });
    _checkForNotifications();
  }

  Future<void> loadTraderInvitationsCount() async {
    if (isLoadingPendingParts) return;

    final user = Provider.of<ProfileProvider>(context, listen: false);

    setState(() {
      isLoadingPendingParts = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/trader/getTraderInvitationsCount1.php?user_id=${user.user_id}'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          final data = responseData['data'];
          final newCount = data['pending_invitations_count'] ?? 0;

          // ✅ فقط حدّث إذا القيمة فعلاً تغيّرت
          if (mounted && newCount != pendingPartsCount) {
            setState(() {
              pendingPartsCount = newCount;
            });
          }
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          isLoadingPendingParts = false;
        });
      }
    }
  }

  Future<void> loadImageRequestsCount() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);

    setState(() {
      isLoadingImageRequests = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/get_image_requests.php?trader_id=${user.user_id}'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          final newCount = responseData['count'] ?? 0;

          if (mounted && newCount != imageRequestsCount) {
            setState(() {
              imageRequestsCount = newCount;
            });
          }
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          isLoadingImageRequests = false;
        });
      }
    }
  }

  Future<void> fetchLengthData(String userId) async {
    String url =
        "https://jordancarpart.com/Api/Out_of_stock.php?user_id=$userId";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey("data") && responseData["data"] is List) {
          setState(() {
            lengthItems = responseData["data"].length; // Update UI
          });
        } else {
          setState(() {
            lengthItems = 0;
          });
        }
      } else {}
    } catch (error) {}
  }

  Future<List<dynamic>> fetchOrders(String user_id, int flag) async {
    final response = await http.get(Uri.parse(
        'https://jordancarpart.com/Api/showallordersoftrader.php?trader_id=${user_id}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success']) {
        final List<dynamic> orders = responseData['orders'];

        if (flag == 1) {
          if (!mounted) return orders;
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

          if (!mounted) return filteredOrders;
          setState(() {
            totalOrdersday = filteredOrders.length;
          });

          return filteredOrders;
        }
        return [];
      }
      return [];
    }
    return [];
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
            _buildHeader(size, user),
            Container(
              height: size.height * 0.52,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProductOrderCard(size, user),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Image Requests Button (Moved to Row Left)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(
                                    text: "طلبات الصور",
                                    color: Colors.black,
                                    textDirection: TextDirection.rtl,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ImageRequestsPage(),
                                        ),
                                      ).then((_) {
                                        Future.delayed(
                                            const Duration(milliseconds: 350),
                                            () {
                                          if (mounted) loadImageRequestsCount();
                                        });
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 50),
                                      decoration: BoxDecoration(
                                        color: orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: 40,
                                        height: 25,
                                        child: Center(
                                          child: isLoadingImageRequests
                                              ? RotatingImagePage()
                                              : CustomText(
                                                  text: imageRequestsCount
                                                      .toString(),
                                                  color: white,
                                                  size: 18,
                                                  weight: FontWeight.bold,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              // Pending Parts (Stays Right)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(
                                    text: "قطع للتسعير",
                                    color: Colors.black,
                                    textDirection: TextDirection.rtl,
                                    size: 16,
                                  ),
                                  const SizedBox(height: 5),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PendingPartsPage(),
                                        ),
                                      ).then((_) {
                                        Future.delayed(
                                            const Duration(milliseconds: 350),
                                            () {
                                          if (mounted)
                                            loadTraderInvitationsCount();
                                        });
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 50),
                                      decoration: BoxDecoration(
                                        color: green,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: SizedBox(
                                        width: 40,
                                        height: 25,
                                        child: Center(
                                          child: isLoadingPendingParts
                                              ? RotatingImagePage()
                                              : CustomText(
                                                  text: pendingPartsCount
                                                      .toString(),
                                                  color: white,
                                                  size: 18,
                                                  weight: FontWeight.bold,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          // Out Of Stock Button (Moved to Bottom)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const OutOfStockPage()),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: "قطع نفذت كميتها",
                                  color: Colors.black,
                                  textDirection: TextDirection.rtl,
                                  size: 16,
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 50),
                                  decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: CustomText(
                                    text: lengthItems.toString(),
                                    color: white,
                                    size: 18,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  Future<Map<String, dynamic>?> getTraderInvitationsCount() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);

    try {
      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/trader/getTraderInvitationsCount1.php?user_id=${user.user_id}'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          return responseData['data'];
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void loadTraderStats() async {
    final data = await getTraderInvitationsCount();
    if (data != null) {}
  }

  Widget _buildHeader(Size size, ProfileProvider user) {
    return CustomHeader(
      title: user.name ?? "",
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
          color: const Color.fromRGBO(246, 246, 246, 0.26),
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

  Widget _buildProductOrderCard(Size size, ProfileProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: size.height * 0.24, // ✅ تقليل الارتفاع
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage("assets/images/card-1.png"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.03), // ✅ تقليل الـ padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildUserInfo(user, size),
              SizedBox(height: size.height * 0.008), // ✅ تقليل المساحة
              Expanded(
                // ✅ استخدام Expanded للمحتوى المتبقي
                child: _buildOrderStats(size, user),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(ProfileProvider user, Size size) {
    final trader = Provider.of<ProfileTraderProvider>(context).trader;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomText(
          text: trader!.store,
          color: white,
          weight: FontWeight.bold,
          size: size.width * 0.05,
        ),
        SizedBox(width: size.width * 0.03),
        Image.asset(
          "assets/images/09.png",
          height: size.height * 0.07,
          fit: BoxFit.fill,
        ),
      ],
    );
  }

  Widget _buildOrderStats(Size size, ProfileProvider user) {
    final trader = Provider.of<ProfileTraderProvider>(context).trader;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ توزيع متساوي
      children: [
        _buildStatsRow([
          //_buildStatItem(":مجموع الطلبات", totalOrders.toString()),
          _buildStatItem(":عدد الطلبات اليومية", totalOrdersday.toString()),
        ]),
        _buildStatsRow([
          // _buildStatItem(":عدد المخالفات", "0"),
          Consumer<ProductProvider>(builder: (context, productProvider, child) {
            return _buildStatItem(":مجموع القطع", "${total}");
          })
        ]),
        /* _buildStatsRow([
          _buildStatItem(
              ":فوري داخل المحافظة",
              trader!.urgentPaymentInside.isEmpty
                  ? "0"
                  : trader.urgentPaymentInside),
          _buildStatItem(
              ":عادي داخل المحافظة",
              trader!.normalPaymentInside.isEmpty
                  ? "0"
                  : trader.normalPaymentInside),
        ]),
        _buildStatsRow([
          _buildStatItem(
              ":فوري خارج المحافظة",
              trader!.urgentPaymentOutside.isEmpty
                  ? "0"
                  : trader.urgentPaymentOutside),
          _buildStatItem(
              ":عادي خارج المحافظة",
              trader!.normalPaymentOutside.isEmpty
                  ? "0"
                  : trader.normalPaymentOutside),
        ]),*/
        _buildSingleStatItem(
            ":نسبة الخصم",
            trader!.discountPercentage.isEmpty
                ? "غ.م"
                : trader.discountPercentage.replaceAll('%', '')),
        _buildSingleStatItem(":حدود التوصيل",
            trader!.deliveryLimit.isEmpty ? "غ.م" : trader.deliveryLimit),
      ],
    );
  }

  Widget _buildStatsRow(List<Widget> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }

  Widget _buildSingleStatItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.normal,
              fontSize: 12,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.normal,
              fontSize: 11,
              fontFamily: 'Tajawal',
            ),
          ),
          const SizedBox(width: 3),
          Text(
            title,
            style: TextStyle(
              color: white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
