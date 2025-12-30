import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/Pay.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../provider/ProfileProvider.dart';
import '../../../screen/home/homeuser.dart';
import '../../../style/colors.dart';
import '../../FullScreenImageViewer.dart';

class OrderDetailsPage_Green extends StatefulWidget {
  final Map<String, dynamic> orderData;

  OrderDetailsPage_Green({required this.orderData});

  @override
  State<OrderDetailsPage_Green> createState() => _OrderDetailsPage_GreenState();
}

class _OrderDetailsPage_GreenState extends State<OrderDetailsPage_Green> {
  bool _checkingPayment = true; // جاري التحقق
  bool _allowBuild = false; // هل نسمح ببناء الصفحة؟

  @override
  void initState() {
    super.initState();
    int orderId = widget.orderData['header']['orderId'];
    checkPaymentStatus(orderId);
  }

  void checkPaymentStatus(int orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/check_payment.php?order_id=$orderId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          bool isConfirmed = data['isConfirmed'];
          int bill_id = data['bill_id'] ?? 0;

          if (!isConfirmed) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PayPage(orderId: orderId, billId: bill_id),
                ),
              );
            });
            return;
          } else {
            _allowBuild = true;
          }
        }
      }
    } catch (e) {}

    setState(() {
      _checkingPayment = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Map<String, dynamic> header = widget.orderData["header"] ?? {};
    List<dynamic> items = widget.orderData["items"] ?? [];

    double totalCost =
        double.tryParse(header['totalCost']?.toString() ?? "0.0") ?? 0.0;

    if (_checkingPayment) {
      return Scaffold(
        body: Center(child: RotatingImagePage()),
      );
    }

    return Scaffold(
      backgroundColor: white,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: _buildHeader(size, context)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                          child: CustomText(
                              text: 'التوصيل',
                              size: 15,
                              weight: FontWeight.bold),
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
                              child: CustomText(
                                  text: header['deliveryType'] ?? 'غير متوفر',
                                  size: 15,
                                  weight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: CustomText(
                            text: 'التوصيل',
                            size: 15,
                            weight: FontWeight.bold,
                            color: Colors.white,
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
                                text: "  التوصيل",
                                color: red,
                                weight: FontWeight.w900,
                                size: 18,
                              ),
                              CustomText(
                                text:
                                "${int.parse(header['deliveryCost'].toString().replaceAll(',', '').split('.')[0])}",
                                size: 18,
                              ),
                              CustomText(
                                text: " دينار أردني ",
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                                  text: "${totalCost.toInt()}", size: 18),
                              CustomText(
                                text: " دينار أردني ",
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return Container(
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
            fontFamily: "Tajawal",
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSelectedItemsList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    if (widget.orderData.containsKey("items") &&
        widget.orderData["items"] != null) {
      List<dynamic> items = widget.orderData["items"] as List<dynamic>;

      if (items.isNotEmpty) {
        Map<String, List<dynamic>> groupedItems = {};

        for (var item in items) {
          String storePhone = item['store_info']?['phone'] ?? 'unknown';
          if (!groupedItems.containsKey(storePhone)) {
            groupedItems[storePhone] = [];
          }
          groupedItems[storePhone]!.add(item);
        }

        List<Widget> widgets = [];

        groupedItems.forEach((storePhone, items) {
          for (var item in items) {
            Map<String, dynamic> productDetails = item['product_details'] ?? {};
            Map<String, dynamic> productInfo = item['product_info'] ?? {};
            String productName = productInfo['name'] ?? 'N/A';
            String productType = productDetails['name'] ?? 'N/A';
            double basePrice =
                double.tryParse(productDetails['price']?.toString() ?? '0') ??
                    0;
            double adjustedPrice =
            (basePrice + (basePrice * 0.08)).ceilToDouble();
            String priceText =
            adjustedPrice > 0 ? adjustedPrice.toInt().toString() : "N/A";

            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
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
                              text: productName,
                              size: 15,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 120,
                              child: CustomText(
                                text: productType,
                                size: 15,
                                weight: FontWeight.bold,
                              ),
                            ),
                            Card(
                              color: Colors.green,
                              child: SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomText(
                                    text: priceText,
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
                            icon: Image.asset(
                              'assets/images/iconinfo.png',
                              width: double.infinity,
                              height: screenWidth * 0.06,
                            ),
                            onPressed: () => _showItemDetails(context, item),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            );
          }
          Map<String, dynamic> storeInfo = items.first['store_info'] ?? {};
          String storeName = storeInfo['name'] ?? 'N/A';
          String storeAddress = storeInfo['full_address'] ?? 'N/A';
          String storeLocation = storeInfo['location'] ?? 'N/A';

          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: buildStoreInfoCard(
                name: storeName,
                phone: storePhone,
                fullAddress: storeAddress,
                location: storeLocation,
              ),
            ),
          );
        });

        return widgets;
      } else {
        return [Center(child: Text("لا توجد عناصر مختارة"))];
      }
    } else {
      return [Center(child: Text("لا توجد عناصر مختارة"))];
    }
  }

  Widget buildStoreInfoCard({
    required String name,
    required String phone,
    required String fullAddress,
    required String location,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomText(
                      text: name,
                      size: 16,
                      color: words,
                    ),
                    SizedBox(width: 5),
                    CustomText(
                      text: "0" + phone,
                      size: 15,
                      color: words,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                CustomText(
                  text: fullAddress,
                  textAlign: TextAlign.right,
                  size: 14,
                  color: words,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () async {
                await launchUrl(Uri.parse(location),
                    mode: LaunchMode.externalApplication);
                throw 'Could not launch Google Maps';
              },
              child: SvgPicture.asset(
                'assets/svg/location_icon.svg',
                width: 32,
                height: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    Map<String, dynamic> productDetails = item['product_details'] ?? {};
    Map<String, dynamic> productInfo = item['product_info'] ?? {};

    String productType = productDetails['name'] ?? 'N/A';
    int warranty = int.tryParse(productDetails['warranty']?.toString() ?? '0') ?? 0;
    String mark = productDetails['mark']?.toString() ?? 'N/A';
    String note = productDetails['note'] ?? 'لا توجد ملاحظات';
    String imgUrl = productDetails['img'] ?? '';
    int number = productDetails['number'] ?? 1;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            final user = Provider.of<ProfileProvider>(context).name.toString();
            return Dialog(
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
                                      text: warranty == 0 ?"غير محدد" : "يوم",
                                      color: words,
                                    ),
                                    SizedBox(width: 2),
                                    warranty == 0
                                        ? SizedBox()
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
                                CustomText(text: "العدد"),
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (imgUrl.isNotEmpty)
                            _buildImageRow("",
                                'https://jordancarpart.com/${imgUrl}', context)
                          else
                            CustomText(
                              text: "لا يوجد صورة",
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
                      SizedBox(height: 15),
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

  Widget _buildOrderDetails(Size size) {
    if (widget.orderData.isEmpty || widget.orderData["header"] == null)
      return Container();
    final header = widget.orderData["header"];
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
                    text:
                    "${header["Enginetype"]} "
                        "${header["Enginecategory"]} "
                        "${header["Engineyear"]} "
                        "${header["Fueltype"]} "
                        "${header["Enginesize"] == "N/A" ? "" : header["Enginesize"]}",
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _buildImageRow(String label, String? imageUrl, BuildContext context) {
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
            _showImageDialog(imageUrl, context);
          },
          child: _SmartImage(
            imageUrl: imageUrl,
            width: MediaQuery.of(context).size.width * 0.26,
            height: MediaQuery.of(context).size.width * 0.22,
            borderRadius: 20,
          ),
        )
            : CustomText(text: "لا توجد صورة", size: 16),
      ],
    );
  }

  void _showImageDialog(String imageUrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullScreenImageViewer(imageUrl: imageUrl);
      },
    );
  }
}

class _SmartImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  const _SmartImage({
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 10,
  });

  @override
  State<_SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<_SmartImage> {
  bool _isImageLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!_isImageLoaded)
          RotatingImagePage(), // ✅ عرض التحميل فقط عند الحاجة
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Image.network(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                Future.microtask(() {
                  if (!_isImageLoaded) {
                    setState(() {
                      _isImageLoaded = true;
                    });
                  }
                });
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) => CustomText(
              text: 'خطأ في تحميل الصورة',
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
