import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/FullScreenImageViewer.dart';
import '../../widget/Inallpage/showConfirmationDialog.dart';
import '../../widget/RotatingImagePage.dart';
import 'homeTrader.dart';

class OutOfStockPage extends StatefulWidget {
  const OutOfStockPage({Key? key}) : super(key: key);

  @override
  State<OutOfStockPage> createState() => _OutOfStockPageState();
}

class _OutOfStockPageState extends State<OutOfStockPage> {
  late Future<List<Map<String, dynamic>>> _outOfStockItems;

  @override
  void initState() {
    super.initState();
    _outOfStockItems = fetchOutOfStockItems();
  }

  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isEditing = false;

  Future<List<Map<String, dynamic>>> fetchOutOfStockItems() async {
    final user = Provider.of<ProfileProvider>(context, listen: false);

    final url = Uri.parse(
        "https://jordancarpart.com/Api/Out_of_stock.php?user_id=${user.user_id}");

    try {
      
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
    } catch (e) {
      
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _outOfStockItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: RotatingImagePage());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Center(
                    child: CustomText(
                        text: "لا توجد قطع نفذت كميتها", size: 18, color: red),
                  );
                }
                return ListView(
                  padding: EdgeInsets.all(10),
                  children: [
                    _buildTableHeader(),
                    ...snapshot.data!
                        .map((item) => _buildTableRow(item))
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFFB02D2D),
            Color(0xFFC41D1D),
            Color(0xFF7D0A0A),
          ],
          stops: [0.1587, 0.3988, 0.9722],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.075,
              left: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => TraderInfoPage()),
                      (route) => false,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                CustomText(
                  text: "قطع نفذت كميتها",
                  color: Colors.white,
                  size: 22,
                  weight: FontWeight.w900,
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Center(
                  child: CustomText(
                      text: "تحديث",
                      weight: FontWeight.bold,
                      color: Colors.black26))),
          Expanded(
              child: Center(
                  child: CustomText(text: "الحالة", weight: FontWeight.bold))),
          Expanded(
              child: Center(
                  child: CustomText(text: "الكمية", weight: FontWeight.bold))),
          Expanded(
              child: Center(
                  child:
                      CustomText(text: "إسم القطعة", weight: FontWeight.bold))),
        ],
      ),
    );
  }

  String formatPrice(dynamic price) {
    if (price == null) return "0"; // Handle null values

    double? parsedPrice = double.tryParse(price.toString());
    if (parsedPrice == null)
      return price.toString(); // Return original if not a valid number

    return parsedPrice % 1 == 0
        ? parsedPrice
            .toInt()
            .toString() // Convert to integer if no decimal values
        : parsedPrice.toString(); // Keep decimal if needed
  }

  Widget _buildTableRow(Map<String, dynamic> item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black12))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                  onTap: () {
                    
                    _showEditProductDialog(
                      context,
                      item['product_id'].toString(),
                      item['id'].toString(),
                      formatPrice(item['price']),
                      // Format price correctly
                      item['amount'].toString(),
                      priceController,
                      amountController,
                    );
                  },
                  child: CustomText(
                      text: "تحديث",
                      size: 16,
                      color: green,
                      weight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showDetailsDialog(
                        context: context,
                        product: item,
                      );
                    },
                    child: Image.asset(
                      'assets/images/iconinfo.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                  ),
                  SizedBox(width: 5),
                  Flexible(
                    child: CustomText(
                      text: item['detail_name'] ?? "غير محدد",
                      size: 14,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: 50,
                height: 40,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                child: Center(
                  child: CustomText(
                      text: item['amount'].toString(),
                      size: 16,
                      color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
                child: CustomText(
              text: item['product_name'],
              size: 16,
              color: Colors.red,
            )),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog({
    required BuildContext context,
    required Map<String, dynamic> product,
  }) {
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15),
                            CustomText(
                              text: "تفاصيل القطعة",
                              size: 20,
                              weight: FontWeight.bold,
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomText(text: "الكفالة"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: "يوم", color: words),
                                          SizedBox(width: 2),
                                          CustomText(
                                            text: product['warranty']
                                                    ?.toString() ??
                                                "غير محدد",
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
                                        text: product['number']?.toString() ??
                                            "غير محدد",
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
                                        text: _getSafeMark(product['mark']),
                                        color: words,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<String>(
                                  future: fetchImageUrl(product['id']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(child: RotatingImagePage());
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return CustomText(
                                          text: "لا توجد صورة");
                                    } else {
                                      return _buildImageRow(
                                        "",
                                        'http://jordancarpart.com/${snapshot.data!}',
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text:
                                        "${product['fromYear']} ${product['Category']} ${product['NameCar']} ${product['engineSize']}-${product['fuelType']}" ??
                                            "غير محدد",
                                    color: words,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                SizedBox(width: 8),
                                CustomText(text: " : نوع السيارة"),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomText(
                                    textAlign: TextAlign.center,
                                    text: product['note']?.isNotEmpty == true
                                        ? product['note']
                                        : "لا يوجد ملاحظات",
                                    color: words,
                                  ),
                                ),
                                CustomText(text: "الملاحظات"),
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

  Future<String> fetchImageUrl(int productId) async {
    final url =
        Uri.parse('http://jordancarpart.com/Api/getphoto.php?id=$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      return data['image'];
    } else {
      throw Exception('فشل في تحميل الصورة');
    }
  }
  String _getSafeMark(dynamic mark) {
    if (mark == null) return "غير محدد";
    if (mark.toString().trim().isEmpty) return "غير محدد";
    return mark.toString();
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

  void _showEditProductDialog(
      BuildContext context,
      String productid,
      String productdetailsid,
      String price,
      String amount,
      TextEditingController priceController,
      TextEditingController amountController) {
    priceController.text = (double.parse(price) % 1 == 0)
        ? double.parse(price)
            .toInt()
            .toString() // Convert to int if no decimals
        : double.parse(price).toString(); // Keep decimals if needed
    amountController.text = amount;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    CustomText(
                        text: "تعديل تفاصيل القطعة",
                        size: 20,
                        weight: FontWeight.bold),
                    SizedBox(height: 20),
                    CustomText(text: "السعر"),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: price,
                        hintText: "السعر",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    CustomText(text: "الكمية"),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: amount,
                        hintText: "الكمية",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showConfirmationDialog(
                              context: context,
                              message:
                                  "هل تريد تأكيد التعديلات على هذه القطعة؟",
                              confirmText: "تأكيد",
                              onConfirm: () {
                                String newPrice =
                                    priceController.text.isNotEmpty
                                        ? priceController.text
                                        : price.toString();
                                String newAmount =
                                    amountController.text.isNotEmpty
                                        ? amountController.text
                                        : amount.toString();
                                saveChanges(
                                  productid,
                                  productdetailsid,
                                  newPrice,
                                  newAmount,
                                );
                                Navigator.of(context).pop();
                              },
                              cancelText: "إلغاء",
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: CustomText(
                            text: "تأكيد",
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool? deleteResult = await _confirmDelete(
                                context, productid, productdetailsid);
                            if (deleteResult == true) {
                              Navigator.of(context).pop();
                              if (mounted) {
                                setState(() {
                                  final user = Provider.of<ProfileProvider>(
                                      context,
                                      listen: false);
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: CustomText(
                            text: "حذف",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDelete(
      BuildContext context, String product, String checkboxItem) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            bool isDeleting = false;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomText(
                        text: "هل أنت متأكد من أنك تريد الحذف",
                        size: 16,
                        color: Colors.black,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // إلغاء الحذف
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            text: "إلغاء",
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isDeleting = true;
                            });
                            bool deleteSuccess = await _deleteProduct(
                                product.toString(), checkboxItem.toString());

                            setState(() {
                              isDeleting = false;
                            });

                            Navigator.of(context).pop(deleteSuccess);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: CustomText(
                            text: "تأكيد",
                            color: white,
                            size: 15,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _deleteProduct(String productId, String detailsId) async {
    try {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/deleteProduct.php?product_id=$productId&details_id=$detailsId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          
          if (mounted) {
            setState(() {
              final user = Provider.of<ProfileProvider>(context, listen: false);
              fetchOutOfStockItems();
            });
          }
          return true;
        } else {
          
          return false;
        }
      } else {
        
        return false;
      }
    } catch (e) {
      
      return false;
    }
  }

  void saveChanges(String product_id, String checkboxItem, String newPrice,
      String newAmount) async {
    
    
    
    

    final url = Uri.parse('https://jordancarpart.com/Api/updateproduct.php');
    final response = await http.post(
      url,
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        "product_id": product_id,
        "details_id": checkboxItem,
        "price": newPrice,
        "amount": newAmount,
      }),
    );



    if (response.statusCode == 200) {
      final updatedItems = await fetchOutOfStockItems();

      if (mounted) {
        setState(() {
          isEditing = false;
          _outOfStockItems = Future.value(updatedItems);
        });
      }
    } else {
      
    }
  }
}
