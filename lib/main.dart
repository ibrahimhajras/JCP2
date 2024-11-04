import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jcp/provider/CountdownProvider.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderFetchProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProductProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Trader/TraderOrderWidget.dart';
import 'package:jcp/screen/home/timer_service.dart';
import 'package:jcp/widget/DetialsOrder/GreenPage/OrderDetailsPage_Green.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'package:provider/provider.dart';
import 'package:jcp/NotificationService.dart';
import 'package:jcp/loading.dart';
import 'package:http/http.dart' as http;

import 'provider/ProfileTraderProvider.dart';
import 'widget/Inallpage/ErrorPage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();

  NotificationService notificationService = NotificationService();
  await notificationService.initNotification();

  final notificationAppLaunchDetails = await notificationService
      .notificationsPlugin
      .getNotificationAppLaunchDetails();
  String? initialPayload =
      notificationAppLaunchDetails?.notificationResponse?.payload;

  runApp(MyApp(initialPayload: initialPayload));
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'background_test',
    'MY FOREGROUND SERVICE',
    description: 'This is a foreground service running in the background',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
    ),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Running in Background",
      content: "Updating notifications...",
    );
    startTimer();
  }
}

class MyApp extends StatelessWidget {
  final String? initialPayload;

  MyApp({this.initialPayload});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => DeliveryModelOrange()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderDetailsProvider()),
        ChangeNotifierProvider(create: (_) => EditProductProvider()),
        ChangeNotifierProvider(create: (_) => CountdownProvider()),
        ChangeNotifierProvider(create: (_) => OrderFetchProvider()),
        ChangeNotifierProvider(create: (_) => ProfileTraderProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Car Parts',
        theme: ThemeData(
            textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.0),
          fontFamily: 'Tajawal',
          canvasColor: Colors.white,
          primarySwatch: Colors.red,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        home: initialPayload != null
            ? _handleInitialPayload(initialPayload!)
            : LoadingPage(),
        routes: {
          '/notification': (context) => NotificationPage(),
        },
      ),
    );
  }

  Widget _handleInitialPayload(String payload) {
    if (payload.contains('/orderDetails')) {
      String orderId = payload.split('/orderDetails/').last;
      return FutureBuilder(
        future: fetchOrderItemsFromUser(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else if (snapshot.hasError) {
            return ErrorPage(errorMessage: snapshot.error.toString());
          } else if (snapshot.hasData) {
            Map<String, dynamic> orderData =
            snapshot.data as Map<String, dynamic>;
            return OrderDetailsPage_Green(orderData: orderData);
          } else {
            return LoadingPage();
          }
        },
      );
    } else if (payload.contains('/pricingOrder')) {
      String orderId = payload.split('/pricingOrder/').last;
      return FutureBuilder(
        future: fetchOrderItemsOrange(orderId, 1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else if (snapshot.hasError) {
            return ErrorPage(errorMessage: snapshot.error.toString());
          } else if (snapshot.hasData) {
            Map<String, dynamic> orderData =
            snapshot.data as Map<String, dynamic>;
            List<dynamic> order1 = orderData['order'];
            List<dynamic> orderItems = orderData['order_items'];
            return OrderDetailsPage_Orange(
                order1: order1, orderItems: orderItems);
          } else {
            return LoadingPage();
          }
        },
      );
    } else if (payload.contains('/newOrder')) {
      String orderId = payload.split('/newOrder/').last;
      return FutureBuilder(
        future: fetchOrderDetails(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else if (snapshot.hasError) {
            return ErrorPage(errorMessage: snapshot.error.toString());
          } else if (snapshot.hasData) {
            Map<String, dynamic> orderDetails =
            snapshot.data as Map<String, dynamic>;
            return TraderOrderDetailsPage(orderDetails: orderDetails);
          } else {
            return LoadingPage();
          }
        },
      );
    } else if (payload.contains('/privateOrder/')) {
      String orderId = payload.split('/privateOrder/').last;
      _handleNewOrderprivate(orderId);
      return LoadingPage(); // Display a loading screen while navigating
    } else {
      return LoadingPage();
    }
  }
  Future<void> _handleNewOrderprivate(String orderId) async {
    try {
      List<dynamic> rawItems = await fetchOrderItems(orderId, 2);
      List<Map<String, dynamic>> items = rawItems.map((item) {
        return {
          'itemname': item['itemname'],
          'itemlink': item['itemlink'],
          'itemimg64': item['itemimg64'],
        };
      }).toList();
      Map<String, dynamic> orderData = await fetchOrderItemsOrangePrivate(orderId);
      await navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => OrderDetailsPage_OrangePrivate(
              orderData: orderData, items: items, carid: '',
          ),
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
          throw Exception(
              'Invalid response format: missing "hdr" or "items" keys');
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
