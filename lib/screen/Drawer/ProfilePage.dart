import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/loading.dart';
import 'package:jcp/provider/DeliveryModel.dart';
import 'package:jcp/provider/EditProductProvider.dart';
import 'package:jcp/provider/OrderDetailsProvider.dart';
import 'package:jcp/provider/OrderProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/Inallpage/showConfirmationDialog.dart';
import '../auth/login.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> list = [
    "عمَان",
    "اربد",
    "الزرقاء",
    "عجلون",
    "جرش",
    "المفرق",
    "البلقاء",
    "مأدبا",
    "الكرك",
    "الطفيلة",
    "معان",
    "العقبة",
  ];

  TextEditingController addressController = TextEditingController();
  String title = "";
  bool cheapest = true;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<ProfileProvider>(context, listen: false);
    addressController.text = user.addressDetail ?? '';

    if (user.city.isNotEmpty && list.contains(user.city)) {
      title = user.city;
    } else {
      title = list.first;
    }
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  String formattedx(String timeStamp) {
    var date = DateTime.parse(timeStamp);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    Future<void> deleteUser(int userId) async {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/deleteuser.php?user_id=$userId');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        print("DELETE USER RESPONSE: ${response.body}");

        if (response.statusCode == 200) {
          showConfirmationDialog(
            context: context,
            message: "تم حذف المستخدم بنجاح",
            confirmText: "حسناً",
            onConfirm: () async {
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
            cancelText: '',
          );
        } else {
          showConfirmationDialog(
            context: context,
            message: "حدث خطأ أثناء حذف المستخدم",
            confirmText: "حسناً",
            onConfirm: () {},
            cancelText: '',
          );
        }
      } catch (error) {
        showConfirmationDialog(
          context: context,
          message: "تأكد من اتصال الإنترنت",
          confirmText: "حسناً",
          onConfirm: () {},
          cancelText: '',
        );
      }
    }

    Future<void> updateUserCityAndAddressDetail(
        int userId, String city, String addressDetail) async {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/updateuser.php?user_id=$userId&city=$city&AddressDetail=$addressDetail'); // أضفنا parameter addressDetail في الرابط

      try {
        final response = await http.get(
          url,
        );
        if (response.statusCode == 200) {
        } else {}
      } catch (error) {}
    }

    savedata(bool value) async {
      cheapest = value ?? false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('cheapest', cheapest);
    }

    Future<String?> _getStoredDate() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? fullDateTime = prefs.getString('time');
      if (fullDateTime != null) {
        DateTime parsedDate = DateTime.parse(fullDateTime);
        String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
        return formattedDate;
      }
      return null;
    }

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.010),
                Container(
                  height: size.height * 0.10,
                  width: size.width,
                  color: white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomText(
                            text: "الصفحة الشخصية",
                            color: black,
                            size: 22,
                            weight: FontWeight.w700,
                          ),
                          SizedBox(width: size.width * 0.18),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.width * 0.25),
                  child: Image.asset(
                    "assets/images/person.png",
                    height: MediaQuery.of(context).size.width * 0.30,
                    width: MediaQuery.of(context).size.width * 0.30,
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "الإسم الكامل",
                        size: 18,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black,
                        color: grey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: TextFormField(
                            enabled: false,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: user.name.capitalizeFirst ?? '',
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "رقم الهاتف",
                        size: 18,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: grey,
                        child: IntlPhoneField(
                          enabled: false,
                          disableLengthCheck: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText:
                            user.phone.replaceFirst("+962", "962") ?? '',
                            border: InputBorder.none,
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w100,
                              fontSize: 16,
                            ),
                            hintStyle: const TextStyle(
                              color: Color.fromRGBO(153, 153, 153, 1),
                              fontSize: 18,
                              fontFamily: "Tajawal",
                              fontWeight: FontWeight.w100,
                            ),
                            contentPadding:
                            EdgeInsets.only(top: 3.0, left: 12.0),
                          ),
                          flagsButtonMargin: EdgeInsets.only(left: 5),
                          disableAutoFillHints: true,
                          initialCountryCode: 'JO',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: "Tajawal",
                          ),
                          onChanged: (phone) {},
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6.5),
                        child: CustomText(
                          text: "المحافظة",
                          size: 18,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: isEditing ? Colors.white : grey,
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,

                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8.0), // مهم لضبط المسافة
                            ),
                            value: (list.contains(title)) ? title : null,
                            isExpanded: true,
                            // هذا يملأ العرض المتاح
                            alignment: Alignment.centerRight,
                            // يجعل السهم والنص بمحاذاة اليمين
                            icon: Icon(Icons.arrow_drop_down),
                            // سهم القائمة
                            iconEnabledColor: Colors.black,
                            // لون السهم
                            items: list.toSet().map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                alignment: Alignment.centerRight,
                                // يضبط كل عنصر للقائمة يمين
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: isEditing
                                ? (val) => setState(() {
                              title = val!;
                              user.city = val;
                            })
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "تفاصيل العنوان",
                        size: 18,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black,
                        color: isEditing ? Colors.white : grey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextFormField(
                            controller: addressController,
                            enabled: isEditing,
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: user.addressDetail.toString(),
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "تاريخ الانضمام",
                        size: 18,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadowColor: Colors.black,
                        color: grey,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: FutureBuilder<String?>(
                            future: _getStoredDate(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return RotatingImagePage();
                              }
                              if (!snapshot.hasData) {
                                return Text("No date available");
                              }
                              return TextFormField(
                                enabled: false,
                                textAlign: TextAlign.end,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: snapshot.data!,
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  fontFamily: "Tajawal",
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       CustomText(
                //         text: "أفضل الأسعار في محافظتك",
                //         size: 18,
                //       ),
                //       Theme(
                //         data: ThemeData(
                //           unselectedWidgetColor: Colors.white,
                //           checkboxTheme: CheckboxThemeData(
                //             fillColor:
                //                 WidgetStateProperty.resolveWith((states) {
                //               if (states.contains(WidgetState.selected)) {
                //                 return Color.fromRGBO(195, 29, 29, 1);
                //               }
                //               return Colors.white;
                //             }),
                //           ),
                //         ),
                //         child: Checkbox(
                //           value: cheapest,
                //           onChanged: (bool? value) {
                //             setState(() {
                //               savedata(value!);
                //             });
                //           },
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                MaterialButton(
                  onPressed: () async {
                    if (isEditing) {
                      if (title.isNotEmpty &&
                          addressController.text.isNotEmpty) {
                        await updateUserCityAndAddressDetail(
                            int.parse(user.getuser_id()),
                            title,
                            addressController.text);

                        user.setcity(title);
                        user.setaddressDetail(addressController.text);

                        setState(() {
                          isEditing = false;
                        });

                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildSuccessBottomSheet(size),
                        );
                      } else {}
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                  height: 50,
                  minWidth: size.width * 0.9,
                  color: title.isNotEmpty && title != user.city
                      ? Color.fromRGBO(153, 153, 160, 1)
                      : Color.fromRGBO(195, 29, 29, 1),
                  child: CustomText(
                    text: isEditing ? "حفظ" : "تعديل",
                    color: Colors.white,
                    size: 16.0,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.010),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.03,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (user.type == "1")
                        GestureDetector(
                          onTap: () {
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
                                        width: size.width * 0.9,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(10),
                                          color:
                                          Color.fromRGBO(255, 255, 255, 1),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.03),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                CustomText(
                                                  text: " الخاصة بك ؟",
                                                  color: black,
                                                  size: 15,
                                                ),
                                                CustomText(
                                                  text: "الحساب",
                                                  color: red,
                                                  size: 15,
                                                ),
                                                CustomText(
                                                  text: " هل انت متأكد من حذف",
                                                  color: black,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.03),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                    Color.fromRGBO(153, 153,
                                                        160, 0.63),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                    ),
                                                  ),
                                                  child: CustomText(
                                                    text: "رفض",
                                                    color: white,
                                                    size: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                        0.03),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await deleteUser(int.parse(
                                                        user.user_id));
                                                  },
                                                  style:
                                                  ElevatedButton.styleFrom(
                                                    backgroundColor: red,
                                                    shape:
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                    ),
                                                  ),
                                                  child: CustomText(
                                                    text: "تأكيد",
                                                    color: grey,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                    0.03),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          child: CustomText(
                            text: "حذف الحساب",
                            size: 16,
                            color: red,
                          ),
                        ),
                      GestureDetector(
                        onTap: () async {
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
                                      width: size.width * 0.9,
                                      // نفس العرض كما كان
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromRGBO(255, 255, 255, 1),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  0.03),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              CustomText(
                                                text:
                                                "هل انت متأكد من تسجيل الخروج ؟",
                                                color: black,
                                                size: 15,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  0.03),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                  Color.fromRGBO(
                                                      153, 153, 160, 0.63),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
                                                  ),
                                                ),
                                                child: CustomText(
                                                  text: "لا",
                                                  color: white,
                                                  size: 15,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                      0.03),
                                              ElevatedButton(
                                                onPressed: () {
                                                  logout(context);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        10),
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
                                              height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  0.03),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: CustomText(
                          text: "تسجيل الخروج",
                          size: 16,
                          color: red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBottomSheet(Size size) {
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
                text: "تم تحديث المدينة وتفاصيل العنوان بنجاح",
                size: 24,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            MaterialButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(page: 1),
                    ));
              },
              height: 45,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "رجوع",
                color: white,
                size: 18,
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

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString('userId');
    String? token = prefs.getString('token');
    _removeFcmToken(token!);
    await prefs.clear();
    await prefs.remove('vehicle_brand');
    await prefs.remove('vehicle_model');
    await prefs.remove('vehicle_year');
    await prefs.remove('vehicle_fuelType');
    await prefs.remove('vehicle_engineSize');
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
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
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
        } else {}
      } else {}
    } catch (e) {}
  }
}
