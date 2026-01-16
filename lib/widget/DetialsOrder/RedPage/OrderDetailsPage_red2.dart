import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import '../../../screen/home/homeuser.dart';
import '../../../style/colors.dart';

class OrderDetailsPage2 extends StatefulWidget {
  final List<dynamic> items;
  final String order_id;

  const OrderDetailsPage2(
      {super.key, required this.items, required this.order_id});

  @override
  _OrderDetailsPage2State createState() => _OrderDetailsPage2State();
}

class _OrderDetailsPage2State extends State<OrderDetailsPage2> {
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          SizedBox(height: 15),
          SingleChildScrollView(
            child: Container(
              height: size.height * 0.77,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(height: 15),
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
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: CustomText(
                        text: "تفاصيل القطعة",
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
                                String? imageUrl;
                                if (e["itemimg64"] != null &&
                                    e["itemimg64"].isNotEmpty) {
                                  imageUrl = e["itemimg64"];
                                  
                                  
                                }
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ListTile(
                                        title: CustomText(
                                          text: "اسم / رقم القطعة",
                                          size: 18,
                                          color: black,
                                        ),
                                        subtitle: CustomText(
                                          text: e["itemname"] ?? '',
                                          size: 14,
                                          color: red,
                                        ),
                                      ),
                                      ListTile(
                                        title: CustomText(
                                          text: " (اختياري) رابط القطعة",
                                          size: 18,
                                          color: black,
                                        ),
                                        subtitle: CustomText(
                                          text: e["itemlink"] ??
                                              'لا يوجد رابط للقطعة',
                                          size: 14,
                                          color: red,
                                        ),
                                      ),
                                      ListTile(
                                        title: CustomText(
                                          text: "صورة القطعة",
                                          size: 18,
                                          color: black,
                                        ),
                                        subtitle: imageUrl != null
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 2,
                                                      blurRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Image.network(
                                                  "$imageUrl",
                                                  height: 250,
                                                  width: 350,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : CustomText(
                                                text: "لا يوجد صورة",
                                                size: 14,
                                                color: Colors.red,
                                              ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Expanded(
      flex: 1,
      child: Container(
        height: size.height * 0.20,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary1, primary2, primary3]),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                text: "تفاصيل الطلب",
                color: Colors.white,
                size: size.width * 0.06,
              ),
              SizedBox(width: size.width * 0.2),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(page: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.arrow_forward_ios_rounded, color: white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
