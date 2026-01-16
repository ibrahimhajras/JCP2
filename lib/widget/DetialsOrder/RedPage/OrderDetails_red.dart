import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/Pay.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../provider/ProfileProvider.dart';
import '../../../style/colors.dart';
import '../../FullScreenImageViewer.dart';
import '../../update.dart';

class OrderDetailsPage_Orange extends StatefulWidget {
  final Map<String, dynamic> order1;
  final List<dynamic> orderItems;
  final List<dynamic> nameproduct;
  final bool status;

  const OrderDetailsPage_Orange({
    super.key,
    required this.order1,
    required this.orderItems,
    required this.nameproduct,
    required this.status,
  });

  @override
  _OrderDetailsPageState_Orange createState() =>
      _OrderDetailsPageState_Orange();
}

class _OrderDetailsPageState_Orange extends State<OrderDetailsPage_Orange> {
  List<int?> selectedFieldsPerRow = [];
  int selectedOptionIndex = -1;
  double selectedDeliveryCost = 0.0;
  int selectedItemPrice = 0;
  List<Map<String, dynamic>> selectedItems = [];
  int selectedDeliveryType = -1;
  int? lastSelectedIndex;
  bool isExpired = false;
  Map<int, String?> selectedItemIdPerRow = {};
  int totalAmount = 0;
  bool isloadding = false;
  List<dynamic> sortedOrderItems = [];

  @override
  void initState() {
    Update.checkAndUpdate(context);
    selectedFieldsPerRow =
        List.generate(widget.orderItems.length, (index) => null);
    _checkExpiration();
    super.initState();

    Map<String, List<dynamic>> groupedItems = {};

    for (var item in widget.orderItems) {
      String agency = item['agency_product']?['name'] ?? 'شركة';
      String commercial = item['commercial_product']?['name'] ?? 'تجاري';
      String commercial2 = item['commercial2_product']?['name'] ?? 'تجاري2';

      String headerKey = '$agency - $commercial - $commercial2';

      if (!groupedItems.containsKey(headerKey)) {
        groupedItems[headerKey] = [];
      }
      groupedItems[headerKey]!.add(item);
    }

    groupedItems.forEach((key, items) {
      sortedOrderItems.addAll(items);
    });
  }

