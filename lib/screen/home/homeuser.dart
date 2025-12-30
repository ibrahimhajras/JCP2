import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import 'package:jcp/screen/Drawer/JoinAsTraderPage.dart';
import 'package:jcp/screen/Drawer/OurViewPage.dart';
import 'package:jcp/screen/Drawer/PricingRequestPage.dart';
import 'package:jcp/screen/Drawer/ProfilePage.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/screen/Trader/stoptrader.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/home/HomeWidget.dart';
import 'package:jcp/screen/home/OrderWidget.dart';
import 'package:jcp/screen/home/ProOrderWidget.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Drawer/PredictivePartsPage.dart';

class HomePage extends StatefulWidget {
  final int page;
  final bool openContactPage;

  const HomePage({required this.page, this.openContactPage = false, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<JoinTraderModel?> fetchUserData(
    String? userId,
    String? userPhone,
    BuildContext context,
    ) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    userId ??= prefs.getString('user_id');
    userPhone ??= prefs.getString('user_phone');

    if (userId == null || userPhone == null) {
      print('userId or userPhone is missing');
      return null;
    }

    final url = Uri.parse(
      'https://jordancarpart.com/Api/trader/getTraderInfo2.php'
          '?user_id=$userId&phone=$userPhone',
    );
    print(url);
    final response = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    print(userId);
    print(userPhone);
    print(response.body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'].isNotEmpty) {
        final user = data['data'][0];

        if (user['store_is_active'].toString() != "1") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Stoptrader()),
          );
          return null;
        }

        return JoinTraderModel(
          fName: user['user_name'].split(' ').first,
          lName: user['user_name'].split(' ').last,
          store: user['store_store'] ?? '',
          phone: user['user_phone'] ?? '',
          full_address: user['store_full_address'] ?? '',

          // ✅ لو فاضي → List فاضية
          master: user['store_master'] is List
              ? List<String>.from(user['store_master'])
              : [],

          parts_type: user['store_parts_type'] is List
              ? List<String>.from(user['store_parts_type'])
              : [],

          activity_type: user['store_activity_type'] is List
              ? List<String>.from(user['store_activity_type'])
              : [],

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
    print('fetchUserData error: $e');
  }
  return null;
}

class _HomePageState extends State<HomePage> {
  late int currentTab;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  late Widget current;
  bool isLoading = false;
  int? verificationValue;

