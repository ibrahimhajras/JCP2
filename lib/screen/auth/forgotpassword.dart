import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/appbar.dart';
import '../../style/colors.dart';
import '../../widget/RotatingImagePage.dart';
import '../../widget/Inallpage/dialogs.dart';
import 'OtpPageForget.dart';

class ForgotPassword extends StatefulWidget {
  static String? verificationCode;

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController controller = TextEditingController();
  String phoneHint = "79xxxxxxxxx";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBarWidget(
        title: "نسيت كلمة المرور",
        color: white,
        lead: Container(),
        widget: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.navigate_next_rounded,
              size: 35,
            ),
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Card(
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
                        showDropdownIcon: false,
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
                        ),
                        flagsButtonMargin: EdgeInsets.only(
                          right: 5,
                        ),
                        controller: controller,
                        disableAutoFillHints: true,
                        textAlignVertical: TextAlignVertical.center,
                        initialCountryCode: 'JO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                        onChanged: (phone) {
                          if (phone.number.length == 0) {
                            phoneHint = "79xxxxxxxxx";
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Container(
                    width: size.width * 0.6,
                    child: MaterialButton(
                      height: 50,
                      minWidth: size.width * 0.6,
                      color: red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "OTP",
                            weight: FontWeight.w500,
                            color: white,
                            size: 16,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "إرسال رمز",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ],
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () {
                        sendOtp(controller.text);
                      },
                    ),
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

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(child: Center(child: RotatingImagePage())),
      ],
    );
  }

  String generateOTP() {
    final Random _random = Random();
    String otp = '';

    for (int i = 0; i < 6; i++) {
      otp += _random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendOtp(String phone) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    String OTP = generateOTP();
    await prefs.setString('otp', OTP);
    String msg =
        "شكرًا لك على الانضمام إلى Jordan Car Parts. تم إرسال الرمز بنجاح ${OTP}";
    Uri apiUrl = Uri.parse(
        'http://82.212.81.40:8080/websmpp/websms?user=JCParts21&pass=123A@Neu%23&text=$msg&type=4&mno=962' +
            phone +
            '&sid=JC-Parts');
    try {
      final response = await http.get(apiUrl);
      setState(() {
        isLoading = false;
      });
      print(response.body.toString());
      if (response.statusCode == 200) {
        print(OTP);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpPageForgwe(phone: phone,),
          ),
        );
      } else {
        AppDialogs.showErrorDialog(context, 'حدث خطأ أثناء إرسال OTP.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      AppDialogs.showErrorDialog(context, 'حدث خطأ أثناء إرسال OTP: $e');
    }
  }
}
