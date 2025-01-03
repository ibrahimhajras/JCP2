import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jcp/screen/home/HomeWidget.dart';
import 'package:jcp/screen/home/OrderWidget.dart';
import 'package:jcp/screen/home/ProOrderWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

Future<JoinTraderModel?> fetchUserData(String userPhone) async {
  final url = Uri.parse('https://jordancarpart.com/Api/showalltraderdetails.php');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    if (data['success']) {
      List<dynamic> users = data['data'];
      final user = users.firstWhere((u) => u['user_phone'] == userPhone, orElse: () => null);

      if (user != null) {
        // Decode the JSON strings back to lists
        List<String> master = user['store_master'] is String
            ? List<String>.from(jsonDecode(user['store_master']))
            : List<String>.from(user['store_master']);

        List<String> partsType = user['store_parts_type'] is String
            ? List<String>.from(jsonDecode(user['store_parts_type']))
            : List<String>.from(user['store_parts_type']);

        List<String> activityType = user['store_activity_type'] is String
            ? List<String>.from(jsonDecode(user['store_activity_type']))
            : List<String>.from(user['store_activity_type']);

        final trader = JoinTraderModel(
          fName: user['user_name'].split(' ').first,
          lName: user['user_name'].split(' ').last,
          store: user['store_name'] ?? '',
          phone: user['user_phone'] ?? '',
          full_address: user['store_full_address'] ?? '',
          master: master,
          parts_type: partsType,
          activity_type: activityType,
        );

        // Print trader details
        trader.printDetails();

        return trader; // Return the trader object
      }
    }
  }
  return null; // Return null if no user is found
}

class _HomePageState extends State<HomePage> {
  int currentTab = 1;
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  late Widget current;
  bool isLoading = false;
  int? verificationValue;

  @override
  void initState() {
    super.initState();
    current = HomeWidget(
      run: (value) {
        setState(() {});
      },
    );
    currentTab = 1;
    _fetchDataAndSave();
    _loadVerificationValue();
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
          final verification =
          responseData['data'][0]['verification'];
          if (verification is int) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setInt('verification', verification);
            print("verification" + verification.toString());
            setState(() {
              verificationValue = verification;
            });
          }
        }
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {} finally {
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

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _key,
      endDrawer: Drawer(
          backgroundColor: white,
          width: size.width * 0.7,
          child: Stack(
            children: [
              Container(
                height: size.height,
                color: white,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 35),
                    Container(
                      height: 175,
                      child: Column(
                        children: [
                          Image.asset(
                            "assets/images/logo-05.png",
                            alignment: Alignment.center,
                            height: 90,
                            width: double.infinity,
                          ),
                          CustomText(
                            text: "قطع سيارات الاردن",
                            size: 14,
                            weight: FontWeight.w800,
                            textDirection: TextDirection.rtl,
                          ),
                          CustomText(
                            text: "Jordan Car Part",
                            size: 16,
                            weight: FontWeight.w700,
                            textDirection: TextDirection.ltr,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(),
                    ),
                    if (isLoading)
                      LinearProgressIndicator(
                        color: button,
                      ),
                    if (user.type == "2")
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });

                            fetchUserData(user.phone).then((fetchedUser) {
                              setState(() {
                                isLoading = false;
                              });

                              print("Fetched User: $fetchedUser");
                              if (fetchedUser != null) {
                                Provider.of<ProfileTraderProvider>(context,
                                        listen: false)
                                    .setTrader(fetchedUser);

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TraderInfoPage()),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                print("Trader not found");
                              }
                            }).catchError((error) {
                              setState(() {
                                isLoading = false;
                              });
                              print("An error occurred: $error");
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: "الصفحة الشخصية",
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/person_drawer.png",
                                height: 30,
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePage(),
                              ));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: "أنضم كتاجر",
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/handshake.png",
                                height: 30,
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TraderPage(),
                              ));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: "رؤيتنا",
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/light-bulb.png",
                                height: 30,
                                width: 30,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OurViewPage(),
                              ));
                        },
                      ),
                    ),
                    verificationValue == 0 ? SizedBox() :
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: "طلب تسعير",
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/4home.png",
                                height: 30,
                                width: 30,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PricingRequestPage(),
                              ));
                        },
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CustomText(
                                text: "تواصل معنا",
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Image.asset(
                                "assets/images/support.png",
                                height: 30,
                                width: 30,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactPage(),
                              ));
                        },
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Image.asset(
                          "assets/images/facebook.png",
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(width: 25),
                        GestureDetector(
                          onTap: () async {
                            await launchUrl(
                              Uri.parse(
                                  "https://api.whatsapp.com/send/?phone=962796888501"),
                              mode: LaunchMode.inAppBrowserView,
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/svg/whatsapp.svg',
                                height: 30,
                                width: 30,
                                colorFilter:
                                    ColorFilter.mode(black, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.12),
                      ],
                    ),
                    SizedBox(height: size.height * 0.2),
                    Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: size.width * 0.4,
                              child: MaterialButton(
                                onPressed: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
      body: SingleChildScrollView(
        child: current,
      ),
      backgroundColor: white,
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: white,
          border: Border(
            top: BorderSide(
              width: 1,
              color: words.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            MaterialButton(
              height: 50,
              minWidth: 30,
              onPressed: () {
                setState(() {
                  current = ProOrderWidget(
                    run: (value) {},
                  );
                  currentTab = 0;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: currentTab == 0
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: grey,
                          )
                        : BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        currentTab == 0
                            ? 'assets/images/sp-red.png'
                            : 'assets/images/sp.png',
                        width: 30,
                        height: 27,
                      ),
                    ),
                  ),
                  CustomText(
                    text: 'الخاصة',
                    color: currentTab == 0 ? red : Colors.grey,
                    weight: FontWeight.bold,
                  )
                ],
              ),
            ),
            MaterialButton(
              minWidth: 30,
              height: 50,
              onPressed: () {
                setState(() {
                  current = HomeWidget(
                    run: (value) {},
                  );
                  currentTab = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: currentTab == 1
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: grey,
                          )
                        : BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        currentTab == 1
                            ? 'assets/images/red home.png'
                            : 'assets/images/home.png',
                        width: 30,
                        height: 27,
                      ),
                    ),
                  ),
                  CustomText(
                    text: 'الرئيسية',
                    color: currentTab == 1 ? red : Colors.grey,
                    weight: FontWeight.bold,
                  )
                ],
              ),
            ),
            MaterialButton(
              minWidth: 30,
              height: 50,
              onPressed: () {
                setState(() {
                  current = OrderWidget();
                  currentTab = 2;
                });
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    decoration: currentTab == 2
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: grey,
                          )
                        : BoxDecoration(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(
                        currentTab == 2
                            ? 'assets/images/normal-red.png'
                            : 'assets/images/normal.png',
                        width: 30,
                        height: 27,
                      ),
                    ),
                  ),
                  CustomText(
                    text: 'الطلبات',
                    color: currentTab == 2 ? red : Colors.grey,
                    weight: FontWeight.bold,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
