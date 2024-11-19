import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/Trader/TraderOrderWidget.dart';
import 'package:jcp/widget/DetialsOrder/GreenPage/OrderDetailsPage_Green.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../main.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
    const AndroidInitializationSettings('app_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {
          print('iOS Local Notification payload: $payload');
        });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          String payload = notificationResponse.payload!;

          if (payload.contains('/orderDetails/')) {
            String orderId = payload.split('/orderDetails/').last;
            _handleOrderDetails(orderId);
          } else if (payload.contains('/pricingOrder/')) {
            String orderId = payload.split('/pricingOrder/').last;
            _handlePricingOrder(orderId);
          } else if (payload.contains('/newOrder/')) {
            String orderId = payload.split('/newOrder/').last;
            _handleNewOrder(orderId);
          }
          else if (payload.contains('/privateOrder/')) {
            String orderId = payload.split('/privateOrder/').last;
            _handleNewOrderprivate(orderId);
          }
        }
      },
    );
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }
  Future<void> _handleNewOrderprivate(String orderId) async {
    try {
      List<dynamic> rawItems =
      await fetchOrderItems(orderId, 2);
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
              builder: (context) =>
                  OrderDetailsPage_OrangePrivate( orderData: orderData, items: items, carid: '',),
            ),
          );
    } catch (e) {
      print('Error fetching pricing order details: $e');
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل التسعير.')),
        );
      }
    }
  }
  Future<List<dynamic>> fetchOrderItems(String orderId, int flag) async {
    // تكوين رابط الطلب مع المعايير
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
      print('Error fetching order items: $e');
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
      print('Error fetching order details: $e');
      throw e;
    }
  }

  Future showNotification(
      {int? id, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin
        .show(id!, title, body, await notificationDetails(), payload: payLoad);
  }

  Future<void> _handleOrderDetails(String orderId) async {
    try {
      Map<String, dynamic> orderData = await fetchOrderItemsFromUser(orderId);
      print(orderData);
      if (navigatorKey.currentState != null) {
        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailsPage_Green(orderData: orderData),
          ),
        );
      }
    } catch (e) {
      print('Error fetching order items: $e');
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
        );
      }
    }
  }

  Future<void> _handlePricingOrder(String orderId) async {
    try {
      Map<String, dynamic> orderData = await fetchOrderItemsOrange(orderId, 1);
      print(orderData);
      if (navigatorKey.currentState != null) {
        List<dynamic> order1 = orderData['order'];
        List<dynamic> orderItems = orderData['order_items'];

        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) =>
                OrderDetailsPage_Orange(order1: order1,orderItems: orderItems,),
          ),
        );
      }
    } catch (e) {
      print('Error fetching pricing order details: $e');
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل التسعير.')),
        );
      }
    }
  }

  Future<void> _handleNewOrder(String orderId) async {
    try {
      Map<String, dynamic> orderDetails = await fetchOrderDetails(orderId);
      print(orderDetails);
      if (navigatorKey.currentState != null) {
        await navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) =>
                TraderOrderDetailsPage(orderDetails: orderDetails),
          ),
        );
      }
    } catch (e) {
      print('Error fetching new order details: $e');
      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('فشل في جلب تفاصيل الطلب الجديد.')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsFromUser(String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId');

    try {
      print('URL being sent: $url');
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
        print('Response Data: $responseData');

        if (responseData.containsKey('hdr') &&
            responseData.containsKey('items')) {
          return {
            'header': responseData['hdr'][0],
            'items': responseData['items'],
          };
        } else {
          throw Exception('Invalid response format: missing "hdr" or "items" keys');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
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

        if (responseData.containsKey('order') &&
            responseData.containsKey('order_items')) {
          return {
            'order': responseData['order'],
            'order_items': responseData['order_items']
          };
        } else {
          return {'order': [], 'order_items': []};
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order items: $e');
      throw e;
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
}
