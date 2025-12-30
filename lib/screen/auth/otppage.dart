import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:http/http.dart' as http;
import '../../style/custom_text.dart';
import '../../utils/otp_rate_limiter.dart';
import '../../widget/Inallpage/dialogs.dart';
import '../../model/UserModel.dart';
import '../../provider/ProfileProvider.dart';
import '../home/homeuser.dart';
import '../../widget/NotificationPermissionHandler.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final String fname;
  final String lname;
  final String password;
  final String city;
  final String AddressDetail;

  const OtpPage(
      {Key? key,
        required this.phone,
        required this.fname,
        required this.lname,
        required this.password,
        required this.city,
        required this.AddressDetail})
      : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> with CodeAutoFill {
  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  bool isLoading = false;
  Timer? _timer;
  int _start = 60;
  String generatedOtp = '';
  bool canResendOtp = false;

  @override
  void initState() {
    super.initState();
    generateAndStoreOtp();
    listenForCode();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNodes[0].requestFocus();
      FocusScope.of(context).requestFocus(focusNodes[0]);
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
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

    print('🔐 OTP Generated: $generatedOtp');

    String msg =
        "شكرًا لك على أنضمامك إلى قطع سيارات الأردن. تم إرسال الرمز بنجاح ${generatedOtp}.";

    Uri apiUrl = Uri.parse('https://jordancarpart.com/Api/auth/send_sms.php');

    try {
      final response = await http.post(
        apiUrl,
        body: {'phone': widget.phone, 'message': msg},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData["status"] == "success") {
        } else {
          showConfirmationDialog(
            context: context,
            message: 'حدث خطأ أثناء إرسال OTP.',
            confirmText: 'حسناً',
            onConfirm: () {},
            cancelText: '',
          );
        }
      } else {
        showConfirmationDialog(
          context: context,
          message: 'حدث خطأ أثناء إرسال OTP.',
          confirmText: 'حسناً',
          onConfirm: () {},
          cancelText: '',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ أثناء إرسال OTP.',
        confirmText: 'حسناً',
        onConfirm: () {},
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
                          horizontal: size.width * 0.006),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return Flexible(
                            child: SizedBox(
                              width: size.width * 0.9,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: TextFormField(
                                  controller: otpControllers[index],
                                  focusNode: focusNodes[index],
                                  // تعيين FocusNode
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                      BorderSide(color: red, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                      BorderSide(color: red, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.black12, width: 1),
                                    ),
                                    hintText: "-",
                                    hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: size.height * 0.030),
                                  ),
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      if (index < 5) {
                                        FocusScope.of(context).requestFocus(
                                            focusNodes[index + 1]);
                                      } else {
                                        _verifyOtp();
                                      }
                                    } else if (value.isEmpty && index > 0) {
                                      FocusScope.of(context)
                                          .requestFocus(focusNodes[index - 1]);
                                    }
                                  },
                                ),
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
                          ? RotatingImagePage()
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
                        fontFamily: "Tajawal",
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    GestureDetector(
                      onTap: canResendOtp ? _resendOtp : null,
                      child: CustomText(
                        text: "مجددًا SMS إرسال رسالة",
                        color: canResendOtp ? Colors.red : Colors.grey,
                        size: size.width * 0.045,
                        weight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        textAlign: TextAlign.center,
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

    // Check OTP rate limit
    final limitCheck = await OtpRateLimiter.checkOtpLimit(widget.phone);

    if (limitCheck['success'] == true && limitCheck['allowed'] == false) {
      setState(() {
        isLoading = false;
      });

      String message = 'لقد تجاوزت الحد المسموح من محاولات إرسال رمز التحقق';
      if (limitCheck['remaining_seconds'] != null) {
        message +=
        '\n\nيمكنك المحاولة مرة أخرى بعد\n${OtpRateLimiter.formatRemainingTime(limitCheck['remaining_seconds'])}';
      }

      showConfirmationDialog(
        context: context,
        message: message,
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
      return;
    }

    // Log OTP attempt
    await OtpRateLimiter.logOtpAttempt(widget.phone);

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

    if (otpFromPrefs == enteredOtp) {
      Uri apiUrl = Uri.parse(
        'https://jordancarpart.com/Api/auth/rigester.php'
            '?phone=${widget.phone}'
            '&type=1'
            '&password=${widget.password}'
            '&city=${widget.city}'
            '&name=${Uri.encodeComponent("${widget.fname} ${widget.lname}")}'
            '&addressDetail=${Uri.encodeComponent(widget.AddressDetail)}',
      );

      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Auto-login after successful registration
          await _autoLogin();
        } else {}
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
        onConfirm: () {},
        cancelText: '',
      );
    }
  }

  Future<void> _autoLogin() async {
    try {
      final url =
          'https://jordancarpart.com/Api/auth/login.php?phone=${widget.phone}&password=${widget.password}';

      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);

      if (responseData['status'] == 'success') {
        final userData = responseData['user'];
        UserModel user = UserModel.fromJson(userData);

        final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
        profileProvider.setuser_id(user.userId);
        profileProvider.setphone(user.phone);
        profileProvider.setname(user.name);
        profileProvider.setpassword(user.password);
        profileProvider.settype(user.type);
        profileProvider.setcity(user.city);
        profileProvider.setcreatedAt(user.createdAt);
        profileProvider.settoken(user.token);
        profileProvider.setaddressDetail(user.addressDetail);

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
        await prefs.setString('phone', user.phone);
        await prefs.setString('password', user.password);
        await prefs.setString('userId', user.userId);
        await prefs.setString('name', user.name);
        await prefs.setString('type', user.type);
        await prefs.setString('city', user.city);
        await prefs.setString('addressDetail', user.addressDetail);
        await prefs.setString('time', user.createdAt.toIso8601String());
        await prefs.setString('token', user.token);

        // Subscribe to FCM topic
        await FirebaseMessaging.instance.subscribeToTopic("User");

        // Update FCM token
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        messaging.getToken().then((token) {
          if (token != null) {
            _updateFCMToken(user.userId, token);
          }
        });

        // Navigate to home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage(page: 1)),
              (Route<dynamic> route) => false,
        );
      } else {
        // If auto-login fails, show success message and go to login
        showConfirmationDialog(
          context: context,
          message: "تم إنشاء الحساب بنجاح",
          confirmText: "حسناً",
          onConfirm: () {
            Navigator.pop(context);
            Future.delayed(Duration(milliseconds: 100), () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            });
          },
          cancelText: '',
        );
      }
    } catch (e) {
      // If auto-login fails, show success message and go to login
      showConfirmationDialog(
        context: context,
        message: "تم إنشاء الحساب بنجاح",
        confirmText: "حسناً",
        onConfirm: () {
          Navigator.pop(context);
          Future.delayed(Duration(milliseconds: 100), () {
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          });
        },
        cancelText: '',
      );
    }
  }

  void _updateFCMToken(String userId, String fcmToken) async {
    final url = Uri.parse('https://jordancarpart.com/Api/update_fcm_token.php');
    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'fcm_token': fcmToken,
      }),
    );
  }

  @override
  void codeUpdated() {
    setState(() {
      for (int i = 0;
      i < generatedOtp.length && i < otpControllers.length;
      i++) {
        otpControllers[i].text = generatedOtp[i];
      }
    });
  }
}
