import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../provider/ProfileProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/FullScreenImageViewer.dart';
import '../../widget/Inallpage/CustomHeader.dart';
import '../../widget/Inallpage/showConfirmationDialog.dart';
import '../../widget/RotatingImagePage.dart';
import 'Index_Driver.dart';

class Archivedetails extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const Archivedetails({super.key, required this.orderData});

  @override
  State<Archivedetails> createState() => _ArchivedetailsState();
}

class _ArchivedetailsState extends State<Archivedetails> {
  TextEditingController noteC = TextEditingController();

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

  Widget _buildVehicleInfo() {
    if (widget.orderData.isEmpty) return Container();
    final vehicleData = widget.orderData;
    String engineSize =
        vehicleData["Enginesize"]?.toString().replaceAll("L", "") ?? "";

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
                        "${engineSize}L",
                  ),
                ],
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderData;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomHeader(
            title: "تفاصيل الطلبية",
            notificationIcon: SizedBox.shrink(),
            menuIcon: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          _buildSectionTitle("المركبة"),
          _buildVehicleInfo(),
          SizedBox(height: 10),
          CustomText(
            text: 'رقم الطلب : ${order['orderid']}',
            size: 18,
            weight: FontWeight.bold,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTableHeader("الكفالة"),
                _buildTableHeader("الحالة"),
                _buildTableHeader("السعر"),
                _buildTableHeader("اسم القطعة"),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: order['items_details'].length,
              itemBuilder: (context, index) {
                var item = order['items_details'][index]['product_details'][0];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: Image.asset(
                                'assets/images/iconinfo.png',
                                width: 25,
                                height: 25,
                              ),
                              onPressed: () {
                                _showDetailsDialog(
                                    context: context, item: item);
                              },
                            ),
                          ),
                          Expanded(child: _buildTableCell(item['name'] ?? '')),
                          Expanded(
                            child: _buildTableCell(
                                ((double.tryParse(item['price'].toString()) ??
                                            0) *
                                        1.08)
                                    .ceil()
                                    .toString()),
                          ),
                          Expanded(
                              child: _buildTableCell(
                                  item['product_info']['name'] ?? '')),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          _buildTotalCost(order['totalCost']),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 1.05,
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomText(
                            textAlign: TextAlign.end,
                            text: "إن وجد :",
                            color: Color(0xffA8A8A8),
                            size: 14,
                          ),
                          CustomText(
                            textAlign: TextAlign.end,
                            text: "إضافة ملاحظة ",
                            color: Colors.black,
                            weight: FontWeight.bold,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 12),
            child: TextField(
              controller: noteC,
              maxLines: 2,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: green, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
                hintText: '',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontFamily: "Tajawal",
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showConfirmationDialog(
                context: context,
                message: "هل أنت متأكد من إتمام التحصيل والتوصيل؟",
                confirmText: "تأكيد",
                onConfirm: () {
                  
                  updateOrderStatus(1,noteC.text,context);
                },
                cancelText: "رفض",
                onCancel: () {},
              );
            },
            label: CustomText(
              text: "تم",
              color: white,
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: white,
              backgroundColor: red,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: "Tajawal",
                  fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Future<void> updateOrderStatus(int status, String note,BuildContext c) async {
    final user = Provider.of<ProfileProvider>(context, listen: false);
    int persion = int.tryParse(user.user_id) ?? 0;
    

    final url =
        Uri.parse('https://jordancarpart.com/Api/delevery/accesspetdeleveryorder.php');
    

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'orderid': int.parse(widget.orderData['orderid'].toString()),
          'persionid': persion,
          'status': status,
          'note': note,
        }),
      );
      
     
      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (c) => Index_Driver(page: 1),
          ),
          (route) => false,
        );
      } else {
        showConfirmationDialog(
          context: context,
          message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
          confirmText: 'حسناً',
          onConfirm: () {},
        );
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: '. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى',
        confirmText: 'حسناً',
        onConfirm: () {},
      );
    } finally {}
  }

  void _showDetailsDialog({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) {
    final user =
        Provider.of<ProfileProvider>(context, listen: false).name.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * 0.9,
                    height: constraints.maxHeight * 0.5,
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15),
                            CustomText(
                              text: user,
                              size: 20,
                              color: green,
                              weight: FontWeight.bold,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: item['mark'] ?? "غير محدد",
                                  color: words,
                                ),
                                CustomText(
                                  text: "العلامة التجارية",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: item['product_info']['fromYear'] ??
                                      "غير محدد",
                                  color: words,
                                ),
                                CustomText(
                                  text: " : نوع السيارة",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "يوم",
                                      color: words,
                                    ),
                                    SizedBox(width: 2),
                                    CustomText(
                                      text: "${item['warranty'].toString()}",
                                      color: words,
                                    ),
                                  ],
                                ),
                                CustomText(
                                  text: "الكفالة",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: item['note'].isNotEmpty
                                        ? item['note']
                                        : "لا يوجد",
                                    color: words,
                                  ),
                                ),
                                CustomText(text: "الملاحظات"),
                              ],
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Spacer(),
                                (item['img'] != null && item['img'].toString().trim().isNotEmpty)
                                    ? _buildImageRow(
                                        "",
                                        'http://jordancarpart.com/${item['img']}',
                                      )
                                    : CustomText(text: "لا توجد صورة", size: 16),
                                Spacer(),
                                CustomText(text: "الصورة"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalCost(String totalCost) {
    int formattedTotalCost = double.tryParse(totalCost)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار أردني ",
                size: 18,
              ),
              CustomText(
                text: formattedTotalCost.toString(), // تم تحويلها إلى int
                size: 18,
              ),
              CustomText(
                text: " المجموع",
                color: red,
                weight: FontWeight.w900,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageRow(String label, String? imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: label,
          size: 16,
          weight: FontWeight.bold,
        ),
        SizedBox(width: 10),
        imageUrl != null && imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _showImageDialog(imageUrl);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    imageUrl,
                    width: MediaQuery.of(context).size.width * 0.26,
                    height: MediaQuery.of(context).size.width * 0.22,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : CustomText(text: "لا توجد صورة", size: 16),
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

  Widget _buildTableHeader(String text) {
    return Expanded(
      flex: 1,
      child: CustomText(
        text: text,
        size: 16,
        weight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return CustomText(
      text: text,
      size: 14,
      textAlign: TextAlign.center,
    );
  }
}
