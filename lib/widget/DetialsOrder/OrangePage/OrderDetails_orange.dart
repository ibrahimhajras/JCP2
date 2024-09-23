import 'dart:convert';
import 'dart:typed_data';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/custom_text.dart';
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
            _buildSectionTitle("رقم الشاصي"),
            _buildOrderDetails2(size),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                vehicleData["Enginetype"].toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                vehicleData["Enginecategory"].toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                vehicleData["Fueltype"].toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                vehicleData["Engineyear"].toString(),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                vehicleData["Enginesize"].toString(),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails2(Size size) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${vehicleData['bodyid']}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    print(widget.orderItems); // Debugging print statement to show the order items

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '   ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "${widget.orderItems[0]['commercial2name'] ?? ''}",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'تجاري',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'شركة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (selectedItemPrice > 0)
                IconButton(
                  icon: Image.asset(
                    'assets/images/iconinfo.png',
                    width: 45,
                    height: 24,
                  ),
                  onPressed: () {
                    int selectedIndex = selectedFieldsPerRow.indexWhere((element) => element != null);
                    if (selectedIndex != -1) {
                      final selectedOrderItem = widget.orderItems[selectedIndex];

                      String selectedPriceType;
                      switch (selectedFieldsPerRow[selectedIndex]) {
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
                        // Debugging: Print the values to check their contents
                        print('Selected Price Type: $selectedPriceType');
                        print('Selected Order Item: $selectedOrderItem');

                        String itemPriceString = selectedOrderItem[selectedPriceType]?.toString().trim() ?? '0';
                        print('Item Price String Before Parsing: $itemPriceString');

                        // Parse item price as double first, then convert to int
                        double itemPrice = double.parse(itemPriceString);
                        int parsedItemPrice = itemPrice.toInt();

                        String warrantyString = selectedOrderItem[selectedPriceType.replaceFirst('price', 'warranty')]?.toString().trim() ?? '0';
                        print('Warranty String Before Parsing: $warrantyString');

                        // Parse warranty as double first, then convert to int
                        double warrantyDouble = double.parse(warrantyString);
                        int warranty = warrantyDouble.toInt();

                        String note = selectedOrderItem[selectedPriceType.replaceFirst('price', 'Note')]?.toString().trim() ?? '';
                        String mark = selectedOrderItem['mark']?.toString().trim() ?? '';
                        String imageUrl = selectedOrderItem[selectedPriceType.replaceFirst('price', 'Img')]?.toString().trim() ?? '';

                        // Print parsed values for debugging
                        print('Parsed Item Price: $parsedItemPrice');
                        print('Parsed Warranty: $warranty');
                        print('Note: $note');
                        print('Mark: $mark');
                        print('Image URL: $imageUrl');

                        _showDetailsDialog(
                          itemPrice: parsedItemPrice,
                          warranty: warranty,
                          note: note,
                          mark: mark,
                          imageUrl: imageUrl,
                        );
                      } catch (e) {
                        // Handle parsing errors and show an error message if parsing fails
                        print('Error parsing values: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('حدث خطأ أثناء معالجة البيانات. الرجاء التحقق من القيم المدخلة.'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('الرجاء تحديد السعر قبل عرض التفاصيل'),
                        ),
                      );
                    }
                  },
                )
              else
                Text(
                  '   ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    IconButton(
                      icon: Image.asset(
                        'assets/images/delete.png',
                        width: 20,
                        height: 20,
                      ),
                      onPressed: () {
                        _confirmDeletion(index);
                      },
                    ),
                    buildTextField(getDisplayText(orderItem['commercial2price']), index, 2),
                    buildTextField(getDisplayText(orderItem['commercialPrice']), index, 0),
                    buildTextField(getDisplayText(orderItem['agencyprice']), index, 1),
                    Text(
                      orderItemName.length > 9
                          ? orderItemName.replaceAllMapped(
                          RegExp(r'(.{9})'), (match) => '${match[0]}\n')
                          : orderItemName,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  void _showDetailsDialog({
    required int itemPrice,
    required int warranty,
    required String note,
    required String mark,
    required String imageUrl,
  }) {
    // itemPrice is already an int, no need for parsing
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
                            text: "$itemPrice", // Display price directly
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
                                text: "$warranty", // Display selected warranty
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
        Uint8List decodedBytes = base64Decode(base64String);
        return Image.memory(
          decodedBytes,
          height: 100,
          width: 100,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text("لا يوجد صورة");
          },
        );
      } else {
        return Text('لا يوجد صورة');
      }
    } catch (e) {
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
          Text('', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (deliverynow == 1) buildOptionButton('فوري', 0, deliverynowCost),
          SizedBox(width: 5),
          if (deliverynormal == 1)
            buildOptionButton('24 ساعة', 1, deliverynormalCost),
          SizedBox(width: 5),
          if (deliveryshop == 1) buildOptionButton('استلام م\n المحل', 2, 0.0),
          Text('التوصيل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  buildTextField(String hintText, int rowIndex, int fieldIndex) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedFieldsPerRow[rowIndex] == fieldIndex) {
            selectedFieldsPerRow[rowIndex] = null;
            selectedItemPrice = 0;
          } else {
            selectedFieldsPerRow[rowIndex] = fieldIndex;
            selectedItemPrice = double.tryParse(hintText)?.toInt() ?? 0;

            final selectedOrderItem = widget.orderItems[rowIndex];

            String selectedItemType = '';
            String selectedImg = '';
            String selectedNote = '';
            String selectedMark = '';  // Define selectedMark to hold the mark

            if (fieldIndex == 0) {
              selectedItemType = 'commercialPrice';
              selectedImg = selectedOrderItem['commercialImg'] ?? '';
              selectedNote = selectedOrderItem['commercialNote'] ?? '';
              selectedMark = selectedOrderItem['mark'] ?? 'غ.م';  // Set mark
            } else if (fieldIndex == 1) {
              selectedItemType = 'agencyprice';
              selectedImg = selectedOrderItem['agencyImg'] ?? '';
              selectedNote = selectedOrderItem['agencyNote'] ?? '';
              selectedMark = selectedOrderItem['mark'] ?? 'غ.م';  // Set mark
            } else if (fieldIndex == 2) {
              selectedItemType = 'commercial2price';
              selectedImg = selectedOrderItem['commercial2Img'] ?? '';
              selectedNote = selectedOrderItem['commercial2Note'] ?? '';
              selectedMark = selectedOrderItem['mark'] ?? 'غ.م';  // Set mark
            }

            String displayType = '';
            if (selectedItemType == 'agencyprice') {
              displayType = selectedOrderItem['agencyname'] ?? 'غير محدد';
            } else if (selectedItemType == 'commercialPrice') {
              displayType = selectedOrderItem['commercialname'] ?? 'غير محدد';
            } else if (selectedItemType == 'commercial2price') {
              displayType = selectedOrderItem['commercial2name'] ?? 'غير محدد';
            }

            selectedItems.add({
              'itemid': selectedOrderItem['id'],
              'itemName': selectedOrderItem['itemname'] ?? 'غير محدد',
              'itemType': displayType,
              'price': selectedOrderItem[selectedItemType] ?? '0',
              'itemImg': selectedImg,
              'itemNote': selectedNote,
              'mark': selectedMark,  // Add mark to selectedItems
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
          double itemPrice = double.parse(selectedOrderItem[selectedPriceType]?.toString().trim() ?? '0');
          int parsedItemPrice = itemPrice.toInt();

          // Parse warranty safely
          String warrantyString = selectedOrderItem[selectedPriceType.replaceFirst('price', 'warranty')]?.toString().trim() ?? '0';
          double warrantyDouble = double.parse(warrantyString);
          int warranty = warrantyDouble.toInt();

          String note = selectedOrderItem[selectedPriceType.replaceFirst('price', 'Note')]?.toString().trim() ?? 'لا توجد ملاحظات';
          String imageUrl = selectedOrderItem[selectedPriceType.replaceFirst('price', 'Img')]?.toString().trim() ?? '';
          String mark = selectedOrderItem['mark']?.toString().trim() ?? 'غ.م';  // Get mark

          // Show details dialog with parsed values
          _showDetailsDialog(
            itemPrice: parsedItemPrice,
            warranty: warranty,
            note: note,
            imageUrl: imageUrl,
            mark: mark,
          );
        } catch (e) {
          print('Error parsing values: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء معالجة البيانات. الرجاء التحقق من القيم المدخلة.'),
            ),
          );
        }
      },
      child: Container(
        width: 61.1,
        height: 44.71,
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedFieldsPerRow[rowIndex] == fieldIndex ? green : grey,
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
                : Colors.black26, // تغيير لون النص بناءً على الحالة
          ),
        ),
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
    return Column(
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
          color: black,
        ),
      ],
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
      print(orderData);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('فشل في إرسال الطلب: ${response.statusCode}'),
          ));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('حدث خطأ أثناء الإرسال: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('يجب عليك اختيار سعر قطعة ونوع توصيل قبل التأكيد'),
      ));
    }
  }

  void _confirmDeletion(int index) {
    if (widget.orderItems.length <= 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('لا يمكن الحذف'),
            content:
                Text('لا يمكنك حذف هذا العنصر لأنه العنصر الوحيد المتبقي.'),
            actions: [
              TextButton(
                child: Text('حسنًا'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Text('هل ترغب في حذف هذا العنصر؟'),
            actions: [
              TextButton(
                child: Text('لا', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  'نعم',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  setState(() {
                    widget.orderItems.removeAt(index);
                    if (widget.orderItems.isEmpty) {
                      selectedFieldsPerRow.clear();
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
