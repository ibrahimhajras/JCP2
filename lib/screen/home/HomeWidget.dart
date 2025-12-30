import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Drawer/PricingRequestPage.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/colors.dart';
import '../../../style/custom_text.dart';
import '../../model/OrderModel.dart';
import '../../provider/CountdownProvider.dart';
import '../../provider/EditProductProvider.dart';
import '../../provider/OrderProvider.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/PartsWidget.dart';
import 'package:http/http.dart' as http;
import '../../widget/update.dart';
import '../auth/login.dart';
import 'component/VehicleInfoCard.dart';
import 'component/VehicleSelectionPage.dart';
import '../../widget/NotificationPermissionHandler.dart';

class HomeWidget extends StatefulWidget {
  final ValueChanged<bool> run;
  final bool? isLogin;

  HomeWidget({super.key, this.isLogin, required this.run});

  @override
  State<HomeWidget> createState() => _HomeWidgetState ();
}

class _HomeWidgetState extends State<HomeWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TextEditingController carid = TextEditingController();
  TextEditingController part_1 = TextEditingController();
  TextEditingController part_2 = TextEditingController();
  TextEditingController part_3 = TextEditingController();
  List<PartsWidget> parts = [];
  String hint = "1 H G B H 4 1 J X M N 1 0 9 1 8 6";
  int count = 0;
  final form = GlobalKey<FormState>();
  Color focusedColor = Colors.black;
  Color bor = green;
  int? flag = 2;
  bool hasNewNotification = false;
  late Future<Map<String, dynamic>> screen;
  Map<String, dynamic>? apiData;
  bool isLoading = true;
  bool isLoading1 = false;
  String? errorMessage;
  int? orderAllowed;
  List<String> partsAutocomplete = [];
  final FocusNode part1FocusNode = FocusNode();
  final FocusNode part2FocusNode = FocusNode();
  final FocusNode part3FocusNode = FocusNode();
  bool isLoading22 = false;

  final GlobalKey part1Key = GlobalKey();
  final GlobalKey part2Key = GlobalKey();
  final GlobalKey part3Key = GlobalKey();

  List<FocusNode> dynamicFocusNodes = [];
  List<GlobalKey> dynamicKeys = [];

  Stream<Map<String, dynamic>>? _limitationStream;
  String? userId;
  int? verificationValue;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();
  ScrollController _scrollController4 = ScrollController();

  String? selectedVehicleBrand;
  String? selectedVehicleModel;
  String? selectedVehicleYear;
  String? selectedVehicleFuelType;
  String? selectedVehicleEngineSize;
  String? selectedVehicleChassisNumber;
  Map<String, String>? vehicleData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Update.checkAndUpdate(context);
    });
    fetchParts();
    _checkForNotifications();
    _fetchData();
    _loadOrderAllowed();
    _initializeStream();
    _loadVerificationValue();
    _loadSavedVehicleData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);

    NotificationPermissionHandler.checkAndRequestPermission(context);

    part1FocusNode.addListener(() => _scrollToField(part1Key));
    part2FocusNode.addListener(() => _scrollToField(part2Key));
    part3FocusNode.addListener(() => _scrollToField(part3Key));
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadSavedVehicleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? brand = prefs.getString('vehicle_brand');
    String? model = prefs.getString('vehicle_model');
    String? year = prefs.getString('vehicle_year');
    String? fuelType = prefs.getString('vehicle_fuelType');
    String? engineSize = prefs.getString('vehicle_engineSize');
    String? chassisNumber = prefs.getString('vehicle_chassisNumber');

    if (brand != null &&
        brand.isNotEmpty &&
        model != null &&
        model.isNotEmpty &&
        year != null &&
        year.isNotEmpty &&
        fuelType != null &&
        fuelType.isNotEmpty &&
        engineSize != null &&
        engineSize.isNotEmpty) {
      setState(() {
        selectedVehicleBrand = brand;
        selectedVehicleModel = model;
        selectedVehicleYear = year;
        selectedVehicleFuelType = fuelType;
        selectedVehicleEngineSize = engineSize;
        selectedVehicleChassisNumber = chassisNumber;

        vehicleData = {
          'brand': brand,
          'model': model,
          'year': year,
          'fuelType': fuelType,
          'engineSize': engineSize,
          'chassisNumber': chassisNumber ?? 'N/A',
        };
      });
    }
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _initializeStream();
        _fetchData();
        _checkForNotifications();
      });
    }
  }

  Future<void> fetchParts() async {
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/get_parts.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && mounted) {
          setState(() {
            partsAutocomplete = List<String>.from(
              jsonResponse['data'].map((item) => item['part_name_ar']),
            );
          });
        }
      }
    } on TimeoutException {
    } catch (error) {}
  }

  Stream<Map<String, dynamic>> limitationStream(
      String userId, String token) async* {
    while (true) {
      final data = await getOrderLimitation(userId, token);
      yield data;
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<Map<String, dynamic>> getOrderLimitation(
      String userId, String token) async {
    final String url =
        'https://jordancarpart.com/Api/getlimitationoforder.php?user_id=$userId&token=$token';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Access-Control-Allow-Headers': 'Authorization',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['time_difference_gt_24hrs']) {}
      if (data['limit_of_order'] == 0) {}
      return data;
    } else {
      _showLogoutDialog(context);
      throw Exception(
          'تم تسجيل الدخول من جهاز آخر. الرجاء تسجيل الخروج والدخول مرة أخرى.');
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
                  color: const Color.fromRGBO(255, 255, 255, 1),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            CustomText(
                              text:
                              'تم تسجيل الدخول من جهاز آخر. الرجاء تسجيل الخروج والدخول مرة أخرى.',
                              color: black,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                logout(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: CustomText(
                                text: "تسجيل الخروج",
                                color: grey,
                                size: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
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

  Future<void> _fetchOrdersForUser(BuildContext context) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final countdownProvider =
    Provider.of<CountdownProvider>(context, listen: false);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      String? token = prefs.getString('token');
      if (userId == null) {
        return;
      }
      final url = Uri.parse(
          'https://jordancarpart.com/Api/getordersofuser.php?user_id=$userId&token=$token');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          List<OrderModel> orders = (responseData['data'] as List<dynamic>)
              .map((order) => OrderModel.fromJson(order))
              .toList();
          orderProvider.setOrders(orders);
          if (orders.isNotEmpty) {
            countdownProvider.startCountdown(DateTime.parse(orders.last.time));
          }
        }
      }
    } catch (e) {}
  }

  void _scrollToField(GlobalKey key) {
    if (key.currentContext != null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          alignment: 0.3,
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();
    _scrollController4.dispose();
    part1FocusNode.dispose();
    part2FocusNode.dispose();
    part3FocusNode.dispose();
    for (var node in dynamicFocusNodes) {
      node.dispose();
    }
    dynamicFocusNodes.clear();
    super.dispose();
  }

  Future<void> _loadVerificationValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      verificationValue = prefs.getInt('verification');
      isLoading = false;
    });
  }

  Future<void> _initializeStream() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    userId = prefs.getString('userId');

    if (userId != null) {
      setState(() {
        _limitationStream = limitationStream(userId!, token!);
      });
      _fetchOrdersForUser(context);
    }
  }

  Future<void> _loadOrderAllowed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      orderAllowed = prefs.getInt('isOrderAllowed') ?? 0;
    });
  }

  Future<void> _fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    try {
      if (userId != null) {
        final data = await getOrderLimitation(userId!, token!);
        setState(() {
          apiData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _scrollToFocusedField() {
    _scrollController2.animateTo(
      _scrollController2.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return  GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          controller: _scrollController2,
          child: Column(
            children: [
              _buildHeader(size),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _limitationStream != null
                          ? StreamBuilder<Map<String, dynamic>>(
                        stream: _limitationStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.3),
                                  RotatingImagePage(),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: CustomText(text: ''));
                          } else if (!snapshot.hasData) {
                            return Center(
                                child: CustomText(text: 'لا يوجد بيانات'));
                          } else {
                            final apiData = snapshot.data!;
                            final countdownProvider =
                            Provider.of<CountdownProvider>(context,
                                listen: false);

                            if (apiData
                                .containsKey('duration_in_seconds')) {
                              final duration =
                                  apiData['duration_in_seconds'] ?? 0;

                              if (duration > 0 &&
                                  countdownProvider.remainingSeconds == 0) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  countdownProvider
                                      .startCountdownFrom(duration);
                                });
                              }
                            }

                            return _buildContentBasedOnApiData(
                                size, user, apiData);
                          }
                        },
                      )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return CustomHeader(
      title: "قطع سيارات الأردن",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildContentBasedOnApiData(
      Size size, ProfileProvider user, Map<String, dynamic> apiData) {
    final timeDifferenceGt24hrs = apiData['time_difference_gt_24hrs'];
    final limitOfOrder = apiData['limit_of_order'];
    saveLimitOfOrder(limitOfOrder);
    if (user.phone == '0781771234' || user.phone == '781771234') {
      return _buildFormFields(context, size, user);
    }
    if (timeDifferenceGt24hrs) {
      return _buildFormFields(context, size, user);
    } else {
      if (orderAllowed == 0) {
        return _buildFormFields2(context, size, user, limitOfOrder);
      } else {
        return _buildFormFields(context, size, user);
      }
    }
  }

  Future<void> saveLimitOfOrder(int limitOfOrder) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('limitOfOrder', limitOfOrder);
  }

  Widget _buildNotificationIcon(Size size) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(),
            )).then((_) {
          _checkForNotifications();
        });
      },
      child: Container(
        height: size.width * 0.1,
        width: size.width * 0.1,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(246, 246, 246, 0.26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            hasNewNotification
                ? 'assets/images/notification-on.png'
                : 'assets/images/notification-off.png',
          ),
        ),
      ),
    );
  }

  Future<void> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> notificationList =
    notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnread =
    notificationList.any((notification) => notification['isRead'] == false);

    setState(() {
      hasNewNotification = hasUnread;
    });
  }

  bool isButtonEnabled = true;

  Future<void> _saveVehicleDataToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('vehicle_brand', selectedVehicleBrand ?? '');
    await prefs.setString('vehicle_model', selectedVehicleModel ?? '');
    await prefs.setString('vehicle_year', selectedVehicleYear ?? '');
    await prefs.setString('vehicle_fuelType', selectedVehicleFuelType ?? '');
    await prefs.setString(
        'vehicle_engineSize', selectedVehicleEngineSize ?? '');
    await prefs.setString(
        'vehicle_chassisNumber', selectedVehicleChassisNumber ?? 'N/A');
  }

  Widget _buildFormFields2(
      BuildContext context, Size size, ProfileProvider user, limitOfOrder) {
    return SingleChildScrollView(
      controller: _scrollController3,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.01),
          _buildVehicleCard(),
          SizedBox(height: size.height * 0.01),
          verificationValue == 0
              ? const SizedBox()
              : Padding(
            padding: EdgeInsets.all(size.width * 0.01),
            child: Column(
              children: [
                Container(
                  child: CustomText(
                    text: "الطلب المجاني سيكون بعد 24 ساعة",
                    size: size.width * 0.05,
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Consumer<CountdownProvider>(
                  builder: (context, countdownProvider, child) {
                    return CustomText(
                      text: countdownProvider.countdownText,
                      size: size.width * 0.05,
                    );
                  },
                ),
                SizedBox(height: size.height * 0.01),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.asset(
                        'assets/images/alarm.png',
                        width: size.width * 0.40,
                        height: size.height * 0.20,
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PricingRequestPage(),
                            ));
                      },
                      child: Container(
                        child: Text(
                          "تواصل معنا",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: green,
                            fontFamily: "Tajawal",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        "  إذا كنت بحاجه لتسعيرات متكررة   ",
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8D8D92),
                          fontFamily: "Tajawal",
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.03),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(size.width * 0.02),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(240, 240, 240, 1),
                            border: Border.all(
                              color: const Color.fromRGBO(240, 240, 240, 1),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "${limitOfOrder}",
                              style: TextStyle(
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: "Tajawal",
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Text(
                          "عدد الطلبات المدفوعه المتبقية",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Tajawal",
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (limitOfOrder > 0 && isButtonEnabled)
                              ? () async {
                            showConfirmationDialog(
                              context: context,
                              message: 'هل أنت متأكد من التفعيل؟',
                              confirmText: 'تأكيد',
                              onConfirm: () async {
                                setState(() {
                                  isLoading = true;
                                  isButtonEnabled = false;
                                });

                                final url =
                                    'http://jordancarpart.com/Api/discountlimitation.php?user_id=${user.user_id}&flag=0';
                                final headers = {
                                  'Access-Control-Allow-Headers':
                                  '*',
                                  'Access-Control-Allow-Origin':
                                  '*',
                                  'Content-Type':
                                  'application/json; charset=UTF-8',
                                };

                                try {
                                  final response = await http.get(
                                    Uri.parse(url),
                                    headers: headers,
                                  );

                                  if (response.statusCode == 200) {
                                    await http.post(
                                      Uri.parse(
                                          'https://jordancarpart.com/Api/log_order_action.php'),
                                      headers: {
                                        'Content-Type':
                                        'application/json; charset=UTF-8',
                                      },
                                      body: jsonEncode({
                                        'user_id': user.user_id,
                                        'action': '0',
                                      }),
                                    );

                                    SharedPreferences prefs =
                                    await SharedPreferences
                                        .getInstance();
                                    await prefs.setInt(
                                        'isOrderAllowed', 1);

                                    setState(() {
                                      errorMessage = null;
                                    });
                                    await _checkForNotifications();
                                    await _fetchData();
                                    await _loadOrderAllowed();
                                    NotificationPermissionHandler.checkAndRequestPermission(context);
                                  } else {
                                    await _logoutUser();
                                  }
                                } catch (e) {
                                  await _logoutUser();
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              cancelText: "لا",
                            );
                          }
                              : null,
                          child: isLoading
                              ? Center(child: RotatingImagePage())
                              : Center(
                            child: Text(
                              'تفعيل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.04,
                                fontFamily: "Tajawal",
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: limitOfOrder > 0
                                ? Colors.green
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.remove('vehicle_brand');
    await prefs.remove('vehicle_model');
    await prefs.remove('vehicle_year');
    await prefs.remove('vehicle_fuelType');
    await prefs.remove('vehicle_engineSize');
    await prefs.remove('vehicle_chassisNumber');
    await prefs.setBool('rememberMe', false);
    await prefs.remove('phone');
    await prefs.remove('password');
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('type');
    await prefs.remove('city');
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    await prefs.setStringList('notifications', notifications);
    await prefs.setInt('isOrderAllowed', 0);
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.resetFields();
    final OrderProvider1 = Provider.of<OrderProvider>(context, listen: false);
    OrderProvider1.clearOrders();
    final orderDetailsProvider =
    Provider.of<OrderDetailsProvider>(context, listen: false);
    orderDetailsProvider.clear();
    final editProductProvider =
    Provider.of<EditProductProvider>(context, listen: false);
    editProductProvider.clear();
    final deliveryModel =
    Provider.of<DeliveryModelOrange>(context, listen: false);
    deliveryModel.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  Widget _buildMenuIcon(BuildContext context, Size size) {
    return MenuIcon(
      size: size,
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }

  Widget _buildFormFields(
      BuildContext context, Size size, ProfileProvider user) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        _buildVehicleCard(),
        SizedBox(height: size.height * 0.02),

        // القطعة الأولى
        PartsWidget(
          onDelete: () {},
          part: part_1,
          suggestions: partsAutocomplete,
          hintText: "القطعة الاولى",
          showDelete: false,
        ),

        SizedBox(height: size.height * 0.02),

        // القطعة الثانية
        PartsWidget(
          onDelete: () {},
          part: part_2,
          suggestions: partsAutocomplete,
          hintText: "القطعة الثانية",
          showDelete: false,
        ),

        SizedBox(height: size.height * 0.02),

        // القطعة الثالثة
        PartsWidget(
          onDelete: () {},
          part: part_3,
          suggestions: partsAutocomplete,
          hintText: "القطعة الثالثة",
          showDelete: false,
        ),

        SizedBox(height: size.height * 0.02),
        _buildAdditionalParts(size),
        _buildSubmitButton(context, size, user),
      ],
    );
  }

  Widget _buildVehicleCard() {
    return VehicleInfoCard(
      brand: vehicleData?['brand'],
      model: vehicleData?['model'],
      year: vehicleData?['year'],
      fuelType: vehicleData?['fuelType'],
      engineSize: vehicleData?['engineSize'],
      chassisNumber: vehicleData?['chassisNumber'],
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleSelectionPage(),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            vehicleData = Map<String, String>.from(result);
            selectedVehicleBrand = vehicleData!['brand'];
            selectedVehicleModel = vehicleData!['model'];
            selectedVehicleYear = vehicleData!['year'];
            selectedVehicleFuelType = vehicleData!['fuelType'];
            selectedVehicleEngineSize = vehicleData!['engineSize'];
            selectedVehicleChassisNumber = vehicleData!['chassisNumber'];
          });

          _saveVehicleDataToLocal();
        }
      },
      onEdit: vehicleData != null
          ? () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleSelectionPage(),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          setState(() {
            vehicleData = Map<String, String>.from(result);
            selectedVehicleBrand = vehicleData!['brand'];
            selectedVehicleModel = vehicleData!['model'];
            selectedVehicleYear = vehicleData!['year'];
            selectedVehicleFuelType = vehicleData!['fuelType'];
            selectedVehicleEngineSize = vehicleData!['engineSize'];
            selectedVehicleChassisNumber = vehicleData!['chassisNumber'];
          });

          // 👈 احفظ البيانات المعدلة (ستستبدل القديمة)
          _saveVehicleDataToLocal();
        }
      }
          : null,
    );
  }

  Widget _buildAdditionalParts(Size size) {
    return Column(
      children: [
        ...parts,
        SizedBox(height: size.height * 0.015),
        GestureDetector(
          onTap: () => onAddForm(),
          child: Center(
            child: CustomText(
              text: "إضافة قطع أخرى",
              color: green,
              size: size.width * 0.045,
              weight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, Size size, ProfileProvider user) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
      child: MaterialButton(
        onPressed: isLoading22
            ? null
            : () async {
          setState(() {
            isLoading22 = true;
          });

          List<String> enteredParts = [
            part_1.text,
            part_2.text,
            part_3.text,
            ...parts.map((p) => p.part?.text ?? '')
          ];

          bool allValid = enteredParts
              .every((p) => p.isEmpty || partsAutocomplete.contains(p));

          bool hasCarInfo = selectedVehicleBrand != null &&
              selectedVehicleModel != null &&
              selectedVehicleYear != null;

          if (hasCarInfo && part_1.text.isNotEmpty && allValid) {
            await onSave(
              '', // carid ما بنستخدمه الآن
              part_1.text,
              part_2.text,
              part_3.text,
              user.user_id,
            );
            widget.run(true);
          } else {
            showConfirmationDialog(
              context: context,
              message: !hasCarInfo
                  ? "الرجاء اختيار معلومات المركبة قبل إرسال الطلب"
                  : allValid
                  ? "الرجاء إدخال القطعة الأولى"
                  : "تأكد أن جميع أسماء القطع مأخوذة من القائمة التنبؤية",
              confirmText: "حسناً",
              onConfirm: () {},
              cancelText: '',
            );
          }

          setState(() {
            isLoading22 = false;
          });
        },
        height: 50,
        minWidth: size.width * 0.9,
        color: const Color.fromRGBO(195, 29, 29, 1),
        child: isLoading22
            ? SizedBox(
          height: 24,
          width: 24,
          child: RotatingImagePage(),
        )
            : CustomText(
          text: "إرسال",
          color: white,
          size: 16,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void onAddForm() {
    setState(() {
      var controller = TextEditingController();
      var focusNode = FocusNode();
      var scrollKey = GlobalKey();

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _scrollToField(scrollKey);
        }
      });

      dynamicFocusNodes.add(focusNode);
      dynamicKeys.add(scrollKey);

      parts.add(PartsWidget(
        part: controller,
        onDelete: () => onDelete(controller),
        focusNode: focusNode,
        scrollKey: scrollKey,
        hintText: "قطعة جديدة",
        suggestions: partsAutocomplete,
      ));
    });
  }

  void onDelete(TextEditingController _controller) {
    final find = parts.firstWhere(
          (it) => it.part!.text == _controller.text,
      orElse: () => null!,
    );
    parts.removeAt(parts.indexOf(find));
    setState(() {});
  }

  Future<void> onSave(
      String carid, String p1, String p2, String p3, String user_id) async {
    List<Map<String, String>> itemsList = [];
    final size = MediaQuery.of(context).size;

    if (p1.isNotEmpty) itemsList.add({"name": p1});
    if (p2.isNotEmpty) itemsList.add({"name": p2});
    if (p3.isNotEmpty) itemsList.add({"name": p3});

    for (var partWidget in parts) {
      if (partWidget.part != null && partWidget.part!.text.isNotEmpty) {
        itemsList.add({"name": partWidget.part!.text});
      }
    }

    final carInfo = {
      "brand": selectedVehicleBrand ?? "N/A",
      "model": selectedVehicleModel ?? "N/A",
      "year": selectedVehicleYear ?? "N/A",
      "fuelType": selectedVehicleFuelType != null
          ? (selectedVehicleFuelType! == "Gasoline"
          ? "Gasoline"
          : selectedVehicleFuelType!.toLowerCase())
          : "N/A",
      "engineSize": selectedVehicleEngineSize ?? "N/A",
      "chassisNumber": selectedVehicleChassisNumber ?? "N/A",
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    bool? filter = prefs.getBool('cheapest');
    String? city = prefs.getString('city');
    String? a = filter == null
        ? city
        : filter == true
        ? city
        : "Jordan";

    final order = {
      "car_info": carInfo,
      "time": DateTime.now().toIso8601String(),
      "type": "1",
      "customer_id": user_id,
      "items": itemsList,
      "token": token,
      "filter": a
    };

    final url = Uri.parse('https://jordancarpart.com/Api/saveorder.php');
    try {
      final response = await http.post(
        url,
        headers: {
          'Access-Control-Allow-Headers': 'Authorization',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(order),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {}
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? isOrderAllowed = prefs.getInt('isOrderAllowed');
        if (isOrderAllowed == 1) {
          await prefs.setInt('isOrderAllowed', 0);
        }
        await _checkForNotifications();
        await _fetchData();
        await _loadOrderAllowed();

        await http.post(
          Uri.parse('https://jordancarpart.com/Api/check_and_log_action.php'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'user_id': user_id,
          }),
        );

        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        showModalBottomSheet(
          isDismissible: false,
          enableDrag: false,
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: Container(
                height: size.height * 0.5,
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),
                      Center(
                        child: Image.asset(
                          "assets/images/done-icon 1.png",
                          height: size.height * 0.15,
                          width: size.width * 0.3,
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                      CustomText(
                        text: "تم ارسال طلبك بنجاح",
                        size: size.width * 0.06,
                      ),
                      SizedBox(height: size.height * 0.02),
                      CustomText(
                        text: "...جارِ العمل على طلبك",
                        size: size.width * 0.055,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: size.height * 0.04),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context); // إغلاق الـ modal
                          widget.run(true); // الانتقال لصفحة الطلبات
                        },
                        height: size.height * 0.06,
                        minWidth: size.width * 0.7,
                        color: const Color.fromRGBO(195, 29, 29, 1),
                        child: CustomText(
                          text: "رجوع",
                          color: white,
                          size: size.width * 0.05,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    }
  }
}

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();

  String? userId = prefs.getString('userId');
  await prefs.clear();
  await prefs.remove('vehicle_brand');
  await prefs.remove('vehicle_model');
  await prefs.remove('vehicle_year');
  await prefs.remove('vehicle_fuelType');
  await prefs.remove('vehicle_engineSize');
  await prefs.remove('vehicle_chassisNumber');
  await prefs.setBool('rememberMe', false);

  final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
  profileProvider.resetFields();
  final OrderProvider1 = Provider.of<OrderProvider>(context, listen: false);
  OrderProvider1.clearOrders();
  final orderDetailsProvider =
  Provider.of<OrderDetailsProvider>(context, listen: false);
  orderDetailsProvider.clear();
  final editProductProvider =
  Provider.of<EditProductProvider>(context, listen: false);
  editProductProvider.clear();
  final deliveryModel =
  Provider.of<DeliveryModelOrange>(context, listen: false);
  deliveryModel.clear();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
  );
}

class PartsFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Size size;
  final List<String> suggestions;
  final FocusNode? focusNode;
  final GlobalKey? scrollKey;

  const PartsFieldWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.size,
    required this.suggestions,
    this.focusNode,
    this.scrollKey,
  }) : super(key: key);

  @override
  _PartsFieldWidgetState createState() => _PartsFieldWidgetState();
}

class _PartsFieldWidgetState extends State<PartsFieldWidget> {
  late FocusNode _focusNode;
  Color borderColor = grey;
  late String currentHintText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    currentHintText = widget.hintText;

    _focusNode.addListener(() async {
      if (_focusNode.hasFocus) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;

        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        if (bottomInset > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.scrollKey?.currentContext != null) {
              Scrollable.ensureVisible(
                widget.scrollKey!.currentContext!,
                alignment: 0.2,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _updateBorderColor(String input) {
    setState(() {
      if (widget.suggestions.contains(input)) {
        borderColor = green;
      } else {
        borderColor = red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.size.width * 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: grey,
        ),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return widget.suggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            setState(() {
              widget.controller.text = selection;
              _updateBorderColor(selection);
            });
          },
          fieldViewBuilder: (
              BuildContext context,
              TextEditingController textEditingController,
              FocusNode _,
              VoidCallback onFieldSubmitted,
              ) {
            textEditingController.text = widget.controller.text;
            textEditingController.selection = TextSelection.fromPosition(
              TextPosition(offset: textEditingController.text.length),
            );

            return TextFormField(
              controller: textEditingController,
              focusNode: _focusNode,
              textAlign: TextAlign.end,
              maxLength: 30,
              onChanged: (val) {
                setState(() {
                  widget.controller.text = val;
                  _updateBorderColor(val);
                });
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: currentHintText,
                hintStyle: TextStyle(
                  color: words,
                  fontSize: widget.size.width * 0.04,
                  fontFamily: "Tajawal",
                ),
                counterText: '',
              ),
              style: TextStyle(
                fontFamily: "Tajawal",
                color: Colors.black,
                fontSize: widget.size.width * 0.04,
              ),
            );
          },
        ),
      ),
    );
  }
}
