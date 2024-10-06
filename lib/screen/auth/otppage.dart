import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import '../../style/custom_text.dart';
import '../../widget/Inallpage/dialogs.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String fname;
  final String lname;
  final String password;
  final String city;

  const OtpPage({
    Key? key,
    required this.phone,
    required this.fname,
    required this.lname,
    required this.password,
    required this.city,
  }) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  bool isLoading = false;
  Timer? _timer;
  int _start = 60;
  String generatedOtp = '';
  bool canResendOtp = false;

  @override
  void initState() {
    super.initState();
    generateAndStoreOtp();
    startTimer();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _start = 60;
    canResendOtp = false;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _timer?.cancel();
          canResendOtp = true;
          clearOtpFromPrefs();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String generateOTP() {
    final Random _random = Random();
    String otp = '';

    for (int i = 0; i < 6; i++) {
      otp += _random.nextInt(10).toString();
    }

    return otp;
  }

  Future<void> generateAndStoreOtp() async {
    generatedOtp = generateOTP();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('otp', generatedOtp);
    String msg =
        "شكرًا لك على أنضمامك إلى Jordan Car Parts. تم إرسال الرمز بنجاح ${generatedOtp}";
    Uri apiUrl = Uri.parse(
        'http://82.212.81.40:8080/websmpp/websms?user=JCParts21&pass=123A@Neu%23&text=$msg&type=4&mno=962+${widget.phone}&sid=JCP-Jordan');
    try {
      final response = await http.get(apiUrl);
      setState(() {
        isLoading = false;
      });
      print(response.body.toString());
      if (response.statusCode == 200) {
        print("تم إرسال OTP بنجاح.");
      } else {
        showConfirmationDialog(
          context: context,
          message: 'حدث خطأ أثناء إرسال OTP.',
          confirmText: 'حسناً',
          onConfirm: () {
            // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
          },
          cancelText: '', // لا حاجة لزر إلغاء
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ أثناء إرسال OTP: $e',
        confirmText: 'حسناً',
        onConfirm: () {
          // يمكن تركه فارغاً
        },
        cancelText: '',
      );
    }
  }

  Future<void> clearOtpFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('otp');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: "أدخل الرمز الذي أرسلناه إلى",
                      color: black,
                      size: size.width * 0.05,
                      weight: FontWeight.w600,
                    ),
                    CustomText(
                      text: "${widget.phone}",
                      color: black,
                      size: size.width * 0.05,
                      weight: FontWeight.w600,
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomText(
                      text:
                          "لقد أرسلنا رمزاً مكوناً من 6 أرقام إلى رقم هاتفك المسجل. يرجى إدخال هذا الرمز لإكمال عملية التسجيل الخاصة بك.",
                      color: Colors.grey,
                      size: size.width * 0.04,
                      weight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: size.height * 0.05),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.015,
                          horizontal: size.width * 0.12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Flexible(
                            // استخدام Flexible لمنع تجاوز العرض
                            child: SizedBox(
                              width: size.width * 0.1,
                              child: TextFormField(
                                controller: otpControllers[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: red, width: 2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: red, width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade400, width: 2),
                                  ),
                                  hintText: "-",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade600),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: size.height * 0.015),
                                ),
                                onChanged: (value) {
                                  if (value.length == 1) {
                                    if (index < 5) {
                                      FocusScope.of(context).nextFocus();
                                    } else {
                                      _verifyOtp();
                                    }
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(context).previousFocus();
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    MaterialButton(
                      height: size.height * 0.07,
                      minWidth: size.width * 0.9,
                      color: Color.fromRGBO(195, 29, 29, 1),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "متابعة",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Tajawal",
                              ),
                            ),
                      padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.015,
                          horizontal: size.width * 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onPressed: () {
                        _verifyOtp();
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    Text(
                      "إعادة إرسال الرمز بعد $_start ثانية",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    GestureDetector(
                      onTap: canResendOtp ? _resendOtp : null,
                      child: Text(
                        "إرسال رسالة SMS مجدداً",
                        style: TextStyle(
                          color: canResendOtp ? red : Colors.grey,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
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

  Future<void> _resendOtp() async {
    setState(() {
      isLoading = true;
    });

    await generateAndStoreOtp();
    startTimer();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    String enteredOtp =
        otpControllers.map((controller) => controller.text).join();

    final prefs = await SharedPreferences.getInstance();
    String? otpFromPrefs = prefs.getString('otp');
    print(enteredOtp + " otp message by user");

    print(otpFromPrefs.toString() + " otp message by API");

    if (otpFromPrefs == enteredOtp) {
      print("OTP صحيح");
      Uri apiUrl = Uri.parse('https://jordancarpart.com/Api/rigester.php'
          '?phone=${widget.phone}'
          '&type=1'
          '&password=${widget.password}'
          '&city=${widget.city}'
          '&name=${Uri.encodeComponent("${widget.fname} ${widget.lname}")}');

      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        print("تم التسجيل بنجاح");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        AppDialogs.showErrorDialog(context, "لم يتم التسجيل حاول في ما بعد");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
      setState(() {
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: "الرمز الذي أدخلته غير صحيح.",
        confirmText: "حسناً",
        onConfirm: () {
          // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
        },
        cancelText: '', // لا حاجة لزر إلغاء
      );
    }
  }

  @override
  void codeUpdated() {}
}
