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
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../../widget/Inallpage/NotificationIcon.dart';

class ProOrderWidget extends StatefulWidget {
  final ValueChanged<bool> run;

  ProOrderWidget({super.key, required this.run});

  @override
  State<ProOrderWidget> createState() => _ProOrderWidgetState();
}

class _ProOrderWidgetState extends State<ProOrderWidget> {
  TextEditingController carid = TextEditingController();
  TextEditingController link = TextEditingController();
  TextEditingController part_1 = TextEditingController();
  Color focusedColor = Colors.black;
  bool isLoading = false;
  String hint = "1 H G B H 4 1 J X M N 1 0 9 1 8 6";
  int count = 0;
  bool check = true;
  File? _imageFile;
  final picker = ImagePicker();
  String? _base64Image;
  Color bor = green;

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
          print("Image successfully encoded to Base64.");
          print(_base64Image.toString().length);
        });
      } catch (e) {
        print("Error reading the image: $e");
      }
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

  @override
  void initState() {
    super.initState();
    _checkForNotifications();
  }

  Widget _buildHeader(Size size) {
    return CustomHeader(
      size: MediaQuery.of(context).size,
      title: "الطلب الخاص",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
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
        Scaffold.of(context).openEndDrawer();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return SingleChildScrollView(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [_buildHeader(size), _buildFormFields(context, size, user)],
        ),
      ),
    );
  }

  Widget _buildFormFields(
      BuildContext context, Size size, ProfileProvider user) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(height: 15),
          _buildVinField(),
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
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
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

  Widget _buildPartField() {
    return Column(
      children: [
        Center(
          child: CustomText(
            text: "قطع غيار",
            color: Color.fromRGBO(0, 0, 0, 1),
            size: 20,
          ),
        ),
        CustomHintTextField(
          hintText: "اسم / رقم القطعة",
          controller: part_1,
        ),
      ],
    );
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
    print(_base64Image.toString().length);
    print(_base64Image);
    if (carid.text.length == 17 && part_1.text.isNotEmpty) {
      final orderData = {
        "carid": carid.text,
        "time": DateTime.now().toIso8601String(),
        "type": "2",
        "customer_id": user_id,
        "itemname": part_1.text,
        "itemlink": link.text,
        "itemimg64": _base64Image ?? "",
        "token": token
      };
      print(orderData.toString());

      try {
        final response = await http.post(
          Uri.parse('https://jordancarpart.com/Api/saveprivateorder.php'),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(orderData),
        );
        print(response.body);
        Navigator.pop(context);

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);

          if (responseBody["status"] == "success") {
            widget.run(true);
            showModalBottomSheet(
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
                            Navigator.pop(context);
                          },
                          height: 45,
                          minWidth: size.width * 0.9,
                          color: Color.fromRGBO(195, 29, 29, 1),
                          child: CustomText(
                            text: "رجوع",
                            color: white,
                            size: 18,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 50),
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
            // عرض رسالة الخطأ باستخدام Bottom Sheet أو Dialog
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
            message: "حدث خطأ أثناء إرسال الطلب:",
            confirmText: "حسناً",
            onConfirm: () {},
            cancelText: '',
          );
        }
      } catch (e) {
        Navigator.pop(context);
        showConfirmationDialog(
          context: context,
          message: "حدث خطأ أثناء إرسال الطلب: $e",
          confirmText: "حسناً",
          onConfirm: () {},
          cancelText: '',
        );
      }
    } else {
      Navigator.pop(context);
      showConfirmationDialog(
        context: context,
        message: "الرجاء إدخال رقم الشصي والقطعة",
        confirmText: "حسناً",
        onConfirm: () {},
        cancelText: '',
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
            counterText: '', // إزالة العداد
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
