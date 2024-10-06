import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jcp/screen/auth/login.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';

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

  Future<void> checkUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe') ?? false;

    if (rememberMe) {
      String userId = prefs.getString('userId') ?? '';
      String phone = prefs.getString('phone') ?? '';
      String password = prefs.getString('password') ?? '';
      String name = prefs.getString('name') ?? '';
      String type = prefs.getString('type') ?? '';
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
      profileProvider.settype(type);
      profileProvider.setcity(city);
      profileProvider.settoken(token);
      profileProvider.setcreatedAt(createdAt);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
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
                Color(0xFFEA3636), // اللون الأول
                Color(0xFFC41D1D), // اللون الثاني
                Color(0xFF7D0A0A), // اللون الثالث
              ],
              stops: [0.1587, 0.3988, 0.9722], // النسب المئوية من CSS
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
