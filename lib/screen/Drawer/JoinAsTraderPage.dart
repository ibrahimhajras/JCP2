import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/helper/snack_bar.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:http/http.dart' as http;
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';

import '../../widget/Inallpage/CustomButton.dart';

class TraderPage extends StatefulWidget {
  const TraderPage({super.key});

  @override
  State<TraderPage> createState() => _TraderPageState();
}

class _TraderPageState extends State<TraderPage> {
  TextEditingController name = TextEditingController();
  TextEditingController phoneCon = TextEditingController();

  final Map<String, bool> y = {};

  bool isChecked = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isLoading = false; // State to handle loading

  String phoneHint = "79xxxxxxxxx";
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

  List<String> list1 = [
    "نعم",
    "لا",
  ];
  List<String> list2 = [
    "كبير",
    "وسط",
    "صغير",
  ];

  String title = "عمَان";
  String title1 = "نعم";
  String title2 = "كبير";

  Future<void> sendDataToApi() async {
    print('Name: ${name.text}');
    print('Phone: ${phoneCon.text}');
    print('City: $title');
    print('Price: $title1');
    print('Ship: $title2');
    print('Time: ${DateTime.now().toString()}');
    print('Agency: $isChecked2');
    print('Used: $isChecked1');
    print('Commercial: $isChecked');

    final url = Uri.parse(
        'https://jordancarpart.com/Api/sent_make_customers_order.php?name=${name.text}&phone=${phoneCon.text}&city=${title}&price=${title1}&ship=${title2}&time=${DateTime.now().toString()}&agency=${isChecked2}&used=${isChecked1}&=commercial${isChecked}');
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': 'Authorization',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        print('Data sent successfully: ${response.body}');
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      primary1,
                      primary2,
                      primary3,
                    ],
                  ),
                  image: DecorationImage(
                    image: AssetImage("assets/images/card.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "انضم كتاجر",
                        color: white,
                        size: 22,
                        weight: FontWeight.w700,
                      ),
                      SizedBox(
                        width: size.width * 0.25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      buildNameField(),
                      buildPhoneField(),
                      buildDropdownField("المحافظة", list, title, (val) {
                        setState(() {
                          title = val!;
                        });
                      }),
                      buildDropdownField(
                          "استعداد لتقديم افضل سعر في المملكة ؟", list1, title1,
                          (val) {
                        setState(() {
                          title1 = val!;
                        });
                      }),
                      buildDropdownField(
                          "حجم تجارتك ومستودعك بالسوق ؟", list2, title2, (val) {
                        setState(() {
                          title2 = val!;
                        });
                      }),
                      buildCheckboxSection(),
                      SizedBox(height: 15),
                      CustomButton(
                        text: "تقديم الطلب",
                        onPressed: () async {
                          if (validateFields()) {
                            await sendDataToApi();
                            showModalBottomSheet(
                              builder: (context) {
                                return _buildSuccessBottomSheet(size);
                              },
                              context: context,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) _buildLoadingOverlay(),
          // Show loading overlay if isLoading is true
        ],
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
                text: "تم ارسال طلبك لتقديم كتاجر بنجاح",
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

  // Helper methods
  Padding buildNameField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "الاسم كامل",
              size: 18,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            shadowColor: Colors.black,
            color: grey,
            child: TextFormField(
              textAlign: TextAlign.end,
              controller: name,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "الأسم الأول مع العائلة",
              ),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPhoneField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "رقم الهاتف",
              size: 18,
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: grey,
            child: IntlPhoneField(
              onTap: () {
                setState(() {
                  phoneHint = "";
                });
              },
              disableLengthCheck: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                hintText: phoneHint,
                border: InputBorder.none,
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                hintStyle: TextStyle(
                  color: Color.fromRGBO(153, 153, 160, 1),
                  fontSize: 18,
                  fontFamily: "Tajawal",
                ),
              ),
              flagsButtonMargin: EdgeInsets.only(right: 5),
              disableAutoFillHints: true,
              textAlignVertical: TextAlignVertical.center,
              initialCountryCode: 'JO',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              onChanged: (phone) {
                String x = phone.completeNumber;
                phoneCon.text =
                    (phone.number.length == 0 || phone.number[0] == '0')
                        ? x.replaceFirst("0", "")
                        : x;
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding buildDropdownField(String label, List<String> options, String value,
      ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: label,
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
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    text: option,
                    color: black,
                  ),
                );
              }).toList(),
              value: value,
              isExpanded: true,
              menuMaxHeight: 200,
              icon: Container(),
              iconSize: 30.0,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(10),
              elevation: 10,
              style: TextStyle(
                color: black,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding buildCheckboxSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: CustomText(
              text: "نوع القطع المتوفرة لديك ؟",
              size: 18,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCheckboxColumn("تجاري", isChecked, (selected) {
                  setState(() {
                    isChecked = selected;
                    y["commercial"] = selected;
                  });
                }),
                buildCheckboxColumn("مستعمل", isChecked1, (selected) {
                  setState(() {
                    isChecked1 = selected;
                    y["used"] = selected;
                  });
                }),
                buildCheckboxColumn("شركة", isChecked2, (selected) {
                  setState(() {
                    isChecked2 = selected;
                    y["agency"] = selected;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column buildCheckboxColumn(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        MSHCheckbox(
          size: 40,
          value: value,
          colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
            checkedColor: red,
          ),
          style: MSHCheckboxStyle.stroke,
          onChanged: onChanged,
        ),
        SizedBox(height: 10),
        CustomText(
          text: label,
          color: black,
        ),
      ],
    );
  }

  bool validateFields() {
    if (title.isEmpty) {
      showSnack(context, "الرجاء اختيار المدينة");
      return false;
    } else if (name.text.isEmpty) {
      showSnack(context, "الرجاء إدخال الاسم");
      return false;
    } else if (phoneCon.text.isEmpty) {
      showSnack(context, "الرجاء إدخال رقم الهاتف");
      return false;
    } else if (title2.isEmpty) {
      showSnack(context, "الرجاء اختيار حجم تجارتك");
      return false;
    } else if (title1.isEmpty) {
      showSnack(context, "الرجاء اختيار الاستعداد لتقديم افضل سعر");
      return false;
    } else if (y.isEmpty) {
      showSnack(context, "الرجاء اختيار نوع القطع المتوفرة");
      return false;
    }
    return true;
  }

  // Loading overlay widget
  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: RotatingImagePage(),
        ),
      ],
    );
  }
}
