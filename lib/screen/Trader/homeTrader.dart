import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/screen/Drawer/ContactPage.dart';
import 'package:jcp/screen/Drawer/OurViewPage.dart';
import 'package:jcp/screen/Trader/AddProductTraderPage.dart';
import 'package:jcp/screen/Trader/EditStockWidget.dart';
import 'package:jcp/screen/Trader/TraderHomeWidget.dart';
import 'package:jcp/screen/Trader/TraderOrderWidget.dart';
import 'package:jcp/screen/Trader/TraderProfilePage.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';

class TraderInfoPage extends StatefulWidget {
  static bool isEnabled = false;

  const TraderInfoPage({super.key});

  @override
  State<TraderInfoPage> createState() => _TraderInfoPageState();
}

bool isLoading = false; // حالة التحميل

class _TraderInfoPageState extends State<TraderInfoPage> {
  int currentTab = 0;

  Widget current = TraderHomeWidget();

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
        width: size.width * 0.7,
        child: Container(
          height: size.height,
          color: white,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 35,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Divider(),
              ),
              SizedBox(
                height: 5,
              ),
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
                          builder: (context) => HomePage(),
                        ));
                  },
                ),
              ),
              Stack(
                children: [
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
                            SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              "assets/images/person_drawer.png",
                              height: 30,
                              width: 30,
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          isLoading = true;
                        });
                        final traderProvider =
                            Provider.of<ProfileTraderProvider>(context,
                                listen: false);
                        final trader1 = traderProvider.trader;

                        if (trader1 != null) {
                          print("User First Name: ${trader1.fName}");
                          print("User Last Name: ${trader1.lName}");
                          print("Store: ${trader1.store}");
                          print("Phone: ${trader1.phone}");
                          print("Full Address: ${trader1.full_address}");
                          print("Master Items: ${trader1.master}");
                          print("Parts Types: ${trader1.parts_type}");
                          print("Activity Types: ${trader1.activity_type}");

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
                          print("User not found in Provider");
                        }
                      },
                    ),
                  ),
                  if (isLoading)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(),
                    ),
                ],
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
                        SizedBox(
                          width: 10,
                        ),
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
                        SizedBox(
                          width: 10,
                        ),
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
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    "assets/images/facebook.png",
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(
                    width: 25,
                  ),
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
                          colorFilter: ColorFilter.mode(black, BlendMode.srcIn),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.12,
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.2,
              ),
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
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            await prefs.setBool('rememberMe', false);
                            await prefs.remove('phone');
                            await prefs.remove('password');
                            await prefs.remove('userId');
                            await prefs.remove('name');
                            await prefs.remove('type');
                            await prefs.remove('city');
                            List<String> notifications =
                                prefs.getStringList('notifications') ?? [];
                            await prefs.setStringList(
                                'notifications', notifications);
                            await prefs.setInt('isOrderAllowed', 0);
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            profileProvider.resetFields();
                            final OrderProvider1 = Provider.of<OrderProvider>(
                                context,
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
      ),
      bottomNavigationBar: Container(
        height: 80,
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
            Expanded(
              // Use Expanded or Flexible here
              child: MaterialButton(
                onPressed: () {
                  setState(() {
                    current = EditStockWidget();
                    currentTab = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Image.asset(
                        currentTab == 1
                            ? 'assets/images/07.png'
                            : 'assets/images/06.png',
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                    ),
                    CustomText(
                      text: 'تعديل البضاعة',
                      color: currentTab == 1 ? red : Colors.grey,
                      weight: FontWeight.bold,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              // Use Expanded or Flexible here
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.06,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddProductTraderPage()),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Image.asset(
                        'assets/images/01.png',
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ),
                    CustomText(
                      text: 'أضافة قطعة',
                      color: Colors.grey,
                      weight: FontWeight.bold,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              // Use Expanded or Flexible here
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.06,
                onPressed: () {
                  setState(() {
                    current = TraderOrderWidget(user.user_id);
                    currentTab = 0;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.02),
                      child: Image.asset(
                        currentTab == 0
                            ? 'assets/images/16.png'
                            : 'assets/images/15.png',
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.height * 0.05,
                      ),
                    ),
                    CustomText(
                      text: 'الطلبيات',
                      color: currentTab == 0 ? red : Colors.grey,
                      size: 15,
                      weight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
