import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';

class ResetPasswordPage extends StatefulWidget {
  final String phone;

  const ResetPasswordPage({Key? key, required this.phone}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String passwordHint = "*****************";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.03), // Proportional padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.05), // Proportional size
              CustomText(
                text: "إعادة تعيين كلمة المرور",
                size: size.width * 0.06, // Proportional size
                weight: FontWeight.bold,
              ),
              SizedBox(height: size.height * 0.03), // Proportional size
              buildTextField(
                passwordController,
                "كلمة المرور الجديدة",
                passwordHint,
                size,
              ),
              SizedBox(height: size.height * 0.05), // Proportional size
              MaterialButton(
                height: size.height * 0.07,
                // Proportional size
                minWidth: size.width * 0.9,
                // Proportional size
                color: button,
                child: isLoading
                    ? RotatingImagePage()
                    : Text(
                  "إعادة تعيين",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.04, // Proportional size
                    fontWeight: FontWeight.bold,
                    fontFamily: "Tajawal",
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.015,
                    horizontal: size.width * 0.1),
                // Proportional padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      size.width * 0.025), // Proportional size
                ),
                onPressed: () {
                  _resetPassword();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String labelText,
      String hintText, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(right: size.width * 0.02),
          // Proportional padding
          child: CustomText(
            text: labelText,
            size: size.width * 0.05, // Proportional size
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(size.width * 0.025), // Proportional size
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
                hintText = "";
              });
            },
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  hintText = labelText;
                });
              }
            },
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w100,
              fontSize: size.width * 0.04,
              fontFamily: "Tajawal",
            ),
            obscureText: true,
          ),
        ),
      ],
    );
  }

  Future<void> _resetPassword() async {
    if (passwordController.text.isEmpty) {
      showConfirmationDialog(
        context: context,
        message: 'يرجى إدخال كلمة المرور.',
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
      return;
    }
    if (passwordController.text.length < 6) {
      showConfirmationDialog(
        context: context,
        message: 'كلمة المرور يجب أن تكون 6 أحرف أو أكثر',
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
      return;
    }
    setState(() {
      isLoading = true;
    });

    Uri apiUrl = Uri.parse(
      'https://jordancarpart.com/Api/auth/changepassword.php?phone=${widget.phone}&password=${passwordController.text}',
    );
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {



        showDialog(
          context: context,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Text(
                    'نجاح',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  SizedBox(height: 20),
                  // المحتوى
                  Text(
                    'تم إعادة تعيين كلمة المرور بنجاح.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // زر التأكيد
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // إغلاق الـ Dialog
                    },
                    color: Color.fromRGBO(195, 29, 29, 1),
                    // اللون الأحمر المستخدم في التصميم
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'حسناً',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  ),
                ],
              ),
            ),
          ),
        ).then((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false,
          );
        });
      } else {
        showConfirmationDialog(
          context: context,
          message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
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
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
    }
  }
}
