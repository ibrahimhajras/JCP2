import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/auth/otppage.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import '../../style/appbar.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'dart:math';

// Import the math package for Random

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController phone = TextEditingController();
  String city = "Amman";
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final _key = GlobalKey<ScaffoldState>();
  bool ob = true;
  bool ob1 = true;
  bool isLoading = false;
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

  String phoneHint = "79xxxxxxxxx",
      passHint = "**********",
      passConfirmHint = "**********";

  String fNameHint = "اسم الاول";
  String lNameHint = "اسم العائلة";

  String image = "assets/images/eye-hide.png";
  String image1 = "assets/images/eye-hide.png";
  String title = "عمَان";

  String generateOTP() {
    final Random _random = Random();
    String otp = '';

    for (int i = 0; i < 6; i++) {
      otp += _random.nextInt(10).toString();
    }

    return otp;
  }

  Future<void> sendOtp(String fname, String lname, String phone,
      String password, String city) async {
    setState(() {
      isLoading = true;
    });

    bool startsWithEnglishLetter(String text) {
      if (text.isEmpty) return false;
      return RegExp(r'^[a-zA-Z]').hasMatch(text[0]);
    }

    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) return text;
      return text[0].toUpperCase() + text.substring(1);
    }

    try {
      if (startsWithEnglishLetter(fname)) {
        fname = capitalizeFirstLetter(fname);
      }
      if (startsWithEnglishLetter(lname)) {
        lname = capitalizeFirstLetter(lname);
      }

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OtpPage(
            phone: phone,
            fname: fname,
            lname: lname,
            password: password,
            city: city,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ أثناء إرسال OTP: $e',
        confirmText: 'حسناً',
        onConfirm: () {
          // يمكن تركه فارغاً لأنه مجرد رسالة معلوماتية
        },
        cancelText: '', // لا حاجة لزر إلغاء في هذه الحالة
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWidget(
        title: "إنشاء حساب جديد",
        color: white,
      ),
      key: _key,
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: size.height * 0.9,
              child: Column(
                children: [
                  buildInputFields(size),
                  SizedBox(height: 15),
                  MaterialButton(
                    onPressed: () {
                      if (fname.text.isEmpty ||
                          lname.text.isEmpty ||
                          phone.text.isEmpty ||
                          password.text.isEmpty ||
                          city.isEmpty) {
                        showConfirmationDialog(
                          context: context,
                          message: 'يرجى تعبئة جميع الحقول',
                          confirmText: 'حسناً',
                          onConfirm: () {
                            // يمكن تركه فارغاً لأنه مجرد رسالة معلوماتية
                          },
                          cancelText: '', // لا حاجة لزر إلغاء في هذه الحالة
                        );
                        return;
                      }
                      if (phone.text.length != 9 ||
                          !phone.text.startsWith('7')) {
                        showConfirmationDialog(
                          context: context,
                          message:
                              'يجب أن يكون رقم الهاتف مكونًا من 9 أرقام ويبدأ بالرقم 7',
                          confirmText: 'حسناً',
                          onConfirm: () {
                            // لا حاجة لفعل شيء بعد الضغط على حسناً
                          },
                          cancelText: '', // لا حاجة لزر إلغاء
                        );
                        return;
                      }

                      if (password.text != confirmPassword.text) {
                        showConfirmationDialog(
                          context: context,
                          message:
                              'كلمة المرور وتأكيد كلمة المرور غير متطابقتين. يرجى التأكد من تطابقهما',
                          confirmText: 'حسناً',
                          onConfirm: () {
                            // لا حاجة لفعل شيء بعد الضغط على حسناً
                          },
                          cancelText: '', // لا حاجة لزر إلغاء
                        );
                        return;
                      }
                      sendOtp(fname.text, lname.text, phone.text, password.text,
                          city);
                    },
                    height: 50,
                    minWidth: size.width * 0.9,
                    color: Color.fromRGBO(195, 29, 29, 1),
                    child: Text(
                      "إنشاء الحساب",
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
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ));
                        },
                        child: CustomText(
                          text: 'تسجيل الدخول',
                          color: red,
                          size: 16,
                          weight: FontWeight.w700,
                        ),
                      ),
                      CustomText(
                        text: 'هل لديك حساب ؟',
                        size: 16,
                        color: Colors.grey.shade600,
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget buildInputFields(Size size) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: buildTextField(fname, "إسم الاول", fNameHint, (newHint) {
                  setState(() {
                    fNameHint = newHint;
                  });
                }),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child:
                    buildTextField(lname, "إسم العائلة", lNameHint, (newHint) {
                  setState(() {
                    lNameHint = newHint;
                  });
                }),
              ),
            ),
          ],
        ),
        buildPhoneField(),
        buildCityField(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child:
              buildPasswordField(password, "كلمة المرور", passHint, ob, (val) {
            setState(() {
              ob = val;
            });
          }),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          child: buildPasswordField(
              confirmPassword, "تأكيد كلمة المرور", passConfirmHint, ob1,
              (val) {
            setState(() {
              ob1 = val;
            });
          }),
        )
      ],
    );
  }

  Widget buildTextField(
    TextEditingController controller,
    String labelText,
    String initialHintText,
    Function(String) updateHint,
  ) {
    String hintText = initialHintText;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6.5),
              child: CustomText(
                text: labelText,
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
                controller: controller,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
                onTap: () {
                  setState(() {
                    updateHint("");
                  });
                },
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      updateHint(labelText);
                    }
                  });
                },
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w100,
                  fontSize: 16,
                  fontFamily: "Tajawal",
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                  fontWeight: FontWeight.w100,
                ),
                contentPadding: EdgeInsets.only(top: 3.0, left: 12.0),
              ),
              flagsButtonMargin: EdgeInsets.only(right: 5),
              disableAutoFillHints: true,
              textAlignVertical: TextAlignVertical.center,
              initialCountryCode: 'JO',
              controller: phone,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              onChanged: (phone) {
                String x = phone.completeNumber;
                if (phone.number.isEmpty) {
                  setState(() {
                    phoneHint = "79xxxxxxxxx";
                  });
                } else if (phone.number[0] == '0') {
                  x = x.replaceFirst("0", "");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCityField() {
    return Padding(
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
                  city = title;
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
    );
  }

  Widget buildPasswordField(
    TextEditingController controller,
    String labelText,
    String hintText,
    bool obscureText,
    Function(bool) toggleVisibility,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6.5),
              child: CustomText(
                text: labelText,
                size: 18,
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: Colors.black,
              color: grey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextFormField(
                  controller: controller,
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    icon: GestureDetector(
                      onTap: () {
                        toggleVisibility(!obscureText);
                      },
                      child: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      hintText = "";
                    });
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        hintText =
                            "**********";
                      });
                    }
                  },
                  obscureText: obscureText,
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
        );
      },
    );
  }

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
