import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jcp/NotificationService.dart';
import 'package:jcp/main.dart';
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/screen/Trader/Outofstock.dart';
import 'package:jcp/screen/Trader/PendingPartsPage.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/driver/Index_Driver.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import 'dart:convert';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  late Timer _timer;
  final NotificationService _notificationService = NotificationService();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  bool _hasInternet = true;
  bool _firebaseReady = false;
  bool _isChecking = false;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _initFirebaseSafely();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller!, curve: Curves.ease);
    _initDeepLink();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      bool hasNet = false;
      if (result is List) {
        hasNet = result.any((item) => item != ConnectivityResult.none);
      } else if (result is ConnectivityResult) {
        hasNet = result != ConnectivityResult.none;
      }

      if (hasNet && !_hasInternet) {
        setState(() {
          _hasInternet = true;
        });
        checkUserPreferences(context);
      } else if (!hasNet && _hasInternet) {
        setState(() {
          _hasInternet = false;
        });
      }
    });

    _timer = Timer(const Duration(milliseconds: 2500), () {
      checkUserPreferences(context);
    });
  }

  Future<void> _initFirebaseSafely() async {
    try {
      // Firebase.initializeApp() is already called in main.dart
      await FirebaseMessaging.instance.subscribeToTopic("all");
      await FirebaseMessaging.instance.subscribeToTopic("all2");
      _firebaseReady = true;
      _initializeNotifications(context);
    } catch (e) {
      _firebaseReady = false;
    }
  }

  Future<void> _checkInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _hasInternet = result != ConnectivityResult.none;
    });
  }

  void _initDeepLink() async {
    _appLinks = AppLinks();
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null && initialUri.host == "callback") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(page: 2)),
      );
    }

    _linkSub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.host == "callback" && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 2)),
        );
      }
    }, onError: (err) {});
  }

  Future<void> _initializeNotifications(BuildContext context) async {
    if (!_firebaseReady) return;
    try {
      _notificationService.requestPermissionNotification();
      _notificationService.fcmConfig(context);
    } catch (e) {}
  }

  Future<JoinTraderModel?> _loadTraderData(
      String userId, String userPhone) async {
    try {
      final url = Uri.parse(
        'https://jordancarpart.com/Api/trader/getTraderInfo2.php'
        '?user_id=$userId&phone=$userPhone',
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true &&
            data['data'] is List &&
            data['data'].isNotEmpty) {
          final user = data['data'][0];

          // ❌ التاجر موقوف
          if (user['store_is_active'].toString() != "1") {
            return null;
          }

          return JoinTraderModel(
            fName: user['user_name'].split(' ').first,
            lName: user['user_name'].split(' ').last,
            store: user['store_store'] ?? '',
            phone: user['user_phone'] ?? '',
            full_address: user['store_full_address'] ?? '',

            // ✅ الحقول المحذوفة من API → Lists فاضية
            master: [],
            parts_type: [],
            activity_type: [],

            discountPercentage: user['store_discount_percentage'] ?? '',
            deliveryLimit: user['store_delivery_limit'] ?? '',
            location: user['store_location'] ?? '',
            normalPaymentInside: user['store_normal_payment_inside'] ?? '',
            urgentPaymentInside: user['store_urgent_payment_inside'] ?? '',
            normalPaymentOutside: user['store_normal_payment_outside'] ?? '',
            urgentPaymentOutside: user['store_urgent_payment_outside'] ?? '',

            isOriginalCountry: user['store_is_original_country'] == "1",
            isCompany: user['store_is_company'] == "1",
            isCommercial: user['store_is_commercial'] == "1",
            isUsed: user['store_is_used'] == "1",
            isCommercial2: user['store_is_commercial2'] == "1",
            // ✅ الحقول المنفصلة الجديدة
            isImageRequired: user['store_is_image_required'] == "1",
            isBrandRequired: user['store_is_brand_required'] == "1",
            isEngineSizeRequired: user['store_is_engine_size_required'] == "1",
          );
        }
      }
    } catch (e) {
      print('_loadTraderData error: $e');
    }
    return null;
  }

  Future<void> _navigateToNotificationPage(RemoteMessage message) async {
    if (!mounted) return;

    String? type = message.data['type'];
    String? orderId = message.data['orderid'];

    try {
      if (type == 'trader_order_received') {
        await _notificationService.fetchAndNavigateToTraderOrderDetails(
            context, orderId.toString());
      } else if (type == 'pricing') {
        _notificationService.navigateToOrderDetails(orderId);
      } else if (type == 'pricing2') {
        await _notificationService.handleNewOrderprivate(orderId!);
      } else if (type == 'order_received') {
        await _notificationService.handleNewOrder(orderId!);
      } else if (type == 'stock_empty') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => OutOfStockPage()),
          );
        }
      } else if (type == 'invitation' || type == 'pending_parts') {
        // الذهاب لصفحة التاجر الرئيسية ثم فتح PendingPartsPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TraderInfoPage()),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => const PendingPartsPage()),
          );
        }
      } else if (type == 'trader_orders') {
        // الذهاب لصفحة التاجر مع فتح تاب الطلبات (index 2)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const TraderInfoPage(initialTab: 2)),
        );
      } else if (type == 'contact_us') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactPage()),
        );
      } else if (type == 'home') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
        );
      } else if (type == 'private') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 0)),
        );
      } else if (type == 'orders') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 2)),
        );
      } else if (type == 'see_photo' && orderId != null) {
        await _notificationService.handleSeePhoto(orderId!);
      } else if (type == 'notifications') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) => NotificationPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
        );
      }
    }
  }

  Future<void> checkUserPreferences(BuildContext c) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      bool rememberMe = prefs.getBool('rememberMe') ?? false;

      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (rememberMe) {
        String userId = prefs.getString('userId') ?? '';
        final response = await http.get(
          Uri.parse(
              'https://jordancarpart.com/Api/auth/TypeUser.php?user_id=$userId'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data['status'] == 'success') {
            int userType = data['type'];

            if (userType == 0) {
              await prefs.clear();

              showCustomDialog(
                context: context,
                message:
                    'لقد تم إيقاف حسابك مؤقتًا، يرجى التواصل مع خدمة العملاء.',
                confirmText: 'حسناً',
              );
            } else if (userType == 4) {
              String phone = prefs.getString('phone') ?? '';
              String password = prefs.getString('password') ?? '';
              String name = prefs.getString('name') ?? '';
              String city = prefs.getString('city') ?? '';
              String token = prefs.getString('token') ?? '';
              String createdAtString = prefs.getString('time') ?? '';
              String addressDetail = prefs.getString('addressDetail') ?? '';

              DateTime createdAt = createdAtString.isNotEmpty
                  ? DateTime.parse(createdAtString)
                  : DateTime.now();
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              profileProvider.setuser_id(userId);
              profileProvider.setphone(phone);
              profileProvider.setpassword(password);
              profileProvider.setname(name);
              profileProvider.settype(userType.toString());
              profileProvider.setcity(city);
              profileProvider.settoken(token);
              profileProvider.setcreatedAt(createdAt);
              profileProvider.setaddressDetail(addressDetail);

              if (initialMessage != null) {
                await _navigateToNotificationPage(initialMessage);
              } else {
                if (userType == 4) {
                  FirebaseMessaging.instance.subscribeToTopic("Driver");
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Index_Driver(page: 1),
                  ),
                );
              }
            } else {
              String phone = prefs.getString('phone') ?? '';
              String password = prefs.getString('password') ?? '';
              String name = prefs.getString('name') ?? '';
              String city = prefs.getString('city') ?? '';
              String token = prefs.getString('token') ?? '';
              String createdAtString = prefs.getString('time') ?? '';
              String addressDetail = prefs.getString('addressDetail') ?? '';

              DateTime createdAt = createdAtString.isNotEmpty
                  ? DateTime.parse(createdAtString)
                  : DateTime.now();
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              profileProvider.setuser_id(userId);
              profileProvider.setphone(phone);
              profileProvider.setpassword(password);
              profileProvider.setname(name);
              profileProvider.settype(userType.toString());
              profileProvider.setcity(city);
              profileProvider.settoken(token);
              profileProvider.setcreatedAt(createdAt);
              profileProvider.setaddressDetail(addressDetail);

              if (userType == 2) {
                final traderData = await _loadTraderData(userId, phone);
                if (traderData != null && mounted) {
                  final traderProvider = Provider.of<ProfileTraderProvider>(
                      context,
                      listen: false);
                  traderProvider.setTrader(traderData);
                }
              }

              if (initialMessage != null) {
                await _navigateToNotificationPage(initialMessage);
              } else {
                if (userType == 1) {
                  FirebaseMessaging.instance.subscribeToTopic("User");
                } else if (userType == 2) {
                  FirebaseMessaging.instance.subscribeToTopic("Trader");
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(page: 1),
                  ),
                );
              }
            }
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        await prefs.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInternet = false;
        });
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _linkSub?.cancel();
    _connectivitySubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEA3636),
                  Color(0xFFC31D1D),
                  Color(0xFF7D0A0A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 35),
                SvgPicture.asset(
                  'assets/svg/logo-05.svg',
                  width: 75,
                  height: 75,
                  colorFilter: const ColorFilter.mode(
                      Color.fromRGBO(246, 246, 246, 1), BlendMode.srcIn),
                ),
                RotationTransition(
                  turns: _animation!,
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: Image.asset('assets/images/logo-loading.png'),
                  ),
                ),
                if (!_hasInternet) ...[
                  const SizedBox(height: 20),
                  const Icon(Icons.wifi_off, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    "لا يوجد اتصال بالإنترنت",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _checkInternetConnection();
                      if (_hasInternet) checkUserPreferences(context);
                    },
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("إعادة المحاولة",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showCustomDialog({
    required BuildContext context,
    required String message,
    required String confirmText,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(confirmText,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
