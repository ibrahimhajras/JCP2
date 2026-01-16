import 'package:flutter/material.dart';
import '../../../style/custom_text.dart';

class CustomHeader extends StatelessWidget {
  final Size size;
  final String title;
  final String? subtitle; // إضافة حقل لاختياري لعرض اسم المستخدم
  final Widget notificationIcon;
  final Widget menuIcon;

  const CustomHeader({
    Key? key,
    required this.size,
    required this.title,
    this.subtitle, // الحقل الجديد لعرض الاسم
    required this.notificationIcon,
    required this.menuIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isnormal=true;
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;

    if (textScaleFactor > 1) {
      isnormal=false;
    } else {
      isnormal=true;

    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
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
            MediaQuery.of(context).size.height<MediaQuery.of(context).size.width*2?
            Padding(
              padding: EdgeInsets.only(
                top: size.height *(isnormal? 0.04:0.03),
                left: size.width * (isnormal? 0.02:0.01),
                right: size.width  *(isnormal? 0.02:0.01),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  notificationIcon,
                  menuIcon,
                ],
              ),
            ):Padding(
              padding: EdgeInsets.only(
                top: size.height *(isnormal? 0.05:0.04),
                left: size.width * (isnormal? 0.03:0.02),
                right: size.width  *(isnormal? 0.03:0.02),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  notificationIcon,
                  menuIcon,
                ],
              ),
            ),
            MediaQuery.of(context).size.height<MediaQuery.of(context).size.width*2?
            SizedBox(height: size.height * 0.01):SizedBox(height: size.height * 0.02),
            Center(
              child: Column(
                children: [
                  MediaQuery.of(context).size.height<MediaQuery.of(context).size.width*2?
                  CustomText(
                    text: title ,
                    color: Color.fromRGBO(255, 255, 255, 1),
                    size: size.width * (isnormal ? 0.05:0.04),
                    weight: FontWeight.w900,
                  ): CustomText(
                    text: title ,
                    color: Color.fromRGBO(255, 255, 255, 1),
                    size: size.width * (isnormal ? 0.05:0.04),
                    weight: FontWeight.w900,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) // عرض subtitle إذا كانت موجودة وليست فارغة
                    Column(
                      children: [
                        SizedBox(height: 5),
                        MediaQuery.of(context).size.height<MediaQuery.of(context).size.width*2?
                        CustomText(
                          text: subtitle!,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          size: size.width * (isnormal ? 0.04:0.03),
                        ):CustomText(
                          text: subtitle!,
                          color: Color.fromRGBO(255, 255, 255, 1),
                          size: size.width * 0.04,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}







// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:jcp/provider/DeliveryModel.dart';
// import 'package:jcp/provider/OrderDetailsProvider.dart';
// import 'package:jcp/provider/ProfileProvider.dart';
// import 'package:jcp/screen/Drawer/Notification.dart';
// import 'package:jcp/screen/Drawer/PricingRequestPage.dart';
// import 'package:jcp/screen/home/homeuser.dart';
// import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
// import 'package:jcp/widget/RotatingImagePage.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../style/colors.dart';
// import '../../../style/custom_text.dart';
// import '../../model/OrderModel.dart';
// import '../../provider/CountdownProvider.dart';
// import '../../provider/EditProductProvider.dart';
// import '../../provider/OrderProvider.dart';
// import '../../provider/languageProvider.dart';
// import '../../widget/Inallpage/CustomHeader.dart';
// import '../../widget/Inallpage/MenuIcon.dart';
// import '../../widget/PartsWidget.dart';
// import 'package:http/http.dart' as http;
// import '../auth/login.dart';
//
// class HomeWidget extends StatefulWidget {
//   final ValueChanged<bool> run;
//   final bool? isLogin;
//
//   HomeWidget({super.key, this.isLogin, required this.run});
//
//   @override
//   State<HomeWidget> createState() => _HomeWidgetState();
// }
//
// class _HomeWidgetState extends State<HomeWidget>
//     with SingleTickerProviderStateMixin {
//   TextEditingController carid = TextEditingController();
//   TextEditingController part_1 = TextEditingController();
//   TextEditingController part_2 = TextEditingController();
//   TextEditingController part_3 = TextEditingController();
//   List<PartsWidget> parts = [];
//   String hint = "1 H G B H 4 1 J X M N 1 0 9 1 8 6";
//   int count = 0;
//   final form = GlobalKey<FormState>();
//   Color focusedColor = Colors.black;
//   Color bor = green;
//   int? flag = 2;
//   bool hasNewNotification = false;
//   late Future<Map<String, dynamic>> screen;
//   Map<String, dynamic>? apiData;
//   bool isLoading = true;
//   String? errorMessage;
//   int? orderAllowed;
//
//   ScrollController _scrollController1 = ScrollController();
//   ScrollController _scrollController2 = ScrollController();
//   ScrollController _scrollController3 = ScrollController();
//   ScrollController _scrollController4 = ScrollController();
//   FocusNode _focusNode = FocusNode();
//
//   Stream<Map<String, dynamic>> limitationStream(
//       String userId, String token) async* {
//     while (true) {
//       final data = await getOrderLimitation(userId, token);
//       yield data;
//       await Future.delayed(Duration(seconds: 5));
//     }
//   }
//
//   Future<Map<String, dynamic>> getOrderLimitation(
//       String userId, String token) async {
//     final String url =
//         'https://jordancarpart.com/Api/getlimitationoforder.php?user_id=$userId&token=$token';
//     final response = await http.get(
//       Uri.parse(url),
//       headers: {
//         'Access-Control-Allow-Headers': 'Authorization',
//         'Access-Control-Allow-Origin': '*',
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//     );
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['time_difference_gt_24hrs']) {}
//       if (data['limit_of_order'] == 0) {}
//       return data;
//     } else {
//       _showLogoutDialog(context);
//       throw Exception(
//           'تم تسجيل الدخول من جهاز آخر. الرجاء تسجيل الخروج والدخول مرة أخرى.');
//     }
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     var LANG = null;
//     LANG = Provider.of<Language>(context, listen: false);
//
//     final size = MediaQuery.of(context).size;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (BuildContext context, setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Container(
//                 width: size.width * 0.9,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Color.fromRGBO(255, 255, 255, 1),
//                 ),
//                 child: SingleChildScrollView(
//                   controller: _scrollController1,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10.0),
//                         child: Wrap(
//                           alignment: WrapAlignment.center,
//                           children: [
//                             CustomText(
//                               text: LANG.Llanguage('msg11'),
//                               color: black,
//                               size: 15,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 10.0),
//                         child: Wrap(
//                           alignment: WrapAlignment.center,
//                           children: [
//                             ElevatedButton(
//                               onPressed: () {
//                                 logout(context);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: red,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                               child: CustomText(
//                                 text: LANG.Llanguage('Signout'),
//                                 color: grey,
//                                 size: 15,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _fetchOrdersForUser(BuildContext context) async {
//     final orderProvider = Provider.of<OrderProvider>(context, listen: false);
//     final countdownProvider =
//     Provider.of<CountdownProvider>(context, listen: false);
//
//     try {
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? userId = prefs.getString('userId');
//       String? token = prefs.getString('token');
//       if (userId == null) {
//         
//         return;
//       }
//       
//       
//       final url = Uri.parse(
//           'https://jordancarpart.com/Api/getordersofuser.php?user_id=$userId&token=$token');
//       final response = await http.get(
//         url,
//       );
//       
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         if (responseData['success'] == true) {
//           List<OrderModel> orders = (responseData['data'] as List<dynamic>)
//               .map((order) => OrderModel.fromJson(order))
//               .toList();
//           orderProvider.setOrders(orders);
//           if (orders.isNotEmpty) {
//             countdownProvider.startCountdown(DateTime.parse(orders.last.time));
//           }
//           
//         } else {
//           
//         }
//       } else {
//         
//       }
//     } catch (e) {
//       
//     }
//   }
//
//   Stream<Map<String, dynamic>>? _limitationStream;
//   String? userId;
//   int? verificationValue;
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode.addListener(_onFocusChange);
//     _checkForNotifications();
//     _fetchData();
//     _loadOrderAllowed();
//     _initializeStream();
//     _loadVerificationValue();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(seconds: 2),
//     );
//
//     _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//
//     _controller.repeat(reverse: true);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _focusNode.removeListener(_onFocusChange);
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _onFocusChange() {
//     if (_focusNode.hasFocus) {
//       _scrollToFocusedField();
//     }
//   }
//
//   void _scrollToFocusedField() {
//     _scrollController2.animateTo(
//       _scrollController2.position.maxScrollExtent,
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   Future<void> _loadVerificationValue() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       verificationValue = prefs.getInt('verification');
//       isLoading = false;
//     });
//   }
//
//   Future<void> _initializeStream() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     userId = prefs.getString('userId');
//
//     if (userId != null) {
//       setState(() {
//         _limitationStream = limitationStream(userId!, token!);
//       });
//       _fetchOrdersForUser(context);
//     } else {
//       
//     }
//   }
//
//   Future<void> _loadOrderAllowed() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       orderAllowed = prefs.getInt('isOrderAllowed') ?? 0;
//     });
//   }
//
//   Future<void> _fetchData() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     try {
//       if (userId != null) {
//         final data = await getOrderLimitation(userId!, token!);
//         setState(() {
//           apiData = data;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('User ID is null');
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString();
//         isLoading = false;
//       });
//     }
//   }
//
//   var LANG = null;
//
//   Widget build(BuildContext context) {
//     LANG = Provider.of<Language>(context, listen: false);
//
//     final size = MediaQuery.of(context).size;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//     final user = Provider.of<ProfileProvider>(context);
//
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           FocusScope.of(context).unfocus();
//         },
//         child: SingleChildScrollView(
//           controller: _scrollController2,
//           child: Container(
//             height: MediaQuery.of(context).size.height * 3,
//             child: Padding(
//               padding: EdgeInsets.only(bottom: keyboardHeight),
//               child: Form(
//                 key: form,
//                 child: Container(
//                   color: Colors.white,
//                   child: Column(
//                     children: [
//                       _buildHeader(size),
//                       _limitationStream != null
//                           ? StreamBuilder<Map<String, dynamic>>(
//                         stream: _limitationStream,
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState ==
//                               ConnectionState.waiting) {
//                             return Center(
//                               child: RotatingImagePage(),
//                             );
//                           } else if (snapshot.hasError) {
//                             return Column(
//                               children: [
//                                 Text(LANG.getLanguage() == "AR"
//                                     ? "لا يوجد اتصال بالإنترنت"
//                                     : "No internet connection"),
//                               ],
//                             );
//                           } else if (!snapshot.hasData) {
//                             return Center(
//                                 child: Text(LANG.Llanguage('Nodata')));
//                           } else {
//                             final apiData = snapshot.data!;
//                             return _buildContentBasedOnApiData(
//                                 size, user, apiData);
//                           }
//                         },
//                       )
//                           : SizedBox(),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContentBasedOnApiData(
//       Size size, ProfileProvider user, Map<String, dynamic> apiData) {
//     final timeDifferenceGt24hrs = apiData['time_difference_gt_24hrs'];
//     final limitOfOrder = apiData['limit_of_order'];
//     saveLimitOfOrder(limitOfOrder);
//     
//     if (timeDifferenceGt24hrs) {
//       return _buildFormFields(context, size, user);
//     } else {
//       if (orderAllowed == 0) {
//         return _buildFormFields2(context, size, user, limitOfOrder);
//       } else {
//         return _buildFormFields(context, size, user);
//       }
//     }
//   }
//
//   Future<void> saveLimitOfOrder(int limitOfOrder) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('limitOfOrder', limitOfOrder);
//   }
//
//   Widget _buildNotificationIcon(Size size) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NotificationPage(),
//             )).then((_) {
//           _checkForNotifications();
//         });
//       },
//       child: Container(
//         height: size.width * 0.1,
//         width: size.width * 0.1,
//         decoration: BoxDecoration(
//           color: Color.fromRGBO(246, 246, 246, 0.26),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Center(
//           child: Image.asset(
//             hasNewNotification
//                 ? 'assets/images/notification-on.png'
//                 : 'assets/images/notification-off.png',
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _checkForNotifications() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     List<String> notifications = prefs.getStringList('notifications') ?? [];
//
//     List<Map<String, dynamic>> notificationList =
//     notifications.map((notification) {
//       return jsonDecode(notification) as Map<String, dynamic>;
//     }).toList();
//
//     bool hasUnread =
//     notificationList.any((notification) => notification['isRead'] == false);
//
//     setState(() {
//       hasNewNotification = hasUnread;
//     });
//   }
//
//   Widget _buildFormFields2(
//       BuildContext context, Size size, ProfileProvider user, limitOfOrder) {
//     bool isnormal = true;
//     double textScaleFactor = MediaQuery.of(context).textScaleFactor;
//
//     if (textScaleFactor > 1) {
//       isnormal = false;
//     } else {
//       isnormal = true;
//     }
//
//     return  SingleChildScrollView(
//       controller: _scrollController3,
//       child: Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: Column(
//           children: [
//             SizedBox(height: size.height * 0.01),
//             _buildVinField(),
//             verificationValue == 0
//                 ? SizedBox()
//                 : Padding(
//               padding: EdgeInsets.all(size.width * 0.01),
//               child: Column(
//                 children: [
//                   Container(
//                     child: Text(
//                       LANG.Llanguage('mss1'),
//                       style: TextStyle(
//                         fontSize: size.width * (isnormal ? 0.05 : 0.04),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.01),
//                   Consumer<CountdownProvider>(
//                     builder: (context, countdownProvider, child) {
//                       return Text(
//                         countdownProvider.countdownText,
//                         style: TextStyle(
//                           fontSize: size.width * 0.05,
//                           fontFamily: "Tajawal",
//                         ),
//                       );
//                     },
//                   ),
//                   SizedBox(height: size.height * 0.01),
//                   AnimatedBuilder(
//                     animation: _controller,
//                     builder: (context, child) {
//                       return Transform.scale(
//                         scale: _scaleAnimation.value,
//                         child: Image.asset(
//                           'assets/images/alarm.png',
//                           width: size.width * 0.40,
//                           height: size.height * 0.20,
//                         ),
//                       );
//                     },
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Container(
//                         child: Text(
//                           LANG.Llanguage('msg12'),
//                           style: TextStyle(
//                             fontSize: size.width * 0.04,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF8D8D92),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 6),
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => PricingRequestPage(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           child: Text(
//                             LANG.Llanguage('Contactus'),
//                             style: TextStyle(
//                               fontSize: size.width * 0.04,
//                               fontWeight: FontWeight.bold,
//                               color: green,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             LANG.Llanguage('msg13'),
//                             style: TextStyle(
//                               fontSize: size.width * 0.04,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(width: size.width * 0.04),
//                           Container(
//                             padding: EdgeInsets.all(size.width * 0.02),
//                             decoration: BoxDecoration(
//                               color: Color.fromRGBO(240, 240, 240, 1),
//                               border: Border.all(
//                                 color: Color.fromRGBO(240, 240, 240, 1),
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 "$limitOfOrder",
//                                 style: TextStyle(
//                                   fontSize: size.width * 0.045,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: size.width * 0.130,
//                               vertical: size.height * 0.02,
//                             ),
//                             child: ElevatedButton(
//                               onPressed: limitOfOrder > 0
//                                   ? () async {
//                                 setState(() {
//                                   isLoading = true;
//                                 });
//                                 final url =
//                                     'http://jordancarpart.com/Api/discountlimitation.php?user_id=${user.user_id}_id&flag=0';
//                                 final headers = {
//                                   'Access-Control-Allow-Headers':
//                                   '*',
//                                   'Access-Control-Allow-Origin':
//                                   '*',
//                                   'Content-Type':
//                                   'application/json; charset=UTF-8',
//                                 };
//                                 try {
//                                   final response = await http.get(
//                                     Uri.parse(url),
//                                     headers: headers,
//                                   );
//                                   if (response.statusCode == 200) {
//                                     jsonDecode(response.body);
//                                     SharedPreferences prefs =
//                                     await SharedPreferences
//                                         .getInstance();
//                                     await prefs.setInt(
//                                         'isOrderAllowed', 1);
//
//                                     setState(() {
//                                       errorMessage = null;
//                                     });
//                                     await _checkForNotifications();
//                                     await _fetchData();
//                                     await _loadOrderAllowed();
//                                   } else {
//                                     await _logoutUser();
//                                   }
//                                 } catch (e) {
//                                   await _logoutUser();
//                                 } finally {
//                                   setState(() {
//                                     isLoading = false;
//                                   });
//                                 }
//                               }
//                                   : null,
//                               child: isLoading
//                                   ? Container(
//                                 child: RotatingImagePage(),
//                                 width: 20,
//                                 height: 20,
//                               )
//                                   : Padding(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8.0),
//                                 child: Text(
//                                   LANG.Llanguage('activation'),
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 15,
//                                   ),
//                                 ),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: limitOfOrder > 0
//                                     ? red
//                                     : Colors.grey,
//                                 textStyle: TextStyle(
//                                     fontSize: size.width * 0.01),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius:
//                                   BorderRadius.circular(8),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//
//   }
//
//   Future<void> _logoutUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     await prefs.setBool('rememberMe', false);
//     await prefs.remove('phone');
//     await prefs.remove('password');
//     await prefs.remove('userId');
//     await prefs.remove('name');
//     await prefs.remove('type');
//     await prefs.remove('city');
//     List<String> notifications = prefs.getStringList('notifications') ?? [];
//     await prefs.setStringList('notifications', notifications);
//     await prefs.setInt('isOrderAllowed', 0);
//     final profileProvider =
//     Provider.of<ProfileProvider>(context, listen: false);
//     profileProvider.resetFields();
//     final OrderProvider1 = Provider.of<OrderProvider>(context, listen: false);
//     OrderProvider1.clearOrders();
//     final orderDetailsProvider =
//     Provider.of<OrderDetailsProvider>(context, listen: false);
//     orderDetailsProvider.clear();
//     final editProductProvider =
//     Provider.of<EditProductProvider>(context, listen: false);
//     editProductProvider.clear();
//     final deliveryModel =
//     Provider.of<DeliveryModelOrange>(context, listen: false);
//     deliveryModel.clear();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//           (Route<dynamic> route) => false,
//     );
//   }
//
//   Widget _buildHeader(Size size) {
//     return CustomHeader(
//       size: MediaQuery.of(context).size,
//       title: LANG.Llanguage('Jordan_Car_Part'),
//       notificationIcon: _buildNotificationIcon(size),
//       menuIcon: _buildMenuIcon(context, size),
//     );
//   }
//
//   Widget _buildMenuIcon(BuildContext context, Size size) {
//     return MenuIcon(
//       size: size,
//       onTap: () {
//         Scaffold.of(context).openEndDrawer();
//       },
//     );
//   }
//
//   Widget _buildFormFields(
//       BuildContext context, Size size, ProfileProvider user) {
//     return Column(
//       children: [
//         SizedBox(height: size.height * 0.02),
//         _buildVinField(),
//         SizedBox(height: size.height * 0.02),
//         PartsFieldWidget(
//           hintText: LANG.Llanguage('msg14'),
//           controller: part_1,
//           size: size,
//         ),
//         SizedBox(height: size.height * 0.02),
//         PartsFieldWidget(
//           hintText: LANG.Llanguage('msg15'),
//           controller: part_2,
//           size: size,
//         ),
//         SizedBox(height: size.height * 0.02),
//         PartsFieldWidget(
//           hintText: LANG.Llanguage('msg16'),
//           controller: part_3,
//           size: size,
//         ),
//         SizedBox(height: size.height * 0.02),
//         _buildAdditionalParts(size),
//         _buildSubmitButton(context, size, user),
//       ],
//     );
//   }
//
//   Widget _buildVinField() {
//     bool isnormal = true;
//     double textScaleFactor = MediaQuery.of(context).textScaleFactor;
//
//     if (textScaleFactor > 1) {
//       isnormal = false;
//     } else {
//       isnormal = true;
//     }
//     return Column(
//       children: [
//         Center(
//           child: CustomText(
//             text: LANG.Llanguage('Chassisnumber').toString().replaceAll(':', ""),
//             color: Color.fromRGBO(0, 0, 0, 1),
//             size: 20,
//           ),
//         ),
//         Container(
//           height: isnormal ? 85 : 100,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   height: 60,
//                   color: grey,
//                   child: TextFormField(
//                     controller: carid,
//                     maxLength: 17,
//                     maxLines: 1,
//                     textCapitalization: TextCapitalization.characters,
//                     textAlign: TextAlign.center,
//                     decoration: InputDecoration(
//                       counterText: "",
//                       enabledBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: bor, width: 2),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderSide: BorderSide(color: focusedColor, width: 2),
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       border: OutlineInputBorder(
//                         borderSide: BorderSide(color: bor, width: 2),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       fillColor: grey,
//                       hintText: hint,
//                       hintStyle: TextStyle(
//                         color: green,
//                         fontSize: 16.0,
//                         fontWeight: FontWeight.w500,
//                         fontFamily: "Tajawal",
//                       ),
//                     ),
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     onChanged: (value) {
//                       count = value.length;
//                       if (value.length == 17 && !value.contains(" ")) {
//                         setState(() {
//                           focusedColor = green;
//                           bor = green;
//                         });
//                       } else {
//                         setState(() {
//                           focusedColor = Colors.red;
//                           bor = Colors.red;
//                         });
//                       }
//                     },
//                     onTap: () {
//                       setState(() {
//                         hint = "";
//                       });
//                     },
//                   ),
//                 ),
//                 CustomText(text: "$count/17"),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAdditionalParts(Size size) {
//     return SingleChildScrollView(
//       controller: _scrollController4,
//       child: Column(
//         children: [
//           ...parts,
//           SizedBox(height: size.height * 0.015),
//           GestureDetector(
//             onTap: () => onAddForm(),
//             child: Center(
//               child: CustomText(
//                 text: LANG.Llanguage('Add_a_piecean'),
//                 color: green,
//                 size: size.width * 0.045,
//                 weight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSubmitButton(
//       BuildContext context, Size size, ProfileProvider user) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
//       child: MaterialButton(
//         onPressed: () async {
//           
//           if (carid.text.length == 17 && part_1.text.isNotEmpty) {
//             onSave(carid.text, part_1.text, part_2.text, part_3.text,
//                 user.user_id);
//             setState(() {
//               parts.clear();
//               part_1.clear();
//               part_2.clear();
//               part_3.clear();
//               carid.clear();
//               count = 0;
//             });
//             widget.run(true);
//           } else {
//             showConfirmationDialog(
//               context: context,
//               message: LANG.Llanguage('msg17'),
//               confirmText: LANG.Llanguage('OK'),
//               onConfirm: () {},
//               cancelText: '',
//             );
//           }
//         },
//         height: 50,
//         minWidth: size.width * 0.9,
//         color: Color.fromRGBO(195, 29, 29, 1),
//         child: CustomText(
//           text: LANG.Llanguage('send'),
//           color: white,
//           size: 16,
//         ),
//         padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//       ),
//     );
//   }
//
//   void onAddForm() {
//     setState(() {
//       var _partController = TextEditingController();
//       parts.add(PartsWidget(
//         part: _partController,
//         onDelete: () => onDelete(_partController),
//       ));
//
//       _scrollToTop();
//     });
//   }
//
//   void _scrollToTop() {}
//
//   void onDelete(TextEditingController _controller) {
//     final find = parts.firstWhere(
//           (it) => it.part!.text == _controller.text,
//       orElse: () => null!,
//     );
//     parts.removeAt(parts.indexOf(find));
//     setState(() {});
//   }
//
//   void onSave(
//       String carid, String p1, String p2, String p3, String user_id) async {
//     List<Map<String, String>> itemsList = [];
//     final size = MediaQuery.of(context).size;
//
//     if (p1.isNotEmpty) itemsList.add({"name": p1});
//     if (p2.isNotEmpty) itemsList.add({"name": p2});
//     if (p3.isNotEmpty) itemsList.add({"name": p3});
//
//     for (var partWidget in parts) {
//       if (partWidget.part != null && partWidget.part!.text.isNotEmpty) {
//         itemsList.add({"name": partWidget.part!.text});
//       }
//     }
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     final order = {
//       "carid": carid,
//       "time": DateTime.now().toIso8601String(),
//       "type": "1",
//       "customer_id": user_id,
//       "items": itemsList,
//       "token": token
//     };
//
//     final url = Uri.parse('https://jordancarpart.com/Api/saveorder.php');
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Access-Control-Allow-Headers': 'Authorization',
//           'Access-Control-Allow-Origin': '*',
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: json.encode(order),
//       );
//
//       if (response.statusCode == 200) {
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         int? isOrderAllowed = prefs.getInt('isOrderAllowed');
//         if (isOrderAllowed == 1) {
//           await prefs.setInt('isOrderAllowed', 0);
//           
//         }
//         setState(() {
//           isLoading = true;
//           errorMessage = null;
//         });
//         await _checkForNotifications();
//         await _fetchData();
//         await _loadOrderAllowed();
//         showModalBottomSheet(
//           context: context,
//           builder: (context) {
//             return Container(
//               height: size.height * 0.5,
//               width: size.width,
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.25),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(1),
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.03),
//                     Center(
//                       child: Image.asset(
//                         "assets/images/done-icon 1.png",
//                         height: size.height * 0.15,
//                         width: size.width * 0.3,
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     CustomText(
//                       text: LANG.Llanguage('msg18'),
//                       size: size.width * 0.06,
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     CustomText(
//                       text: LANG.Llanguage('msg19'),
//                       size: size.width * 0.06,
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     MaterialButton(
//                       onPressed: () {},
//                       height: size.height * 0.06,
//                       minWidth: size.width * 0.7,
//                       color: Color.fromRGBO(195, 29, 29, 1),
//                       child: CustomText(
//                         text: LANG.Llanguage('back'),
//                         color: white,
//                         size: size.width * 0.05,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       } else {
//         showConfirmationDialog(
//           context: context,
//           message: LANG.Llanguage('msg20') + " ${response.reasonPhrase}",
//           confirmText: "حسناً",
//           onConfirm: () {},
//           cancelText: '',
//         );
//       }
//     } catch (e) {
//       showConfirmationDialog(
//         context: context,
//         message: LANG.Llanguage('msg21'),
//         confirmText: LANG.Llanguage('OK'),
//         onConfirm: () {},
//         cancelText: '',
//       );
//     }
//   }
// }
//
// Future<void> logout(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//
//   String? userId = prefs.getString('userId');
//   await prefs.clear();
//
//   final profileProvider =
//   Provider.of<ProfileProvider>(context, listen: false);
//   profileProvider.resetFields();
//   final OrderProvider1 = Provider.of<OrderProvider>(context, listen: false);
//   OrderProvider1.clearOrders();
//   final orderDetailsProvider =
//   Provider.of<OrderDetailsProvider>(context, listen: false);
//   orderDetailsProvider.clear();
//   final editProductProvider =
//   Provider.of<EditProductProvider>(context, listen: false);
//   editProductProvider.clear();
//   final deliveryModel =
//   Provider.of<DeliveryModelOrange>(context, listen: false);
//   deliveryModel.clear();
//
//   Navigator.pushAndRemoveUntil(
//     context,
//     MaterialPageRoute(builder: (context) => LoginPage()),
//         (Route<dynamic> route) => false,
//   );
// }
//
// class PartsFieldWidget extends StatefulWidget {
//   final String hintText;
//   final TextEditingController controller;
//   final Size size;
//
//   const PartsFieldWidget({
//     Key? key,
//     required this.hintText,
//     required this.controller,
//     required this.size,
//   }) : super(key: key);
//
//   @override
//   _PartsFieldWidgetState createState() => _PartsFieldWidgetState();
// }
//
// class _PartsFieldWidgetState extends State<PartsFieldWidget> {
//   late FocusNode _focusNode;
//   late String currentHintText;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     currentHintText = widget.hintText;
//
//     _focusNode.addListener(() {
//       setState(() {
//         if (_focusNode.hasFocus) {
//           currentHintText = '';
//         } else if (widget.controller.text.isEmpty) {
//           currentHintText = widget.hintText;
//         }
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: widget.size.width * 0.05),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           color: grey,
//         ),
//         child: TextFormField(
//           controller: widget.controller,
//           focusNode: _focusNode,
//           textAlign: TextAlign.start,
//           maxLength: 30,
//           decoration: InputDecoration(
//             enabledBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: grey, width: 2),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: grey, width: 2),
//               borderRadius: BorderRadius.circular(10.0),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             hintText: currentHintText,
//             hintStyle: TextStyle(
//               color: words,
//               fontSize: widget.size.width * 0.04,
//             ),
//             counterText: '',
//           ),
//           style: TextStyle(
//             fontFamily: "Tajawal",
//             color: Colors.black,
//             fontSize: widget.size.width * 0.04,
//           ),
//         ),
//       ),
//     );
//   }
// }