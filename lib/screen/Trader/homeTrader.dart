import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import 'package:jcp/screen/Drawer/JoinAsTraderPage.dart';
import 'package:jcp/screen/Drawer/OurViewPage.dart';
import 'package:jcp/screen/Trader/AddProductTraderPage.dart';
import 'package:jcp/screen/Trader/EditStockWidget.dart';
import 'package:jcp/screen/Trader/TraderHomeWidget.dart';
import 'package:jcp/screen/Trader/TraderOrderWidget.dart';
import 'package:jcp/screen/Trader/TraderProfilePage.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;
import '../Drawer/PredictivePartsPage.dart';
import '../Drawer/PricingRequestPage.dart';
import '../home/homeuser.dart';

class TraderInfoPage extends StatefulWidget {
  static bool isEnabled = false;
  final int initialTab;

  const TraderInfoPage({super.key, this.initialTab = 1});

  @override
  State<TraderInfoPage> createState() => _TraderInfoPageState();
}

bool isLoading = false;

class _TraderInfoPageState extends State<TraderInfoPage> {
  late int currentTab;
  late Widget current;

  @override
  void initState() {
    super.initState();
    currentTab = widget.initialTab;
    _updateCurrentWidget();
  }

  void _updateCurrentWidget() {
    switch (currentTab) {
      case 0:
        current = EditStockWidget();
        break;
      case 1:
        current = TraderHomeWidget();
        break;
      case 2:
        current = TraderOrderWidget();
        break;
      default:
        current = TraderHomeWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: current,
      backgroundColor: white,
      endDrawer: Drawer(
        backgroundColor: white,
        width: MediaQuery.of(context).size.width *
            0.75,
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
                        height: MediaQuery.of(context).size.height *
                            0.1, // حجم متجاوب
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      CustomText(
                        text: "قطع سيارات الاردن",
                        size: MediaQuery.of(context).size.width *
                            0.04, // تكيف الحجم
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
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
                                  text: "الرجوع الى التطبيق",
                                  size: 18,
                                  color: white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            "assets/images/10.png",
                            height: 30,
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(page: 1),
                          ));
                    },
                  ),
                ),
                _buildDrawerButton(
                  text: "الصفحة الشخصية",
                  icon: "assets/images/person_drawer.png",
                  onTap: () {
                    setState(() {
                      isLoading = true;
                    });
                    final traderProvider = Provider.of<ProfileTraderProvider>(
                        context,
                        listen: false);
                    final trader1 = traderProvider.trader;

                    if (trader1 != null) {


                      setState(() {
                        isLoading = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TraderProfilePage(trader: trader1),
                        ),
                      );
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                ),
                _buildDrawerButton(
                  text: "أنضم كتاجر",
                  icon: "assets/images/handshake.png",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TraderPage()));
                  },
                ),

                _buildDrawerButton(
                  text: "رؤيتنا",
                  icon: "assets/images/light-bulb.png",
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OurViewPage()));
                  },
                ),
                _buildDrawerButton(
                  text: "طلب تسعير",
                  icon: "assets/images/4home.png",
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PricingRequestPage()));
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ContactPage()));
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton("tel:962795888268", "assets/images/call.png"),
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
      bottomNavigationBar:  BottomNavigationBar(
        iconSize: 30,
        currentIndex: currentTab,
        onTap: (index) {
          setState(() {
            currentTab = index;
            _updateCurrentTab(user.user_id);
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: red,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: "Tajawal",
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          fontFamily: "Tajawal",
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/06.png"),
              width: 25,
              height: 25,
            ),
            activeIcon: Image(
              image: AssetImage("assets/images/07.png"),
              width: 25,
              height: 25,
            ),
            label: "تعديل",
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/home.png"),
              width: 25,
              height: 25,
            ),
            activeIcon: Image(
              image: AssetImage("assets/images/red home.png"),
              width: 25,
              height: 25,
            ),
            label: "الرئيسية",
          ),
          BottomNavigationBarItem(
            icon: Image(
              image: AssetImage("assets/images/15.png"), // الطلبات
              width: 25,
              height: 25,
            ),
            activeIcon: Image(
              image: AssetImage("assets/images/16.png"),
              width: 25,
              height: 25,
            ),
            label: "الطلبيات",
          ),
        ],
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
  Widget _buildSocialButton2(String url, String iconPath) {
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
            height: 55,
            width: 55,
            colorFilter: ColorFilter.mode(black, BlendMode.srcIn),
          )
              : Image.asset(iconPath, height: 50, width: 50),
        ),
      ),
    );
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
                                  await prefs.clear();    await prefs.remove('vehicle_brand');
                                  await prefs.remove('vehicle_model');
                                  await prefs.remove('vehicle_year');
                                  await prefs.remove('vehicle_fuelType');
                                  await prefs.remove('vehicle_engineSize');
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

        } else {

        }
      } else {

      }
    } catch (e) {

    }
  }



  void _updateCurrentTab(String userId) {
    setState(() {
      _updateCurrentWidget();
    });
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
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: CustomText(
                      text: text,
                      size: MediaQuery.of(context).size.width * 0.04,
                      color: color != null ? white : black,
                    ),
                  ),
                ),
              ),
              Image.asset(icon,
                  height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
      BuildContext context, String text, String icon, VoidCallback onTap,
      {bool isActive = false}) {
    return Expanded(
      child: MaterialButton(
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, width: 30),
            SizedBox(height: 5),
            CustomText(
              text: text,
              size: getResponsiveFontSize(context, 12),
              color: isActive ? red : Colors.grey,
              weight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  double getResponsiveFontSize(BuildContext context, double fontSize) {
    return fontSize * MediaQuery.of(context).size.width / 400;
  }
}
