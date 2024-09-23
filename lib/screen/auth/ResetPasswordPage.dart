import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/widget/Inallpage/dialogs.dart';
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
                    ? CircularProgressIndicator(color: Colors.white)
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
      AppDialogs.showErrorDialog(context, 'يرجى إدخال كلمة المرور.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    Uri apiUrl = Uri.parse('https://jordancarpart.com/Api/changepassword.php');
    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': widget.phone,
          'password': passwordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text('نجاح'),
            content: Text('تم إعادة تعيين كلمة المرور بنجاح.'),
          ),
        ).then((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        });
      } else {
        AppDialogs.showErrorDialog(
            context, 'حدث خطأ أثناء إعادة تعيين كلمة المرور.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      AppDialogs.showErrorDialog(context, 'حدث خطأ أثناء الاتصال بالخادم: $e');
    }
  }
}
