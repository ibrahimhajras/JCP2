import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';

import '../../../style/colors.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<dynamic> items;
  final String order_id;

  const OrderDetailsPage(
      {super.key, required this.items, required this.order_id});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height * 0.20,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [
                    primary1,
                    primary2,
                    primary3,
                  ],
                ),
                image: DecorationImage(
                  image: AssetImage("assets/images/card.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomText(
                      text: "تفاصيل الطلب",
                      color: Colors.white,
                      size: 22,
                    ),
                    SizedBox(width: size.width * 0.2),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              height: size.height * 0.77,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.02, // 2% من ارتفاع الشاشة
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "قيد المراجعة ",
                          size: 20,
                          color: Colors.yellow[600],
                        ),
                        CustomText(
                          text: "${widget.order_id} طلبك رقم ",
                          size: 20,
                          color: Colors.yellow[600],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      child: CustomText(
                        text: "جاري العمل على تقديم أفضل سعر في اقرب وقت ...",
                        size: 18,
                        weight: FontWeight.w100,
                        textAlign: TextAlign.start,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: CustomText(
                        text: "اسم القطعة",
                        size: 20,
                        weight: FontWeight.w900,
                      ),
                    ),
                    Container(
                      height: size.height * 0.5,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: SingleChildScrollView(
                          child: Column(
                            children: widget.items.map(
                              (e) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: grey,
                                    ),
                                    child: TextFormField(
                                      enabled: false,
                                      textAlign: TextAlign.end,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: words,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: grey,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        fillColor:
                                            Color.fromRGBO(246, 246, 246, 1),
                                        hintText: e["name"],
                                        hintStyle: TextStyle(
                                          color: black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Tajawal",
                                        ),
                                      ),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Tajawal",
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
