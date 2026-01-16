import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:jcp/main.dart';
import 'package:jcp/screen/Trader/Outofstock.dart';
import 'package:jcp/screen/Trader/PendingPartsPage.dart';
import 'package:jcp/screen/Trader/TraderOrderWidget.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'package:jcp/widget/DetialsOrder/RedPage/OrderDetails_red.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import 'package:jcp/screen/Trader/ImageRequestsPage.dart';

class NotificationService {
  FirebaseMessaging? _firebaseMessaging;

  NotificationService() {
    _initFirebaseSafely();
  }

  Future<void> _initFirebaseSafely() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      _firebaseMessaging = FirebaseMessaging.instance;
    } catch (e) {
    }
  }

  Future<void> requestPermissionNotification() async {
    NotificationSettings settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
    }
  }

  void fcmConfig(BuildContext context) {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      String? title = message.notification?.title ?? 'عنوان غير متوفر';
      String? body = message.notification?.body ?? 'نص غير متوفر';
      String? messageId = message.messageId ?? DateTime.now().toString();

      showSnackBar(body);
      FlutterRingtonePlayer().play(
        android: AndroidSounds.notification,
        ios: IosSounds.glass,
        looping: false,
        volume: 0.1,
        asAlarm: false,
      );
      await _storeNotification(messageId, body);
      _createLocalNotification(messageId, title, body);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      String? type = message.data['type'];
      String? orderId = message.data['orderid'];

      if (type == 'maintenance') {
        return;
      }
      if (type == 'trader_order_received') {
        fetchAndNavigateToTraderOrderDetails(context, orderId.toString());
      }else if (type == 'pricing') {
        navigateToOrderDetails(orderId);
      } else if (type == 'pricing2') {
        handleNewOrderprivate(orderId!);
      } else if (type == 'order_received') {
        handleNewOrder(orderId!);
      } else if (type == 'stock_empty') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (context) => OutOfStockPage(),
              ));
        }
      } else if (type == 'invitation' || type == 'pending_parts') {
        if (navigatorKey.currentState != null) {
          // الذهاب لصفحة التاجر الرئيسية ثم فتح PendingPartsPage
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => TraderInfoPage()),
                (route) => false,
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => PendingPartsPage()),
            );
          }
        }
      } else if (type == 'trader_orders') {
        if (navigatorKey.currentState != null) {
          // الذهاب لصفحة التاجر مع فتح تاب الطلبات (index 2)
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TraderInfoPage(initialTab: 2)),
                (route) => false,
          );
        }
      } else if (type == 'contact_us') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(page: 3, openContactPage: true),
            ),
                (route) => false,
          );
        }
      } else if (type == 'home') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 1)),
                (route) => false,
          );
        }
      } else if (type == 'private') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 0)),
                (route) => false,
          );
        }
      } else if (type == 'orders') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 2)),
                (route) => false,
          );
        }
      } else if (type == 'see_photo' && orderId != null) {
        handleSeePhoto(orderId!);
      } else if (type == 'image_request') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 1)),
                (route) => false,
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const ImageRequestsPage()),
            );
          }
        }
      } else if (type == 'image_request_completed' && orderId != null) {
        navigateToOrderDetails(orderId!);
      } else if (type == 'part_image_uploaded') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 1)),
                (route) => false,
          );
          await Future.delayed(const Duration(milliseconds: 300));
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(builder: (context) => const PendingPartsPage()),
            );
          }
        }
      } else if (type == 'notifications') {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
        }
      } else {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage(page: 1)),
                (route) => false,
          );
        }
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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


  void showSnackBar(String message) {
    // Convert literal \n to actual newlines for proper display
    String processedMessage = message.replaceAll(r'\n', '\n');

    showSimpleNotification(
      Container(
        decoration: BoxDecoration(
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: CustomText(
                text: processedMessage,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      background: Colors.transparent,
      position: NotificationPosition.top,
      slideDismissDirection: DismissDirection.up,
      duration: Duration(seconds: 10),
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? body = message.notification?.body ?? 'نص غير متوفر';
    String? messageId = message.messageId ?? DateTime.now().toString();

    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];
    Set<String> existingIds =
    storedNotifications.map((n) => jsonDecode(n)['id'].toString()).toSet();

    if (!existingIds.contains(messageId)) {
      storedNotifications.add(jsonEncode({
        'id': messageId,
        'message': body,
        'isRead': false,
      }));
      await prefs.setStringList('notifications', storedNotifications);
    } else {
    }
  }

  Future<void> _storeNotification(String id, String body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> storedNotifications =
        prefs.getStringList('notifications') ?? [];
    Set<String> existingIds =
    storedNotifications.map((n) => jsonDecode(n)['id'].toString()).toSet();

    if (!existingIds.contains(id)) {
      storedNotifications.add(jsonEncode({
        'id': id,
        'message': body,
        'isRead': false,
      }));
      await prefs.setStringList('notifications', storedNotifications);
    } else {
    }
  }

  //------------------------------------------
  Future<void> handleNewOrder(String orderId) async {
    try {
      Map<String, dynamic> orderDetails = await fetchOrderDetails(orderId);
      if (navigatorKey.currentState != null) {
        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => TraderOrderDetailsPage(
              orderDetails: orderDetails,
              anotherParameter: 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل الطلب الجديد.')),
        );
      }
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

  Future<void> handleNewOrderprivate(String orderId) async {
    try {
      List<dynamic> rawItems = await fetchOrderItems(orderId, 2);
      List<Map<String, dynamic>> items = rawItems.map((item) {
        return {
          'itemname': item['itemname'],
          'itemlink': item['itemlink'],
          'itemimg64': item['itemimg64'],
        };
      }).toList();

      Map<String, dynamic> orderData =
      await fetchOrderItemsOrangePrivate(orderId);

      await navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => OrderDetailsPage_OrangePrivate(
            orderData: orderData,
            items: items,
            status: true,
          ),
        ),
      );
    } catch (e) {
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل التسعير.')),
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
            return data[0]; // Return the first element of 'data'
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

  void navigateToOrderDetails(String? orderId) async {
    if (orderId != null) {
      try {
        Map<String, dynamic> orderData =
        await fetchOrderItemsOrange(orderId.toString(), 1);
        List<dynamic> orderItems2 = [];

        final response = await http.get(
          Uri.parse(
              "https://jordancarpart.com/Api/gitnameorder.php?order_id=${orderId}"),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = json.decode(response.body);

          if (jsonResponse['success'] == true &&
              jsonResponse.containsKey('items')) {
            orderItems2 = jsonResponse['items'];
          }
        }

        if (orderData['order'].isNotEmpty &&
            orderData['order_items'].isNotEmpty) {
          Map<String, dynamic> order1 = orderData['order'];
          List<dynamic> orderItems = orderData['order_items'];

          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage_Orange(status: true,
                order1: order1, // ✅ Now it's a List<dynamic>
                orderItems: orderItems,
                nameproduct: orderItems2.isNotEmpty
                    ? orderItems2
                    : List.filled(orderItems.length, "غير معروف"),
              ),
            ),
          );
        } else {
        }
      } catch (e) {
      }
    } else {
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrange(
      String orderId, int flag) async {
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
          // ✅ Get the first order from the list
          var order = responseData['orders'][0];

          return {
            'order': order,
            // The main order data
            'order_items': order['items'] ?? []
            // The order items inside 'items' key
          };
        } else {
          return {
            'order': {},
            'order_items': []
          }; // Return empty if no orders exist
        }
      } else {
        throw Exception('Failed to load order');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> handleSeePhoto(String orderId) async {
    try {
      // First check order state
      final stateResponse = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/checkOrderInDatabase.php?order_id=$orderId'));

      if (stateResponse.statusCode == 200) {
        final stateData = json.decode(stateResponse.body);

        // Only proceed if order is in state 1 (red/pending)
        if (stateData['summary']?['order_state'] != 1) {
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text('الطلب تم تسعيره بالفعل'),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/getItemsFromOrders.php?flag=1&order_id=$orderId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['order_items'] != null) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => OrderDetailsPage(
                items: data['order_items'],
                order_id: orderId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
        );
      }
    }
  }

  void _createLocalNotification(String id, String title, String body) {
  }
}
