import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/helper/snack_bar.dart';
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Drawer/ProfilePage.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;

class TraderProfilePage extends StatefulWidget {
  final JoinTraderModel trader;
  const TraderProfilePage({super.key, required this.trader});

  @override
  State<TraderProfilePage> createState() => _TraderProfilePageState();
}

class _TraderProfilePageState extends State<TraderProfilePage> {
  TextEditingController phoneCon = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController item = TextEditingController();
  String phoneHint = "79xxxxxxxxx";

  List<dynamic> cars = [];
  List<dynamic> select = [];
  List<dynamic> select1 = [];

  bool check = false;

  @override
  void initState() {
    select = widget.trader.master;

    select1 = widget.trader.parts_type;

    cars = widget.trader.activity_type;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: white,
      body: Container(
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [
                      Color(0xFFB02D2D),
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: size.height * 0.05,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: white,
                                      weight: 10,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: CustomText(
                        text: "معلومات التاجر",
                        color: Color.fromRGBO(255, 255, 255, 1),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(
                        text: "إسم صاحب المحل",
                        size: 18,
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black,
                      color: grey,
                      child: TextFormField(
                        enabled: false,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              widget.trader.fName + " " + widget.trader.lName,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(
                        text: "إسم المحل",
                        size: 18,
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black,
                      color: grey,
                      child: TextFormField(
                        enabled: false,
                        textAlign: TextAlign.end,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: widget.trader.store,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(
                        text: "رقم الهاتف",
                        size: 18,
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: grey,
                      child: IntlPhoneField(
                        enabled: false,
                        disableLengthCheck: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          hintText:
                              widget.trader.phone.replaceFirst("+962", ""),
                          border: InputBorder.none,
                          labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(153, 153, 160, 1),
                            fontSize: 18,
                            fontFamily: "Tajawal",
                          ),
                        ),
                        flagsButtonMargin: EdgeInsets.only(
                          right: 5,
                        ),
                        disableAutoFillHints: true,
                        textAlignVertical: TextAlignVertical.center,
                        initialCountryCode: 'JO',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(
                        text: "العنوان الكامل",
                        size: 18,
                      ),
                    ),
                    Card(
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: grey,
                      child: TextFormField(
                        enabled: false,
                        maxLines: 2,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: black,
                              width: 1,
                            ),
                          ),
                          hintText: widget.trader.full_address,
                        ),
                        textAlign: TextAlign.end,
                        textAlignVertical: TextAlignVertical.top,
                        style: TextStyle(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6.5),
                      child: CustomText(
                        text: "نوع القطعة",
                        size: 18,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(
                        text: "الاختصاص",
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select1.contains("ميكانيك")) {
                            select1.remove("ميكانيك");
                          } else {
                            select1.add("ميكانيك");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select1.contains("ميكانيك") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "ميكانيك",
                            size: 10,
                            color: select1.contains("ميكانيك") ? red : black,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select1.contains("بودي")) {
                            select1.remove("بودي");
                          } else {
                            select1.add("بودي");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select1.contains("بودي") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "بودي",
                            size: 10,
                            color: select1.contains("بودي") ? red : black,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 3,
                      color: grey,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select.contains("بلد المنشأ")) {
                            select.remove("بلد المنشأ");
                          } else {
                            select.add("بلد المنشأ");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select.contains("بلد المنشأ") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "بلد المنشأ",
                            size: 10,
                            color: select.contains("بلد المنشأ") ? red : black,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select.contains("شركة")) {
                            select.remove("شركة");
                          } else {
                            select.add("شركة");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select.contains("شركة") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "شركة",
                            size: 10,
                            color: select.contains("شركة") ? red : black,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select.contains("تجاري")) {
                            select.remove("تجاري");
                          } else {
                            select.add("تجاري");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select.contains("تجاري") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "تجاري",
                            size: 10,
                            color: select.contains("تجاري") ? red : black,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (select.contains("مستعمل")) {
                            select.remove("مستعمل");
                          } else {
                            select.add("مستعمل");
                          }
                        });
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: grey,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            width: 1,
                            color: select.contains("مستعمل") ? red : grey,
                          ),
                        ),
                        child: Center(
                          child: CustomText(
                            text: "مستعمل",
                            size: 10,
                            color: select.contains("مستعمل") ? red : black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Divider(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 150,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            mainAxisExtent: 40,
                          ),
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            return Container(
                              decoration: BoxDecoration(
                                color: grey.withOpacity(0.5),
                                border: Border.all(
                                  width: 1,
                                  color: words,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Stack(
                                alignment: Alignment.bottomLeft,
                                children: [
                                  Positioned(
                                    top: 1,
                                    right: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          cars.removeAt(index);
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: red,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: CustomText(
                                      text: cars[index],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 15,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6.5),
                        child: Container(
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              CustomText(
                                text: "نوع النشاط",
                                size: 18,
                              ),
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                shadowColor: Colors.black,
                                color: grey,
                                child: TextFormField(
                                  controller: item,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "",
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w100,
                                    fontSize: 16,
                                    fontFamily: "Tajawal",
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    cars.add(item.text);
                                    item.text = "";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        left: 5,
                                        right: 5,
                                        bottom: 3,
                                      ),
                                      child: CustomText(
                                        text: "اضافة",
                                        color: white,
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
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                      text: "اضافة ملاحظات",
                      size: 18,
                    ),
                    Card(
                      shadowColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: grey,
                      child: TextFormField(
                        maxLines: 2,
                        controller: address,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: black,
                              width: 1,
                            ),
                          ),
                        ),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: black,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: "Tajawal",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              check
                  ? GestureDetector(
                      onTap: () async {
                        if (select1.isEmpty && select.isEmpty && cars.isEmpty) {
                          showSnack(context, "لا يوجد تعديل");
                          return;
                        }
                        String phoneNumber = widget.trader.phone;
                        List modifications1 = select1;
                        List modifications2 = select;
                        List modifications3 = cars;

                        String apiUrl =
                            'https://jordancarpart.com/Api/updateuser.php'
                            '?phone=$phoneNumber'
                            '&modifications1=${modifications1.join(",")}'
                            '&modifications2=${modifications2.join(",")}'
                            '&modifications3=${modifications3.join(",")}';

                        final response = await http.get(
                          Uri.parse(apiUrl),
                          headers: {
                            'Accept': 'application/json',
                          },
                        );
                        print(response.body);
                        if (response.statusCode == 200) {
                          showSnack(context, "تم حفظ التعديلات بنجاح");
                          setState(() {
                            check = false;
                          });
                        } else {
                          showSnack(context, "فشل في حفظ التعديلات");
                        }
                      },
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Container(
                          width: size.width * 0.93,
                          height: 50,
                          decoration: BoxDecoration(
                            color: red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: CustomText(
                              text: "حفظ",
                              color: white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          check = true;
                        });
                      },
                      child: CustomText(
                        text: "تعديل المعلومات",
                        color: red,
                      ),
                    ),
              SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
