import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import '../../../style/colors.dart';

class OrderDetailsPage_Green extends StatelessWidget {
  final Map<String, dynamic> orderData;

  OrderDetailsPage_Green({required this.orderData});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<dynamic> items = orderData["items"] as List<dynamic>;
    Map<String, dynamic> items1 = orderData["header"];
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              _buildHeader(size, context),
              SizedBox(height: size.height * 0.01),
              _buildSectionTitle("المركبة"),
              _buildOrderDetails(size),
              SizedBox(height: size.height * 0.01),
              _buildSectionTitle("رقم الشاصي"),
              _buildOrderDetails2(size),
              SizedBox(height: size.height * 0.01),
              ..._buildSelectedItemsList(context),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'التوصيل',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    children: [
                      MSHCheckbox(
                        size: 40,
                        value: true,
                        colorConfig:
                            MSHColorConfig.fromCheckedUncheckedDisabled(
                          checkedColor: green,
                        ),
                        style: MSHCheckboxStyle.stroke,
                        onChanged: (selected) {},
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          items1['deliveryType'] ?? 'N/A',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      '',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 2,
              ),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomText(
                          text: "  المجموع",
                          color: red,
                          weight: FontWeight.w900,
                          size: 18,
                        ),
                        CustomText(
                          text: "${items1['totalCost']}",
                          size: 18,
                        ),
                        CustomText(
                          text: "دينار اردني  ",
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [Colors.black, Colors.grey],
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
                  Navigator.pop(context);
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

  List<Widget> _buildSelectedItemsList(BuildContext context) {
    if (orderData.containsKey("items") && orderData["items"] != null) {
      List<dynamic> items = orderData["items"] as List<dynamic>;
      if (items.isNotEmpty) {
        return items.map<Widget>((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    item['itemType'] ?? 'N/A',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        item['itemName'] ?? 'N/A',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Card(
                      color: green,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          item["price"] ?? 'N/A',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: green,
                      ),
                      onPressed: () => _showItemDetails(context, item),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  height: 2,
                )
              ],
            ),
          );
        }).toList();
      } else {
        return [Center(child: Text("لا توجد عناصر مختارة"))];
      }
    } else {
      return [Center(child: Text("لا توجد عناصر مختارة"))];
    }
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Item Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'العلامه التجاري: ${item["itemType"] ?? 'N/A'}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'مده الكفاله : ${item["itemWarranty"] ?? 'N/A'}شهر',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 8),
              Text(
                'الملاحضات: ${item["itemNote"] ?? 'N/A'}',
                style: TextStyle(fontSize: 15),
              ),
              SizedBox(height: 8),
              Text("الصوره:"),
              item["itemImg"] != null && item["itemImg"].isNotEmpty
                  ? _buildImageFromBase64(item["itemImg"])
                  : Text('No image available'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageFromBase64(String base64String) {
    try {
      final decodedBytes = base64Decode(base64String);
      return Image.memory(
        Uint8List.fromList(decodedBytes),
        height: 100, // Adjust height as needed
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return Text('Error loading image');
    }
  }

  Widget _buildOrderDetails(Size size) {
    final header = orderData["header"];
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
                child: Text(header["Fueltype"].toString(),
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text(header["Enginecategory"].toString(),
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text(header["Enginetype"].toString(),
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text(header["Engineyear"].toString(),
                    textAlign: TextAlign.center)),
            Expanded(
                child: Text(header["Enginesize"].toString(),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails2(Size size) {
    final header = orderData["header"];
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
          // Spacing evenly between items
          crossAxisAlignment: CrossAxisAlignment.center,
          // Align vertically centered
          children: [
            Expanded(
                child: Text(header["bodyid"].toString(),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
