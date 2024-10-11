import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
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

    print(items);
    print(items1);

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
              ..._buildSelectedItemsList(context),
              SizedBox(height: size.height * 0.04),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Divider(height: 2),
              ),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 80,
                        height: 70,
                        child: Align(
                          child: CustomText(
                            text: item['itemName'] ?? 'N/A',
                            size: 15,
                            weight: FontWeight.bold,
                          ),
                        )),
                    Column(
                      children: [
                        SizedBox(
                          width: 120,
                          child: CustomText(
                            text: item['itemType'] ?? 'N/A',
                            size: 15,
                            weight: FontWeight.bold,
                          ),
                        ),
                        Card(
                          color: green,
                          child: SizedBox(
                            width: 80,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomText(
                                text: item["price"] ?? 'N/A',
                                color: Colors.white,
                                size: 15,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: green,
                        ),
                        onPressed: () => _showItemDetails(context, item),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Divider(height: 2),
                ),
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
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
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
                            text: "${item['itemType']}",
                            color: words,
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
                                text: "${item['itemWarranty'] ?? 'N/A'}",
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
                            text: item['itemNote']?.isEmpty ?? true
                                ? "لا يوجد"
                                : item['itemNote'],
                            color: words,
                          ),
                          CustomText(
                            text: " : الملاحظات",
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (item['itemImg'] != null && item['itemImg'].isNotEmpty)
                        _buildImageRow(
                            "",
                            'https://jordancarpart.com${item['itemImg']}',
                            context)
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

  Widget _buildImageRow(String label, String imageUrl, BuildContext context) {
    print(imageUrl);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        imageUrl.isNotEmpty // التحقق من أن الصورة عبر URL وليست فارغة
            ? GestureDetector(
                onTap: () {
                  _showImageDialog(imageUrl, context);
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
                    return Text(
                      "لا توجد صورة متاحة",
                      style: TextStyle(fontSize: 16),
                    );
                  },
                ),
              )
            : Text(
                "لا توجد صورة متاحة",
                style: TextStyle(fontSize: 16),
              ),
      ],
    );
  }

  void _showImageDialog(String imageUrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: RotatingImagePage());
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return Center(
                    child: Text(
                      'خطأ في تحميل الصورة',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderDetails(Size size) {
    if (orderData.isEmpty || orderData["header"] == null) return Container();
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    text: header["Enginetype"].toString() +
                        "  " +
                        header["Enginecategory"].toString() +
                        "  " +
                        header["Fueltype"].toString() +
                        " " +
                        header["Engineyear"].toString() +
                        "  " +
                        header["Enginesize"].toString(),
                  ),
                ],
              ),
              CustomText(
                text: header["bodyid"].toString(),
                color: black,
                letters: true,
              )
            ],
          )),
    );
  }
}