  @override
  void initState() {
    super.initState();

    currentTab = (widget.page >= 0 && widget.page <= 2) ? widget.page : 1;

    switch (currentTab) {
      case 0:
        current = ProOrderWidget(run: (value) {});
        break;
      case 1:
        current = HomeWidget(run: (shouldNavigateToOrders) {
          if (shouldNavigateToOrders) {
            setState(() {
              currentTab = 2;
              current = const OrderWidget();
            });
          }
        });
        break;
      case 2:
        current = const OrderWidget();
        break;
      default:
        current = HomeWidget(run: (value) {});
    }

    _loadVerificationValue();

    if (widget.openContactPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactPage()),
        );
      });
    }
  }

  Future<void> _loadVerificationValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      verificationValue = prefs.getInt('verification');
      isLoading = false;
    });
  }

  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();

        final maxDuration = Duration(seconds: 2);

        final isWarning =
            lastPressed == null || now.difference(lastPressed!) > maxDuration;

        if (isWarning) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: 'اضغط مرة أخرى للخروج',
                color: Colors.white,
              ),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _key,
        endDrawer: Drawer(
          backgroundColor: white,
          width: MediaQuery.of(context).size.width * 0.75,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.22,
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/logo-05.png",
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        CustomText(
                          text: "قطع سيارات الاردن",
                          size: MediaQuery.of(context).size.width * 0.04,
                          weight: FontWeight.w800,
                        ),
                        CustomText(
                          text: "Jordan Car Part",
                          size: MediaQuery.of(context).size.width * 0.045,
                          weight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(),
                  ),
                  if (isLoading) LinearProgressIndicator(color: button),
                  if (user.type == "2")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoading = true;
                          });

                          fetchUserData(user.user_id, user.phone, context)
                              .then((fetchedUser) {
                            setState(() {
                              isLoading = false;
                            });

                            if (fetchedUser != null) {
                              Provider.of<ProfileTraderProvider>(context,
                                  listen: false)
                                  .setTrader(fetchedUser);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => TraderInfoPage()),
                              );
                            } else {}
                          });
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                      top: 5,
                                      bottom: 3,
                                    ),
                                    child: CustomText(
                                      text: "العضوية العادية",
                                      size: 18,
                                      color: white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/10.png",
                                height: 30,
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 5),
                  _buildDrawerButton(
                    text: "الصفحة الشخصية",
                    icon: "assets/images/person_drawer.png",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()));
                    },
                  ),
                  _buildDrawerButton(
                    text: "أنضم كتاجر",
                    icon: "assets/images/handshake.png",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TraderPage()));
                    },
                  ),
                  _buildDrawerButton(
                    text: "رؤيتنا",
                    icon: "assets/images/light-bulb.png",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OurViewPage()));
                    },
                  ),
                  if (_isPricingAllowed())
                    _buildDrawerButton(
                      text: "طلب تسعير",
                      icon: "assets/images/4home.png",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PricingRequestPage()),
                        );
                      },
                    ),
                  _buildDrawerButton(
                    text: "الأسماء التنبؤية للقطع",
                    icon: "assets/images/parts2.png",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PredictivePartsPage()));
                    },
                  ),
                  _buildDrawerButton(
                    text: "تواصل معنا",
                    icon: "assets/images/support.png",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactPage()));
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                          "tel:962795888268", "assets/images/call.png"),
                      SizedBox(width: 20),
                      _buildSocialButton(
                          "https://api.whatsapp.com/send/?phone=962796888501",
                          'assets/svg/whatsapp.svg'),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "السبت - الخميس",
                            size: 12,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 4),
                          CustomText(
                            text: "أوقات عمل التوصيل",
                            size: 12,
                            weight: FontWeight.bold,
                            color: black,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      CustomText(
                        text: "9:00 صباحاً - 5:00 مساءً",
                        size: 12,
                        color: Colors.grey[700],
                        textDirection: TextDirection.rtl,
                      )
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _buildLogoutButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: current,
        backgroundColor: white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentTab,
          onTap: (index) {
            setState(() {
              currentTab = index;
              _updateCurrentTab();
            });
          },
          backgroundColor: Colors.white,
          selectedItemColor: red,
          // أو أي لون تفضليه
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: "Tajawal",
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
            fontFamily: "Tajawal",
          ),
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/sp.png",
                width: 25,
                height: 25,
              ),
              activeIcon: Image.asset(
                "assets/images/sp-red.png",
                width: 25,
                height: 25,
              ),
              label: "الخاصة",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/home.png",
                width: 25,
                height: 25,
              ),
              activeIcon: Image.asset(
                "assets/images/red home.png",
                width: 25,
                height: 25,
              ),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/images/normal.png",
                width: 25,
                height: 25,
              ),
              activeIcon: Image.asset(
                "assets/images/normal-red.png",
                width: 25,
                height: 25,
              ),
              label: "الطلبات",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String url, String iconPath) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: iconPath.endsWith('.svg')
              ? SvgPicture.asset(
            iconPath,
            height: 30,
            width: 30,
            colorFilter: ColorFilter.mode(black, BlendMode.srcIn),
          )
              : Image.asset(iconPath, height: 30, width: 30),
        ),
      ),
    );
  }

  bool _isPricingAllowed() {
    final prefs = SharedPreferences.getInstance();

    String? savedPhone =
        Provider.of<ProfileProvider>(context, listen: false).phone;

    if (savedPhone == null) return false;

    savedPhone = savedPhone.replaceAll("+962", "").replaceAll("962", "");
    if (savedPhone.startsWith("0")) {
      savedPhone = savedPhone.substring(1);
    }

    if (savedPhone == "781771234" || savedPhone == "781771234") {
      return false;
    }

    return true;
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.06,
      child: MaterialButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "هل انت متأكد من تسجيل الخروج ؟",
                                color: black,
                                size: 15,
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.03),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Color.fromRGBO(153, 153, 160, 0.63),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: CustomText(
                                  text: "لا",
                                  color: white,
                                  size: 15,
                                ),
                              ),
                              SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.03),
                              ElevatedButton(
                                onPressed: () async {
                                  final prefs =
                                  await SharedPreferences.getInstance();
                                  String? token = prefs.getString('token');
                                  _removeFcmToken(token!);

                                  await prefs.clear();
                                  await prefs.remove('vehicle_brand');
                                  await prefs.remove('vehicle_model');
                                  await prefs.remove('vehicle_year');
                                  await prefs.remove('vehicle_fuelType');
                                  await prefs.remove('vehicle_engineSize');
                                  await prefs.setBool('rememberMe', false);
                                  await prefs.setBool('rememberMe', false);
                                  await prefs.remove('phone');
                                  await prefs.remove('password');
                                  await prefs.remove('userId');
                                  await prefs.remove('name');
                                  await prefs.remove('type');
                                  await prefs.remove('city');
                                  List<String> notifications =
                                      prefs.getStringList('notifications') ??
                                          [];
                                  await prefs.setStringList(
                                      'notifications', notifications);
                                  await prefs.setInt('isOrderAllowed', 0);
                                  final profileProvider =
                                  Provider.of<ProfileProvider>(context,
                                      listen: false);
                                  profileProvider.resetFields();
                                  final OrderProvider1 =
                                  Provider.of<OrderProvider>(context,
                                      listen: false);
                                  OrderProvider1.clearOrders();
                                  final orderDetailsProvider =
                                  Provider.of<OrderDetailsProvider>(context,
                                      listen: false);
                                  orderDetailsProvider.clear();
                                  final editProductProvider =
                                  Provider.of<EditProductProvider>(context,
                                      listen: false);
                                  editProductProvider.clear();
                                  final deliveryModel =
                                  Provider.of<DeliveryModelOrange>(context,
                                      listen: false);
                                  deliveryModel.clear();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()),
                                        (Route<dynamic> route) => false,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: CustomText(
                                  text: "نعم",
                                  color: grey,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.03),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        height: 45,
        minWidth: 50,
        color: Color.fromRGBO(195, 29, 29, 1),
        child: CustomText(
          text: "تسجيل الخروج",
          size: 16,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void unsubscribeFromTopic() {
    FirebaseMessaging.instance
        .unsubscribeFromTopic("all")
        .then((_) {})
        .catchError((e) {});
    FirebaseMessaging.instance
        .unsubscribeFromTopic("driver")
        .then((_) {})
        .catchError((e) {});
  }

  Future<void> _removeFcmToken(String token) async {
    final String apiUrl = "https://jordancarpart.com/Api/clear_fcm_token.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == "success") {
        } else {}
      } else {}
    } catch (e) {}
  }

  Widget _buildDrawerButton(
      {required String text,
        required String icon,
        Color? color,
        required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  color: color ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: CustomText(
                      text: text,
                      size: MediaQuery.of(context).size.width * 0.04,
                      color: color != null ? white : black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Image.asset(icon,
                  height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  void _updateCurrentTab() {
    setState(() {
      switch (currentTab) {
        case 0:
          current = ProOrderWidget(run: (value) {});
          break;
        case 1:
          current = HomeWidget(run: (shouldNavigateToOrders) {
            if (shouldNavigateToOrders) {
              setState(() {
                currentTab = 2;
                current = const OrderWidget();
              });
            }
          });
          break;
        case 2:
          current = const OrderWidget();
          break;
        default:
          current = HomeWidget(run: (value) {});
      }
    });
  }
}
