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
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> list = [
    "عمان",
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

  String title = "";

  @override
  void initState() {
    super.initState();
    final user = Provider.of<ProfileProvider>(context, listen: false);

    if (user.city.isNotEmpty && list.contains(user.city)) {
      title = user.city;
    } else {
      title = list.first;
    }
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

        if (response.statusCode == 200) {
          print('تم حذف الحساب بنجاح');
        } else {
          print('فشل في حذف الحساب: ${response.statusCode}');
        }
      } catch (error) {
        print('حدث خطأ أثناء حذف الحساب: $error');
      }
    }

    Future<void> updateUserCity(int userId, String city) async {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/updateuser.php?user_id=$userId&city=$city');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print(response.body.toString());
          print('تم تحديث المدينة بنجاح');
        } else {
          print('فشل في تحديث المدينة: ${response.statusCode}');
        }
      } catch (error) {
        print('حدث خطأ أثناء تحديث المدينة: $error');
      }
    }

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String time =
        DateFormat('yyyy-MM-dd').format(profileProvider.getcreatedAt());

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.015),
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
                        SizedBox(width: size.width * 0.12),
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
                    MediaQuery.of(context).size.width *
                        0.25), // نسبة من عرض الشاشة لتحديد نصف القطر
                child: Image.asset(
                  "assets/images/person.png",
                  height: MediaQuery.of(context).size.width *
                      0.30, // نسبة من عرض الشاشة لتحديد الارتفاع
                  width: MediaQuery.of(context).size.width *
                      0.30, // نسبة من عرض الشاشة لتحديد العرض
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "ألاسم الكامل",
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
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.02,
                  // نسبة من ارتفاع الشاشة لتحديد الهوامش الرأسية
                  horizontal: MediaQuery.of(context).size.width *
                      0.03, // نسبة من عرض الشاشة لتحديد الهوامش الأفقية
                ),
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
                        decoration: InputDecoration(
                          hintText:
                              user.phone.replaceFirst("+962", "962") ?? '',
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        flagsButtonMargin: EdgeInsets.only(right: 5),
                        disableAutoFillHints: true,
                        textAlignVertical: TextAlignVertical.center,
                        initialCountryCode: 'JO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                        onChanged: (phone) {},
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: grey,
                      child: DropdownButtonFormField<String>(
                        padding: EdgeInsets.only(right: 5),
                        alignment: Alignment.center,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          border: InputBorder.none,
                        ),
                        items: list.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            alignment: Alignment.centerRight,
                            child: CustomText(
                              text: value,
                              color: black,
                            ),
                          );
                        }).toList(),
                        value: title,
                        isExpanded: true,
                        menuMaxHeight: 200,
                        icon: Container(),
                        iconSize: 30.0,
                        onChanged: (val) {
                          setState(() {
                            title = val!;
                            user.city = val;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        elevation: 10,
                        style: TextStyle(
                          color: black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
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
                        child: TextFormField(
                          enabled: false,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '$time',
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
              SizedBox(height: 10),
              MaterialButton(
                onPressed: () async {
                  if (title.isNotEmpty) {
                    await updateUserCity(int.parse(user.getuser_id()), title);
                    user.setcity(title);
                    showModalBottomSheet(
                      builder: (context) {
                        return _buildSuccessBottomSheet(size);
                      },
                      context: context,
                    );
                  } else {
                    print('لم يتم تغيير المدينة أو العنوان فارغ.');
                  }
                },
                height: MediaQuery.of(context).size.height * 0.06,
                // 7% من ارتفاع الشاشة
                minWidth: size.width * 0.9,
                color: title.isNotEmpty && title != user.city
                    ? Color.fromRGBO(153, 153, 160, 1)
                    : Color.fromRGBO(195, 29, 29, 1),
                child: Text(
                  "حفظ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontFamily: "Tajawal",
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width *
                      0.05, // 5% من عرض الشاشة
                  vertical: MediaQuery.of(context).size.height *
                      0.03, // 3% من ارتفاع الشاشة
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Color.fromRGBO(
                                                    153, 153, 160, 0.63),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: CustomText(
                                                text: "رفض",
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
                                              onPressed: () async {
                                                await deleteUser(
                                                    int.parse(user.user_id));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                backgroundColor: Color.fromRGBO(
                                                    153, 153, 160, 0.63),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                      BorderRadius.circular(10),
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
                text: "تم تحديث المدينة بنجاح",
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
                      builder: (context) => HomePage(),
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

    await prefs.clear();

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
}
