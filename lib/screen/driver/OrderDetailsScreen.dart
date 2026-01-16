import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/Delevery/Item.dart';
import '../../model/Delevery/Trader.dart';
import '../../provider/DeliveryModel.dart';
import '../../provider/EditProductProvider.dart';
import '../../provider/OrderDetailsProvider.dart';
import '../../provider/OrderProvider.dart';
import '../../provider/ProfileProvider.dart';
import '../../provider/ProfileTraderProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/Inallpage/NotificationIcon.dart';
import '../Drawer/ContactPage.dart';
import '../Drawer/Notification.dart';
import '../Drawer/OurViewPage.dart';
import '../Drawer/ProfilePage.dart';
import '../Trader/homeTrader.dart';
import '../auth/login.dart';
import 'Home_Driver.dart';
import 'Index_Driver.dart';
import 'detailsorder.dart';

class OrderDetailsScreen extends StatefulWidget {
  final order;
  final int screentype;
  Map<String, dynamic> order2;

  OrderDetailsScreen(
      {required this.order, required this.screentype, required this.order2});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  bool check = true;
  late Widget current;
  late int currentTab;
  TextEditingController noteC = TextEditingController();

  bool isLoading = false;
  int? verificationValue;

  @override
  void initState() {
    super.initState();
    currentTab = 1;
    current = Home_Driver();
    _checkForNotifications();
  }

