import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:jcp/NotificationService.dart';
import 'package:jcp/loading.dart';
import 'package:jcp/provider/CountdownProvider.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderFetchProvider.dart';
import 'package:jcp/provider/ProductProvider.dart';
import 'provider/OrderProvider.dart';
import 'provider/ProfileProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  NotificationService().initNotification();

  runApp(
    MultiProvider(
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
      child: const MyApp(),
    ),
  );
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

        for (var notification in notifications) {
          _createNotification(notification);
        }
      } else {}
    } else {}
  } catch (e) {}
}

void _createNotification(Map<String, dynamic> notification) {
  NotificationService().showNotification(
    id: notification['id'],
    title: 'قطع سيارات الاردن',
    body: notification['desc'],
  );
}

Future<void> _storeNotifications(List<dynamic> notifications) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> storedNotifications = prefs.getStringList('notifications') ?? [];

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

  List<String> currentStoredNotifications =
      prefs.getStringList('notifications') ?? [];
  print("Current stored notifications: $currentStoredNotifications");
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
  }

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      await fetchNotifications(userId);
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "Service Running",
          content: "قطع سيارات الاردن",
        );
      }
    } else {
      print("userId is null. Cannot fetch notifications.");
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Parts',
      theme: ThemeData(
        fontFamily: 'Tajawal',
        canvasColor: Colors.white,
        primarySwatch: Colors.red,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      home: LoadingPage(),
    );
  }
}
