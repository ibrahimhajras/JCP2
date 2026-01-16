import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/ProfileProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../Drawer/Notification.dart';
import 'Outofstock.dart';

class Stoptrader extends StatefulWidget {
  const Stoptrader({super.key});

  @override
  State<Stoptrader> createState() => _StoptraderState();
}

class _StoptraderState extends State<Stoptrader> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ProfileProvider>(context);
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      height: size.height * 0.8,
      child: Column(
        children: [
          CustomHeader(
            title: "${user.name ?? ""}",
            notificationIcon: SizedBox.shrink(),
            menuIcon: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProductOrderCard(size, user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBanner(Size size, ProfileProvider user) {
    return CustomHeader(
      title: user.name,
      notificationIcon: _buildTopBar(),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildMenuIcon(BuildContext context, Size size) {
    return MenuIcon(
      size: size,
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }

  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
          child: hasNewNotification
              ? _buildIconBox("assets/images/notification-on.png")
              : _buildIconBox("assets/images/notification-off.png"),
        ),
      ],
    );
  }

  Widget _buildIconBox(dynamic icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Color.fromRGBO(246, 246, 246, 0.26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: icon is String
            ? Image.asset(icon)
            : Icon(icon, color: Color.fromRGBO(246, 246, 246, 1)),
      ),
    );
  }

  Widget _buildProductOrderCard(Size size, ProfileProvider user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: size.height * 0.25,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage("assets/images/stop.jpg"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildUserInfo(user, size),
              SizedBox(height: size.height * 0.015),
              CustomText(
                text: "حالة العضوية : متوقفة",
                color: Colors.white,
                textAlign: TextAlign.center,
                size: 18,
              ),
              CustomText(
                text: "سبب ايقاف العضوية ",
                color: Colors.white,
                textAlign: TextAlign.center,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(ProfileProvider user, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomText(
          text: user.name,
          color: white,
          weight: FontWeight.bold,
          size: size.width * 0.05,
        ),
        SizedBox(width: size.width * 0.03),
        Image.asset(
          "assets/images/09.png",
          height: size.height * 0.07,
          fit: BoxFit.fill,
        ),
      ],
    );
  }
}
