import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/helper/snack_bar.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
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

  Map<String, bool> selectedTradeFields = {
    "ياباني": false,
    "ألماني": false,
    "أمريكي": false,
    "أخرى": false,
    "صيني": false,
    "كوري": false,
  };

  TextEditingController otherTradeController = TextEditingController();

  final Map<String, bool> y = {};

  bool isChecked = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  bool isLoading = false;
  String nameHint = "الأسم الأول مع العائلة";
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
    final Map<String, dynamic> formData = {
      'name': name.text,
      'phone': phoneCon.text,
      'city': title,
      'offerPrice': title1,
      'businessSize': title2,
      'tradeTypes': getSelectedTradeTypes(),
      'otherTrade': otherTradeController.text,
      'productTypes': y.keys.toList(),
    };

    if (formData['name'] == null ||
        formData['phone'] == null ||
        formData['city'] == null ||
        formData['offerPrice'] == null ||
        formData['businessSize'] == null) {
      return;
    }

    final String jsonData = json.encode(formData);

    final String apiUrl =
        'https://jordancarpart.com/Api/sent_make_customers_order.php'; // ضع هنا عنوان الـ API الخاص بك

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: size.height * 0.20,
                width: size.width,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [primary1, primary2, primary3]),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "انضم كتاجر",
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                      SizedBox(width: size.width * 0.2),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_forward_ios_rounded,
                              color: white),
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
                      if (selectedTradeFields["أخرى"] == true)
                        buildOtherField(),
                      SizedBox(height: 15),
                      CustomButton(
                        height: 50,
                        minWidth: size.width * 0.9,
                        text: "تقديم الطلب",
                        onPressed: () async {
                          if (validateFields()) {
                            await sendDataToApi();
                            showModalBottomSheet(
                              builder: (context) {
                                return _buildSuccessBottomSheet(context);
                              },
                              context: context,
                            );
                          }
                        },
                      ),
                      SizedBox(height: 45),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  List<String> getSelectedTradeTypes() {
    List<String> selectedTypes = [];
    selectedTradeFields.forEach((key, value) {
      if (value) {
        selectedTypes.add(key);
      }
    });
    return selectedTypes;
  }

  Padding buildOtherField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6.5),
                  child: CustomText(
                    text: "مجال تجارة القطع",
                    size: 18,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.black,
                    color: grey,
                    child: TextFormField(
                      controller: otherTradeController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: " ... ادخل مجال التجارة",
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        fontFamily: "Tajawal",
                      ),
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Padding buildCheckboxSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
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
                      buildCheckboxColumn("بلد المنشأ", isChecked3, (selected) {
                        setState(() {
                          isChecked3 = selected;
                          y["commercial2"] = selected;
                        });
                      }),
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
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(right: 6.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText(
                  text: "*",
                  size: 25,
                  color: red,
                ),
                CustomText(
                  text: "  مجال تجارة القطع",
                  size: 18,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 50.0, right: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: List.generate(
                (selectedTradeFields.keys.length / 3).ceil(),
                (index) {
                  int start = index * 3;
                  int end = (start + 3) > selectedTradeFields.keys.length
                      ? selectedTradeFields.keys.length
                      : start + 3;

                  var keysSubset =
                      selectedTradeFields.keys.toList().sublist(start, end);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: keysSubset.map((key) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.0, right: 10.0),
                        child: Column(
                          children: [
                            MSHCheckbox(
                              size: 40,
                              value: selectedTradeFields[key]!,
                              colorConfig:
                                  MSHColorConfig.fromCheckedUncheckedDisabled(
                                checkedColor: red,
                              ),
                              style: MSHCheckboxStyle.stroke,
                              onChanged: (bool value) {
                                setState(() {
                                  selectedTradeFields[key] = value;
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            CustomText(
                              text: key,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSuccessBottomSheet(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.5,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                height: size.height * 0.15,
                width: size.width * 0.3,
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: CustomText(
                text: "تم ارسال طلبك لتقديم كتاجر بنجاح",
                size: size.width * 0.06,
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
              height: size.height * 0.07,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "رجوع",
                color: Colors.white,
                size: size.width * 0.045,
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
              text: "الإسم الكامل",
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
                  hintText: nameHint, // عرض الـ hint هنا
                  contentPadding: EdgeInsets.symmetric(horizontal: 6.5)),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: "Tajawal",
              ),
              onTap: () {
                setState(() {
                  nameHint = "";
                });
              },
              onChanged: (text) {
                setState(() {
                  if (text.isEmpty) {
                    nameHint = "الإسم الاول مع العائلة";
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
      padding: const EdgeInsets.all(10.0),
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
              dropdownColor: Colors.white,
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
    } else if (getSelectedTradeTypes().isEmpty) {
      showSnack(context, "الرجاء اختيار نوع التجارة");
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
