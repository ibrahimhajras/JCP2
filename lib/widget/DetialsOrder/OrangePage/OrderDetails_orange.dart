import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/NotificationService.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../style/colors.dart';

class OrderDetailsPage_Orange extends StatefulWidget {
  final List<dynamic> order1;
  final List<dynamic> orderItems;

  const OrderDetailsPage_Orange({
    super.key,
    required this.order1,
    required this.orderItems,
  });

  @override
  _OrderDetailsPageState_Orange createState() =>
      _OrderDetailsPageState_Orange();
}

class _OrderDetailsPageState_Orange extends State<OrderDetailsPage_Orange> {
  List<int?> selectedFieldsPerRow = [];
  int selectedOptionIndex = -1;
  double selectedDeliveryCost = 0.0;
  int selectedItemPrice = 00;
  List<Map<String, dynamic>> selectedItems = [];
  int selectedDeliveryType = -1;
  int? lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    selectedFieldsPerRow =
        List.generate(widget.orderItems.length, (index) => null);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(size),
            SizedBox(height: size.height * 0.01),
            _buildSectionTitle("المركبة"),
            _buildVehicleInfo(),
            SizedBox(height: size.height * 0.01),
            if (widget.orderItems.isNotEmpty) _buildOrderItemsList(),
            SizedBox(height: 30),
            _buildFooterOptions(widget.order1),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Divider(height: 2),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildFooterTotal(),
                  _buildFooterSummary(),
                ],
              ),
            ),
            SizedBox(height: 6),
            MaterialButton(
              onPressed: _handleConfirm,
              height: 50,
              minWidth: size.width * 0.9,
              color: Color.fromRGBO(195, 29, 29, 1),
              child: CustomText(
                text: "تاكيد",
                color: white,
                size: 16,
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.20,
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
              text: "تفاصيل الطلب",
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
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
    );
  }

  Widget _buildVehicleInfo() {
    if (widget.order1.isEmpty) return Container();
    final vehicleData = widget.order1[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: vehicleData["Enginetype"].toString() +
                        "  " +
                        vehicleData["Enginecategory"].toString() +
                        "  " +
                        vehicleData["Fueltype"].toString() +
                        " " +
                        vehicleData["Engineyear"].toString() +
                        "  " +
                        vehicleData["Enginesize"].toString(),
                  ),
                ],
              ),
              CustomText(
                text: vehicleData['bodyid'],
                color: black,
                letters: true,
              )
            ],
          )),
    );
  }

  Widget _buildOrderItemsList() {
    final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة
    final screenWidth = size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
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
                    child: CustomText(
                      text: widget.orderItems[0]['commercial2name'] ?? '',
                      color: Colors.white,
                      weight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.01),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // أخذ العرض الكامل
                  height: screenWidth * 0.10,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomText(
                      text: widget.orderItems[0]['commercial2name'] ?? '',
                      color: black,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // أخذ العرض الكامل
                  height: screenWidth * 0.10,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomText(
                      text: 'تجاري',
                      color: black,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity, // أخذ العرض الكامل
                  height: screenWidth * 0.10,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomText(
                      text: 'شركة',
                      color: black,
                      weight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Flexible(
                flex: 2, // نفس flex في كلا الحالتين
                child: SizedBox(
                  height: screenWidth * 0.10, // نفس الارتفاع في كلا الحالتين
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: lastSelectedIndex != null &&
                            selectedFieldsPerRow[lastSelectedIndex!] != null
                        ? IconButton(
                            icon: Image.asset(
                              'assets/images/iconinfo.png',
                              width: double.infinity, // عرض كامل
                            ),
                            onPressed: () {
                              final selectedOrderItem =
                                  widget.orderItems[lastSelectedIndex!];
                              int? selectedFieldIndex =
                                  selectedFieldsPerRow[lastSelectedIndex!];

                              if (selectedFieldIndex != null) {
                                String selectedPriceType;
                                switch (selectedFieldIndex) {
                                  case 0:
                                    selectedPriceType = 'commercialPrice';
                                    break;
                                  case 1:
                                    selectedPriceType = 'agencyprice';
                                    break;
                                  case 2:
                                    selectedPriceType = 'commercial2price';
                                    break;
                                  default:
                                    selectedPriceType = 'agencyprice';
                                }

                                try {
                                  String itemPriceString =
                                      selectedOrderItem[selectedPriceType]
                                              ?.toString()
                                              ?.trim() ??
                                          '0';
                                  double itemPrice =
                                      double.parse(itemPriceString);
                                  int parsedItemPrice = itemPrice.toInt();

                                  String warrantyString = selectedOrderItem[
                                              selectedPriceType.replaceFirst(
                                                  'price', 'warranty')]
                                          ?.toString()
                                          ?.trim() ??
                                      '0';
                                  double warrantyDouble =
                                      double.parse(warrantyString);
                                  int warranty = warrantyDouble.toInt();

                                  String note = selectedOrderItem[
                                              selectedPriceType.replaceFirst(
                                                  'price', 'Note')]
                                          ?.toString()
                                          ?.trim() ??
                                      '';
                                  String mark = selectedOrderItem['mark']
                                          ?.toString()
                                          ?.trim() ??
                                      '';
                                  String imageUrl = selectedOrderItem[
                                              selectedPriceType.replaceFirst(
                                                  'price', 'Img')]
                                          ?.toString()
                                          ?.trim() ??
                                      '';

                                  _showDetailsDialog(
                                    itemPrice: parsedItemPrice,
                                    warranty: warranty,
                                    note: note,
                                    mark: mark,
                                    imageUrl: imageUrl,
                                  );
                                } catch (e) {
                                  print('Error parsing values: $e');
                                  showConfirmationDialog(
                                    context: context,
                                    message:
                                        'حدث خطأ أثناء معالجة البيانات. الرجاء التحقق من القيم المدخلة.',
                                    confirmText: 'موافق',
                                    onConfirm: () {},
                                  );
                                }
                              } else {
                                showConfirmationDialog(
                                  context: context,
                                  message:
                                      'الرجاء تحديد السعر قبل عرض التفاصيل',
                                  confirmText: 'موافق',
                                  onConfirm: () {},
                                );
                              }
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.orderItems.length,
            itemBuilder: (context, index) {
              final orderItem = widget.orderItems[index];
              String orderItemName = orderItem['itemname'];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
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
                    Flexible(
                      flex: 1,
                      child: buildTextField(
                          getDisplayText(orderItem['commercial2price']),
                          index,
                          2),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Flexible(
                      flex: 1,
                      child: buildTextField(
                          getDisplayText(orderItem['commercialPrice']),
                          index,
                          0),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Flexible(
                      flex: 1,
                      child: buildTextField(
                          getDisplayText(orderItem['agencyprice']), index, 1),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Flexible(
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
                    SizedBox(width: screenWidth * 0.03),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooterOptions(List<dynamic> order) {
    final size = MediaQuery.of(context).size; // الحصول على حجم الشاشة
    final screenWidth = size.width;

    // الحصول على القيم من الطلب
    final deliveryshop = int.tryParse(order[0]['deliveryshop'].toString()) ?? 0;
    final deliverynormal =
        int.tryParse(order[0]['deliverynormal'].toString()) ?? 0;
    final deliverynow = int.tryParse(order[0]['deliverynow'].toString()) ?? 0;

    final deliverynormalCost =
        double.tryParse(order[0]['deliverynormalcost'].toString()) ?? 0.0;
    final deliverynowCost =
        double.tryParse(order[0]['deliverynowcost'].toString()) ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0),
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
          if (deliverynow == 1)
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
          if (deliverynormal == 1)
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
          if (deliveryshop == 1)
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

  Widget buildTextField(String hintText, int rowIndex, int fieldIndex) {
    bool isForbidden = hintText == 'غ.م';
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    return GestureDetector(
      onTap: isForbidden
          ? null
          : () {
              setState(() {
                if (selectedFieldsPerRow[rowIndex] == fieldIndex) {
                  selectedFieldsPerRow[rowIndex] = null;
                  lastSelectedIndex =
                      null; // إلغاء التحديد إذا تم النقر مرة أخرى
                } else {
                  selectedFieldsPerRow[rowIndex] = fieldIndex;
                  lastSelectedIndex =
                      rowIndex; // تعيين الصف الحالي كآخر صف مختار
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
                  selectedPriceType = 'commercialPrice';
                  break;
                case 1:
                  selectedPriceType = 'agencyprice';
                  break;
                case 2:
                  selectedPriceType = 'commercial2price';
                  break;
                default:
                  selectedPriceType = 'agencyprice';
              }

              try {
                double itemPrice = double.tryParse(
                        selectedOrderItem[selectedPriceType]
                                ?.toString()
                                .trim() ??
                            '0') ??
                    0;
                int parsedItemPrice = itemPrice.toInt();

                String warrantyString = selectedOrderItem[
                            selectedPriceType.replaceFirst('price', 'warranty')]
                        ?.toString()
                        .trim() ??
                    '0';
                int warranty = int.tryParse(warrantyString) ?? 0;

                String note = selectedOrderItem[selectedPriceType.replaceFirst(
                            'price'.toUpperCase(), 'Note')]
                        ?.toString()
                        .trim() ??
                    'لا توجد ملاحظات';

                String imageUrl = selectedOrderItem[selectedPriceType
                            .toLowerCase()
                            .replaceFirst('price'.toUpperCase(), 'Img')]
                        ?.toString()
                        .trim() ??
                    'لا توجد صورة';

                String mark =
                    selectedOrderItem['mark']?.toString().trim() ?? 'غ.م';

                _showDetailsDialog(
                  itemPrice: parsedItemPrice,
                  warranty: warranty,
                  note: note,
                  imageUrl: imageUrl,
                  mark: mark,
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
        height: screenHeight * 0.06, // على سبيل المثال، 5% من ارتفاع الشاشة
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isForbidden
                ? Colors.white // لون الحقل عندما يكون ممنوعًا
                : (selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isForbidden
                  ? Colors.white // لون الحدود عندما يكون ممنوعًا
                  : (selectedFieldsPerRow[rowIndex] == fieldIndex
                      ? green
                      : grey),
              width: 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            hintText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isForbidden
                  ? Colors.black26 // لون النص عندما يكون ممنوعًا
                  : (selectedFieldsPerRow[rowIndex] == fieldIndex
                      ? Colors.white
                      : Colors.black26),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog({
    required int itemPrice,
    required int warranty,
    required String note,
    required String mark,
    required String imageUrl,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // عرض مناسب للـ Dialog
                height:
                    MediaQuery.of(context).size.height * 0.5, // ارتفاع مناسب
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 7,
                    color: words, // يجب أن تحدد متغير اللون 'words'
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      Text(
                        "تفاصيل القطعة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      // عرض العلامة التجارية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "$mark",
                            color: words, // يجب أن تحدد متغير اللون 'words'
                          ),
                          CustomText(
                            text: " : العلامة التجارية",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // عرض مدة الكفالة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "أشهر",
                                color: words,
                              ),
                              SizedBox(width: 2),
                              CustomText(
                                text: "$warranty",
                                color: words,
                              ),
                            ],
                          ),
                          CustomText(
                            text: " : مدة الكفالة",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // عرض الملاحظات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: note.isEmpty ? "لا يوجد" : note,
                            color: words,
                          ),
                          CustomText(
                            text: " : الملاحظات",
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // عرض الصورة
                      if (imageUrl.isNotEmpty)
                        _buildImageRowWithClick(" ", imageUrl)
                      else
                        CustomText(
                          text: "لا يوجد صورة",
                          color: words,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// دالة لبناء الصورة مع القدرة على النقر عليها لفتحها في نافذة جديدة
  Widget _buildImageRowWithClick(String label, String? base64Image) {
    Uint8List? decodedImage;
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        if (base64Image.contains(',')) {
          base64Image = base64Image
              .split(',')
              .last; // معالجة البيانات إذا كانت تحتوي على ','.
        }
        decodedImage = base64Decode(base64Image);
      } catch (e) {
        print("Error decoding base64: $e");
      }
    }

    return Center(
      child: decodedImage != null
          ? GestureDetector(
              onTap: () {
                _showImageDialog(decodedImage!); // فتح الصورة في نافذة جديدة
              },
              child: Image.memory(
                decodedImage,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            )
          : Text(
              'لا يوجد صورة',
              style: TextStyle(fontSize: 16),
            ),
    );
  }

// دالة لعرض الصورة في نافذة جديدة عند النقر عليها
  void _showImageDialog(Uint8List decodedImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black54, // لون خلفية شفاف
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pop(); // إغلاق الـDialog عند النقر على الصورة
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Image.memory(
                decodedImage,
                fit: BoxFit.contain, // لضمان عرض الصورة بالكامل
              ),
            ),
          ),
        );
      },
    );
  }

  String getDisplayText(dynamic value) {
    double? number = double.tryParse(value.toString());
    if (number == null || number == 0 || number.toString().isEmpty) {
      return "غ.م";
    }
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      return number.toStringAsFixed(2);
    }
  }

  Widget _buildFooterTotal() {
    int a = selectedDeliveryCost.toInt();
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
                text: "$a",
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

  Widget _buildFooterSummary() {
    double totalCost = selectedDeliveryCost;
    for (int i = 0; i < selectedFieldsPerRow.length; i++) {
      int? selectedFieldIndex = selectedFieldsPerRow[i];
      if (selectedFieldIndex != null) {
        final selectedOrderItem = widget.orderItems[i];
        String selectedPriceType;

        switch (selectedFieldIndex) {
          case 0:
            selectedPriceType = 'commercialPrice';
            break;
          case 1:
            selectedPriceType = 'agencyprice';
            break;
          case 2:
            selectedPriceType = 'commercial2price';
            break;
          default:
            selectedPriceType = 'agencyprice';
        }

        totalCost += double.tryParse(
                selectedOrderItem[selectedPriceType]?.toString() ?? '0') ??
            0;
      }
    }
    int b = totalCost.toInt();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار اردني فقط لا غير",
                size: 18,
              ),
              CustomText(
                text: " $b",
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

  buildOptionButton(String label, int index, double cost) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          MSHCheckbox(
            size: 40,
            value: selectedOptionIndex == index,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: green,
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (value) {
              setState(() {
                selectedOptionIndex = index;
                selectedDeliveryCost = cost;
                if (selectedOptionIndex != index) {
                  selectedDeliveryCost = 0.0;
                }
                selectedDeliveryType = index;
              });
            },
          ),
          SizedBox(height: 10),
          CustomText(
            text: label,
            color: selectedOptionIndex == index ? green : black,
          ),
        ],
      ),
    );
  }

  buildFixedRedOptionButton(String label) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          MSHCheckbox(
            size: 40,
            value: true,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: Colors.red,
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (selected) {},
          ),
          SizedBox(height: 10),
          CustomText(
            text: label,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _handleConfirm() async {
    bool isPriceSelected = selectedFieldsPerRow.any((field) => field != null);
    bool isDeliverySelected = selectedDeliveryType != -1;

    if (isPriceSelected && isDeliverySelected) {
      double totalCost = 0.0;
      List<Map<String, dynamic>> selectedItems = [];

      for (int i = 0; i < selectedFieldsPerRow.length; i++) {
        int? selectedFieldIndex = selectedFieldsPerRow[i];
        if (selectedFieldIndex != null) {
          final selectedOrderItem = widget.orderItems[i];
          String selectedPriceType;
          String selectedImg;
          String selectedWarranty;
          String selectedNote;
          String selectedItemId = '';
          String itemTypeDisplay = '';

          switch (selectedFieldIndex) {
            case 0:
              selectedPriceType = 'commercialPrice';
              selectedImg = selectedOrderItem['commercialImg'] ?? '';
              selectedNote = selectedOrderItem['commercialNote'] ?? '';
              selectedWarranty = selectedOrderItem['commercialwarranty'] ?? '';
              itemTypeDisplay = 'تجاري';
              selectedItemId = selectedOrderItem['commercialitemid'] ?? '';
              break;
            case 1:
              selectedPriceType = 'agencyprice';
              selectedImg = selectedOrderItem['agencyImg'] ?? '';
              selectedNote = selectedOrderItem['agencyNote'] ?? '';
              selectedWarranty = selectedOrderItem['agencywarranty'] ?? '';
              itemTypeDisplay = 'شركه';
              selectedItemId = selectedOrderItem['agencyitemid'] ?? '';
              break;
            case 2:
              selectedPriceType = 'commercial2price';
              selectedImg = selectedOrderItem['commercial2Img'] ?? '';
              selectedNote = selectedOrderItem['commercial2Note'] ?? '';
              itemTypeDisplay =
                  selectedOrderItem['commercial2name'] ?? 'غير محدد';
              selectedWarranty = selectedOrderItem['commercial2warranty'] ?? '';
              selectedItemId = selectedOrderItem['commercial2itemid'] ?? '';
              break;
            default:
              selectedPriceType = 'agencyprice';
              selectedImg = selectedOrderItem['agencyImg'] ?? '';
              selectedNote = selectedOrderItem['agencyNote'] ?? '';
              itemTypeDisplay = 'شركه';
              selectedWarranty = selectedOrderItem['agencywarranty'] ?? '';
          }

          selectedItems.add({
            'itemid': selectedOrderItem['id'],
            'itemName': selectedOrderItem['itemname'],
            'itemType': itemTypeDisplay,
            'itemwarranty': selectedWarranty,
            'detid': selectedItemId,
            'price': selectedOrderItem[selectedPriceType],
            'itemImg': selectedImg,
            'itemNote': selectedNote,
          });

          totalCost += double.tryParse(
                  selectedOrderItem[selectedPriceType]?.toString() ?? '0') ??
              0;
        }
      }

      totalCost += selectedDeliveryCost;

      String deliveryType = '';
      switch (selectedDeliveryType) {
        case 0:
          deliveryType = 'فوري';
          break;
        case 1:
          deliveryType = '24 ساعة';
          break;
        case 2:
          deliveryType = 'استلام من المحل';
          break;
        default:
          deliveryType = 'غير محدد';
      }

      final orderData = {
        'selectedItems': selectedItems,
        'totalCost': totalCost,
        'deliveryType': deliveryType,
        'deliveryCost': selectedDeliveryCost,
        'orderId': widget.order1[0]['orderid'],
        'userId': widget.order1[0]['userid'],
        'timeorder': widget.order1[0]['timeorder'],
        'Enginesize': widget.order1[0]['Enginesize'],
        'Fueltype': widget.order1[0]['Fueltype'],
        'Engineyear': widget.order1[0]['Engineyear'],
        'Enginecategory': widget.order1[0]['Enginecategory'],
        'Enginetype': widget.order1[0]['Enginetype'],
        'bodyid': widget.order1[0]['bodyid'],
      };

      // إرسال الطلب إلى الـ API
      try {
        final response = await http.post(
          Uri.parse('https://jordancarpart.com/Api/setAcceptedOrder2.php'),
          headers: {
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(orderData),
        );

        print(response.body.toString());

        if (response.statusCode == 200) {
          NotificationService().showNotification(
            id: 0,
            title: 'تم تأكيد طلبك بنجاح',
            body:
                'طلب رقم ${widget.order1[0]['orderid']} تم تأكيده بنجاح. سوف يتم التواصل معك قريباً.',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );

          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> notifications =
              prefs.getStringList('notifications') ?? [];
          List<Map<String, dynamic>> notificationList =
              notifications.map((notification) {
            return jsonDecode(notification) as Map<String, dynamic>;
          }).toList();

          void addNotification(String message, String type) {
            notificationList.add({
              'message': message,
              'type': type,
              'isRead': false,
            });
          }

          addNotification(
              'تم تأكيد طلب رقم ${widget.order1[0]['orderid']}', "تأكيد");
          List<String> updatedNotifications = notificationList
              .map((notification) => jsonEncode(notification))
              .toList();
          await prefs.setStringList('notifications', updatedNotifications);

          print("Notification stored successfully in SharedPreferences.");
        } else {
          showConfirmationDialog(
            context: context,
            message: 'فشل في إرسال الطلب: ${response.statusCode}',
            confirmText: 'حسنًا',
            onConfirm: () {},
          );
        }
      } catch (e) {
        showConfirmationDialog(
          context: context,
          message: 'حدث خطأ أثناء الإرسال: $e',
          confirmText: 'حسنًا',
          onConfirm: () {},
        );
      }
    } else {
      showConfirmationDialog(
        context: context,
        message: 'يجب عليك اختيار سعر قطعة ونوع توصيل قبل التأكيد',
        confirmText: 'حسنًا',
        onConfirm: () {},
      );
    }
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
}
