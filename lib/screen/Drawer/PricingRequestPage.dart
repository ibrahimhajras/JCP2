import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/Inallpage/CustomButton.dart';

class PricingRequestPage extends StatefulWidget {
  const PricingRequestPage({super.key});

  @override
  State<PricingRequestPage> createState() => _PricingRequestPageState();
}

class _PricingRequestPageState extends State<PricingRequestPage> {
  int selectedRequests = 1;
  final TextEditingController messageController = TextEditingController();
  int? limitOfOrder;

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("موافق"),
          ),
        ],
      ),
    );
  }

  Future<int?> getLimitOfOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('limitOfOrder');
  }

  Future<void> _loadLimitOfOrder() async {
    int? retrievedLimitOfOrder = await getLimitOfOrder();
    setState(() {
      limitOfOrder = retrievedLimitOfOrder; // استرجاع القيمة
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLimitOfOrder();
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
                height: size.height * 0.2,
                width: size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [primary1, primary2, primary3],
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
                        text: "طلب تسعير",
                        color: white,
                        size: 22,
                        weight: FontWeight.w700,
                      ),
                      SizedBox(width: size.width * 0.27),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
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
                          height: MediaQuery.of(context).size.height * 0.001),
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
                      ),
                      SizedBox(height: 10),
                      CustomText(
                        text:
                            "يمكنك تفعيل أكثر من طلب تسعير بصلاحية تنتهي بانتهاء عدد الطلبات المدفوعة مع الاحتفاظ بحقك في التسعير المجاني لمرة واحدة في اليوم",
                        size: 14,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.01),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<int>(
                            value: selectedRequests,
                            items: List.generate(20, (index) => index + 1)
                                .map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: CustomText(
                                  text: value.toString(),
                                  size: 20,
                                  weight: FontWeight.bold,
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                selectedRequests = newValue!;
                              });
                            },
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width *
                                0.10, // 10% من عرض الشاشة
                          ),
                          CustomText(
                            text: "حدد عدد الطلبات:",
                            size: 16,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.02, // 2% من ارتفاع الشاشة
                      ),

                      // Display the calculated cost based on the selected number of requests
                      CustomText(
                        text: "JDالتكلفة الإجمالية: ${selectedRequests * 2} ",
                        size: 16,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.03, // 2% من ارتفاع الشاشة
                      ),
                      CustomButton(
                        text: "إرسال طلب",
                        onPressed: () {
                          _submitRequest(selectedRequests.toString(), context);
                        },
                        color: button, // يمكنك تمرير أي لون تريده
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontFamily: "Tajawal",
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomText(
                        text: "رقم الدفع:",
                        size: 18,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.009,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "0796888501",
                            size: 16,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.009,
                          ),
                          IconButton(
                            icon: Icon(Icons.copy, color: Colors.grey),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: "0796888501"));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('تم نسخ رقم الهاتف')),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.009,
                      ),
                      CustomText(
                        text: "طرق الدفع",
                        size: 18,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.009,
                      ),
                      CustomText(
                        text: "من خلال اي فواتيركم من قائمة فاتورتك",
                        size: 14,
                        textAlign: TextAlign.center,
                      ),
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
    final String apiUrl = "https://jordancarpart.com/Api/pricingrequest.php";
    final user = Provider.of<ProfileProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    Map<String, dynamic> requestBody = {
      "name": user.name,
      "user_id": user.user_id,
      "phone": user.phone,
      "message": message,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(requestBody),
      );
      print('Name: ${user.name}');
      print('User ID: ${user.user_id}');
      print('Phone: ${user.phone}');
      print('Message: $message');

      if (response.statusCode == 200) {
        print("Request successful: ${response.body}");
        showModalBottomSheet(
          builder: (context) {
            return _buildSuccessBottomSheet(size);
          },
          context: context,
        );
      } else {
        print("Request failed: ${response.statusCode}");
        _showDialog("خطأ", "حدث خطأ أثناء إرسال طلبك. حاول مرة أخرى.");
      }
    } catch (e) {
      print("Request error: $e");
      _showDialog("خطأ", "حدث خطأ أثناء الاتصال بالخادم.");
    }
  }

  Widget _buildSuccessBottomSheet(Size size) {
    return Container(
      height: 390,
      width: size.width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 15),
            Center(
              child: SvgPicture.asset(
                'assets/svg/line.svg',
                width: 30,
                height: 5,
              ),
            ),
            SizedBox(height: 35),
            Center(
              child: Image.asset(
                "assets/images/done-icon 1.png",
                height: 122,
                width: 122,
              ),
            ),
            SizedBox(height: 25),
            Center(
              child: CustomText(
                text:
                    "تم ارسال طلبك لتسعير\n سوف يتم زيادة الطلبات في اقرب وقت",
                size: 24,
                weight: FontWeight.w700,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            MaterialButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ));
              },
              height: 45,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "رجوع",
                color: white,
                size: 18,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
