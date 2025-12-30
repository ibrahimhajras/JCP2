import 'package:flutter/material.dart';
import 'package:jcp/screen/auth/ResetPasswordPage.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../style/custom_text.dart';

class OtpPageForgwe extends StatefulWidget {
  final String phone;

  const OtpPageForgwe({
    Key? key,
    required this.phone,
  }) : super(key: key);

  @override
  State<OtpPageForgwe> createState() => _OtpPageForgweState();
}

class _OtpPageForgweState extends State<OtpPageForgwe> with CodeAutoFill {
  List<TextEditingController> otpControllers =
  List.generate(6, (index) => TextEditingController());
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Container(
                height: size.height * 0.15,
                width: size.width,
                color: white,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "OTP " + "التحقق من كود",
                        color: black,
                        size: size.width * 0.055,
                        weight: FontWeight.w700,
                      ),
                      SizedBox(width: size.width * 0.1),
                      Padding(
                        padding: EdgeInsets.only(right: size.width * 0.04),
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
                ),
              ),
              SizedBox(height: size.height * 0.02), // جعل الحجم مرناً
              Padding(
                padding: EdgeInsets.all(size.width * 0.02),
                child: Center(
                  child: Column(
                    children: [
                      CustomText(
                        text: "الرجاء إدخال الرمز الذي أرسلناه للتو إلى",
                        size: size.width * 0.05,
                      ),
                      CustomText(
                        text: "رقم الهاتف ${widget.phone}",
                        size: size.width * 0.05, // تعديل الحجم باستخدام size
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05), // جعل الحجم مرناً
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.015,
                    horizontal: size.width * 0.12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: size.width * 0.1, // جعل الحجم مرناً
                      child: TextFormField(
                        controller: otpControllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: red, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: red, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade400, width: 2),
                          ),
                          hintText: "-",
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: size.height * 0.015),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context).nextFocus();
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
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
                  "تحقق",
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
            ],
          ),
        ),
      ),
    );
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

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(phone: widget.phone),
          ));

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
