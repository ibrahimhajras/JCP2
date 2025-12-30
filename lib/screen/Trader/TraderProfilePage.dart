import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jcp/helper/snack_bar.dart';
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/ProductProvider.dart';
import '../../provider/ProfileTraderProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;

import '../../widget/Inallpage/CustomHeader.dart';

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
  int totalOrders = 0;
  int totalOrdersday = 0;
  int total = 0;

  List<dynamic> cars = [];
  List<dynamic> select = [];
  List<dynamic> select1 = [];

  bool check = false;

  @override
  void initState() {
    select = widget.trader.master;
    select1 = widget.trader.parts_type;
    cars = widget.trader.activity_type;

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        final user = Provider.of<ProfileProvider>(context, listen: false);

        fetchOrders(user.user_id, 1);
        fetchOrders(user.user_id, 2);

        int totalFetched = await fetchTotalParts(user.user_id);
        if (mounted) {
          setState(() {
            total = totalFetched;
          });
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<int> fetchTotalParts(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
      'http://jordancarpart.com/Api/get_total_parts.php?user_id=$userId&token=$token',
    );

    final response = await http.get(url);

    try {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey('total')) {
        return int.tryParse(jsonResponse['total'].toString()) ?? 0;
      } else {
        throw Exception('Key "total" not found in response: ${response.body}');
      }
    } catch (e) {
      throw Exception('Exception parsing total: $e\nBody: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchOrders(String user_id, int flag) async {
    final response = await http.get(Uri.parse(
        'https://jordancarpart.com/Api/showallordersoftrader.php?trader_id=${user_id}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success']) {
        final List<dynamic> orders = responseData['orders'];

        if (flag == 1) {
          setState(() {
            totalOrders = orders.length;
          });
          return orders;
        } else if (flag == 2) {
          final DateTime now = DateTime.now();
          final List<dynamic> filteredOrders = orders.where((order) {
            DateTime orderTime = DateTime.parse(order['time']);
            Duration difference = now.difference(orderTime);
            return difference.inHours < 24;
          }).toList();
          setState(() {
            totalOrdersday = filteredOrders.length;
          });
          return filteredOrders;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Widget _buildHeader(Size size) {
    return Container(
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
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.040,
          left: 10,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: 40),
            CustomText(
              text: "معلومات التاجر",
              color: Colors.white,
              size: 22,
              weight: FontWeight.w900,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:
                  Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
              _buildHeader(size),
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
                            contentPadding: EdgeInsets.only(right: 10)),
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
                            contentPadding: EdgeInsets.only(right: 10)),
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
                          contentPadding: EdgeInsets.only(top: 3.0, left: 12.0),
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
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: grey,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CustomText(
                          text: "إحصائيات التاجر",
                          size: 20,
                          weight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        SizedBox(height: 15),
                        _buildTraderStats(size, user),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraderStats(Size size, ProfileProvider user) {
    final trader = Provider.of<ProfileTraderProvider>(context).trader;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // إضافة البيانات المُعلق عليها
        _buildStatsRow([
          _buildStatItem(":مجموع الطلبات", totalOrders.toString()),
          _buildStatItem(":عدد المخالفات", "0"),
        ]),
        _buildStatsRow([
          _buildStatItem(":عدد الطلبات اليومية", totalOrdersday.toString()),
          Consumer<ProductProvider>(builder: (context, productProvider, child) {
            return _buildStatItem(":مجموع القطع", "${total}");
          })
        ]),

        // البيانات الموجودة أصلاً
        _buildStatsRow([
          _buildStatItem(
              ":فوري داخل المحافظة",
              trader!.urgentPaymentInside.isEmpty
                  ? "0"
                  : trader.urgentPaymentInside),
          _buildStatItem(
              ":عادي داخل المحافظة",
              trader.normalPaymentInside.isEmpty
                  ? "0"
                  : trader.normalPaymentInside),
        ]),
        _buildStatsRow([
          _buildStatItem(
              ":فوري خارج المحافظة",
              trader.urgentPaymentOutside.isEmpty
                  ? "0"
                  : trader.urgentPaymentOutside),
          _buildStatItem(
              ":عادي خارج المحافظة",
              trader.normalPaymentOutside.isEmpty
                  ? "0"
                  : trader.normalPaymentOutside),
        ]),
      ],
    );
  }

  Widget _buildStatsRow(List<Widget> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      ),
    );
  }

  Widget _buildSingleStatItem(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 13,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(width: 3),
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }
}
// Padding(
//   padding: EdgeInsets.symmetric(
//     horizontal: 10,
//   ),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Padding(
//         padding: const EdgeInsets.only(left: 6.5),
//         child: CustomText(
//           text: "نوع القطعة",
//           size: 18,
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(right: 6.5),
//         child: CustomText(
//           text: "الاختصاص",
//           size: 18,
//         ),
//       ),
//     ],
//   ),
// ),
// Padding(
//   padding: EdgeInsets.symmetric(
//     horizontal: 10,
//   ),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select1.contains("ميكانيك")) {
//               select1.remove("ميكانيك");
//             } else {
//               select1.add("ميكانيك");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select1.contains("ميكانيك") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "ميكانيك",
//               size: 10,
//               color: select1.contains("ميكانيك") ? red : black,
//             ),
//           ),
//         ),
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select1.contains("بودي")) {
//               select1.remove("بودي");
//             } else {
//               select1.add("بودي");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select1.contains("بودي") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "بودي",
//               size: 10,
//               color: select1.contains("بودي") ? red : black,
//             ),
//           ),
//         ),
//       ),
//       Container(
//         height: 50,
//         width: 3,
//         color: grey,
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select.contains("بلد المنشأ")) {
//               select.remove("بلد المنشأ");
//             } else {
//               select.add("بلد المنشأ");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select.contains("بلد المنشأ") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "بلد المنشأ",
//               size: 10,
//               color: select.contains("بلد المنشأ") ? red : black,
//             ),
//           ),
//         ),
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select.contains("شركة")) {
//               select.remove("شركة");
//             } else {
//               select.add("شركة");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select.contains("شركة") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "شركة",
//               size: 10,
//               color: select.contains("شركة") ? red : black,
//             ),
//           ),
//         ),
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select.contains("تجاري")) {
//               select.remove("تجاري");
//             } else {
//               select.add("تجاري");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select.contains("تجاري") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "تجاري",
//               size: 10,
//               color: select.contains("تجاري") ? red : black,
//             ),
//           ),
//         ),
//       ),
//       GestureDetector(
//         onTap: () {
//           setState(() {
//             if (select.contains("مستعمل")) {
//               select.remove("مستعمل");
//             } else {
//               select.add("مستعمل");
//             }
//           });
//         },
//         child: Container(
//           height: 50,
//           width: 50,
//           decoration: BoxDecoration(
//             color: grey,
//             borderRadius: BorderRadius.circular(50),
//             border: Border.all(
//               width: 1,
//               color: select.contains("مستعمل") ? red : grey,
//             ),
//           ),
//           child: Center(
//             child: CustomText(
//               text: "مستعمل",
//               size: 10,
//               color: select.contains("مستعمل") ? red : black,
//             ),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 10),
//   child: Divider(),
// ),
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 10),
//   child: Row(
//     children: [
//       Expanded(
//         flex: 3,
//         child: Container(
//           height: 150,
//           child: GridView.builder(
//             gridDelegate:
//             SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               mainAxisSpacing: 5,
//               crossAxisSpacing: 5,
//               mainAxisExtent: 40,
//             ),
//             itemCount: cars.length,
//             itemBuilder: (context, index) {
//               return Container(
//                 decoration: BoxDecoration(
//                   color: grey.withOpacity(0.5),
//                   border: Border.all(
//                     width: 1,
//                     color: words,
//                   ),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.bottomLeft,
//                   children: [
//                     Positioned(
//                       top: 1,
//                       right: 1,
//                       child: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             cars.removeAt(index);
//                           });
//                         },
//                         child: Icon(
//                           Icons.close,
//                           color: red,
//                           size: 15,
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(10),
//                       child: CustomText(
//                         text: cars[index],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       Expanded(
//         flex: 1,
//         child: Container(
//           width: 15,
//         ),
//       ),
//       Expanded(
//         flex: 1,
//         child: Padding(
//           padding: const EdgeInsets.only(right: 6.5),
//           child: Container(
//             height: 150,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 CustomText(
//                   text: "نوع النشاط",
//                   size: 18,
//                 ),
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   shadowColor: Colors.black,
//                   color: grey,
//                   child: TextFormField(
//                     controller: item,
//                     textAlign: TextAlign.center,
//                     decoration: InputDecoration(
//                       border: InputBorder.none,
//                       hintText: "",
//                     ),
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontWeight: FontWeight.w100,
//                       fontSize: 25,
//                       fontFamily: "Tajawal",
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       cars.add(item.text);
//                       item.text = "";
//                     });
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: red,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: Padding(
//                         padding: EdgeInsets.only(
//                           top: 5,
//                           left: 5,
//                           right: 5,
//                           bottom: 3,
//                         ),
//                         child: CustomText(
//                           text: "اضافة",
//                           color: white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// SizedBox(
//   height: 10,
// ),
// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 10.0),
//   child: Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       CustomText(
//         text: "اضافة ملاحظات",
//         size: 18,
//       ),
//       Card(
//         shadowColor: Colors.black,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(5),
//         ),
//         color: grey,
//         child: TextFormField(
//           maxLines: 2,
//           controller: address,
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(5),
//               borderSide: BorderSide(
//                 color: black,
//                 width: 1,
//               ),
//             ),
//           ),
//           textAlign: TextAlign.end,
//           style: TextStyle(
//             color: black,
//             fontWeight: FontWeight.w500,
//             fontSize: 16,
//             fontFamily: "Tajawal",
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
// check
//     ? GestureDetector(
//   onTap: () async {
//     if (select1.isEmpty && select.isEmpty && cars.isEmpty) {
//       showSnack(context, "لا يوجد تعديل");
//       return;
//     }
//     String phoneNumber = widget.trader.phone;
//     String modifications1 = select1.toString();
//     String modifications2 = select.toString();
//     String modifications3 = cars.toString();
//     if (widget.trader.master.contains("\u062a\u062c\u0627\u0631\u064a2") == true &&
//         !select.contains("\u062a\u062c\u0627\u0631\u064a2")) {
//       select.add("\u062a\u062c\u0627\u0631\u064a2");
//       modifications2 = select.toString();
//     }
//
//
//
//     String apiUrl =
//         'https://jordancarpart.com/Api/updatemaketrader.php'
//         '?phone=$phoneNumber'
//         '&parts_type=${modifications1}'
//         '&master=${modifications2}'
//         '&activity_type=${modifications3}';
//
//     final response = await http.get(
//       Uri.parse(apiUrl),
//       headers: {
//         'Accept': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       showSnack(context, "تم حفظ التعديلات بنجاح");
//       setState(() {
//         check = false;
//       });
//     } else {
//       showSnack(context, "فشل في حفظ التعديلات");
//     }
//   },
//   child: Padding(
//     padding:
//     EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//     child: Container(
//       width: size.width * 0.93,
//       height: 50,
//       decoration: BoxDecoration(
//         color: red,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Center(
//         child: CustomText(
//           text: "حفظ",
//           color: white,
//         ),
//       ),
//     ),
//   ),
// )
//     : GestureDetector(
//   onTap: () {
//     setState(() {
//       check = true;
//     });
//   },
//   child: CustomText(
//     text: "تعديل المعلومات",
//     color: red,
//   ),
// ),
// SizedBox(
//   height: 25,
// ),
