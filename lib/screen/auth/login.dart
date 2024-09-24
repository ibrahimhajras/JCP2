import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../model/UserModel.dart';
import '../../style/appbar.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/dialogs.dart';
import '../home/homeuser.dart';
import '../auth/forgotpassword.dart';
import '../auth/register.dart';
import '../../provider/ProfileProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String image = "assets/images/eye-hide.png";
  bool ob = true;
  bool rememberMe = false;
  bool isLoading = false;
  String phoneHint = "79xxxxxxxxx", passHint = "**********";

  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserPreferences();
  }

  Future<void> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      phone.text = prefs.getString('phone') ?? '';
      password.text = prefs.getString('password') ?? '';
    });
  }

  Future<void> saveUserPreferences(String userId, String name, String password,
      String type, String city, DateTime time) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('rememberMe', rememberMe);
    await prefs.setString('phone', phone.text);
    await prefs.setString('password', password);
    await prefs.setString('userId', userId);
    await prefs.setString('name', name);
    await prefs.setString('type', type);
    await prefs.setString('city', city);
    await prefs.setString('time', time.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(title: "تسجيل الدخول", color: white),
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              width: size.width,
              child: Column(
                children: [
                  _buildLogo(size),
                  const SizedBox(height: 15),
                  _buildPhoneInput(),
                  _buildPasswordInput(),
                  _buildRememberMeCheckbox(),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 20),
                  _buildLoginButton(size),
                  const SizedBox(height: 10),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLogo(Size size) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20, bottom: 5),
      child: Image.asset(
        'assets/images/logo-5.png',
        width: size.height * 0.21,
        height: size.height * 0.21,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                text: "رقم الهاتف",
                color: Color.fromRGBO(0, 0, 0, 1),
                size: 18,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
              ),
              flagsButtonMargin: const EdgeInsets.only(right: 5),
              disableAutoFillHints: true,
              textAlignVertical: TextAlignVertical.center,
              initialCountryCode: 'JO',
              controller: phone,
              style: const TextStyle(
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
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                text: "كلمة المرور",
                color: Color.fromRGBO(0, 0, 0, 1),
                size: 18,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: grey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 50,
                child: TextFormField(
                  controller: password,
                  onTap: () {
                    setState(() {
                      passHint = "";
                    });
                  },
                  onTapOutside: (event) {
                    setState(() {
                      passHint = "**********";
                    });
                  },
                  onChanged: (value) {
                    if (value.isEmpty) {
                      setState(() {
                        passHint = "**********";
                      });
                    }
                  },
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: passHint,
                    icon: GestureDetector(
                      onTap: () {
                        setState(() {
                          ob = !ob;
                          image = ob
                              ? "assets/images/eye-hide.png"
                              : "assets/images/eye-show.png";
                        });
                      },
                      child: Image.asset(
                        image,
                        width: 32,
                        height: 32,
                      ),
                    ),
                  ),
                  obscureText: ob,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 28, right: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Theme(
            data: ThemeData(
              unselectedWidgetColor: Colors.white,
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Color.fromRGBO(195, 29, 29, 1);
                  }
                  return Colors.white;
                }),
              ),
            ),
            child: Checkbox(
              value: rememberMe,
              onChanged: (bool? value) {
                setState(() {
                  rememberMe = value ?? false;
                });
              },
            ),
          ),
          Text(
            'تذكرني',
            style: TextStyle(
              color: rememberMe ? Color.fromRGBO(195, 29, 29, 1) : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "Tajawal",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "هل نسيت كلمة المرور ؟",
              style: const TextStyle(
                color: Color.fromRGBO(195, 29, 29, 1),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontFamily: "Tajawal",
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPassword(),
                    ),
                  );
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(Size size) {
    return MaterialButton(
      onPressed: () {
        loginUser(context, phone.text, password.text);
      },
      height: 50,
      minWidth: size.width * 0.9,
      color: Color.fromRGBO(195, 29, 29, 1),
      child: const Text(
        "تسجيل الدخول",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontFamily: "Tajawal",
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
          child: const Text(
            "إنشاء الحساب",
            style: TextStyle(
              color: Color.fromRGBO(195, 29, 29, 1),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "Tajawal",
            ),
          ),
        ),
        Text(
          'ليس لديك حساب ؟',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: "Tajawal",
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(child: RotatingImagePage()),
      ],
    );
  }

  Future<void> loginUser(
      BuildContext context, String phone, String password) async {
    if (phone.isEmpty || password.isEmpty) {
      showConfirmationDialog(
        context: context,
        message: 'يرجى إدخال رقم الهاتف وكلمة المرور.',
        confirmText: 'حسناً',
        onConfirm: () {
          // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
        },
        cancelText: '', // لا حاجة لزر إلغاء
      );
      return;
    }

    final url = 'https://jordancarpart.com/Api/login.php?phone=' +
        phone +
        '&password=' +
        password;
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      print(json.encode({'phone': phone, 'password': password}).toString());
      print(response.body.toString());

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is List<dynamic>) {
          if (responseData.isNotEmpty &&
              responseData[0] is Map<String, dynamic>) {
            UserModel user = UserModel.fromJson(responseData[0]);

            profileProvider.setuser_id(user.userId);
            profileProvider.setphone(user.phone);
            profileProvider.setname(user.name);
            profileProvider.setpassword(user.password);
            profileProvider.settype(user.type);
            profileProvider.setcity(user.city);
            profileProvider.setcreatedAt(user.createdAt);

            final userId = profileProvider.getuser_id();
            if (userId.isNotEmpty && int.tryParse(userId) != null) {
              await saveUserPreferences(
                  profileProvider.getuser_id(),
                  profileProvider.getname(),
                  profileProvider.getpassword(),
                  profileProvider.gettype(),
                  profileProvider.getcity(),
                  profileProvider.getcreatedAt());
              print(profileProvider.getuser_id());
              print(profileProvider.getcreatedAt());

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            } else {
              showConfirmationDialog(
                context: context,
                message: 'رقم الهاتف أو كلمة المرور غير صحيحة.',
                confirmText: 'حسناً',
                onConfirm: () {
                  // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
                },
                cancelText: '', // لا حاجة لزر إلغاء
              );
            }
          } else {
            showConfirmationDialog(
              context: context,
              message: 'حدث خطأ في استلام البيانات. يرجى المحاولة مرة أخرى.',
              confirmText: 'حسناً',
              onConfirm: () {
                // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
              },
              cancelText: '', // لا حاجة لزر إلغاء
            );
          }
        } else {
          showConfirmationDialog(
            context: context,
            message: 'رقم الهاتف أو كلمة المرور غير صحيحة.',
            confirmText: 'حسناً',
            onConfirm: () {
              // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
            },
            cancelText: '', // لا حاجة لزر إلغاء
          );
        }
      } else {
        showConfirmationDialog(
          context: context,
          message: 'رقم الهاتف أو كلمة المرور غير صحيحة.',
          confirmText: 'حسناً',
          onConfirm: () {
            // يمكن تركه فارغًا لأنه مجرد رسالة معلوماتية
          },
          cancelText: '', // لا حاجة لزر إلغاء
        );
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ أثناء الاتصال بالخادم: $e',
        confirmText: 'حسناً',
        onConfirm: () {},
        cancelText: '',
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
