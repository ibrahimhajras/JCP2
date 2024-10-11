import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat();

    _animation = CurvedAnimation(parent: _controller!, curve: Curves.ease);

    _timer = Timer(Duration(milliseconds: 2500), () {
      checkUserPreferences();
    });
  }

  void showCustomDialog({
    required BuildContext context,
    required String message,
    required String confirmText,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> checkUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      String userId = prefs.getString('userId') ?? '';
      final response = await http.get(
        Uri.parse('http://jordancarpart.com/Api/TypeUser.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          int userType = data['type'];

          if (userType == 0) {
            await prefs.clear();
            showCustomDialog(
              context: context,
              message:
                  'لقد تم إيقاف حسابك مؤقتًا، يرجى التواصل مع خدمة العملاء.',
              confirmText: 'حسناً',
            );
          } else {
            String phone = prefs.getString('phone') ?? '';
            String password = prefs.getString('password') ?? '';
            String name = prefs.getString('name') ?? '';
            String city = prefs.getString('city') ?? '';
            String token = prefs.getString('token') ?? '';
            String createdAtString = prefs.getString('time') ?? '';
            DateTime createdAt = createdAtString.isNotEmpty
                ? DateTime.parse(createdAtString)
                : DateTime.now();
            final profileProvider =
                Provider.of<ProfileProvider>(context, listen: false);
            profileProvider.setuser_id(userId);
            profileProvider.setphone(phone);
            profileProvider.setpassword(password);
            profileProvider.setname(name);
            profileProvider.settype(userType.toString());
            profileProvider.setcity(city);
            profileProvider.settoken(token);
            profileProvider.setcreatedAt(createdAt);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } else {
      await prefs.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              colors: [
                Color(0xFFEA3636),
                Color(0xFFC41D1D),
                Color(0xFF7D0A0A),
              ],
              stops: [0.1587, 0.3988, 0.9722],
            ),
            image: DecorationImage(
              image: AssetImage("assets/images/card.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 35),
                SvgPicture.asset(
                  'assets/svg/logo-05.svg',
                  width: 75,
                  height: 75,
                  colorFilter: ColorFilter.mode(
                      Color.fromRGBO(246, 246, 246, 1), BlendMode.srcIn),
                ),
                RotationTransition(
                  turns: _animation!,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 5),
                      child: Container(
                        height: 150,
                        width: 150,
                        child: Image.asset(
                          'assets/images/logo-loading.png',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
