import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jcp/screen/Trader/PendingPartsPage.dart';
import 'package:jcp/screen/driver/Home_Driver.dart';
import 'package:jcp/screen/driver/Index_Driver.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../widget/DetialsOrder/GreenPage/OrderDetailsPage_Green.dart';
import '../../widget/DetialsOrder/GreenPage/OrderDetailsPage_Greenprivate.dart';
import '../../widget/DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';
import '../../widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import '../Trader/TraderOrderWidget.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import '../../widget/DetialsOrder/RedPage/OrderDetails_red.dart' as red_details;

class NotificationPage extends StatefulWidget {
  NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);
    fetchAndShowNotifications();
    _markAllNotificationsAsRead(); // ✅ نعلم كل الإشعارات المحلية كمقروءة
  }
  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !_isFetchingMore &&
        _hasMore) {
      fetchAndShowNotifications(loadMore: true);
    }
  }

  int _limit = 50;
  int _offset = 0;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  ScrollController _scrollController = ScrollController();

  Future<void> fetchAndShowNotifications({bool loadMore = false}) async {
    if (loadMore) {
      setState(() {
        _isFetchingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        _offset = 0;
        notifications.clear();
        _hasMore = true;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");

    final url = Uri.parse(
        'https://jordancarpart.com/Api/get_notifications.php?user_id=$userId&limit=$_limit&offset=$_offset');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == "success") {
          List<dynamic> newNotifications = responseData['notifications'];

          setState(() {
            if (loadMore) {
              notifications.addAll(
                  newNotifications.map((n) => _mapNotification(n)).toList());
            } else {
              notifications =
                  newNotifications.map((n) => _mapNotification(n)).toList();
            }

            _offset += _limit;
            _hasMore = newNotifications.length == _limit;
          });
        }
      }
    } catch (e) {

    } finally {
      setState(() {
        isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  Map<String, dynamic> _mapNotification(dynamic n) {
    return {
      'id': n['id'].toString(),
      'message': n['body'] ?? "",
      'type': n['type'] ?? "",
      'orderid': n['orderid']?.toString() ?? "",
      'isRead': true,
    };
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> fetchNotifications(String userId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/notifications.php?user_id=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<dynamic> notifications = responseData['data'];
          await _storeNotifications(notifications);
        } else {}
      } else {}
    } catch (e) {}
  }

  Future<void> _storeNotifications(List<dynamic> notifications) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    Set<String> existingIds =
    storedNotifications.map((n) => jsonDecode(n)['id'].toString()).toSet();

    for (var notification in notifications) {
      if (!existingIds.contains(notification['id'].toString())) {
        storedNotifications.add(jsonEncode({
          'id': notification['id'],
          'message': notification['desc'],
          'isRead': false,
        }));
      }
    }

    await prefs.setStringList('notifications', storedNotifications);
  }



  Future<void> _markAllNotificationsAsRead() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];

    List<String> updatedNotifications = storedNotifications.map((notification) {
      Map<String, dynamic> notificationMap =
      Map<String, dynamic>.from(jsonDecode(notification));
      notificationMap['isRead'] = true;
      return jsonEncode(notificationMap);
    }).toList();

    await prefs.setStringList('notifications', updatedNotifications);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          SizedBox(height: size.height * 0.01),
          isLoading // ✅ إذا الصفحة ما زالت تحمّل
              ? Column(
            children: [
              SizedBox(height: size.height * 0.3),
              Center(child: RotatingImagePage()),
            ],
          ) // شاشة التحميل
              : Expanded(
            child: notifications.isEmpty
                ? Center(
              child: CustomText(
                text: "لا توجد إشعارات جديدة",
                color: Colors.grey,
                size: size.height * 0.02,
              ),
            )
                : _buildNotificationList(notifications, size),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.18,
      width: size.width,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: CustomText(
              text: "الإشعارات",
              size: size.width * 0.06,
              weight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
                size: size.width * 0.07,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
      List<Map<String, dynamic>> notifications, Size size) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == notifications.length) {
          return _isFetchingMore
              ? Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: RotatingImagePage()),
          )
              : SizedBox.shrink();
        }
        return _buildNotificationCard(notifications[index], index, size);
      },
    );
  }

  Future<void> deleteNotificationFromServer(String notificationId) async {
    final url =
    Uri.parse('https://jordancarpart.com/Api/delete_notification.php');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'id': notificationId}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
        } else {
        }
      } else {
      }
    } catch (e) {
    }
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, int index, Size size) {
    RegExp regExp = RegExp(r"\d+");
    String message = notification['message'] ?? " ";
    Iterable<Match> matches = regExp.allMatches(message);
    String number = matches.isNotEmpty ? matches.first.group(0) ?? "" : "";
    String messageWithoutNumber =
    message.replaceFirst(number, '').replaceAll(':', '').trim();
    return GestureDetector(
        onTap: () {
          final type = notification['type']?.toString() ?? "";
          final orderId = notification['orderid']?.toString() ?? "";
          print(type);
          if (type == "maintenance") {
            return;
          }

          if (type == "pricing") {
            fetchAndNavigateToOrderDetails(context, orderId);
            return;
          }

          if (type == "pricing2") {
            fetchAndNavigateToOrderDetailsOrangePrivate(context, orderId);
            return;
          }

          if (type == "admin_order_confirmed" || type == "user_order_confirmed") {
            fetchAndNavigateToOrderDetails2(context, orderId);
            return;
          }

          if (type == "private_order_confirmed") {
            fetchAndNavigateToOrderDetailsGreenPrivate(context, orderId);
            return;
          }

          if (type == "trader_order_received") {
            fetchAndNavigateToTraderOrderDetails(context, orderId);
            return;
          }

          if (type == "invitation" || type == "pending_parts") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PendingPartsPage()),
            );
            return;
          }

          if (type == "trader_orders") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TraderOrderWidget()),
            );
            return;
          }

          if (type == "contact_us") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ContactPage()),
            );
            return;
          }

          if (type == "stock_empty") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PendingPartsPage()),
            );
            return;
          }

          if (type == "home") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(page: 1)),
                  (route) => false,
            );
            return;
          }

          if (type == "private") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(page: 0)),
                  (route) => false,
            );
            return;
          }

          if (type == "orders") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage(page: 2)),
                  (route) => false,
            );
            return;
          }

          if (type == "notifications") {
            // We are already on the notification page, maybe refresh?
            // Or push a new instance if that's what is expected, but usually
            // staying put or refreshing is better.
            // Logic in NotificationService pushes NotificationPage.
            // Given we are IN NotificationPage, let's just refresh.
            fetchAndShowNotifications();
            return;
          }

          if (type == "see_photo") {
            handleSeePhoto(context, orderId);
            return;
          }

          // باقي الأنواع تجاهلها من دون أي أكشن
          return;
        },
        child: Dismissible(
          key: Key(notification['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: size.width * 0.05),
            color: red,
            child: Image.asset(
              'assets/images/deletenotification.png',
              width: size.width * 0.08,
              color: Colors.white,
            ),
          ),
          onDismissed: (direction) async {
            await deleteNotificationFromServer(notification['id']);
            setState(() {
              notifications.removeAt(index);
            });
          },
          child: Card(
            color: Colors.grey[50],
            margin: EdgeInsets.symmetric(
              vertical: size.height * 0.01,
              horizontal: size.width * 0.04,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
            ),
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.02,
                horizontal: size.width * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: RichText(
                        textAlign: TextAlign.right,
                        text: TextSpan(
                          children: _buildColoredTextSpans(message, size),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: messageWithoutNumber == "تم تأكيد الطلب رقم" ||
                          messageWithoutNumber.contains(
                              "تم شراء طلب جديد يرجى تجهيز القطع رقم")
                          ? Colors.green
                          : Colors.orange,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.asset(
                      messageWithoutNumber == "تم تأكيد الطلب رقم" ||
                          messageWithoutNumber.contains(
                              "تم شراء طلب جديد يرجى تجهيز القطع رقم")
                          ? "assets/images/green.png"
                          : "assets/images/orange.png",
                      width: size.width * 0.09,
                      height: size.height * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  List<TextSpan> _buildColoredTextSpans(String message, Size size) {
    final regExp = RegExp(r"\d+");

    // Convert literal \n to actual newlines
    // This handles cases where \n comes as text from backend
    String processedMessage = message.replaceAll(r'\n', '\n');

    List<TextSpan> spans = [];

    // Split message by \n to handle multi-line
    List<String> lines = processedMessage.split('\n');

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      String line = lines[lineIndex];
      final matches = regExp.allMatches(line);
      int lastEnd = 0;

      for (final match in matches) {
        // النص قبل الرقم
        if (match.start > lastEnd) {
          spans.add(TextSpan(
            text: line.substring(lastEnd, match.start),
            style: TextStyle(
              color: Colors.black,
              fontSize: size.height * 0.02,
              fontFamily: "Tajawal",
            ),
          ));
        }

        // الرقم نفسه بلون خاص
        final number = match.group(0)!;
        spans.add(TextSpan(
          text: number,
          style: TextStyle(
            color: _getNumberColor(message),
            fontSize: size.height * 0.02,
            fontWeight: FontWeight.bold,
            fontFamily: "Tajawal",
          ),
        ));

        lastEnd = match.end;
      }

      // النص بعد آخر رقم
      if (lastEnd < line.length) {
        spans.add(TextSpan(
          text: line.substring(lastEnd),
          style: TextStyle(
            color: Colors.black,
            fontSize: size.height * 0.02,
            fontFamily: "Tajawal",
          ),
        ));
      }

      // Add line break if not the last line
      if (lineIndex < lines.length - 1) {
        spans.add(TextSpan(text: '\n'));
      }
    }

    return spans;
  }

  Color _getNumberColor(String message) {
    if (message.contains("تأكيد")) return Colors.green;
    if (message.contains("تسعير")) return Colors.orange;
    if (message.contains("استلام") || message.contains("إستلام"))
      return Colors.orange;
    if (message.contains("تسعيرات")) return orange;
    return Colors.black;
  }

  Future<void> fetchAndNavigateToOrderDetails(
      BuildContext context, String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: RotatingImagePage());
      },
    );

    try {
      List<dynamic> orderItems2 = [];

      Map<String, dynamic> orderData =
      await fetchOrderItemsOrange(orderId.toString(), 1);

      final response = await http.get(
        Uri.parse(
            "https://jordancarpart.com/Api/gitnameorder.php?order_id=$orderId"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true &&
            jsonResponse.containsKey('items')) {
          orderItems2 = jsonResponse['items']; // ✅ استخراج القائمة الصحيحة
        }
      }

      if (orderData.isNotEmpty &&
          orderData.containsKey('order') &&
          orderData.containsKey('order_items')) {
        Map<String, dynamic> order1 = orderData['order'];
        List<dynamic> orderItems = orderData['order_items'];

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage_Orange(
              status: false,
              order1: order1,
              orderItems: orderItems,
              nameproduct: orderItems2.isNotEmpty
                  ? orderItems2
                  : List.filled(orderItems.length,
                  "غير معروف"), // ✅ إذا كانت فارغة، املأها
            ),
          ),
        );
      } else {
        throw Exception("Order data is missing required keys.");
      }
    } catch (e) {
      Navigator.pop(context);

    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrange(String orderId, int flag) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getorderacept.php?order_id=$orderId&flag=$flag');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ✅ Check if 'orders' key exists in the response
        if (responseData.containsKey('orders') &&
            (responseData['orders'] as List).isNotEmpty) {
          var order = responseData['orders'][0];

          return {'order': order, 'order_items': order['items'] ?? []};
        } else {
          return {
            'order': {},
            'order_items': []
          }; // Return empty if no orders exist
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {

      throw e;
    }
  }

  Future<void> fetchAndNavigateToOrderDetails2(
      BuildContext context, String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: RotatingImagePage());
      },
    );

    try {
      Map<String, dynamic> orderData = await fetchOrderItemsFromUser(orderId);


      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OrderDetailsPage_Green(
            orderData: orderData,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);



      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsFromUser(String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId');

    try {


      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);


        if (responseData.containsKey('hdr') &&
            responseData.containsKey('items')) {
          return {
            'header': responseData['hdr']
            [0], // Assuming there's only one header
            'items': responseData['items'], // List of items
          };
        } else {
          throw Exception(
              'Invalid response format: missing "hdr" or "items" keys');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {

      throw e;
    }
  }

  Future<void> fetchAndNavigateToTraderOrderDetails(
      BuildContext context, String order) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(child: RotatingImagePage()),
          );
        },
      );

      final orderDetails = await fetchOrderDetails(order.toString());

      Navigator.pop(context);


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TraderOrderDetailsPage(
            orderDetails: orderDetails,
            anotherParameter: 0,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل تفاصيل الطلب')),
      );
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

  Future<void> fetchAndNavigateToOrderDetailsOrangePrivate(
      BuildContext context, String order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: RotatingImagePage());
      },
    );

    try {
      List<dynamic> rawItems = await fetchOrderItems(order, 2);
      List<Map<String, dynamic>> items = rawItems.map((item) {
        return {
          'itemname': item['itemname'],
          'itemlink': item['itemlink'],
          'itemimg64': item['itemimg64'],
        };
      }).toList();

      Map<String, dynamic> orderData =
      await fetchOrderItemsOrangePrivate(order);

      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage_OrangePrivate(
              orderData: orderData,
              items: items,
              status: false,
            ),
          ),
        );
      }
    } catch (e) {
      // ✅ التأكد من إغلاق شاشة التحميل عند حدوث خطأ
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في جلب تفاصيل الطلب.')),
        );
      }

    }
  }

  Future<List<dynamic>> fetchOrderItems(String orderId, int flag) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getItemsFromOrders.php?order_id=$orderId&flag=$flag');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('order_items')) {
          return responseData['order_items'];
        } else if (responseData.containsKey('order_private_items')) {
          return responseData['order_private_items'];
        } else {
          throw Exception('Invalid response format: missing expected keys');
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {

      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrangePrivate(
      String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedprivateorder.php?order_id=$orderId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('data')) {
          List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            return data[0];
          } else {
            throw Exception('No data found for the given order ID');
          }
        } else {
          throw Exception('Invalid response format: missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {

      throw e;
    }
  }

  Future<void> fetchAndNavigateToOrderDetailsGreenPrivate(
      BuildContext context, String order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: RotatingImagePage());
      },
    );

    try {
      List<dynamic> rawItems = await fetchOrderItems(order, 2);
      List<Map<String, dynamic>> items = rawItems.map((item) {
        return {
          'itemname': item['itemname'],
          'itemlink': item['itemlink'],
          'itemimg64': item['itemimg64'],
        };
      }).toList();

      Map<String, dynamic> orderData =
      await fetchOrderItemsOrangePrivate(order);



      if (context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage_Greenprivate(
              orderData: orderData,
              items: items,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في جلب تفاصيل الطلب.')),
        );
      }

    }
  }

  Future<void> handleSeePhoto(BuildContext context, String orderId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: RotatingImagePage());
      },
    );

    try {
      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/getItemsFromOrders.php?flag=1&order_id=$orderId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['order_items'] != null) {
          if (context.mounted) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => red_details.OrderDetailsPage(
                  items: data['order_items'],
                  order_id: orderId,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
        );
      }
    }
  }
}
