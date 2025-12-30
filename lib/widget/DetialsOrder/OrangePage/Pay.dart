import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/payment/EfawateercomPaymentPage.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/ProfileProvider.dart';
import '../../../screen/home/homeuser.dart' show HomePage;
import '../../Inallpage/showConfirmationDialog.dart';
import 'payment/credit_card_payment_page.dart';

class PayPage extends StatefulWidget {
  final int orderId;
  final int billId;

  const PayPage({super.key, required this.orderId, required this.billId});

  @override
  _PayPageState createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  bool _checkingPayment = true;
  bool _allowBuild = false;
  String Amount = "";
  String city = "";
  String addressDetails = "";
  bool isEfawateercomSelected = false;
  String billCategory = '';

  void _cancelOrder() {
    showConfirmationDialog(
      context: context,
      message:
      "هل أنت متأكد من إلغاء الطلب؟ سيتم حذف الفاتورة والعودة لصفحة اختيار القطع",
      confirmText: "نعم",
      onConfirm: () async {
        await _processCancelOrder();
      },
      cancelText: "لا",
      onCancel: () {},
    );
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrange(
      String orderId, int flag) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getorderacept.php?order_id=$orderId&flag=$flag');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData =
        jsonDecode(utf8.decode(response.bodyBytes));

        // ✅ Check if 'orders' key exists in the response
        if (responseData.containsKey('orders') &&
            (responseData['orders'] as List).isNotEmpty) {
          var order = responseData['orders'][0];

          return {'order': order, 'order_items': order['items'] ?? []};
        } else {
          return {
            'order': {},
            'order_items': []
          }; // Return empty if no orders exist
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> _processCancelOrder() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: RotatingImagePage()),
        ),
      );

      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/cancel_order_aftrebills.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8', // Added proper headers
        },
        body: jsonEncode({
          'order_id': widget.orderId,
          'bill_id': widget.billId,
        }),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData =
        jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData['success'] == true) {
          showConfirmationDialog(
            context: context,
            message: 'تم إلغاء الطلب بنجاح. يمكنك الآن اختيار قطع جديدة',
            confirmText: 'حسناً',
            preventDismissal: true,
            onConfirm: () async {
              try {
                List<dynamic> orderItems2 = [];

                Map<String, dynamic> orderData =
                await fetchOrderItemsOrange(widget.orderId.toString(), 1);

                final response = await http.get(
                  Uri.parse(
                      "https://jordancarpart.com/Api/gitnameorder.php?order_id=${widget.orderId}"),
                );

                if (response.statusCode == 200) {
                  final Map<String, dynamic> jsonResponse =
                  json.decode(utf8.decode(response.bodyBytes));

                  if (jsonResponse['success'] == true &&
                      jsonResponse.containsKey('items')) {
                    orderItems2 = jsonResponse['items'];
                  }
                }

                if (orderData.isNotEmpty &&
                    orderData.containsKey('order') &&
                    orderData.containsKey('order_items')) {
                  Map<String, dynamic> order1 = orderData['order'];
                  List<dynamic> orderItems = orderData['order_items'];

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage_Orange(
                        status: true,
                        order1: order1,
                        orderItems: orderItems,
                        nameproduct: orderItems2.isNotEmpty
                            ? orderItems2
                            : List.filled(orderItems.length, "غير معروف"),
                      ),
                    ),
                  );
                } else {
                  throw Exception("Order data is missing required keys.");
                }
              } catch (e) {
                Navigator.pop(context);
              }
            },
          );
        } else {
          showConfirmationDialog(
            context: context,
            message: responseData['message'] ?? 'حدث خطأ أثناء إلغاء الطلب.',
            confirmText: 'حسناً',
            preventDismissal: true,
            onConfirm: () {},
          );
        }
      } else {
        showConfirmationDialog(
          context: context,
          message: 'خطأ في الاتصال بالخادم. يرجى المحاولة مرة أخرى.',
          confirmText: 'حسناً',
          preventDismissal: true,
          onConfirm: () {},
        );
      }
    } catch (e) {
      Navigator.of(context).pop();

      showConfirmationDialog(
        context: context,
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
        confirmText: 'حسناً',
        preventDismissal: true,
        onConfirm: () {},
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await checkPaymentStatus(widget.orderId);
    setState(() {
      _checkingPayment = false;
    });
  }

  Future<void> checkPaymentStatus(int orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/check_payment.php?order_id=$orderId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['success']) {
          setState(() {
            Amount = data['total_amount'];
            city = data['city'];
            addressDetails = data['addressDetails'];
            billCategory = data['bill_category'];

            title = city;
            addressController.text = addressDetails;
          });
        }
      }
    } catch (e) {}
  }

  bool isCashOnDeliverySelected = false;
  bool isVisaSelected = false;
  List<String> list = [
    "عمَان",
    "اربد",
    "الزرقاء",
    "عجلون",
    "جرش",
    "المفرق",
    "البلقاء",
    "مأدبا",
    "الكرك",
    "الطفيلة",
    "معان",
    "العقبة",
  ];
  String title = "عمَان";
  TextEditingController addressController = TextEditingController();

  void togglePaymentMethod(String method) {
    setState(() {
      if (method == 'cash') {
        isCashOnDeliverySelected = !isCashOnDeliverySelected;
        if (isCashOnDeliverySelected) {
          isVisaSelected = false;
          isEfawateercomSelected = false;
        }
      } else if (method == 'visa') {
        isVisaSelected = !isVisaSelected;
        if (isVisaSelected) {
          isCashOnDeliverySelected = false;
          isEfawateercomSelected = false;
        }
      } else if (method == 'efawateercom') {
        isEfawateercomSelected = !isEfawateercomSelected;
        if (isEfawateercomSelected) {
          isCashOnDeliverySelected = false;
          isVisaSelected = false;
        }
      }
    });
  }

  bool isAddressChecked = true;

  Future<void> _cancelPricingBill() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);

    showConfirmationDialog(
      context: context,
      message: "هل أنت متأكد من إلغاء طلب التسعير؟",
      confirmText: "نعم",
      cancelText: "لا",
      onConfirm: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: RotatingImagePage()),
            ),
          );

          final response = await http.post(
            Uri.parse(
                "https://jordancarpart.com/Api/proccising/cancel_pricing_bill.php"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "bill_id": widget.billId,
              "user_id": user.user_id,
            }),
          );

          Navigator.of(context).pop();

          final data = jsonDecode(utf8.decode(response.bodyBytes));

          if (response.statusCode == 200 && data["success"] == true) {
            showConfirmationDialog(
              context: context,
              message: "تم إلغاء الطلب بنجاح",
              confirmText: "حسناً",
              preventDismissal: true,
              onConfirm: () {
                Navigator.pop(context);
              },
            );
          } else {
            showConfirmationDialog(
              context: context,
              message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
              confirmText: "حسناً",
              preventDismissal: true,
              onConfirm: () {},
            );
          }
        } catch (e) {
          Navigator.of(context).pop();

          showConfirmationDialog(
            context: context,
            message: "حدث خطأ أثناء الإلغاء. حاول مرة أخرى.",
            confirmText: "حسناً",
            preventDismissal: true,
            onConfirm: () {},
          );
        }
      },
      onCancel: () {},
    );
  }

  Future<void> _cancelPrivateBill() async {
    showConfirmationDialog(
      context: context,
      message:
      "هل أنت متأكد من إلغاء الطلب الخاص؟ سيتم إرجاع الطلب إلى حالته السابقة",
      confirmText: "نعم",
      cancelText: "لا",
      onConfirm: () async {
        try {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Center(child: RotatingImagePage()),
            ),
          );

          final response = await http.post(
            Uri.parse(
                'https://jordancarpart.com/Api/proccising/cancel_private_bill.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "bill_id": widget.billId,
              "order_id": widget.orderId,
            }),
          );

          Navigator.of(context).pop();

          final data = jsonDecode(utf8.decode(response.bodyBytes));

          if (response.statusCode == 200 && data['success'] == true) {
            showConfirmationDialog(
              context: context,
              message: "تم إرجاع الطلب إلى حالته السابقة",
              confirmText: "حسناً",
              preventDismissal: true,
              onConfirm: () {
                Navigator.pop(context);
              },
            );
          } else {
            showConfirmationDialog(
              context: context,
              message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
              confirmText: "حسناً",
              preventDismissal: true,
              onConfirm: () {},
            );
          }
        } catch (e) {
          Navigator.of(context).pop();
          showConfirmationDialog(
            context: context,
            message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
            confirmText: "حسناً",
            preventDismissal: true,
            onConfirm: () {},
          );
        }
      },
      onCancel: () {},
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.18,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary1, primary2, primary3]),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              Expanded(
                child: Center(
                  child: CustomText(
                    text: "طريقة الدفع",
                    color: Colors.white,
                    size: size.width * 0.04,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              if (billCategory == "normal")
                IconButton(
                  onPressed: _cancelOrder,
                  icon: SvgPicture.asset(
                    'assets/svg/cancel.svg',
                    colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 26,
                    height: 26,
                  ),
                )
              else if (billCategory == "pricing")
                IconButton(
                  onPressed: _cancelPricingBill,
                  icon: SvgPicture.asset(
                    'assets/svg/cancel.svg',
                    colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    width: 26,
                    height: 26,
                  ),
                )
              else if (billCategory == "special")
                  IconButton(
                    onPressed: _cancelPrivateBill,
                    icon: SvgPicture.asset(
                      'assets/svg/cancel.svg',
                      colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      width: 26,
                      height: 26,
                    ),
                  )
                else
                  const SizedBox(width: 26),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_checkingPayment) {
      return Scaffold(
        backgroundColor: white,
        body: Center(child: RotatingImagePage()),
      );
    }

    return Scaffold(
      backgroundColor: white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(size),
            SizedBox(height: size.height * 0.001),
            CustomText(
              text: "المبلغ",
              weight: FontWeight.bold,
            ),
            SizedBox(height: size.height * 0.003),
            CustomText(
                text: double.tryParse(Amount)?.toInt().toString() ?? Amount),
            SizedBox(height: size.height * 0.01),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // GestureDetector(
                //   onTap: () => togglePaymentMethod('visa'),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Row(
                //         children: [
                //           Image.asset('assets/images/visa.png',
                //               height: 50, width: 50),
                //           SizedBox(height: 5),
                //           CustomText(
                //             text: "من خلال ",
                //             textAlign: TextAlign.right,
                //             color: Colors.black,
                //             weight: FontWeight.w600,
                //           ),
                //         ],
                //       ),
                //       Checkbox(
                //         value: isVisaSelected,
                //         onChanged: (bool? value) => togglePaymentMethod('visa'),
                //         activeColor: Colors.green,
                //         shape: CircleBorder(),
                //       ),
                //     ],
                //   ),
                // ),
                SizedBox(height: size.height * 0.015),
                GestureDetector(
                  onTap: () => togglePaymentMethod('cash'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "إي فواتيركم",
                        textAlign: TextAlign.right,
                        color: Colors.black,
                        weight: FontWeight.w600,
                      ),
                      Checkbox(
                        value: isCashOnDeliverySelected,
                        onChanged: (bool? value) => togglePaymentMethod('cash'),
                        activeColor: Colors.green,
                        shape: CircleBorder(),
                        checkColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                GestureDetector(
                  onTap: () => togglePaymentMethod('efawateercom'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "الدفع المباشر",
                        textAlign: TextAlign.right,
                        color: Colors.black,
                        weight: FontWeight.w600,
                      ),
                      Checkbox(
                        value: isEfawateercomSelected,
                        onChanged: (bool? value) =>
                            togglePaymentMethod('efawateercom'),
                        activeColor: Colors.green,
                        shape: CircleBorder(),
                        checkColor: Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (billCategory != "pricing") ...[
              SizedBox(height: size.height * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6.5),
                      child: CustomText(text: "المحافظة", size: 18),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: grey,
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        padding: EdgeInsets.only(right: 5),
                        alignment: Alignment.center,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                          border: InputBorder.none,
                        ),
                        items: list.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            alignment: Alignment.centerRight,
                            child: CustomText(text: value, color: black),
                          );
                        }).toList(),
                        value: title,
                        isExpanded: true,
                        menuMaxHeight: 200,
                        icon: Container(),
                        onChanged: (val) {
                          setState(() {
                            title = val!;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        elevation: 10,
                        style: TextStyle(color: black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(text: "تفاصيل العنوان", size: 18),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black,
                      color: grey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextFormField(
                          controller: addressController,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: addressController.text.isNotEmpty
                                ? addressController.text
                                : "الحي الشرقي - شارع الأمير محمد - بناية 08",
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: "Tajawal",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText(
                    text: "تذكر العنوان",
                    size: 16,
                    color: Colors.black,
                  ),
                  Checkbox(
                    value: isAddressChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isAddressChecked = value ?? false;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ],
            SizedBox(height: size.height * 0.02),
            MaterialButton(
              onPressed: () async {
                if (!isCashOnDeliverySelected &&
                    !isVisaSelected &&
                    !isEfawateercomSelected) {
                  showConfirmationDialog(
                    context: context,
                    message: 'يرجى اختيار طريقة الدفع أولاً.',
                    confirmText: 'حسنًا',
                    onConfirm: () {},
                  );
                  return;
                }

                final user =
                Provider.of<ProfileProvider>(context, listen: false);
                await updateUserCityAndAddressDetail(
                  int.parse(user.user_id),
                  title,
                  addressController.text.isNotEmpty
                      ? addressController.text
                      : (user.addressDetail ?? ""),
                );

                if (isCashOnDeliverySelected) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EfawateercomPaymentPage(billId: widget.billId),
                    ),
                  );
                } else if (isVisaSelected) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CreditCardPaymentPage(
                  //       billId: widget.billId,
                  //       orderId: widget.orderId,
                  //       amount: Amount,
                  //     ),
                  //   ),
                  // );
                } else if (isEfawateercomSelected) {
                  final double amount = double.tryParse(Amount.toString()) ?? 0;
                  final bilrTrxNo =
                  DateTime.now().millisecondsSinceEpoch.toString();

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: Center(child: RotatingImagePage()),
                    ),
                  );

                  final response = await http.post(
                    Uri.parse(
                        'https://jordancarpart.com/Api/Bills/generate_directpay_url.php'),
                    body: {
                      'code': widget.billId.toString(),
                      'amount': amount.toStringAsFixed(3),
                    },
                  );

                  Navigator.of(context).pop();

                  if (response.statusCode == 200 && response.body.isNotEmpty) {
                    try {
                      final data = jsonDecode(response.body);
                      if (data['status'] == 'success') {
                        await launchUrl(
                          Uri.parse(data['url']),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        showConfirmationDialog(
                          context: context,
                          message: 'فشل إنشاء رابط الدفع: ${data['message']}',
                          confirmText: 'حسنًا',
                          onConfirm: () {},
                        );
                      }
                    } catch (e) {
                      showConfirmationDialog(
                        context: context,
                        message: 'فشل في تحليل البيانات: $e',
                        confirmText: 'حسنًا',
                        onConfirm: () {},
                      );
                    }
                  } else {
                    showConfirmationDialog(
                      context: context,
                      message:
                      'فشل في الاتصال بالخادم. الكود: ${response.statusCode}',
                      confirmText: 'حسنًا',
                      onConfirm: () {},
                    );
                  }
                }
              },
              height: 50,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "متابعة",
                color: white,
                size: 16,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            billCategory == "pricing"
                ? Container()
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CustomText(
                    text: "ملاحظة",
                    size: 16,
                    color: Colors.black,
                    weight: FontWeight.bold,
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 5),
                  CustomText(
                    text:
                    "في حال تغيير العنوان سيتم إعادة احتساب فرق التوصيل إن وجد",
                    size: 14,
                    color: Colors.black,
                    weight: FontWeight.w200,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateUserCityAndAddressDetail(
      int userId, String city, String addressDetail) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/updateuser.php?user_id=$userId&city=$city&AddressDetail=$addressDetail'); // أضفنا parameter addressDetail في الرابط

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        // ✅ تحديث ProfileProvider
        final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
        profileProvider.setcity(city);
        profileProvider.setaddressDetail(addressDetail);

        // ✅ تحديث SharedPreferences أيضًا
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('city', city);
        await prefs.setString('addressDetail', addressDetail);

        setState(() {
          title = city;
          addressController.text = addressDetail;
        }); // تحديث الواجهة بعد الحفظ
      } else {
        print(
            'فشل في تحديث المدينة وتفاصيل العنوان: ${response.body.toString()}');
      }
    } catch (error) {}
  }

  String buildDirectPayUrl({
    required String bilrTrxNo,
    required String billingNo,
    required double amount,
    String email = "prajwal@hazesoft.co",
  }) {
    const String billerCode = "1907";
    const String serviceCode = "113529";
    const String paymentType = "1";
    const String currency = "JOD";
    const String language = "AR";
    const String secretToken = "5a1acfdcca76499e94b54e369b3737d1";

    final String amountStr = amount.toStringAsFixed(3);

    final String rawParams =
        "$bilrTrxNo|$billerCode|$serviceCode|$paymentType|$currency|$billingNo||$amountStr||$email|$language|";

    final String stringToHash = rawParams + secretToken;

    final String secureHash = BCrypt.hashpw(stringToHash, BCrypt.gensalt())
        .replaceFirst('\$2b\$', '\$2a\$');

    final String finalParams = "$rawParams$secureHash";

    return "https://stgdirectpay.efawateercom.jo/main-page?RequestParams=$finalParams";
  }
}
