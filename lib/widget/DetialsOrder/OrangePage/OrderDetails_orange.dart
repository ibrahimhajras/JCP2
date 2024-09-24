import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
            Divider(height: 2),
            _buildFooterTotal(),
            _buildFooterSummary(),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomText(
                    text: widget.orderItems[0]['commercial2name'] ?? '',
                    color: white,
                    weight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomText(
                    text: widget.orderItems[0]['commercial2name'] ?? '',
                    color: black,
                    weight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomText(
                    text: 'تجاري',
                    color: black,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                height: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: CustomText(
                    text: 'شركة',
                    color: black,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
              if (lastSelectedIndex != null &&
                  selectedFieldsPerRow[lastSelectedIndex!] != null)
                SizedBox(
                  width: 120,
                  height: 40,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/iconinfo.png',
                        width: 20,
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
                            double itemPrice = double.parse(itemPriceString);
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

                            String note = selectedOrderItem[selectedPriceType
                                        .replaceFirst('price', 'Note')]
                                    ?.toString()
                                    ?.trim() ??
                                '';
                            String mark =
                                selectedOrderItem['mark']?.toString()?.trim() ??
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
                              onConfirm: () {
                                // قم بأي إجراء إضافي هنا عند الضغط على "موافق"
                              },
                            );
                          }
                        } else {
                          showConfirmationDialog(
                            context: context,
                            message: 'الرجاء تحديد السعر قبل عرض التفاصيل',
                            confirmText: 'موافق',
                            onConfirm: () {
                              // أي إجراء إضافي إذا كان مطلوبًا عند النقر على "موافق"
                            },
                          );
                        }
                      },
                    ),
                  ),
                )
              else
                SizedBox(
                  width: 120,
                  child: CustomText(
                    text: 'تجاري',
                    color: white,
                    weight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    SizedBox(
                      width: 40,
                      child: IconButton(
                        icon: Image.asset(
                          'assets/images/02.png',
                          width: 20,
                          height: 20,
                        ),
                        onPressed: () {
                          _confirmDeletion(index);
                        },
                      ),
                    ),
                    buildTextField(
                        getDisplayText(orderItem['commercial2price']),
                        index,
                        2),
                    buildTextField(
                        getDisplayText(orderItem['commercialPrice']), index, 0),
                    buildTextField(
                        getDisplayText(orderItem['agencyprice']), index, 1),
                    SizedBox(
                      width: 120,
                      child: CustomText(
                          text: orderItemName,
                          color: black,
                          weight: FontWeight.bold),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  buildTextField(String hintText, int rowIndex, int fieldIndex) {
    return GestureDetector(
        onTap: () {
          setState(() {
            if (selectedFieldsPerRow[rowIndex] == fieldIndex) {
              // إذا تم إلغاء تحديد الحقل الحالي
              selectedFieldsPerRow[rowIndex] = null;
              selectedItemPrice = 0;

              // إذا كان الصف الحالي هو آخر صف محدد، نقوم بإعادة تعيين lastSelectedIndex
              if (lastSelectedIndex == rowIndex) {
                lastSelectedIndex = null;
              }
            } else {
              // إذا تم تحديد حقل جديد
              selectedFieldsPerRow[rowIndex] = fieldIndex;
              selectedItemPrice = double.tryParse(hintText)?.toInt() ?? 0;

              // تحديث lastSelectedIndex بالصف الحالي
              lastSelectedIndex = rowIndex;

              // بقية الكود الخاص بتحديث selectedItems (يمكنك الاحتفاظ به كما هو)
              final selectedOrderItem = widget.orderItems[rowIndex];
              print(rowIndex.toString() + " " + fieldIndex.toString());
              String selectedItemType = '';
              String selectedImg = '';
              String selectedNote = '';
              String selectedMark = '';

              if (fieldIndex == 0) {
                selectedItemType = 'commercialPrice';
                selectedImg = selectedOrderItem['commercialImg'] ?? '';
                selectedNote = selectedOrderItem['commercialNote'] ?? '';
                selectedMark = selectedOrderItem['mark'] ?? 'غ.م';
              } else if (fieldIndex == 1) {
                selectedItemType = 'agencyprice';
                selectedImg = selectedOrderItem['agencyImg'] ?? '';
                selectedNote = selectedOrderItem['agencyNote'] ?? '';
                selectedMark = selectedOrderItem['mark'] ?? 'غ.م';
              } else if (fieldIndex == 2) {
                selectedItemType = 'commercial2price';
                selectedImg = selectedOrderItem['commercial2Img'] ?? '';
                selectedNote = selectedOrderItem['commercial2Note'] ?? '';
                selectedMark = selectedOrderItem['mark'] ?? 'غ.م';
              }

              String displayType = '';
              if (selectedItemType == 'agencyprice') {
                displayType = selectedOrderItem['agencyname'] ?? 'غير محدد';
              } else if (selectedItemType == 'commercialPrice') {
                displayType = selectedOrderItem['commercialname'] ?? 'غير محدد';
              } else if (selectedItemType == 'commercial2price') {
                displayType =
                    selectedOrderItem['commercial2name'] ?? 'غير محدد';
              }

              selectedItems.add({
                'itemid': selectedOrderItem['id'],
                'itemName': selectedOrderItem['itemname'] ?? 'غير محدد',
                'itemType': displayType,
                'price': selectedOrderItem[selectedItemType] ?? '0',
                'itemImg': selectedImg,
                'itemNote': selectedNote,
                'mark': selectedMark,
              });
            }
          });
        },
        onLongPress: () {
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
            // Parse item price safely
            double itemPrice = double.parse(
                selectedOrderItem[selectedPriceType]?.toString().trim() ?? '0');
            int parsedItemPrice = itemPrice.toInt();

            // Parse warranty safely
            String warrantyString = selectedOrderItem[
                        selectedPriceType.replaceFirst('price', 'warranty')]
                    ?.toString()
                    .trim() ??
                '0';
            double warrantyDouble = double.parse(warrantyString);
            int warranty = warrantyDouble.toInt();

            String note = selectedOrderItem[
                        selectedPriceType.replaceFirst('price', 'Note')]
                    ?.toString()
                    .trim() ??
                'لا توجد ملاحظات';
            String imageUrl = selectedOrderItem[
                        selectedPriceType.replaceFirst('price', 'Img')]
                    ?.toString()
                    .trim() ??
                '';
            String mark = selectedOrderItem['mark']?.toString().trim() ?? 'غ.م';
            print('Image URL: $imageUrl'); // هنا

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
              message:
                  'حدث خطأ أثناء معالجة البيانات. الرجاء التحقق من القيم المدخلة.',
              confirmText: 'موافق',
              onConfirm: () {
                // تنفيذ أي إجراء إضافي عند النقر على "موافق" إذا لزم الأمر
              },
            );
          }
        },
        child: SizedBox(
          width: 61.1,
          height: 44.71,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color:
                  selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey,
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              hintText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selectedFieldsPerRow[rowIndex] == fieldIndex
                    ? Colors.white
                    : Colors.black26,
              ),
            ),
          ),
        ));
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
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 7,
                    color: words,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "$mark",
                            color: words,
                          ),
                          CustomText(
                            text: " : العلامة التجارية",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "$itemPrice",
                            color: words,
                          ),
                          CustomText(
                            text: " : السعر",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "شهر",
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
                      if (imageUrl.isNotEmpty)
                        _buildImageFromBase64(imageUrl)
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

  Widget _buildImageFromBase64(String base64String) {
    try {
      if (base64String.isNotEmpty) {
        if (base64String.contains(',')) {
          base64String = base64String.split(',').last;
        }
        print('Base64 String Length: ${base64String.length}');
        Uint8List decodedBytes = base64Decode(base64String);
        print('Decoded Bytes Length: ${decodedBytes.length}');
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            child: Card(
              elevation: 10,
              shadowColor: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.memory(
                    decodedBytes,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error in Image.memory: $error');
                      return Text("لا يوجد صورة");
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        print('Base64 String is empty');
        return Text('لا يوجد صورة');
      }
    } catch (e) {
      print('Error decoding image: $e');
      return Text('لا يوجد صورة');
    }
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

  Widget _buildFooterOptions(List<dynamic> order) {
    final deliveryshop = int.tryParse(order[0]['deliveryshop'].toString()) ?? 0;
    final deliverynormal =
        int.tryParse(order[0]['deliverynormal'].toString()) ?? 0;
    final deliverynow = int.tryParse(order[0]['deliverynow'].toString()) ?? 0;

    final deliverynormalCost =
        double.tryParse(order[0]['deliverynormalcost'].toString()) ?? 0.0;
    final deliverynowCost =
        double.tryParse(order[0]['deliverynowcost'].toString()) ?? 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomText(
                text: 'التوصيل',
                color: white,
                weight: FontWeight.bold,
              ),
            ),
          ),
          if (deliverynow == 1)
            buildOptionButton('فوري', 0, deliverynowCost)
          else
            buildFixedRedOptionButton('فوري'),
          if (deliverynormal == 1)
            buildOptionButton('24 ساعة', 1, deliverynormalCost)
          else
            buildFixedRedOptionButton('24 ساعة'),
          if (deliveryshop == 1)
            buildOptionButton('استلام م\n المحل', 2, 0.0)
          else
            buildFixedRedOptionButton('استلام م\n المحل'),
          SizedBox(
            width: 120,
            height: 40,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomText(
                text: 'التوصيل',
                color: black,
                weight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
            value: true, // دائمًا مفعل
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: Colors.red, // اللون الأحمر دائمًا
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (selected) {}, // لا يوجد تأثير عند النقر
          ),
          SizedBox(height: 10),
          CustomText(
            text: label,
            color: Colors.red, // جعل لون النص نفس لون الـ Checkbox
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
          String selectedwarranty;
          String selectedNote;
          String Select_id = '';
          String itemTypeDisplay = '';
          switch (selectedFieldIndex) {
            case 0:
              selectedPriceType = 'commercialPrice';
              selectedImg = selectedOrderItem['commercialImg'] ?? '';
              selectedNote = selectedOrderItem['commercialNote'] ?? '';
              selectedwarranty = selectedOrderItem['commercialwarranty'] ?? '';
              itemTypeDisplay = 'تجاري';
              Select_id = selectedOrderItem['commercialitemid'] ?? '';
              break;
            case 1:
              selectedPriceType = 'agencyprice';
              selectedImg = selectedOrderItem['agencyImg'] ?? '';
              selectedNote = selectedOrderItem['agencyNote'] ?? '';
              selectedwarranty = selectedOrderItem['agencywarranty'] ?? '';
              itemTypeDisplay = 'شركه';
              Select_id = selectedOrderItem['agencyitemid'] ?? '';
              break;
            case 2:
              selectedPriceType = 'commercial2price';
              selectedImg = selectedOrderItem['commercial2Img'] ?? '';
              selectedNote = selectedOrderItem['commercial2Note'] ?? '';
              itemTypeDisplay =
                  selectedOrderItem['commercial2name'] ?? 'غير محدد';
              selectedwarranty = selectedOrderItem['commercial2warranty'] ?? '';
              Select_id = selectedOrderItem['commercial2itemid'] ?? '';
              break;
            default:
              selectedPriceType = 'agencyprice';
              selectedImg = selectedOrderItem['agencyImg'] ?? '';
              selectedNote = selectedOrderItem['agencyNote'] ?? '';
              itemTypeDisplay = 'شركه';
              selectedwarranty = selectedOrderItem['agencywarranty'] ?? '';
          }
          selectedItems.add({
            'itemid': selectedOrderItem['id'],
            'itemName': selectedOrderItem['itemname'],
            'itemType': itemTypeDisplay,
            'itemwarranty': selectedwarranty,
            'detid': Select_id,
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
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ));
          AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: 2,
                channelKey: 'basic_key',
                title: ' ${widget.order1[0]['orderid']} تم تأكيد طلبك بنجاح ',
                body: 'سوف يتم التواصل معك قريباً',
                bigPicture: "asset://assets/images/app_logo.png",
                notificationLayout: NotificationLayout.BigPicture),
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          List<String> notifications =
              prefs.getStringList('notifications') ?? [];
          List<Map<String, dynamic>> notificationList =
              notifications.map((notification) {
            Map<String, dynamic> notificationMap = jsonDecode(notification);
            return notificationMap;
          }).toList();
          void addNotification(String message, String type) {
            notificationList.add({
              'message': message,
              'type': type,
              'isRead': false,
            });
          }

          addNotification(
              ' ${widget.order1[0]['orderid']} تم تأكيد طلب رقم  ', "تأكيد");
          List<String> updatedNotifications = notificationList
              .map((notification) => jsonEncode(notification))
              .toList();
          await prefs.setStringList('notifications', updatedNotifications);
          print("Notification stored successfully in SharedPreferences.");
        } else {
          showConfirmationDialog(
            context: context,
            message: 'فشل في إرسال الطلب: ${response.statusCode}',
            confirmText: 'حسناً',
            onConfirm: () {},
          );
        }
      } catch (e) {
        showConfirmationDialog(
          context: context,
          message: 'حدث خطأ أثناء الإرسال: $e',
          confirmText: 'حسناً',
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
            if (widget.orderItems.isEmpty) {
              selectedFieldsPerRow.clear();
            }
          });
        },
        cancelText: 'لا',
        onCancel: () {},
      );
    }
  }
}
