import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/appbar.dart';
import '../../style/colors.dart';
import '../../widget/RotatingImagePage.dart';
import '../../utils/otp_rate_limiter.dart';
import 'OtpPageForget.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:jcp/widget/KeyboardActionsUtil.dart';

class ForgotPassword extends StatefulWidget {
  static String? verificationCode;

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController controller = TextEditingController();
  final FocusNode phoneFocus = FocusNode();
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
      body: KeyboardActions(
        config: KeyboardActionsUtil.buildConfig(context, [phoneFocus]),
        tapOutsideBehavior: TapOutsideBehavior.opaqueDismiss,
        child: Stack(
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
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: grey,
                        child: IntlPhoneField(
                          focusNode: phoneFocus,
                          onTap: () {
                            setState(() {
                              phoneHint = "";
                            });
                          },
                          disableLengthCheck: true,
                          showDropdownIcon: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            hintText: phoneHint,
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
                            contentPadding: EdgeInsets.only(top: 3.0, left: 12.0),
                          ),
                          flagsButtonMargin: const EdgeInsets.only(right: 5),
                          disableAutoFillHints: true,
                          textAlignVertical: TextAlignVertical.center,
                          initialCountryCode: 'JO',
                          controller: controller,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: "Tajawal",
                          ),
                          onChanged: (phone) {
                            if (phone.number.isEmpty) {
                              setState(() {
                                phoneHint = "79xxxxxxxxx";
                              });
                            }
                          },
                          onSubmitted: (value) {
                            FocusScope.of(context).unfocus();
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
                          sendOtpWithPhoneCheck(controller.text,context);
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
  String? formatPhone(BuildContext context, String phone) {
    phone = phone.trim();

    if (phone.length == 9 && phone.startsWith('7')) {
      return phone;
    } else if (phone.length == 9 && !phone.startsWith('7')) {
      showConfirmationDialog(
        context: context,
        message: 'الرقم يجب أن يبدأ بالرقم 7',
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
      return null;
    } else if (phone.length == 10 && phone.startsWith('0')) {
      return phone.substring(1);
    } else {
      showConfirmationDialog(
        context: context,
        message: 'رقم الهاتف غير صالح',
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
      return null;
    }
  }


  Future<void> sendOtpWithPhoneCheck(String phone, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? formattedPhone = formatPhone(context,phone);
    if (formattedPhone == null) return; // أضف هذا السطر لمنع المتابعة في حال الرقم غير صحيح

    setState(() {
      isLoading = true;
    });

    // Check OTP rate limit first
    final limitCheck = await OtpRateLimiter.checkOtpLimit(formattedPhone);

    if (limitCheck['success'] == true && limitCheck['allowed'] == false) {
      setState(() {
        isLoading = false;
      });

      String message = 'لقد تجاوزت الحد المسموح من محاولات إرسال رمز التحقق';
      if (limitCheck['remaining_seconds'] != null) {
        message += '\n\nيمكنك المحاولة مرة أخرى بعد\n${OtpRateLimiter.formatRemainingTime(limitCheck['remaining_seconds'])}';
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

    final checkApiUrl = Uri.parse('https://jordancarpart.com/Api/auth/CheckPhone.php?phone=$formattedPhone');

    try {
      final checkResponse = await http.get(checkApiUrl);

      if (checkResponse.statusCode == 200) {
        final checkData = json.decode(checkResponse.body);

        if (checkData['success'] == true && checkData['exists'] == true) {
          // Log OTP attempt
          await OtpRateLimiter.logOtpAttempt(formattedPhone);
          String OTP = generateOTP();
          await prefs.setString('otp', OTP);

          // Print OTP in terminal for development
          print('🔐 OTP Generated (Forgot Password): $OTP');

          String msg = "يرجى إدخال الرمز التالي لإعادة تعيين كلمة المرور: $OTP";

          final sendApiUrl = Uri.parse('https://jordancarpart.com/Api/auth/send_sms.php');

          final sendResponse = await http.post(sendApiUrl, body: {'phone': formattedPhone, 'message': msg});

          setState(() {
            isLoading = false;
          });

          if (sendResponse.statusCode == 200) {
            final sendData = json.decode(sendResponse.body);

            if (sendData["status"] == "success") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpPageForgwe(phone: formattedPhone !),
                ),
              );
            } else {
              showConfirmationDialog(
                context: context,
                message: 'حدث خطأ أثناء إرسال OTP.',
                confirmText: 'حسناً',
                onConfirm: () {},
              );
            }
          } else {
            showConfirmationDialog(
              context: context,
              message: 'حدث خطأ أثناء إرسال OTP.',
              confirmText: 'حسناً',
              onConfirm: () {},
            );
          }
        } else if (checkData['success'] == true && checkData['exists'] == false) {
          setState(() {
            isLoading = false;
          });
          showConfirmationDialog(
            context: context,
            message: 'رقم الهاتف غير مسجل لدينا. يرجى التحقق من الرقم والمحاولة مرة أخرى',
            confirmText: 'حسناً',
            onConfirm: () {},
          );
          return;
        } else {
          setState(() {
            isLoading = false;
          });
          showConfirmationDialog(
            context: context,
            message: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
            confirmText: 'حسناً',
            onConfirm: () {},
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showConfirmationDialog(
          context: context,
          message: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
          confirmText: 'حسناً',
          onConfirm: () {},
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showConfirmationDialog(
        context: context,
        message: 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
    }
  }
}
