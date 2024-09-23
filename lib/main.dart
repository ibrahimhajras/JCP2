import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:jcp/loading.dart';
import 'package:jcp/provider/CountdownProvider.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderFetchProvider.dart';
import 'package:jcp/provider/ProductProvider.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:provider/provider.dart';
import 'provider/OrderProvider.dart';
import 'provider/ProfileProvider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    'resource://drawable/launch_background',
    [
      NotificationChannel(
        channelKey: 'basic_key',
        channelName: 'Test Channel',
        channelDescription: 'Notification channel for basic tests',
        channelShowBadge: true,
        playSound: true,
        defaultColor: Colors.red,
        ledColor: Colors.white,
      ),
    ],
  );
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
      ],
      child: MyApp(),
    ),
  );
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
