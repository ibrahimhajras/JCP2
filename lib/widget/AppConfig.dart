import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ✅ **أحجام الخط الثابتة للتطبيق**
class FontSizes {
  static const double tiny = 10;
  static const double small = 12;
  static const double medium = 14;
  static const double large = 16;
  static const double title = 18;
  static const double headline = 20;
  static const double display = 24;
  static const double hero = 28;
  static const double massive = 32;
}

class AppColors {
  Color primary1 = Color.fromRGBO(176, 45, 45, 1);
  Color primary2 = Color.fromRGBO(195, 29, 29, 1);
  Color primary3 = Color.fromRGBO(125, 10, 10, 1);
  Color red = Color.fromRGBO(195, 29, 29, 1);
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Color.fromRGBO(246, 246, 246, 1);
  Color green = Color.fromRGBO(54, 181, 67, 1);
  Color orange = Color.fromRGBO(246, 141, 44, 1);
  Color words = Color.fromRGBO(153, 153, 160, 1);
  Color button = Color.fromRGBO(195, 29, 29, 1);
}

class AppConfig {

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // تثبيت الاتجاه
    await setOrientation();

    // تثبيت شريط الحالة
    setSystemUI();
  }

  // ✅ **تثبيت الاتجاه - عمودي فقط**
  static Future<void> setOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // ✅ **إعداد شريط الحالة والنافذة**
  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // شريط الحالة
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,

        // شريط التنقل
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.grey,

        // منع اللمس خارج الشاشة
        systemNavigationBarContrastEnforced: false,
      ),
    );

    // ✅ **إخفاء الشاشة الكاملة عند الحاجة**
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ✅ **فرض إعادة تطبيق الاتجاه في أي وقت**
  static Future<void> forcePortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  // ✅ **إعدادات النص الثابتة**
  static MediaQueryData getFixedTextMediaQuery(MediaQueryData originalData) {
    return originalData.copyWith(
      textScaleFactor: 1.0,  // حجم ثابت
      boldText: false,       // منع النص العريض
      accessibleNavigation: false, // تبسيط التنقل
      disableAnimations: false,     // السماح بالحركات
      platformBrightness: Brightness.light, // سطوع ثابت
    );
  }



  // ✅ **Theme ثابت للتطبيق**
  static ThemeData getAppTheme() {
    return ThemeData(
      primarySwatch: Colors.red,
      fontFamily: 'Tajawal',

      // إعدادات النص
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: FontSizes.massive,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: FontSizes.hero,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
        displaySmall: TextStyle(
          fontSize: FontSizes.display,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontSize: FontSizes.headline,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: FontSizes.title,
          fontWeight: FontWeight.w600,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
        bodyLarge: TextStyle(
          fontSize: FontSizes.large,
          fontFamily: 'Tajawal',
          height: 1.3,
        ),
        bodyMedium: TextStyle(
          fontSize: FontSizes.medium,
          fontFamily: 'Tajawal',
          height: 1.3,
        ),
        bodySmall: TextStyle(
          fontSize: FontSizes.small,
          fontFamily: 'Tajawal',
          height: 1.3,
        ),
        labelLarge: TextStyle(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w500,
          fontFamily: 'Tajawal',
          height: 1.2,
        ),
      ),

      // إعدادات الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.w600,
            fontFamily: 'Tajawal',
            height: 1.2,
          ),
          minimumSize: const Size(120, 45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // إعدادات AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleTextStyle: TextStyle(
          fontSize: FontSizes.headline,
          fontWeight: FontWeight.bold,
          fontFamily: 'Tajawal',
          color: Colors.black,
          height: 1.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // إعدادات الحقول
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: TextStyle(
          fontSize: FontSizes.medium,
          fontFamily: 'Tajawal',
        ),
        hintStyle: TextStyle(
          fontSize: FontSizes.medium,
          fontFamily: 'Tajawal',
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ✅ **Widget للتطبيق الكامل مع الإعدادات**
class FixedOrientationApp extends StatelessWidget {
  final Widget child;

  const FixedOrientationApp({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // إعادة تطبيق الاتجاه عند كل بناء
    AppConfig.forcePortraitOrientation();

    return MediaQuery(
      data: AppConfig.getFixedTextMediaQuery(MediaQuery.of(context)),
      child: child,
    );
  }
}