  Widget _buildNotificationIcon(Size size) {
    return NotificationIcon(
      size: size,
      check: check,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationPage(),
          ),
        ).then((_) {
          _checkForNotifications();
        });
      },
    );
  }

  Widget _buildMenuIcon(BuildContext context, Size size) {
    return MenuIcon(
      size: size,
      onTap: () {
        _key.currentState!.openEndDrawer();
      },
    );
  }

  Widget _buildDrawerButton({required String text,
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
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.05,
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
                      size: MediaQuery
                          .of(context)
                          .size
                          .width * 0.04,
                      color: color != null ? white : black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Image.asset(icon,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return CustomHeader(
      title: widget.screentype == 2 ? "تفاصيل الطلبية المنجزة" : "تفاصيل الطلب",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Future<bool> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    List<Map<String, dynamic>> notificationList =
    notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnreadNotifications =
    notificationList.any((notification) => notification['isRead'] == false);

    setState(() {
      check = hasUnreadNotifications;
    });

    return hasUnreadNotifications;
  }

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery
        .of(context)
        .textScaleFactor;
    bool isnormal = textScaleFactor <= 1;
    final size = MediaQuery
        .of(context)
        .size;
    final user = Provider.of<ProfileProvider>(context);
    Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.center,
          child: CustomText(
            text: title,
            size: 18,
            weight: FontWeight.bold,
            color: Colors.black,
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
          height: MediaQuery
              .of(context)
              .size
              .height * 0.05,
          width: MediaQuery
              .of(context)
              .size
              .height * 0.05,
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
        width: MediaQuery
            .of(context)
            .size
            .width * 0.4,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.06,
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
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromRGBO(255, 255, 255, 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                height:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.03),
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
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.03),
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
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.03),
                                ElevatedButton(
                                  onPressed: () async {
                                    final prefs =
                                    await SharedPreferences.getInstance();
                                    String? userId = prefs.getString('userId');
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
                                    Provider.of<OrderDetailsProvider>(
                                        context,
                                        listen: false);
                                    orderDetailsProvider.clear();
                                    final editProductProvider =
                                    Provider.of<EditProductProvider>(
                                        context,
                                        listen: false);
                                    editProductProvider.clear();
                                    final deliveryModel =
                                    Provider.of<DeliveryModelOrange>(
                                        context,
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
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.03),
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

    final screenWidth = size.width;
    List<Trader> uniqueTraders = [];
    Set<int> seenTraderIds = {};

    for (var trader in widget.order.traderDetails) {
      Trader traderObj = trader is Trader ? trader : Trader.fromMap(trader);
      if (!seenTraderIds.contains(traderObj.traderId)) {
        seenTraderIds.add(traderObj.traderId);
        uniqueTraders.add(traderObj);
      }
    }

    return Scaffold(
      key: _key,
      endDrawer: Drawer(
        backgroundColor: white,
        width: MediaQuery
            .of(context)
            .size
            .width *
            0.75, // اجعلها تأخذ 75% من عرض الشاشة
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.02),
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.22,
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/logo-05.png",
                        height: MediaQuery
                            .of(context)
                            .size
                            .height *
                            0.1, // حجم متجاوب
                        width: double.infinity,
                        fit: BoxFit.contain,
                      ),
                      CustomText(
                        text: "قطع سيارات الاردن",
                        size: MediaQuery
                            .of(context)
                            .size
                            .width *
                            0.04, // تكيف الحجم
                        weight: FontWeight.w800,
                      ),
                      CustomText(
                        text: "Jordan Car Part",
                        size: MediaQuery
                            .of(context)
                            .size
                            .width * 0.045,
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
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.02),
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
                SizedBox(height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: _buildLogoutButton(),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            _buildHeader(size, context),
            Expanded(
              child: SingleChildScrollView(
                child: widget.screentype == 1
                    ? Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    _buildSectionTitle('المركبة'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF6F6F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  CustomText(
                                    color: Color(0xFF8D8D92),
                                    text:
                                    "${widget.order.engineType.toString()} "
                                        "${widget.order.fuelType.toString()} "
                                        "${widget.order.engineYear.toString()} "
                                        "${widget.order.engineCategory
                                        .toString()} "
                                        "${widget.order.engineSize
                                        .toString()}L",
                                  ),
                                ],
                              ),
                              CustomText(
                                text: widget.order.carid.toString(),
                                color: Color(0xFF8D8D92),
                                letters: true,
                              )
                            ],
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width / 1.1,
                      child: Center(
                        child: Row(
                          children: [
                            Spacer(),
                            CustomText(
                              text: widget.order.orderId.toString(),
                              size: 16,
                              color: Colors.black,
                              weight: FontWeight.bold,
                            ),
                            CustomText(
                              text: ": رقم الطلب ",
                              size: 16,
                              color: Colors.black,
                              weight: FontWeight.bold,
                            ),
                            Spacer(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: List.generate(
                          widget.order.itemsDetails.length, (index) {
                        var item = widget.order.itemsDetails[index];
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: CustomText(
                                        text: item.itemName,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: CustomText(
                                        text: "${item.agencyPrice} \$",
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: CustomText(
                                        text: item.commercialName,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: IconButton(
                                      icon: Image.asset(
                                        'assets/images/iconinfo.png',
                                        width: double.infinity,
                                        height: 30,
                                      ),
                                      onPressed: () =>
                                          _showItemDetails(context, item),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Divider(
                                  color: Colors.grey, thickness: 0.5),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CustomText(
                            text: "عدد التجار : ${uniqueTraders.length}",
                            color: Colors.black,
                            weight: FontWeight.w500,
                            size: 16,
                          )),
                    ),
                    SizedBox(height: 10),
                    ...uniqueTraders
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key +
                          1; // 🔹 `key` يبدأ من 0، لذا نضيف 1 لجعله 1، 2، 3...
                      Trader trader = entry.value;

                      return Center(
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.05,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    1.1,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: CustomText(
                                    textAlign: TextAlign.end,
                                    text: "معلومات التاجر : ${index}",
                                    color: Colors.black,
                                    weight: FontWeight.w500,
                                    size: 16,
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width /
                                    1.1,
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Color(0xffA8A8A8),
                                        width: 1),
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(5.0),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.end,
                                            children: [
                                              CustomText(
                                                text:
                                                "${trader.traderName}",
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                              CustomText(
                                                text: ":اسم المحل ",
                                                color: Colors.black,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.all(5.0),
                                          child: CustomText(
                                            text:
                                            "عنوان المحل : ${trader
                                                .traderCity}",
                                            color: Color(0xffA8A8A8),
                                            size: 16,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                await Clipboard.setData(
                                                  ClipboardData(
                                                    text:
                                                    "+962${widget.order
                                                        .customerPhone}",
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                    context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .check_circle,
                                                            color: Colors
                                                                .green),
                                                        SizedBox(
                                                            width: 8),
                                                        Text(
                                                          'تم نسخ الرقم بنجاح!',
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor: red,
                                                    behavior:
                                                    SnackBarBehavior
                                                        .floating,
                                                    margin:
                                                    EdgeInsets.all(
                                                        16),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          16),
                                                    ),
                                                    duration: Duration(
                                                        seconds: 2),
                                                    elevation: 6,
                                                  ),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    bottom: 5.0,
                                                    left: 10,
                                                    right: 10),
                                                child: Icon(
                                                  Icons.copy,
                                                  color:
                                                  Color(0xffA8A8A8),
                                                  size: size.width * 0.05,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(
                                                  5.0),
                                              child: CustomText(
                                                text:
                                                "رقم الهاتف : ${trader
                                                    .traderPhone}",
                                                color: Color(0xffA8A8A8),
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 1.05,
                        child: Column(
                          children: [
                            Container(
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.1,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CustomText(
                                  textAlign: TextAlign.end,
                                  text: "معلومات الزبون",
                                  color: Colors.black,
                                  weight: FontWeight.w500,
                                  size: 16,
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.1,
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Color(0xffA8A8A8), width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            CustomText(
                                              text:
                                              "${widget.order.customerName}",
                                              color: Color(0xffA8A8A8),
                                              size: 16,
                                            ),
                                            CustomText(
                                              text: " :اسم الزبون",
                                              color: Color(0xffA8A8A8),
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.all(5.0),
                                        child: CustomText(
                                          text:
                                          "العنوان: ${widget.order
                                              .customerCity}",
                                          color: Color(0xffA8A8A8),
                                          size: 16,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              await Clipboard.setData(
                                                ClipboardData(
                                                  text:
                                                  "+962${widget.order
                                                      .customerPhone}",
                                                ),
                                              );
                                              ScaffoldMessenger.of(
                                                  context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .check_circle,
                                                          color: Colors
                                                              .green),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'تم نسخ الرقم بنجاح!',
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: red,
                                                  behavior:
                                                  SnackBarBehavior
                                                      .floating,
                                                  margin:
                                                  EdgeInsets.all(16),
                                                  shape:
                                                  RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(16),
                                                  ),
                                                  duration: Duration(
                                                      seconds: 2),
                                                  elevation: 6,
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 5.0,
                                                  left: 10,
                                                  right: 10),
                                              child: Icon(
                                                Icons.copy,
                                                color: Color(0xffA8A8A8),
                                                size: size.width * 0.05,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.all(5.0),
                                            child: CustomText(
                                              text:
                                              "رقم الهاتف: ${widget.order
                                                  .customerPhone}",
                                              color: Color(0xffA8A8A8),
                                              size: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 1.05,
                        child: Column(
                          children: [
                            Container(
                              color: Colors.white,
                              width:
                              MediaQuery
                                  .of(context)
                                  .size
                                  .width / 1.1,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: CustomText(
                                  textAlign: TextAlign.end,
                                  text: "معلومات الطلبية",
                                  color: Colors.black,
                                  weight: FontWeight.w500,
                                  size: 16,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      Detailsorder(orderData: widget.order2),));
                              },
                              child: Container(
                                width:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.1,
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: Color(0xffA8A8A8), width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 2.5, horizontal: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 2.5),
                                          child: CustomText(
                                            text: "مجموع المنتجات: ${calculateTotalProductsInProductDetails()}",
                                            color: Color(0xffA8A8A8),
                                            size: 16,
                                          ),

                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 2.5),
                                          child: CustomText(
                                            text:
                                            "نوع التوصيل : ${widget.order
                                                .deliveryType}",
                                            color: Color(0xffA8A8A8),
                                            size: 16,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.all(5.0),
                                              child: CustomText(
                                                text: (widget.order
                                                    .totalCost !=
                                                    null &&
                                                    widget.order
                                                        .totalCost !=
                                                        "0.0")
                                                    ? (double.tryParse(widget
                                                    .order
                                                    .totalCost
                                                    .toString()) ??
                                                    0)
                                                    .toStringAsFixed(2)
                                                    .replaceAll(".00",
                                                    "") // يحذف `.00` إذا كان عددًا صحيحًا
                                                    : "",
                                                color: black,
                                                size: 16,
                                              ),
                                            ),
                                            CustomText(
                                              text: "jd ",
                                              color: black,
                                              size: 16,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(vertical: 2.5),
                                              child: CustomText(
                                                text: ":المبلغ مع التوصيل",
                                                color: Color(0xffA8A8A8),
                                                size: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    widget.screentype == 2
                        ? Container()
                        : Center(
                      child: Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width /
                            1.05,
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width /
                                  1.1,
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.end,
                                  children: [
                                    CustomText(
                                      textAlign: TextAlign.end,
                                      text: "إن وجد :",
                                      color: Color(0xffA8A8A8),
                                      size: 14,
                                    ),
                                    CustomText(
                                      textAlign: TextAlign.end,
                                      text: "إضافة ملاحظة ",
                                      color: Colors.black,
                                      weight: FontWeight.bold,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.screentype == 2
                        ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23.0),
                      child: Center(
                        child: Column(
                          children: [
                            Align(
                              child: CustomText(
                                textAlign: TextAlign.start,
                                text: ":الملاحظة",
                                color: Colors.black,
                                weight: FontWeight.w500,
                                size: 16,
                              ),
                              alignment: Alignment.topRight,
                            ),
                            Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width /
                                  1.1,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color(0xffA8A8A8),
                                    width: 1.5),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: CustomText(
                                  textAlign: TextAlign.end,
                                  text: widget.order.note
                                      .toString()
                                      .isNotEmpty
                                      ? widget.order.note
                                      : "لا يوجد ملاحظات",
                                  color: Color(0xffA8A8A8),
                                  weight: FontWeight.bold,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 12),
                      child: TextField(
                        controller: noteC,
                        maxLines: 2,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                                color: Colors.grey, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                            BorderSide(color: green, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Colors.grey, width: 1.5),
                          ),
                          hintText: '',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontFamily: "Tajawal",
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    widget.screentype == 2
                        ? Container()
                        : Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            updateOrderStatus(2, noteC.text);
                          },
                          label: CustomText(text: "أرشفه"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            // لون النص
                            backgroundColor: Colors.white,
                            // لون الخلفية
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontFamily: "Tajawal",
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              side: BorderSide(
                                // ✅ إضافة حواف سوداء
                                color: Colors.black54,
                                width: 2, // عرض الحد
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            showConfirmationDialog(
                              context: context,
                              message:
                              "هل أنت متأكد من إتمام التحصيل والتوصيل؟",
                              confirmText: "تأكيد",
                              onConfirm: () {
                                updateOrderStatus(1, noteC.text);
                              },
                              cancelText: "رفض",
                              onCancel: () {},
                            );
                          },
                          label: CustomText(
                            text: "تم",
                            color: white,
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: white,
                            backgroundColor: red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            textStyle: TextStyle(
                                fontSize: 18,
                                fontFamily: "Tajawal",
                                fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          children: <Widget>[
            _buildNavItem(
              context,
              iconActive: 'assets/images/sp-red.png',
              iconInactive: 'assets/images/sp.png',
              text: "الأرشيف",
              index: 0,
            ),
            _buildNavItem(
              context,
              iconActive: 'assets/images/red home.png',
              iconInactive: 'assets/images/home.png',
              text: "جديد",
              index: 1,
            ),
            _buildNavItem(
              context,
              iconActive: 'assets/images/normal-red.png',
              iconInactive: 'assets/images/normal.png',
              text: "الطلبيات",
              index: 2,
            ),
          ],
        ),
      ),
    );
  }

  int calculateTotalProductsInProductDetails() {
    int totalProducts = 0;

    var order = widget.order2;

    if (order.containsKey('items_details') &&
        order['items_details'] != null &&
        order['items_details'] is List) {
      List<dynamic> itemsDetails = order['items_details'];

      for (var itemDetail in itemsDetails) {

        if (itemDetail.containsKey('product_details') &&
            itemDetail['product_details'] != null &&
            itemDetail['product_details'] is List) {
          List<dynamic> productDetails = itemDetail['product_details'];
          totalProducts += productDetails.length;
        } else {
        }
      }
    } else {
    }
    return totalProducts;
  }

  Widget _buildNavItem(BuildContext context, {
    required String iconActive,
    required String iconInactive,
    required String text,
    required int index,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Index_Driver(page: index),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              currentTab == index ? iconActive : iconInactive,
              width: 30,
              height: 27,
            ),
            SizedBox(height: 4),
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

  Future<void> updateOrderStatus(int status, String note) async {
    setState(() {
      isLoading = true;
    });

    final user = Provider.of<ProfileProvider>(context, listen: false);
    int persion = int.tryParse(user.user_id) ?? 0;

    final url =
    Uri.parse('https://jordancarpart.com/Api/delevery/accesspetdeleveryorder.php');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'orderid': int.parse(widget.order.orderId.toString()),
          'persionid': persion,
          'status': status,
          'note': note,
        }),
      );


      if (response.statusCode == 200) {
        showMessage("تم تحديث حالة الطلب بنجاح", true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Index_Driver(page: 1),
          ),
              (route) => false,
        );
      } else {
        showConfirmationDialog(
          context: context,
          message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          confirmText: 'حسناً',
          onConfirm: () {},
        );
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? red : Colors.red,
      ),
    );
  }

  void _showItemDetails(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.9,
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.5,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 7,
                    color: words,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      CustomText(
                        text: "تفاصيل القطعة",
                        size: 20,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "${item.mark}",
                            color: words,
                          ),
                          CustomText(
                            text: "العلامة التجارية",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "أيوم",
                                color: words,
                              ),
                              SizedBox(width: 2),
                              CustomText(
                                text: "${item.warranty ?? 'N/A'}",
                                color: words,
                              ),
                            ],
                          ),
                          CustomText(
                            text: "مدة الكفالة :",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // عرض الملاحظات
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
