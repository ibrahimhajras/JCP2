import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jcp/loading.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:jcp/provider/CarProvider.dart';
import 'package:jcp/provider/CountdownProvider.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/EngineSizeProvider.dart';
import 'package:jcp/provider/ImageProviderNotifier.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderFetchProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProductProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'provider/ProfileTraderProvider.dart';
import 'provider/TextInputState.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await Firebase.initializeApp();
  runApp(const OverlaySupport.global(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        ChangeNotifierProvider(create: (_) => ImageProviderNotifier()),
        ChangeNotifierProvider(create: (_) => CarProvider()),
        ChangeNotifierProvider(create: (_) => TextInputState()),
        ChangeNotifierProvider(create: (_) => EngineSizeProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Car Parts',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0,
              boldText: false,
              accessibleNavigation: false,
              disableAnimations: false,
            ),
            child: child!,
          );
        },
        theme: ThemeData(
          fontFamily: 'Tajawal',
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          textTheme: const TextTheme(
            displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            displayMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            displaySmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            headlineLarge: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            headlineSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
                height: 1.2),
            titleLarge: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                height: 1.2),
            titleMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                height: 1.2),
            titleSmall: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                height: 1.2),
            bodyLarge:
                TextStyle(fontSize: 16, fontFamily: 'Tajawal', height: 1.3),
            bodyMedium:
                TextStyle(fontSize: 14, fontFamily: 'Tajawal', height: 1.3),
            bodySmall:
                TextStyle(fontSize: 12, fontFamily: 'Tajawal', height: 1.3),
            labelLarge: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                height: 1.2),
            labelMedium: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                height: 1.2),
            labelSmall: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                fontFamily: 'Tajawal',
                height: 1.2),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
                height: 1.2,
              ),
            ),
          ),
          appBarTheme: const AppBarTheme(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
              color: Colors.black,
              height: 1.2,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            labelStyle: TextStyle(
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
            hintStyle: TextStyle(
              fontSize: 14,
              fontFamily: 'Tajawal',
              color: Colors.grey,
            ),
          ),
        ),
        home: const LoadingPage(),
      ),
    );
  }
}

class OrientationHelper {
  static Future<void> forcePortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> forcePortraitOnly() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }
}

class FixedPage extends StatelessWidget {
  final Widget child;

  const FixedPage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OrientationHelper.forcePortrait();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
        boldText: false,
      ),
      child: child,
    );
  }
}
