import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/Pay.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widget/Inallpage/CustomButton.dart';
import '../../widget/Inallpage/showConfirmationDialog.dart';

class PricingRequestPage extends StatefulWidget {
  const PricingRequestPage({super.key});

  @override
  State<PricingRequestPage> createState() => _PricingRequestPageState();
}

class _PricingRequestPageState extends State<PricingRequestPage> {
  int selectedRequests = 0;
  final TextEditingController messageController = TextEditingController();
  int? limitOfOrder;
  int? billId;
  double? dueAmount;
  bool hasActiveBill = false;
  late ProfileProvider userProvider;
  Timer? _refreshTimer;
  bool isLoading = true;

  Future<int?> getLimitOfOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('limitOfOrder');
  }

  Future<void> _loadLimitOfOrder() async {
    int? retrievedLimitOfOrder = await getLimitOfOrder();
    setState(() {
      limitOfOrder = retrievedLimitOfOrder;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePage();
    _loadLimitOfOrder();
    checkActivePricingBill();
  }

  Future<void> _initializePage() async {
    await _loadLimitOfOrder();
    await checkActivePricingBill();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userProvider = Provider.of<ProfileProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> checkActivePricingBill() async {
    try {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/Bills/check_pricing_bill.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"user_id": userProvider.user_id}),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          hasActiveBill = true;
          billId = data['bill_id'];
          dueAmount = double.tryParse(data['due_amount'].toString()) ?? 0.0;
        });
      } else {
        setState(() {
          hasActiveBill = false;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: size.height * 0.20,
                width: size.width,
                decoration: BoxDecoration(
                  gradient:
                  LinearGradient(colors: [primary1, primary2, primary3]),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomText(
                        text: "تفعيل طلب تسعير",
                        color: Colors.white,
                        size: size.width * 0.06,
                      ),
                      SizedBox(width: size.width * 0.2),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_forward_ios_rounded,
                              color: white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              isLoading
                  ? Center(
                  child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3),
                      RotatingImagePage(),
                    ],
                  ))
                  : Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 5),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomText(
                        text: "الطلبات المتبقية",
                        size: 20,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.001),
                      CustomText(
                        text: "${limitOfOrder?.toInt() ?? 0}",
                        size: 30,
                        weight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text: "هذا القسم مخصص للتسعير المدفوع",
                        size: 16,
                        textAlign: TextAlign.center,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text:
                        "يمكنك تفعيل أكثر من طلب تسعير بصلاحية تنتهي بانتهاء عدد الطلبات المدفوعة مع الاحتفاظ بحقك في التسعير المجاني لمرة واحدة في اليوم",
                        size: 14,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.001),
                      CustomText(
                        text: " JD2تكلفة كل طلب جديد هي ",
                        size: 14,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height:
                          MediaQuery.of(context).size.height * 0.02),
                      Column(
                        children: [
                          ...(hasActiveBill
                              ? []
                              : [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.15,
                                  child: TextField(
                                    keyboardType:
                                    TextInputType.number,
                                    textAlign: TextAlign.center,
                                    // 🔥 يخلي الكتابة بالنص
                                    textAlignVertical:
                                    TextAlignVertical.center,
                                    // 🔥 يخليها بنص الصندوق عمودياً
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '',
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                          vertical:
                                          10), // 🔥 أحلى تمركز
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRequests =
                                            int.tryParse(value) ??
                                                0;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.05,
                                ),
                                CustomText(
                                  text: ": عدد الطلبات",
                                  size: 16,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context)
                                  .size
                                  .height *
                                  0.02,
                            ),
                            CustomText(
                              text:
                              "JDالتكلفة الإجمالية: ${selectedRequests * 2} ",
                              size: 16,
                              textAlign: TextAlign.center,
                            ),
                          ])
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
                      hasActiveBill
                          ? Column(
                        children: [
                          SizedBox(height: 10),
                          CustomText(
                            text: "لديك طلب تسعير مفعل بالفعل",
                            size: 16,
                            color: Colors.green,
                            weight: FontWeight.bold,
                          ),
                          SizedBox(height: 5),
                          Column(
                            children: [
                              CustomText(
                                text: ":رقم الفاتورة",
                                size: 16,
                                color: Colors.black87,
                              ),
                              CustomText(
                                text: "$billId",
                                size: 16,
                                color: Colors.black87,
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: ":المبلغ المستحق",
                                size: 16,
                                color: Colors.red,
                              ),
                              CustomText(
                                text:
                                "${dueAmount?.toStringAsFixed(2)} JD",
                                size: 16,
                                color: Colors.red,
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          CustomButton(
                            height: 50,
                            text: "متابعة",
                            onPressed: () async {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PayPage(
                                        orderId: int.parse(
                                            userProvider.user_id),
                                        billId: billId!),
                                  ));
                            },
                            color: button,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontFamily: "Tajawal",
                            ),
                          ),
                        ],
                      )
                          : CustomButton(
                        height: 50,
                        minWidth: size.width * 0.9,
                        text: "شراء",
                        onPressed: () {
                          _submitRequest(
                              selectedRequests.toString(), context);
                        },
                        color: button,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: "Tajawal",
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest(String message, context) async {
    final user = Provider.of<ProfileProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final billData = {
      "order_id": user.user_id,
      "user_id": user.user_id,
      "cust_name": user.name,
      "due_amount": (int.tryParse(message) ?? 0) * 2,
      "service_type": "Pay_bill",
      "bill_type": "OneOff",
      "bill_status": "BillNew",
      "status": "pricing",
      "bill_category": "pricing",
    };

    try {
      final billResponse = await http.post(
        Uri.parse('https://jordancarpart.com/Api/Bills/create_bill.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(billData),
      );

      final responseJson = jsonDecode(billResponse.body);

      if (billResponse.statusCode == 200 && responseJson['success'] == true) {
        await checkActivePricingBill();

        setState(() {
          hasActiveBill = true;
          billId = responseJson['bill_id'];
          dueAmount = double.tryParse(message) ?? 0.0;
        });
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PayPage(
                  orderId: int.parse(userProvider.user_id), billId: billId!),
            ));
      } else {
        showConfirmationDialog(
          context: context,
          message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          confirmText: 'حسنًا',
          onConfirm: () {},
        );
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسنًا',
        onConfirm: () {},
      );
    }
  }
}