  void _checkExpiration() {
    if (widget.order1.isNotEmpty && widget.order1['expierdtime'] != null) {
      try {
        final expierdtime = DateTime.parse(widget.order1['expierdtime'].toString());
        setState(() {
          isExpired = DateTime.now().isAfter(expierdtime);
        });
      } catch (e) {
        print("Error parsing date: $e");
      }
    }
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
            backgroundColor: Colors.transparent, child: RotatingImagePage());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  _buildSectionTitle("المركبة"),
                  _buildVehicleInfo(),
                  if (widget.orderItems.isNotEmpty) _buildOrderItemsList(),
                  const SizedBox(height: 30),
                  _buildFooterOptions(widget.order1),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildFooterTotal(),
                        _buildFooterSummary(),
                      ],
                    ),
                  ),
                  SizedBox(height: 6),
                  MaterialButton(
                    onPressed: isExpired ? _handleBack : _handleConfirm,
                    height: 50,
                    minWidth: size.width * 0.9,
                    color: const Color.fromRGBO(195, 29, 29, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: CustomText(
                      text: isExpired ? "رجوع" : "متابعة",
                      color: white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterOptions(Map<String, dynamic> order) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final deliveryshop = int.tryParse(order['deliveryshop'].toString()) ?? 0;
    final deliverynormal =
        int.tryParse(order['deliverynormal'].toString()) ?? 0;
    final deliverynow = int.tryParse(order['deliverynow'].toString()) ?? 0;

    final deliverynormalCost =
        double.tryParse(order['deliverynormalcost'].toString()) ?? 0.0;
    final deliverynowCost =
        double.tryParse(order['deliverynowcost'].toString()) ?? 0.0;

    bool hasMultipleTraders = _checkMultipleTraders();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: screenWidth * 0.02),
          Flexible(
            flex: 1,
            child: SizedBox(
              height: screenWidth * 0.10,
              child: Align(
                alignment: Alignment.center,
                child: CustomText(
                  text: 'التوصيل',
                  color: white,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.01),
          if (deliverynow == 1 && isExpired == false)
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildOptionButton('فوري', 0, deliverynowCost),
              ),
            )
          else
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildFixedRedOptionButton('فوري'),
              ),
            ),
          SizedBox(width: screenWidth * 0.03),
          if (deliverynormal == 1 && isExpired == false)
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildOptionButton('24 ساعة', 1, deliverynormalCost),
              ),
            )
          else
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildFixedRedOptionButton('24 ساعة'),
              ),
            ),
          SizedBox(width: screenWidth * 0.03),
          if (deliveryshop == 1 && isExpired == false && !hasMultipleTraders)
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildOptionButton('استلام من المحل', 2, 0.0),
              ),
            )
          else
            Flexible(
              flex: 1,
              child: Align(
                alignment: Alignment.center,
                child: buildFixedRedOptionButton('استلام من المحل'),
              ),
            ),
          SizedBox(width: screenWidth * 0.02),
          Flexible(
            flex: 2,
            child: SizedBox(
              height: screenWidth * 0.10,
              child: Align(
                alignment: Alignment.center,
                child: CustomText(
                  text: 'التوصيل',
                  color: black,
                  weight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
        ],
      ),
    );
  }

  bool _checkMultipleTraders() {
    String userCity = widget.order1['user_city'] ?? '';
    String normalizedUserCity = _normalizeArabicText(userCity);

    for (int i = 0; i < selectedFieldsPerRow.length; i++) {
      int? selectedFieldIndex = selectedFieldsPerRow[i];

      if (selectedFieldIndex != null) {
        final selectedOrderItem = widget.orderItems[i];
        String selectedPriceType;

        switch (selectedFieldIndex) {
          case 0:
            selectedPriceType = 'commercial_product';
            break;
          case 1:
            selectedPriceType = 'agency_product';
            break;
          case 2:
            selectedPriceType = 'commercial2_product';
            break;
          default:
            selectedPriceType = 'agency_product';
        }

        if (selectedOrderItem[selectedPriceType] != null) {
          String traderCity =
              selectedOrderItem[selectedPriceType]['trader_city']?.toString() ??
                  '';

          if (traderCity.isNotEmpty) {
            String normalizedTraderCity = _normalizeArabicText(traderCity);

            if (normalizedTraderCity != normalizedUserCity) {
              print(
                  "❌ التاجر من $traderCity، العميل من $userCity - استلام من المحل ممنوع!");
              return true;
            }
          }
        }
      }
    }

    print(
        "✅ جميع التجار من نفس محافظة العميل ($userCity) - استلام من المحل متاح!");
    return false;
  }

  String _normalizeArabicText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ء', '');
  }

  Widget buildOptionButton(String label, int index, double cost) {
    bool isDisabled = (index == 2 && _checkMultipleTraders());

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          MSHCheckbox(
            size: 40,
            value: isDisabled ? false : selectedOptionIndex == index,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: isDisabled ? const Color(0xFF8D8D92) : green,
              uncheckedColor: const Color(0xFF8D8D92),
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (value) {
              if (!isDisabled) {
                setState(() {
                  selectedOptionIndex = index;
                  selectedDeliveryCost = cost;
                  selectedDeliveryType = index;
                });
              } else {}
            },
          ),
          const SizedBox(height: 10),
          CustomText(
            text: label,
            color: isDisabled
                ? const Color(0xFF8D8D92)
                : (selectedOptionIndex == index
                ? green
                : const Color(0xFF8D8D92)),
          ),
        ],
      ),
    );
  }

  Widget buildFixedRedOptionButton(String label) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          MSHCheckbox(
            size: 40,
            value: true,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: const Color(0xFF8D8D92),
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (selected) {},
          ),
          const SizedBox(height: 10),
          CustomText(
            text: label,
            color: const Color(0xFF8D8D92),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSummary() {
    double totalCost = 0.0;
    Set<int> uniqueTraders = <int>{};
    Map<int, Map<String, dynamic>> traderPaymentInfo = {};

    for (int i = 0; i < selectedFieldsPerRow.length; i++) {
      int? selectedFieldIndex = selectedFieldsPerRow[i];

      if (selectedFieldIndex != null) {
        final selectedOrderItem = widget.orderItems[i];
        String selectedPriceType;

        switch (selectedFieldIndex) {
          case 0:
            selectedPriceType = 'commercial_product';
            break;
          case 1:
            selectedPriceType = 'agency_product';
            break;
          case 2:
            selectedPriceType = 'commercial2_product';
            break;
          default:
            selectedPriceType = 'agency_product';
        }

        if (selectedOrderItem[selectedPriceType] != null &&
            selectedOrderItem[selectedPriceType]['price'] != null) {
          double price = double.tryParse(
              selectedOrderItem[selectedPriceType]['price'].toString()) ??
              0.0;
          double finalPrice = (price + (price * 0.08)).ceil().toDouble();
          totalCost += finalPrice;

          int traderId = selectedOrderItem[selectedPriceType]['user_id'] ?? 0;
          if (traderId != 0) {
            uniqueTraders.add(traderId);
            traderPaymentInfo[traderId] = {
              'trader_city': selectedOrderItem[selectedPriceType]
              ['trader_city'],
              'payment_info': selectedOrderItem[selectedPriceType]
              ['payment_info'],
            };
          }
        }
      }
    }

    double deliveryCost = 0.0;
    String userCity = widget.order1['user_city'] ?? '';

    for (int traderId in uniqueTraders) {
      if (traderPaymentInfo.containsKey(traderId)) {
        String traderCity = traderPaymentInfo[traderId]!['trader_city'] ?? '';
        Map<String, dynamic> paymentInfo =
            traderPaymentInfo[traderId]!['payment_info'] ?? {};

        double traderDeliveryCost = 0.0;

        if (selectedDeliveryType != -1) {
          bool isInsideCity =
              userCity.toLowerCase() == traderCity.toLowerCase();

          if (selectedDeliveryType == 0) {
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['urgent_payment_inside']
                : paymentInfo['urgent_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          } else if (selectedDeliveryType == 1) {
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['normal_payment_inside']
                : paymentInfo['normal_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          }
        }

        deliveryCost += traderDeliveryCost;
        print(
            "   📍 نفس المدينة: ${userCity.toLowerCase() == traderCity.toLowerCase()}");
      }
    }

    totalCost += deliveryCost;
    totalAmount = totalCost.toInt();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار أردني فقط لا غير",
                size: 18,
              ),
              CustomText(
                text: " $totalAmount",
                size: 18,
              ),
            ],
          ),
          CustomText(
            text: "  المجموع",
            color: red,
            weight: FontWeight.w900,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterTotal() {
    double deliveryCost = 0.0;
    Set<int> uniqueTraders = <int>{};
    Map<int, Map<String, dynamic>> traderPaymentInfo = {};

    for (int i = 0; i < selectedFieldsPerRow.length; i++) {
      int? selectedFieldIndex = selectedFieldsPerRow[i];

      if (selectedFieldIndex != null) {
        final selectedOrderItem = widget.orderItems[i];
        String selectedPriceType;

        switch (selectedFieldIndex) {
          case 0:
            selectedPriceType = 'commercial_product';
            break;
          case 1:
            selectedPriceType = 'agency_product';
            break;
          case 2:
            selectedPriceType = 'commercial2_product';
            break;
          default:
            selectedPriceType = 'agency_product';
        }

        if (selectedOrderItem[selectedPriceType] != null) {
          int traderId = selectedOrderItem[selectedPriceType]['user_id'] ?? 0;
          if (traderId != 0) {
            uniqueTraders.add(traderId);
            traderPaymentInfo[traderId] = {
              'trader_city': selectedOrderItem[selectedPriceType]
              ['trader_city'],
              'payment_info': selectedOrderItem[selectedPriceType]
              ['payment_info'],
            };
          }
        }
      }
    }

    String userCity = widget.order1['user_city'] ?? '';

    for (int traderId in uniqueTraders) {
      if (traderPaymentInfo.containsKey(traderId)) {
        String traderCity = traderPaymentInfo[traderId]!['trader_city'] ?? '';
        Map<String, dynamic> paymentInfo =
            traderPaymentInfo[traderId]!['payment_info'] ?? {};

        double traderDeliveryCost = 0.0;

        if (selectedDeliveryType != -1) {
          bool isInsideCity =
              userCity.toLowerCase() == traderCity.toLowerCase();

          if (selectedDeliveryType == 0) {
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['urgent_payment_inside']
                : paymentInfo['urgent_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          } else if (selectedDeliveryType == 1) {
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['normal_payment_inside']
                : paymentInfo['normal_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          }
        }

        deliveryCost += traderDeliveryCost;
      }
    }

    int deliveryCostInt = deliveryCost.toInt();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار اردني  ",
                size: 18,
              ),
              CustomText(
                text: "$deliveryCostInt",
                size: 18,
              ),
            ],
          ),
          CustomText(
            text: "  التوصيل",
            color: red,
            weight: FontWeight.w900,
            size: 18,
          ),
        ],
      ),
    );
  }

  void _handleConfirm() async {
    final user =
    Provider.of<ProfileProvider>(context, listen: false).name.toString();
    List<Map<String, dynamic>> selectedItems = [];

    Set<int> uniqueTraders = <int>{};
    Map<int, Map<String, dynamic>> traderPaymentInfo = {};
    double totalProductCost = 0.0;

    for (int i = 0; i < selectedFieldsPerRow.length; i++) {
      int? selectedFieldIndex = selectedFieldsPerRow[i];
      if (selectedFieldIndex != null) {
        final selectedOrderItem = widget.orderItems[i];
        String selectedPriceType;
        String selectedItemId = '';

        switch (selectedFieldIndex) {
          case 0:
            selectedPriceType = 'commercial_product';
            selectedItemId =
                selectedOrderItem['commercial_product']?['id'].toString() ?? '';
            break;
          case 1:
            selectedPriceType = 'agency_product';
            selectedItemId =
                selectedOrderItem['agency_product']?['id'].toString() ?? '';
            break;
          case 2:
            selectedPriceType = 'commercial2_product';
            selectedItemId =
                selectedOrderItem['commercial2_product']?['id'].toString() ??
                    '';
            break;
          default:
            selectedPriceType = 'agency_product';
        }

        selectedItems.add({
          "itemid": selectedOrderItem['itemid'],
          "detid": selectedItemId,
        });

        // ✅ حساب سعر القطعة وإضافة معلومات التاجر
        if (selectedOrderItem[selectedPriceType] != null &&
            selectedOrderItem[selectedPriceType]['price'] != null) {
          double price = double.tryParse(
              selectedOrderItem[selectedPriceType]['price'].toString()) ??
              0.0;
          double finalPrice = (price + (price * 0.08)).ceil().toDouble();
          totalProductCost += finalPrice;

          int traderId = selectedOrderItem[selectedPriceType]['user_id'] ?? 0;
          if (traderId != 0) {
            uniqueTraders.add(traderId);
            traderPaymentInfo[traderId] = {
              'trader_city': selectedOrderItem[selectedPriceType]
              ['trader_city'],
              'payment_info': selectedOrderItem[selectedPriceType]
              ['payment_info'],
            };
          }
        }
      }
    }

    if (selectedItems.isEmpty) {
      showConfirmationDialog(
        context: context,
        message: '!يرجى اختيار قطعة واحدة على الأقل قبل المتابعة',
        confirmText: 'موافق',
        onConfirm: () {},
      );
      return;
    }

    if (selectedDeliveryType == -1) {
      showConfirmationDialog(
        context: context,
        message: '.يرجى اختيار نوع التوصيل قبل متابعة الطلب',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
      return;
    }

    double calculatedDeliveryCost = 0.0;
    String userCity = widget.order1['user_city'] ?? '';
    List<Map<String, dynamic>> deliveryDetails = [];

    for (int traderId in uniqueTraders) {
      if (traderPaymentInfo.containsKey(traderId)) {
        String traderCity = traderPaymentInfo[traderId]!['trader_city'] ?? '';
        Map<String, dynamic> paymentInfo =
            traderPaymentInfo[traderId]!['payment_info'] ?? {};

        double traderDeliveryCost = 0.0;
        String deliveryLocation = '';
        String deliverySpeed = '';

        if (selectedDeliveryType != 2) {
          bool isInsideCity =
              userCity.toLowerCase() == traderCity.toLowerCase();
          deliveryLocation = isInsideCity ? 'inside' : 'outside';

          if (selectedDeliveryType == 0) {
            // فوري
            deliverySpeed = 'urgent';
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['urgent_payment_inside']
                : paymentInfo['urgent_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          } else if (selectedDeliveryType == 1) {
            // 24 ساعة
            deliverySpeed = 'normal';
            traderDeliveryCost = double.tryParse((isInsideCity
                ? paymentInfo['normal_payment_inside']
                : paymentInfo['normal_payment_outside'])
                ?.toString() ??
                '0') ??
                0.0;
          }
        } else {
          deliveryLocation = 'pickup';
          deliverySpeed = 'pickup';
          traderDeliveryCost = 0.0;
        }

        calculatedDeliveryCost += traderDeliveryCost;

        deliveryDetails.add({
          'trader_id': traderId,
          'trader_city': traderCity,
          'user_city': userCity,
          'delivery_location': deliveryLocation,
          'delivery_speed': deliverySpeed,
          'delivery_cost': traderDeliveryCost,
        });
      }
    }

    double totalCostCalculated = totalProductCost + calculatedDeliveryCost;

    setState(() {
      isloadding = true;
    });
    _showLoadingDialog();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final orderData = {
      "orderId": widget.order1['orderid'],
      "userId": widget.order1['userid'],
      "totalCost": totalCostCalculated.toInt(),
      "deliveryType": selectedDeliveryType == 0
          ? 'فوري'
          : selectedDeliveryType == 1
          ? '24 ساعة'
          : 'استلام من المحل',
      "deliveryCost": calculatedDeliveryCost,
      "deliveryDetails": deliveryDetails,
      "tradersCount": uniqueTraders.length,
      "userCity": userCity,
      "timeorder": widget.order1['timeorder'],
      "Enginesize": widget.order1['Enginesize'],
      "Fueltype": widget.order1['Fueltype'],
      "Engineyear": widget.order1['Engineyear'],
      "Enginecategory": widget.order1['Enginecategory'],
      "Enginetype": widget.order1['Enginetype'],
      "bodyid": widget.order1['bodyid'],
      "paymentMethod": "wait",
      "selectedItems": selectedItems,
      'token': token,
    };

    Navigator.of(context).pop();

    final response = await http.post(
      Uri.parse('https://jordancarpart.com/Api/setAcceptedOrder2.php'),
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      setState(() {
        isloadding = false;
      });

      if (responseBody['status'] == 'error') {
        String errorMessage = responseBody['message'] ??
            "حدث خطأ غير معروف، يرجى المحاولة مرة أخرى.";

        if (errorMessage.contains("الكمية غير متوفرة")) {
          setState(() {
            isloadding = false;
          });
          showConfirmationDialog(
            context: context,
            message:
            "المنتج الذي تحاول طلبه غير متوفر حاليًا، يرجى اختيار منتج آخر",
            confirmText: 'حسنًا',
            onConfirm: () {},
          );
        } else {
          setState(() {
            isloadding = false;
          });
          showConfirmationDialog(
            context: context,
            message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
            confirmText: 'حسناً',
            onConfirm: () {
              Navigator.pop(context);
            },
          );
        }
      } else {
        setState(() {
          isloadding = false;
        });
        await http.get(
          Uri.parse(
            'https://jordancarpart.com/Api/deletePricedNotification.php?order_id=${widget.order1['orderid']}',
          ),
        );
        final billData = {
          "order_id": widget.order1['orderid'],
          "cust_name": user,
          "user_id": Provider.of<ProfileProvider>(context, listen: false)
              .user_id, // ✅ تمت الإضافة هنا
          "due_amount": totalCostCalculated.toInt(),
          "service_type": "Pay_bill",
          "bill_type": "OneOff",
          "bill_status": "BillNew",
          "status": "order",
          "bill_category": "normal",
        };

        final billResponse = await http.post(
          Uri.parse('https://jordancarpart.com/Api/Bills/create_bill.php'),
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(billData),
        );

        final billResponseData = jsonDecode(billResponse.body);
        final int billId = billResponseData['bill_id'];

        if (billResponse.statusCode != 200 ||
            billResponseData['success'] != true) {
          Navigator.of(context).pop();
          showConfirmationDialog(
            context: context,
            message: "يرجى المحاولة لاحقًا.",
            confirmText: "حسنًا",
            onConfirm: () {},
          );
          return;
        }
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PayPage(
                orderId: widget.order1['orderid'],
                billId: billId,
              ),
            ));
      }
    } else {
      showConfirmationDialog(
        context: context,
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسناً',
        onConfirm: () {
          Navigator.pop(context);
        },
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: title,
          size: 18,
          weight: FontWeight.bold,
          color: Colors.black,
        ),
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

  Widget _buildVehicleInfo() {
    if (widget.order1.isEmpty) return Container();

    final vehicleData = widget.order1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    color: Color(0xFF8D8D92),
                    text: "${vehicleData["Enginetype"]} "
                        "${vehicleData["Enginecategory"]} "
                        "${vehicleData["Engineyear"]} "
                        "${vehicleData["Fueltype"]} "
                        "${vehicleData["Enginesize"] == "N/A" ? "" : vehicleData["Enginesize"]}",
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildOrderItemsList() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.orderItems.length,
          itemBuilder: (context, index) {
            final orderItem = widget.orderItems[index];

            String orderItemName = orderItem['agency_product']?['product_name']
                ?.toString() ??
                orderItem['commercial_product']?['product_name']?.toString() ??
                orderItem['commercial2_product']?['product_name']?.toString() ??
                widget.nameproduct[index];

            String commercial2Price =
            getDisplayText(orderItem['commercial2_product']);

            String commercialPrice =
            getDisplayText(orderItem['commercial_product']);

            String agencyPrice = getDisplayText(orderItem['agency_product']);

            bool areSameAsPrevious = index > 0 &&
                widget.orderItems[index]['commercial2_product']?['name'] ==
                    widget.orderItems[index - 1]['commercial2_product']
                    ?['name'] &&
                widget.orderItems[index]['commercial_product']?['name'] ==
                    widget.orderItems[index - 1]['commercial_product']
                    ?['name'] &&
                widget.orderItems[index]['agency_product']?['name'] ==
                    widget.orderItems[index - 1]['agency_product']?['name'];

            String commercial2Price1 = areSameAsPrevious
                ? "1"
                : widget.orderItems[index]['commercial2_product']?['name'] ??
                'مستعمل';

            String commercialPrice1 = areSameAsPrevious
                ? "1"
                : widget.orderItems[index]['commercial_product']?['name'] ??
                'تجاري';

            String agencyPrice1 = areSameAsPrevious
                ? "1"
                : widget.orderItems[index]['agency_product']?['name'] ?? 'شركة';

            return Column(
              children: [
                if (!areSameAsPrevious)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              agencyPrice1,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Tajawal",
                                fontWeight: FontWeight.bold,
                                fontSize: max(
                                  10,
                                  min(
                                      screenWidth * 0.035,
                                      screenWidth /
                                          (commercial2Price1.length + 8)),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              (commercial2Price1).replaceAll(' ', '\n'),
                              style: TextStyle(
                                fontFamily: "Tajawal",
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: max(
                                  10,
                                  min(
                                      screenWidth * 0.030,
                                      screenWidth /
                                          (commercial2Price1.length + 8)),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              (commercialPrice1).replaceAll(' ', '\n'),
                              style: TextStyle(
                                fontFamily: "Tajawal",
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: max(
                                  10,
                                  min(
                                      screenWidth * 0.030,
                                      screenWidth /
                                          (commercial2Price1.length + 8)),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Flexible(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          height: screenWidth * 0.10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              (agencyPrice1).replaceAll(' ', '\n'),
                              style: TextStyle(
                                fontFamily: "Tajawal",
                                color: black,
                                fontWeight: FontWeight.bold,
                                fontSize: max(
                                  10,
                                  min(
                                      screenWidth * 0.030,
                                      screenWidth /
                                          (commercial2Price1.length + 8)),
                                ),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.visible,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Flexible(
                        flex: 2,
                        child: SizedBox(
                          height: screenWidth * 0.10,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: index == 0
                                ? IconButton(
                              icon: Image.asset(
                                (selectedItemIdPerRow.values
                                    .any((id) => id != null))
                                    ? 'assets/images/iconinfo.png'
                                    : 'assets/images/iconinfo2.png',
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                errorBuilder:
                                    (context, error, stackTrace) {
                                  return Icon(Icons.info, color: red);
                                },
                              ),
                              onPressed: () {
                                print(
                                    "📢 البيانات المخزنة: $selectedItemIdPerRow");

                                List<int> keys = selectedItemIdPerRow.keys
                                    .toList()
                                  ..sort();
                                String? lastSelectedId;
                                for (int i = keys.length - 1;
                                i >= 0;
                                i--) {
                                  int key = keys[i];
                                  if (selectedItemIdPerRow[key] != null) {
                                    lastSelectedId =
                                    selectedItemIdPerRow[key];
                                    break;
                                  }
                                }

                                if (lastSelectedId == null) {
                                  return;
                                }

                                print(
                                    "🟢 آخر ID غير فارغ: $lastSelectedId");

                                Map<String, dynamic>? selectedProduct;
                                String productType = '';
                                int orderItemId = 0;
                                for (var item in widget.orderItems) {
                                  if (item['agency_product']?['id']
                                      .toString() ==
                                      lastSelectedId) {
                                    selectedProduct =
                                    item['agency_product'];
                                    productType = 'agency';
                                    orderItemId = item['id'] ?? 0;
                                    break;
                                  }
                                  if (item['commercial_product']?['id']
                                      .toString() ==
                                      lastSelectedId) {
                                    selectedProduct =
                                    item['commercial_product'];
                                    productType = 'commercial';
                                    orderItemId = item['id'] ?? 0;
                                    break;
                                  }
                                  if (item['commercial2_product']?['id']
                                      .toString() ==
                                      lastSelectedId) {
                                    selectedProduct =
                                    item['commercial2_product'];
                                    productType = 'commercial2';
                                    orderItemId = item['id'] ?? 0;
                                    break;
                                  }
                                }

                                if (selectedProduct == null) {
                                  print(
                                      "🚨 لم يتم العثور على منتج مطابق!");
                                  return;
                                }

                                int warranty =
                                    selectedProduct['warranty'] ?? 0;
                                String note = selectedProduct['note'] ??
                                    "لا توجد ملاحظات";
                                int number =
                                    selectedProduct['number'] ?? 1;
                                String mark = selectedProduct['mark'] ??
                                    "غير متوفر";
                                String imageUrl =
                                selectedProduct['img'] != null
                                    ? '${selectedProduct['img']}'
                                    : "";

                                double parsedItemPrice = double.tryParse(
                                    selectedProduct['price']
                                        ?.toString() ??
                                        "0") ??
                                    0.0;

                                print(
                                    "💰 السعر: ${parsedItemPrice.toInt()}");

                                _showDetailsDialog(
                                  itemPrice: parsedItemPrice.toInt(),
                                  warranty: warranty,
                                  note: note,
                                  imageUrl: imageUrl,
                                  mark: mark,
                                  number: number,
                                  traderId: selectedProduct['user_id'] ?? 0,
                                  productId: selectedProduct['id'] ?? 0,
                                  productType: productType,
                                  productName: selectedProduct['product_name'] ?? '',
                                  orderId: widget.order1['orderid'] ?? 0,
                                  orderItemId: orderItemId,
                                  userId: widget.order1['userid'] ?? 0,
                                );
                              },
                            )
                                : CustomText(
                              text: 'تجاري',
                              color: Colors.white,
                              weight: FontWeight.bold,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                    ],
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: screenWidth * 0.02),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Image.asset(
                            'assets/images/02.png',
                            width: double.infinity,
                            height: screenWidth * 0.05,
                          ),
                          onPressed: () {
                            _confirmDeletion(index);
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Expanded(
                        flex: 1,
                        child: buildTextField(commercial2Price, index, 2),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        flex: 1,
                        child: buildTextField(commercialPrice, index, 0),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        flex: 1,
                        child: buildTextField(agencyPrice, index, 1),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomText(
                            text: orderItemName,
                            color: black,
                            size: 14,
                            weight: FontWeight.bold,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _confirmDeletion(int index) {
    if (widget.orderItems.length <= 1) {
      showConfirmationDialog(
        context: context,
        message: 'لا يمكنك حذف هذا العنصر لأنه العنصر الوحيد المتبقي',
        confirmText: 'حسنًا',
        onConfirm: () {},
      );
    } else {
      showConfirmationDialog(
        context: context,
        message: 'هل ترغب في حذف هذا العنصر؟',
        confirmText: 'نعم',
        onConfirm: () {
          setState(() {
            widget.orderItems.removeAt(index);
            selectedFieldsPerRow.removeAt(index);
            if (lastSelectedIndex == index) {
              lastSelectedIndex = null;
            } else if (lastSelectedIndex != null &&
                lastSelectedIndex! > index) {
              lastSelectedIndex = lastSelectedIndex! - 1;
            }
          });
        },
        cancelText: 'لا',
        onCancel: () {},
      );
    }
  }

  String getDisplayText(Map<String, dynamic>? product) {
    if (product == null) return "غ.م";

    double? price = double.tryParse(product['price']?.toString() ?? '0');
    int? amount = int.tryParse(product['amount']?.toString() ?? '0');
    int? active = int.tryParse(product['active']?.toString() ?? '0');
    int? flagactive = int.tryParse(product['delete_flag']?.toString() ?? '0');
    int? type = int.tryParse(product['user_type']?.toString() ?? '1');
    int? traderStatus = int.tryParse(product['trader_status_active']?.toString() ?? '1');

    if (price == null || price == 0 || active == 0 || flagactive == 1) {
      return "غ.م";
    }

    if (traderStatus == 0) {
      return "نفذت";
    }

    if (type == 1) {
      return "غ.م";
    }

    if (amount == 0) {
      return "نفذت";
    }

    double finalPrice = (price + (price * 0.08)).ceil().toDouble();

    return finalPrice.toInt().toString();
  }

  Widget buildTextField(String hintText, int rowIndex, int fieldIndex) {
    bool isForbidden = hintText == 'غ.م' || isExpired || hintText == "نفذت";
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

    return GestureDetector(
      onTap: isForbidden
          ? null
          : () {
        setState(() {
          if (selectedFieldsPerRow[rowIndex] == fieldIndex) {
            selectedFieldsPerRow[rowIndex] = null;
            selectedItemIdPerRow[rowIndex] = null;
          } else {
            selectedFieldsPerRow[rowIndex] = fieldIndex;
            String selectedPriceType;
            switch (fieldIndex) {
              case 0:
                selectedPriceType = 'commercial_product';
                break;
              case 1:
                selectedPriceType = 'agency_product';
                break;
              case 2:
                selectedPriceType = 'commercial2_product';
                break;
              default:
                selectedPriceType = 'agency_product';
            }
            final selectedOrderItem = widget.orderItems[rowIndex];
            final selectedProduct = selectedOrderItem[selectedPriceType];

            if (selectedProduct != null) {
              selectedItemIdPerRow[rowIndex] =
                  selectedProduct['id'].toString();
              print(
                  "✅ تم تخزين ID: ${selectedItemIdPerRow[rowIndex]} للصف $rowIndex");
            }
          }

          if (selectedDeliveryType == 2 && _checkMultipleTraders()) {
            selectedDeliveryType = -1;
            selectedOptionIndex = -1;
            selectedDeliveryCost = 0.0;
            print(
                "🚫 تم إلغاء اختيار 'استلام من المحل' بسبب وجود تجار متعددين");
          }
        });
      },
      onLongPress: isForbidden
          ? null
          : () {
        final selectedOrderItem = widget.orderItems[rowIndex];
        String selectedPriceType;
        switch (fieldIndex) {
          case 0:
            selectedPriceType = 'commercial_product';
            break;
          case 1:
            selectedPriceType = 'agency_product';
            break;
          case 2:
            selectedPriceType = 'commercial2_product';
            break;
          default:
            selectedPriceType = 'agency_product';
        }

        try {
          final selectedProduct = selectedOrderItem[selectedPriceType];
          if (selectedProduct == null) {
            showConfirmationDialog(
              context: context,
              message: 'لم يتم العثور على بيانات للمنتج المحدد.',
              confirmText: 'موافق',
              onConfirm: () {},
            );
            return;
          }

          double itemPrice = double.tryParse(
              selectedProduct['price']?.toString().trim() ?? '0') ??
              0;
          int parsedItemPrice = itemPrice.toInt();

          String warrantyString =
              selectedProduct['warranty']?.toString().trim() ?? '0';
          int warranty = int.tryParse(warrantyString) ?? 0;

          String note = selectedProduct['note']?.toString().trim() ??
              'لا توجد ملاحظات';
          String imageUrl =
              selectedProduct['img']?.toString().trim() ?? '';
          String mark =
              selectedProduct['mark']?.toString().trim() ?? 'غ.م';
          int number = selectedProduct['number'] ?? 1;

          String productType;
          switch (fieldIndex) {
            case 0:
              productType = 'commercial';
              break;
            case 1:
              productType = 'agency';
              break;
            case 2:
              productType = 'commercial2';
              break;
            default:
              productType = 'agency';
          }

          _showDetailsDialog(
            itemPrice: parsedItemPrice,
            warranty: warranty,
            note: note,
            imageUrl: imageUrl,
            mark: mark,
            number: number,
            traderId: selectedProduct['user_id'] ?? 0,
            productId: selectedProduct['id'] ?? 0,
            productType: productType,
            productName: selectedProduct['product_name'] ?? '',
            orderId: widget.order1['orderid'] ?? 0,
            orderItemId: selectedOrderItem['id'] ?? 0,
            userId: widget.order1['userid'] ?? 0,
          );
        } catch (e) {
          showConfirmationDialog(
            context: context,
            message: 'حدث خطأ أثناء معالجة البيانات.',
            confirmText: 'موافق',
            onConfirm: () {},
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: screenHeight * 0.06,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isForbidden
                ? Colors.white
                : (selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: hintText,
            size: 14,
            weight: FontWeight.w700,
            color: isForbidden
                ? Colors.black26
                : (selectedFieldsPerRow[rowIndex] == fieldIndex
                ? Colors.white
                : Color(0xFF8D8D92)),
          ),
        ),
      ),
    );
  }

  bool _isRequestingImage = false;

  Future<void> _requestImage({
    required int traderId,
    required int productId,
    required String productType,
    required String productName,
    required int orderId,
    required int orderItemId,
    required int userId,
  }) async {
    if (_isRequestingImage) return;

    setState(() {
      _isRequestingImage = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/request_image.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': orderId,
          'order_item_id': orderItemId,
          'trader_id': traderId,
          'user_id': userId,
          'product_id': productId,
          'product_type': productType,
          'product_name': productName,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: 'تم إرسال طلب الصورة للتاجر بنجاح',
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            backgroundColor: green,
          ),
        );
        Navigator.of(context).pop(); // Close the dialog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: data['message'] ?? 'حدث خطأ',
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            backgroundColor: red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: 'حدث خطأ في الاتصال',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          backgroundColor: red,
        ),
      );
    } finally {
      setState(() {
        _isRequestingImage = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _checkImageRequestStatus(int productId, int traderId) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/check_image_request_status.php?product_id=$productId&trader_id=$traderId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Error checking image request status: $e");
    }
    return null;
  }

  void _showDetailsDialog({
    required int itemPrice,
    required int warranty,
    required String note,
    required String mark,
    required String imageUrl,
    required int number,
    required int traderId,
    required int productId,
    required String productType,
    required String productName,
    required int orderId,
    required int orderItemId,
    required int userId,
  }) async {
    // Check status before showing dialog
    String? requestStatus;
    bool showButton = true;

    if (imageUrl.isEmpty) {
      final statusData = await _checkImageRequestStatus(productId, traderId);
      if (statusData != null && statusData['status'] == 'success') {
        requestStatus = statusData['request_status'];
        showButton = statusData['show_button'] ?? true;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) => Dialog(
            backgroundColor: grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                  color: words,
                ),
                borderRadius: BorderRadius.circular(10),
                color: grey,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              CustomText(text: "الكفالة"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomText(
                                    text: warranty == 0 ? "غير محدد" : "يوم",
                                    color: words,
                                  ),
                                  SizedBox(width: 2),
                                  warranty == 0
                                      ? SizedBox() // ما نعرض الرقم
                                      : CustomText(
                                    text: warranty.toString(),
                                    color: words,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CustomText(text: "الكمية"),
                              CustomText(
                                text: number.toString(),
                                color: words,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CustomText(text: "العلامة التجارية"),
                              CustomText(
                                text: (mark != null && mark.trim().isNotEmpty)
                                    ? mark
                                    : "غير محدد",
                                color: words,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (imageUrl.isNotEmpty)
                          _buildImageRow(
                              "", 'https://jordancarpart.com/$imageUrl')
                        else if (requestStatus == 'rejected')
                          CustomText(
                            text: "غير متوفر",
                            color: red,
                            weight: FontWeight.bold,
                          )
                        else if (requestStatus == 'pending')
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomText(
                                text: "تم إرسال الطلب",
                                color: Colors.orange,
                                weight: FontWeight.bold,
                              ),
                            )
                          else if (showButton)
                              ElevatedButton.icon(
                                onPressed: _isRequestingImage
                                    ? null
                                    : () => _requestImage(
                                  traderId: traderId,
                                  productId: productId,
                                  productType: productType,
                                  productName: productName,
                                  orderId: orderId,
                                  orderItemId: orderItemId,
                                  userId: userId,
                                ),
                                label: Text(
                                  _isRequestingImage ? "جاري الإرسال..." : "طلب صورة",
                                  style: TextStyle(
                                    fontFamily: 'Tajawal',
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              )
                            else
                              CustomText(
                                text: "غير متوفر",
                                color: words,
                              ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomText(
                            text: note.isNotEmpty ? note : "لا يوجد ملاحظات",
                            color: words,
                          ),
                        ),
                        CustomText(text: "الملاحظات"),
                      ],
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageRow(String label, String? imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        imageUrl != null && imageUrl.isNotEmpty
            ? GestureDetector(
          onTap: () {
            _showImageDialog(imageUrl);
          },
          child: Image.network(
            imageUrl,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: RotatingImagePage(),
              );
            },
            errorBuilder: (BuildContext context, Object error,
                StackTrace? stackTrace) {
              return const Text(
                "لا توجد صورة",
                style: TextStyle(fontSize: 16),
              );
            },
          ),
        )
            : const Text(
          "لا توجد صورة",
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullScreenImageViewer(imageUrl: imageUrl);
      },
    );
  }
}
