import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/ProfileProvider.dart';
import '../../../screen/Drawer/Notification.dart';
import '../../../style/colors.dart';
import '../../../style/custom_text.dart';
import '../../provider/CountdownProvider.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../Drawer/PricingRequestPage.dart';
import '../auth/login.dart';
import 'component/VehicleInfoCard.dart';
import 'component/VehicleSelectionPage.dart';
import 'homeuser.dart';

class ProOrderWidget extends StatefulWidget {
  final ValueChanged<bool> run;

  ProOrderWidget({super.key, required this.run});

  @override
  State<ProOrderWidget> createState() => _ProOrderWidgetState();
}

class _ProOrderWidgetState extends State<ProOrderWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  TextEditingController link = TextEditingController();
  TextEditingController part_1 = TextEditingController();
  Color focusedColor = Colors.black;
  bool isLoading = false;
  bool check = false;
  File? _imageFile;
  final picker = ImagePicker();
  String? _base64Image;
  Color bor = green;

  String? selectedVehicleBrand;
  String? selectedVehicleModel;
  String? selectedVehicleYear;
  String? selectedVehicleFuelType;
  String? selectedVehicleEngineSize;
  String? selectedVehicleChassisNumber;
  Map<String, String>? vehicleData;

  Stream<Map<String, dynamic>>? _limitationStream;
  String? userId;
  int? orderAllowed;
  Map<String, dynamic>? apiData;
  bool isLoadingData = true;
  int? verificationValue;
  String? errorMessage;
  bool isButtonEnabled = true;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      try {
        final bytes = await _imageFile!.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);


        });
      } catch (e) {

      }
    }
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForNotifications();
    _loadOrderAllowed();
    _initializeStream();
    _loadVerificationValue();
    _loadSavedProVehicleData();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {

      Future.delayed(Duration(milliseconds: 500), () {
        _initializeStream();
        _fetchData();
        _checkForNotifications();
      });
    }
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

  Future<void> _loadVerificationValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      verificationValue = prefs.getInt('verification');
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
          isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingData = false;
      });
    }
  }

  Future<void> _logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.remove('vehicle_brand');
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
    List<String> notifications = prefs.getStringList('notifications') ?? [];
    await prefs.setStringList('notifications', notifications);
    await prefs.setInt('isOrderAllowed', 0);

    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.resetFields();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  Future<void> _saveProVehicleDataToLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pro_vehicle_brand', selectedVehicleBrand ?? '');
    await prefs.setString('pro_vehicle_model', selectedVehicleModel ?? '');
    await prefs.setString('pro_vehicle_year', selectedVehicleYear ?? '');
    await prefs.setString(
        'pro_vehicle_fuelType', selectedVehicleFuelType ?? '');
    await prefs.setString(
        'pro_vehicle_engineSize', selectedVehicleEngineSize ?? '');
    await prefs.setString(
        'pro_vehicle_chassisNumber', selectedVehicleChassisNumber ?? 'N/A');
  }

  Future<void> _loadSavedProVehicleData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? brand = prefs.getString('pro_vehicle_brand');
    String? model = prefs.getString('pro_vehicle_model');
    String? year = prefs.getString('pro_vehicle_year');
    String? fuelType = prefs.getString('pro_vehicle_fuelType');
    String? engineSize = prefs.getString('pro_vehicle_engineSize');
    String? chassisNumber = prefs.getString('pro_vehicle_chassisNumber');

    if (brand != null &&
        model != null &&
        year != null &&
        fuelType != null &&
        engineSize != null &&
        brand.isNotEmpty &&
        model.isNotEmpty &&
        year.isNotEmpty &&
        fuelType.isNotEmpty &&
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


  Future<void> _loadOrderAllowed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      orderAllowed = prefs.getInt('isOrderAllowed') ?? 0;
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
    }
  }

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
      return data;
    } else {
      throw Exception('خطأ في جلب البيانات');
    }
  }

  Widget _buildHeader(Size size) {
    return CustomHeader(
      title: "الشحن الخارجي",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
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
            check
                ? 'assets/images/notification-on.png'
                : 'assets/images/notification-off.png',
          ),
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(size),
          _limitationStream != null
              ? StreamBuilder<Map<String, dynamic>>(
            stream: _limitationStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.3),
                      RotatingImagePage(),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: CustomText(text: 'لا يوجد بيانات'));
              } else if (!snapshot.hasData) {
                return Center(child: CustomText(text: 'لا يوجد بيانات'));
              } else {
                final apiData = snapshot.data!;
                return _buildContentBasedOnApiData(size, user, apiData);
              }
            },
          )
              : Center(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.3),
                RotatingImagePage(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildContentBasedOnApiData(
      Size size, ProfileProvider user, Map<String, dynamic> apiData) {
    final timeDifferenceGt24hrs = apiData['time_difference_gt_24hrs'];
    final limitOfOrder = apiData['limit_of_order'];

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

  Widget _buildFormFields2(
      BuildContext context, Size size, ProfileProvider user, limitOfOrder) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.01),
          _buildVehicleCard(),
          SizedBox(height: size.height * 0.01),
          verificationValue == 0
              ? SizedBox()
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
                          color: Color(0xFF8D8D92),
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
                            color: Color.fromRGBO(240, 240, 240, 1),
                            border: Border.all(
                              color: Color.fromRGBO(240, 240, 240, 1),
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
                          onPressed: (limitOfOrder > 0)
                              ? () async {
                            showConfirmationDialog(
                              context: context,
                              message: 'هل أنت متأكد من التفعيل؟',
                              confirmText: 'تأكيد',
                              onConfirm: () async {
                                setState(() {
                                  isLoading = true;
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
                                  }
                                } catch (e) {

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

  Widget _buildFormFields(
      BuildContext context, Size size, ProfileProvider user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildVehicleCard(),
            SizedBox(height: 10),
            _buildPartField(),
            _buildLinkField(),
            _buildImagePicker(size),
            SizedBox(height: 15),
            MaterialButton(
              onPressed: () => sendOrder(context, user.user_id),
              height: 50,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "ارسال",
                color: white,
                size: 16,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
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

          _saveProVehicleDataToLocal();
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
        }
      }
          : null,
    );
  }

  Widget _buildPartField() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: "*",
            size: 20,
            color: red,
          ),
          Center(
            child: CustomText(
              text: "  قطع غيار",
              color: Color.fromRGBO(0, 0, 0, 1),
              size: 20,
            ),
          ),
        ],
      ),
      CustomHintTextField(
        hintText: "يسمح بقطعة واحدة لكل طلب",
        controller: part_1,
      ),
    ]);
  }

  Widget _buildLinkField() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                text: "(اختياري) رابط القطعة",
                color: Color.fromRGBO(0, 0, 0, 1),
                size: 18,
              ),
            ],
          ),
        ),
        CustomHintTextField(
          hintText: "https://www.ebay.com",
          controller: link,
          keyboardType: TextInputType.url,
          textAlign: TextAlign.start,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Image.asset("assets/images/link.png"),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(Size size) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                text: "صورة القطعة (اختياري)",
                color: Color.fromRGBO(0, 0, 0, 1),
                size: 18,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: CustomText(
                    text: 'إختر الصورة من',
                    size: 30,
                  ),
                  content: CustomText(
                    text: 'الهاتف او الكاميرا',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _getImage(ImageSource.camera);
                      },
                      child: Icon(
                        Icons.photo_camera,
                        size: 30,
                        color: red,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _getImage(ImageSource.gallery);
                      },
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: red,
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: _imageFile != null
              ? Center(
            child: Container(
              width: size.width * 0.5,
              child: Card(
                color: Colors.white,
                elevation: 10,
                shadowColor: Colors.black,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.file(
                      _imageFile!,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          )
              : Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
            child: Container(
              height: size.height * 0.1,
              width: size.width * 0.9,
              color: Color.fromRGBO(246, 246, 246, 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/photo.png"),
                  CustomText(
                    text: "اضافة صورة",
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> sendOrder(BuildContext context, String user_id) async {
    final size = MediaQuery.of(context).size;

    // التحقق من معلومات المركبة
    bool hasCarInfo = selectedVehicleBrand != null &&
        selectedVehicleModel != null &&
        selectedVehicleYear != null;

    if (!hasCarInfo) {
      showConfirmationDialog(
        context: context,
        message: "الرجاء اختيار معلومات المركبة قبل إرسال الطلب",
        confirmText: "حسناً",
        onConfirm: () {},
        cancelText: '',
      );
      return;
    }

    if (part_1.text.isEmpty) {
      showConfirmationDialog(
        context: context,
        message: "الرجاء إدخال اسم القطعة",
        confirmText: "حسناً",
        onConfirm: () {},
        cancelText: '',
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: RotatingImagePage(),
        );
      },
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final carInfo = {
      "brand": selectedVehicleBrand ?? "N/A",
      "model": selectedVehicleModel ?? "N/A",
      "year": selectedVehicleYear ?? "N/A",
      "fuelType": selectedVehicleFuelType != null
          ? selectedVehicleFuelType![0].toLowerCase() +
          selectedVehicleFuelType!.substring(1)
          : "N/A",
      "engineSize": selectedVehicleEngineSize ?? "N/A",
      "chassisNumber": selectedVehicleChassisNumber ?? "N/A",
    };

    final orderData = {
      "car_info": carInfo,
      "time": DateTime.now().toIso8601String(),
      "type": "2",
      "customer_id": user_id,
      "itemname": part_1.text,
      "itemlink": link.text,
      "itemimg64": _base64Image ?? "",
      "token": token
    };



    try {
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/saveprivateorder.php'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(orderData),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody["status"] == "success") {
          // 👇 أضف هاي الأسطر
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
          widget.run(true);
          showModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            context: context,
            builder: (context) {
              return Container(
                height: 390,
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
                      SizedBox(height: 15),
                      Center(
                        child: SvgPicture.asset(
                          'assets/svg/line.svg',
                          width: 30,
                          height: 5,
                        ),
                      ),
                      SizedBox(height: 35),
                      Center(
                        child: Image.asset(
                          "assets/images/done-icon 1.png",
                          height: 122,
                          width: 122,
                        ),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: CustomText(
                          text: "تم ارسال طلبك بنجاح",
                          size: 24,
                          weight: FontWeight.w700,
                        ),
                      ),
                      Center(
                        child: CustomText(
                          text: "... " + "جار العمل على طلبك",
                          size: 24,
                          weight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      MaterialButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage(page: 2)),
                                (Route<dynamic> route) => false,
                          );
                        },
                        height: 45,
                        minWidth: size.width * 0.9,
                        color: Color.fromRGBO(195, 29, 29, 1),
                        child: CustomText(
                          text: "رجوع",
                          color: white,
                          size: 18,
                        ),
                        padding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 50),
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
        } else if (responseBody["status"] == "error") {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 200,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    SizedBox(height: 15),
                    CustomText(
                      text: responseBody["message"] ??
                          "حدث خطأ أثناء معالجة طلبك",
                      size: 20,
                      weight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.red,
                      child: CustomText(
                        text: "إغلاق",
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      } else {
        showConfirmationDialog(
          context: context,
          message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          confirmText: 'حسناً',
          onConfirm: () {},
        );
      }
    } catch (e) {
      Navigator.pop(context);
      showConfirmationDialog(
        context: context,
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
    }
  }
}

class CustomHintTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextAlign textAlign;
  final Widget? prefixIcon;

  const CustomHintTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textAlign = TextAlign.center,
    this.prefixIcon,
  }) : super(key: key);

  @override
  _CustomHintTextFieldState createState() => _CustomHintTextFieldState();
}

class _CustomHintTextFieldState extends State<CustomHintTextField> {
  late FocusNode _focusNode;
  late String currentHintText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    currentHintText = widget.hintText;

    _focusNode.addListener(() {
      setState(() {
        currentHintText = _focusNode.hasFocus ? '' : widget.hintText;
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
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: grey,
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          textAlign: widget.textAlign,
          keyboardType: widget.keyboardType,
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
              fontSize: 16.0,
              fontWeight: FontWeight.normal,
              fontFamily: "Tajawal",
            ),
            counterText: '',
            prefixIcon: widget.prefixIcon,
          ),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
            fontFamily: "Tajawal",
          ),
        ),
      ),
    );
  }
}
