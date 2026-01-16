import 'dart:convert';
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
import 'package:jcp/screen/Drawer/OurViewPage.dart';
import 'package:jcp/screen/Drawer/ProfilePage.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Archev_Driver.dart';
import 'Done_Order_Driver.dart';
import 'Home_Driver.dart';

  class Index_Driver extends StatefulWidget {
  final int page;

  const Index_Driver({required this.page, super.key});

  @override
  State<Index_Driver> createState() => _Index_DriverState();
}

Future<JoinTraderModel?> fetchUserData(String userPhone, BuildContext context) async {
  final url = Uri.parse('https://jordancarpart.com/Api/trader/getTraderInfo.php');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['success']) {
      List<dynamic> users = data['data'];
      final user = users.firstWhere(
              (u) => u['user_phone'] == userPhone && u['user_type'] == "2",
          orElse: () => null);

      if (user != null) {
        // ✅ التحقق من حالة الحساب
        bool isActive = user['store_is_active']?.toString() == "1";

        if (!isActive) {
          // ✅ عرض رسالة التوقيف
          final size = MediaQuery.of(context).size;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  CustomText(
                                    text: 'تم توقيف عضويتك. يرجى التواصل مع الدعم الفني.',
                                    color: black,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: CustomText(
                                      text: "حسنا",
                                      color: grey,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
          return null;
        }

        // ✅ معالجة البيانات
        List<String> master = parseList(user['store_master']);
        List<String> partsType = parseList(user['store_parts_type']);
        List<String> activityType = parseList(user['store_activity_type']);

        // ✅ قراءة الأعمدة الجديدة
        bool isOriginalCountry = user['store_is_original_country']?.toString() == "1";
        bool isCompany = user['store_is_company']?.toString() == "1";
        bool isCommercial = user['store_is_commercial']?.toString() == "1";
        bool isUsed = user['store_is_used']?.toString() == "1";
        bool isCommercial2 = user['store_is_commercial2']?.toString() == "1";

        final trader = JoinTraderModel(
          fName: user['user_name'].split(' ').first,
          lName: user['user_name'].split(' ').last,
          store: user['store_store'] ?? '',
          phone: user['user_phone'] ?? '',
          full_address: user['store_full_address'] ?? '',
          master: master,
          parts_type: partsType,
          activity_type: activityType,
          discountPercentage: user['store_discount_percentage'] ?? '',
          deliveryLimit: user['store_delivery_limit'] ?? '',
          location: user['store_location'] ?? '',
          normalPaymentInside: user['store_normal_payment_inside'] ?? '',
          urgentPaymentInside: user['store_urgent_payment_inside'] ?? '',
          normalPaymentOutside: user['store_normal_payment_outside'] ?? '',
          urgentPaymentOutside: user['store_urgent_payment_outside'] ?? '',

          // ✅ إضافة الحقول الجديدة
          isOriginalCountry: isOriginalCountry,
          isCompany: isCompany,
          isCommercial: isCommercial,
          isUsed: isUsed,
          isCommercial2: isCommercial2,
          // ✅ الحقول المنفصلة الجديدة
          isImageRequired: user['store_is_image_required']?.toString() == "1",
          isBrandRequired: user['store_is_brand_required']?.toString() == "1",
          isEngineSizeRequired: user['store_is_engine_size_required']?.toString() == "1",
          isYearRangeRequired: user['store_is_year_range_required']?.toString() == "1",
        );

        trader.printDetails();
        return trader;

      } else {
        // ✅ المستخدم غير موجود
        final size = MediaQuery.of(context).size;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return StatefulBuilder(
              builder: (BuildContext context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: size.width * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                CustomText(
                                  text: 'لم يتم العثور على حساب تاجر بهذا الرقم.',
                                  color: black,
                                  size: 15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: CustomText(
                                    text: "حسنا",
                                    color: grey,
                                    size: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        return null;
      }
    }
  }
  return null;
}

// ✅ Helper function
List<String> parseList(dynamic value) {
  if (value == null) return [];
  if (value is String) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      return [];
    }
  }
  return [];
}



class _Index_DriverState extends State<Index_Driver> {
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  late Widget current;
  late int currentTab;

  bool isLoading = false;
  int? verificationValue;

  @override
  void initState() {
    super.initState();
    currentTab = 1;
    if (widget.page == 0) {
      current = Archev_Driver(page: 0);
      currentTab = 0;
    } else if (widget.page == 1) {
      currentTab = 1;
      current = Home_Driver();
    } else {
      currentTab = 2;
      current = Done_Order_Driver(page: 2);
    }

  }

  Future<void> _fetchDataAndSave() async {
    const url = 'https://jordancarpart.com/Api/applyupload.php';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['data'] != null &&
            responseData['data'] is List &&
            responseData['data'].isNotEmpty) {
          final verification = responseData['data'][0]['verification'];
          if (verification is int) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('verification', verification);

            setState(() {
              verificationValue = verification;
            });
          }
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _key,
      endDrawer: Drawer(
        backgroundColor: white,
        width: MediaQuery.of(context).size.width *
            0.75,
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

              if (user.type == "2")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });

                      fetchUserData(user.phone, context).then((fetchedUser) {
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
                                builder: (context) => TraderInfoPage()),
                          );
                        } else {
                          
                        }
                      }).catchError((error) {
                        setState(() {
                          isLoading = false;
                        });
                        
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
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
                  _buildSocialButton(
                      "https://www.facebook.com/share/19iyooB38J/?mibextid=wwXIfr",
                      "assets/images/facebook.png"),
                  SizedBox(width: 20),
                  _buildSocialButton(
                      "https://api.whatsapp.com/send/?phone=962796888501",
                      'assets/svg/whatsapp.svg'),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // ✅ زر تسجيل الخروج
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _buildLogoutButton(),
              ),
            ],
          ),
        ),
      ),
      body: current,
      backgroundColor: white,
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          border: Border(
            top: BorderSide(width: 1, color: words.withOpacity(0.1)),
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildNavItem(
              context,
              iconActive: 'assets/images/sp-red.png',
              iconInactive: 'assets/images/sp.png',
              text: "الأرشيف",
              index: 0,
              page: Archev_Driver(page: 0),
            ),
            _buildNavItem(
              context,
              iconActive: 'assets/images/red home.png',
              iconInactive: 'assets/images/home.png',
              text: "جديد",
              index: 1,
              page: Home_Driver(),
            ),
            _buildNavItem(
              context,
              iconActive: 'assets/images/normal-red.png',
              iconInactive: 'assets/images/normal.png',
              text: "الطلبيات",
              index: 2,
              page: Done_Order_Driver(page: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String iconActive,
    required String iconInactive,
    required String text,
    required int index,
    required Widget page,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (currentTab != index) {
            setState(() {
              current = page;
              currentTab = index;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              currentTab == index ? iconActive : iconInactive,
              width: 30,
              height: 27,
            ),
            SizedBox(height: 4), // مسافة صغيرة بين الأيقونة والنص
            CustomText(
              text: text,
              color: currentTab == index ? red : Colors.grey,
              weight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
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

  Widget _buildSocialButton(String url, String iconPath) {
    return GestureDetector(
      onTap: () async {
        await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: iconPath.endsWith('.svg')
              ? SvgPicture.asset(iconPath,
                  height: 30,
                  width: 30,
                  colorFilter: ColorFilter.mode(black, BlendMode.srcIn))
              : Image.asset(iconPath, height: 30, width: 30),
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
                                  await prefs.clear();   await prefs.remove('vehicle_brand');
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
}
