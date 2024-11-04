import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/screen/Drawer/PricingRequestPage.dart';
import 'package:jcp/screen/home/timer_service.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/colors.dart';
import '../../../style/custom_text.dart';
import '../../model/OrderModel.dart';
import '../../provider/CountdownProvider.dart';
import '../../provider/OrderProvider.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/PartsWidget.dart';
import 'package:http/http.dart' as http;

class HomeWidget extends StatefulWidget {
  final ValueChanged<bool> run;
  final bool? isLogin;

  HomeWidget({super.key, this.isLogin, required this.run});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
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
  String? errorMessage;
  int? orderAllowed;

  Stream<Map<String, dynamic>> limitationStream(
      String userId, String token) async* {
    while (true) {
      final data = await getOrderLimitation(userId, token);
      yield data;
      await Future.delayed(Duration(seconds: 5));
    }
  }

  Future<Map<String, dynamic>> getOrderLimitation(
      String userId, String token) async {
    final String url =
        'https://jordancarpart.com/Api/getlimitationoforder.php?user_id=$userId&time=${Uri.encodeComponent(DateTime.now().toIso8601String())}&token=$token';
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
      throw Exception('Failed to load limitation');
    }
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
        print('User ID not found in SharedPreferences');
        return;
      }
      print(token);
      print(userId);
      final url = Uri.parse(
          'https://jordancarpart.com/Api/getordersofuser.php?user_id=$userId&token=$token');
      final response = await http.get(
        url,
      );
      print(response.body);
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
          print('Orders updated successfully: ${orders.length} orders');
        } else {
          print('Failed to load orders');
        }
      } else {
        print('Failed to load orders');
      }
    } catch (e) {
      print('Failed to load orders');
    }
  }

  Stream<Map<String, dynamic>>? _limitationStream;
  String? userId;

  @override
  void initState() {
    super.initState();
    _checkForNotifications();
    _fetchData();
    _loadOrderAllowed();
    _initializeStream();
    _initializeServiceAndStartTimer();
  }

  void _initializeServiceAndStartTimer() async {
    FlutterBackgroundService service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();

    if (!isRunning) {
      service.startService();
    }
    startTimer();
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
    } else {
      print('User ID not found in SharedPreferences');
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
      } else {
        throw Exception('User ID is null');
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return SingleChildScrollView(
      child: Form(
        key: form,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              _buildHeader(size),
              _limitationStream != null
                  ? StreamBuilder<Map<String, dynamic>>(
                stream: _limitationStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SizedBox(
                      height: size.height * 0.5,
                      child: Center(
                        child: RotatingImagePage(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('لا يوجد بيانات'));
                  } else {
                    final apiData = snapshot.data!;
                    return _buildContentBasedOnApiData(
                        size, user, apiData);
                  }
                },
              )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBasedOnApiData(
      Size size, ProfileProvider user, Map<String, dynamic> apiData) {
    final timeDifferenceGt24hrs = apiData['time_difference_gt_24hrs'];
    final limitOfOrder = apiData['limit_of_order'];
    saveLimitOfOrder(limitOfOrder);

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
          color: Color.fromRGBO(246, 246, 246, 0.26),
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

  Widget _buildFormFields2(
      BuildContext context, Size size, ProfileProvider user, limitOfOrder) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.01),
          _buildVinField(),
          Padding(
            padding: EdgeInsets.all(size.width * 0.01),
            child: Column(
              children: [
                Container(
                  child: Text(
                    "الطلب المجاني سيكون بعد 24 ساعة",
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Consumer<CountdownProvider>(
                  builder: (context, countdownProvider, child) {
                    return Text(
                      countdownProvider.countdownText,
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontFamily: "Tajawal",
                      ),
                    );
                  },
                ),
                SizedBox(height: size.height * 0.01),
                Image.asset(
                  'assets/images/alarm.png',
                  width: size.width * 0.40,
                  height: size.height * 0.20,
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
                              builder: (context) => PricingRequestPage(),
                            ));
                      },
                      child: Container(
                        child: Text(
                          "تواصل معنا",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: green,
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
                            color: Color(0xFF8D8D92)),
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
                            color: Color.fromRGBO(240, 240, 240, 1),
                            border: Border.all(
                              color: Color.fromRGBO(240, 240, 240, 1),
                              width: 2, // Border width
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "${limitOfOrder}",
                              style: TextStyle(
                                fontSize: size.width * 0.045,
                                // Dynamic font size
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Text color
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
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.130,
                              vertical: size.height * 0.02,
                            ),
                            child: ElevatedButton(
                              onPressed: limitOfOrder > 0
                                  ? () async {
                                setState(() {
                                  isLoading = true;
                                });

                                final url =
                                    'http://jordancarpart.com/Api/discountlimitation.php?user_id=${user.user_id}_id&flag=0';
                                final headers = {
                                  'Access-Control-Allow-Headers': '*',
                                  'Access-Control-Allow-Origin': '*',
                                  'Content-Type':
                                  'application/json; charset=UTF-8',
                                };
                                try {
                                  final response = await http.get(
                                    Uri.parse(url),
                                    headers: headers,
                                  );
                                  if (response.statusCode == 200) {
                                    jsonDecode(response.body);
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
                                  } else {
                                    print(response.body.toString());
                                    print('Failed to load data');
                                  }
                                } catch (e) {
                                  print('Error: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              }
                                  : null,
                              child: isLoading
                                  ? Container(
                                child: RotatingImagePage(),
                                width: 20,
                                height: 20,
                              )
                                  : Text(
                                'تفعيل',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: limitOfOrder > 0
                                    ? Colors.green
                                    : Colors.grey,
                                textStyle:
                                TextStyle(fontSize: size.width * 0.01),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            )),
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

  Widget _buildHeader(Size size) {
    return CustomHeader(
      size: MediaQuery.of(context).size,
      title: "قطع سيارات الأردن",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
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
        SizedBox(height: size.height * 0.02), // consistent spacing

        _buildVinField(),
        SizedBox(height: size.height * 0.02), // consistent spacing
        PartsFieldWidget(
          hintText: "القطعة الاولى",
          controller: part_1,
          size: size,
        ),
        SizedBox(height: size.height * 0.02), // consistent spacing

        PartsFieldWidget(
          hintText: "القطعة الثانية",
          controller: part_2,
          size: size,
        ),
        SizedBox(height: size.height * 0.02), // consistent spacing
        PartsFieldWidget(
          hintText: "القطعة الثالثة",
          controller: part_3,
          size: size,
        ),
        SizedBox(height: size.height * 0.02), // consistent spacing

        _buildAdditionalParts(size),
        _buildSubmitButton(context, size, user),
      ],
    );
  }

  Widget _buildVinField() {
    return Column(
      children: [
        Center(
          child: CustomText(
            text: "رقم الشاصي",
            color: Color.fromRGBO(0, 0, 0, 1),
            size: 20,
          ),
        ),
        Container(
          height: 85,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 60,
                  color: grey,
                  child: TextFormField(
                    controller: carid,
                    maxLength: 17,
                    maxLines: 1,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      counterText: "",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: bor, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: focusedColor, width: 2),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: bor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: grey,
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: green,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Tajawal",
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      count = value.length;
                      if (value.length == 17 && !value.contains(" ")) {
                        setState(() {
                          focusedColor = green;
                          bor = green;
                        });
                      } else {
                        setState(() {
                          focusedColor = Colors.red;
                          bor = Colors.red;
                        });
                      }
                    },
                    onTap: () {
                      setState(() {
                        hint = "";
                      });
                    },
                  ),
                ),
                CustomText(text: "$count/17"),
              ],
            ),
          ),
        ),
      ],
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
        onPressed: () async {
          if (carid.text.length == 17 && part_1.text.isNotEmpty) {
            onSave(carid.text, part_1.text, part_2.text, part_3.text,
                user.user_id);
            setState(() {
              parts.clear();
              part_1.clear();
              part_2.clear();
              part_3.clear();
              carid.clear();
              count = 0;
            });
            widget.run(true);
          } else {
            showConfirmationDialog(
              context: context,
              message: "الرجاء إدخال رقم الشصي والقطعة الأولى",
              confirmText: "حسناً",
              onConfirm: () {
                // يمكنك تركه فارغًا أو إضافة منطق إضافي إذا لزم الأمر
              },
              cancelText: '', // لا حاجة لزر إلغاء
            );
          }
        },
        height: 50, // نفس ارتفاع الزر الثاني
        minWidth: size.width * 0.9, // نفس عرض الزر الثاني
        color: Color.fromRGBO(195, 29, 29, 1),
        child: CustomText(
          text: "إرسال",
          color: white,
          size: 16, // نفس حجم النص في الزر الثاني
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void onAddForm() {
    setState(() {
      var _partController = TextEditingController();
      parts.add(PartsWidget(
        part: _partController,
        onDelete: () => onDelete(_partController),
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

  void onSave(
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final order = {
      "carid": carid,
      "time": DateTime.now().toIso8601String(),
      "type": "1",
      "customer_id": user_id,
      "items": itemsList,
      "token": token
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? isOrderAllowed = prefs.getInt('isOrderAllowed');
        if (isOrderAllowed == 1) {
          await prefs.setInt('isOrderAllowed', 0);
          print("isOrderAllowed set to 0.");
        }
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        await _checkForNotifications();
        await _fetchData();
        await _loadOrderAllowed();
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: size.height * 0.5,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(1),
                  borderRadius: BorderRadius.only(
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
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomText(
                      text: "... جار العمل على طلبك",
                      size: size.width * 0.06,
                      weight: FontWeight.w700,
                    ),
                    SizedBox(height: size.height * 0.04),
                    MaterialButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      height: size.height * 0.06,
                      minWidth: size.width * 0.7,
                      color: Color.fromRGBO(195, 29, 29, 1),
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
            );
          },
        );
      } else {
        showConfirmationDialog(
          context: context,
          message: "فشل في إرسال الطلب: ${response.reasonPhrase}",
          confirmText: "حسناً",
          onConfirm: () {},
          cancelText: '',
        );
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: "حدث خطأ في الاتصال بالإنترنت",
        confirmText: "حسناً",
        onConfirm: () {},
        cancelText: '',
      );
    }
  }
}

class PartsFieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Size size;

  const PartsFieldWidget({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.size,
  }) : super(key: key);

  @override
  _PartsFieldWidgetState createState() => _PartsFieldWidgetState();
}

class _PartsFieldWidgetState extends State<PartsFieldWidget> {
  late FocusNode _focusNode;
  late String currentHintText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    currentHintText = widget.hintText;

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          currentHintText = '';
        } else if (widget.controller.text.isEmpty) {
          currentHintText = widget.hintText;
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          textAlign: TextAlign.end,
          maxLength: 30,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grey, width: 2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: grey, width: 2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            hintText: currentHintText,
            hintStyle: TextStyle(
              color: words,
              fontSize: widget.size.width * 0.04,
            ),
            counterText: '', // إزالة العداد
          ),
          style: TextStyle(
            color: Colors.black,
            fontSize: widget.size.width * 0.04,
          ),
        ),
      ),
    );
  }
}