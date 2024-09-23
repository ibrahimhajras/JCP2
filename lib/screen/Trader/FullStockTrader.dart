import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:provider/provider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'homeTrader.dart';

class StockViewPage extends StatefulWidget {
  StockViewPage({super.key});

  @override
  State<StockViewPage> createState() => _StockViewPageState();
}

class _StockViewPageState extends State<StockViewPage> {
  TextEditingController search = TextEditingController(text: "بحث");
  bool isEditing = false;
  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    priceController.dispose();
    amountController.dispose();
    super.dispose();
  }

  String title = "",
      title1 = "",
      title2 = "",
      title3 = "",
      title4 = "",
      title5 = "";

  List<String> list = [
    'اختر المركبة',
    'تويوتا',
    'هوندا',
    'نيسان',
    'هيونداي',
    'كيا',
    'بيجو',
    'رينو',
    'ميتسوبيشي',
    'مازدا',
    'سوبارو',
    'فورد',
    'شيفروليه',
    'جي إم سي',
    'مرسيدس بنز',
    'بي إم دبليو',
    'أودي',
    'لكزس',
    'إنفينيتي',
    'بورشه',
    'فولكس فاجن',
    'جيب',
    'رام',
    'فيات',
    'سيتروين',
    'سكودا',
    'سيات',
    'ألفا روميو',
    'لاند روفر',
    'جاجوار',
    'تسلا',
    'بيوك',
    'كاديلاك',
    'شيري',
    'فولفو',
    'سوزوكي',
    'دودج',
    'لوتس',
    'مازيراتي',
    'ماكلارين',
    'بنتلي',
    'رولز رويس',
    'أستون مارتن',
    'لامبورغيني',
    'فيراري',
    'باجاني',
    'بوجاتي',
    'إم جي',
    'أوبل',
    'جيلي',
    'هافال',
    'شانجان',
    'بي واي دي',
    'داتسون',
    'إسكاليد'
  ];
  List<String> list1 = [
    'اختر الفئة',
    'S-Class', // مرسيدس
    'AMG', // مرسيدس
    'M Series', // بي إم دبليو
    'RS', // أودي
    'GT', // فورد
    'Type R', // هوندا
    'STI', // سوبارو
    'Z', // نيسان
    'GTR', // نيسان
    'TRD', // تويوتا
    'Nismo', // نيسان
    'GTI', // فولكس فاجن
    'R', // فولكس فاجن
    'Coupe', // فئة الكوبيه
    'Sedan', // السيدان
    'SUV', // السيارات الرياضية متعددة الاستخدامات
    'Roadster', // سيارات الرودستر المكشوفة
    'Convertible', // سيارات الكشف
    'Hatchback', // الهاتشباك
    'Crossover', // الكروس أوفر
    'Estate', // السيارات العائلية
    'X', // فئة X (بي إم دبليو)
    'F Sport', // لكزس
    'V Series', // كاديلاك
    'GT-R NISMO', // نيسان
    'Raptor', // فورد (فئة الأداء العالي)
    'Trackhawk', // جيب (للأداء العالي)
    'Hellcat', // دودج (للأداء العالي)
    'Vantage', // أستون مارتن
    'GranTurismo', // مازيراتي
    'Speed', // بنتلي (فئة الأداء العالي)
    'SuperSport', // بوجاتي
    'Performante', // لامبورغيني
    'Spider', // فيراري (فئة الأداء العالي)
    'Superleggera' // أستون مارتن (خفيفة الوزن)
  ];
  List<String> list2 = [
    "من",
    "2010",
    "2011",
    "2012",
    "2013",
    "2014",
    "2015",
    "2016",
    "2017",
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025"
  ];
  List<String> list3 = [
    "إلى",
    "2010",
    "2011",
    "2012",
    "2013",
    "2014",
    "2015",
    "2016",
    "2017",
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025"
  ];
  List<String> list4 = ["نوع الوقود", "هايبرد", "بنزين", "كهرباء", "ديزل"];
  List<String> list5 = [
    "حالة القطعة",
    "شركة",
    "تجاري",
    "بلد المنشأ",
    "مستعمل",
    "تجاري 2"
  ];

  bool hide = false;

  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    final url = Uri.parse(
        'http://jordancarpart.com/Api/getproduct2.php?user_id=$userId');
    final response = await http.get(
      url,
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        print(data);
        return data.cast<Map<String, dynamic>>();
      } else {
        ('لا يوجد قطع');
        return [];
      }
    } else {
      ('Failed to load products. Status code: ${response.statusCode}');
      return [];
    }
  }

  void saveChanges(String product_id, Map<String, dynamic> checkboxItem,
      String newPrice, String newAmount) async {
    print(product_id);
    print(checkboxItem['id']);
    print(newPrice);
    print(newAmount);

    final url = Uri.parse('https://jordancarpart.com/Api/updateproduct2.php');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "product_id": product_id,
        "details_id": checkboxItem['id'],
        "price": newPrice,
        "amount": newAmount,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        isEditing = false;
      });
    } else {
      // Handle error
      print('Failed to update the product');
    }
  }

  void deleteProduct(String product_id, String checkboxItem) async {
    final url = Uri.parse('https://jordancarpart.com/Api/deleteProduct2.php');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "product_id": product_id,
        "details_id": checkboxItem,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {});
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Scaffold(
        backgroundColor: white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                _buildHeader(size, user),
                Container(
                  height: size.height * 0.67,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDropdownRow(),
                        _buildSearchField(size),
                        _buildProductList(size,
                            user.user_id),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader(Size size, ProfileProvider user) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.09,
              left: 10,
              right: 10,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TraderInfoPage()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: white,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: Center(
                        child: CustomText(
                          text: "كامل المخزن",
                          color: Color.fromRGBO(255, 255, 255, 1),
                          size: 22,
                          weight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDropdownRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              _buildDropdown(list5, (val) => setState(() => title5 = val!)),
              _buildDropdown(list1, (val) => setState(() => title1 = val!)),
              _buildDropdown(list, (val) => setState(() => title = val!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<String> items, ValueChanged<String?> onChanged) {
    return Flexible(
      flex: 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white, // Adjust color as needed
        child: DropdownButtonFormField<String>(
          padding: EdgeInsets.only(right: 5),
          alignment: Alignment.center,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.keyboard_arrow_down_rounded),
            border: InputBorder.none,
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.black, // Adjust color as needed
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          value: items[0],
          // Set the current value
          isExpanded: true,
          menuMaxHeight: 200,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(10),
          elevation: 10,
          style: TextStyle(color: Colors.black), // Adjust color as needed
        ),
      ),
    );
  }
  Widget _buildSearchField(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      child: Container(
        width: size.width * 0.805,
        decoration: BoxDecoration(
          color: grey,
          border: Border.all(
            color: words,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: TextField(
            controller: search,
            textAlignVertical: TextAlignVertical.center,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    hide ? Container() : Icon(Icons.search),
                    CustomText(
                      text: search.text.isEmpty ? "" : search.text,
                    ),
                  ],
                ),
              ),
              hintText: "",
            ),
            onTap: () {
              setState(() {
                search.text = "";
                hide = true;
                TraderInfoPage.isEnabled = true;
              });
            },
            onChanged: (value) {
              setState(() {});
            },
            onTapOutside: (event) {
              setState(() {
                TraderInfoPage.isEnabled = false;
              });
            },
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w100,
              fontSize: 16,
              fontFamily: "Tajawal",
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildProductList(Size size, String userId) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchProducts(userId),
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No products found'));
        } else {
          final list = snapshot.data!;
          bool hasZeroAmount = false;

          for (var product in list) {
            for (var item in product['checkboxData']) {
              if (item['amount'] == 0) {
                hasZeroAmount = true;
                break;
              }
            }
          }
          if (hasZeroAmount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('تنبيه'),
                    content: Text('لديك كمية لقطعة قد نفذت'),
                    actions: [
                      TextButton(
                        child: Text('موافق'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            });
          }
          print("Fetched products: ${list.length}");
          print("Products data: ${list}");

          List<Map<String, dynamic>> filteredList = list;

          if (title4.isNotEmpty) {
            filteredList = filteredList.where((product) {
              print(
                  "Checking NameCar: ${product['NameCar']} against filter title4: $title4");
              return product['NameCar'] == title4;
            }).toList();
          }

          if (title1.isNotEmpty) {
            filteredList = filteredList.where((product) {
              print(
                  "Checking Category: ${product['Category']} against filter title1: $title1");
              return product['Category'] == title1;
            }).toList();
          }

          final fromYear = int.tryParse(title2);
          final toYear = int.tryParse(title3);
          if (fromYear != null && toYear != null) {
            filteredList = filteredList.where((product) {
              final productFromYear =
              int.tryParse(product['engineSize']?.toString() ?? '');
              final productToYear =
              int.tryParse(product['fuelType']?.toString() ?? '');
              print(
                  "Checking engineSize: $productFromYear and fuelType: $productToYear against range $fromYear to $toYear");
              return productFromYear != null &&
                  productToYear != null &&
                  productFromYear >= fromYear &&
                  productToYear <= toYear;
            }).toList();
          }

          if (title.isNotEmpty) {
            filteredList = filteredList.where((product) {
              print(
                  "Checking fromYear: ${product['fromYear']} against filter title6: $title");
              return product['fromYear'] == title;
            }).toList();
          }

          if (title5.isNotEmpty) {
            filteredList = filteredList.where((product) {
              print("Checking checkboxData for name: $title5");
              return product['checkboxData']?.any((checkboxItem) {
                print("Checking checkboxItem name: ${checkboxItem['name']}");
                return checkboxItem['name'] == title5;
              }) ?? false;
            }).toList();
          }



          print("Filtered products: ${filteredList.length}");
          print("Filtered data: ${filteredList}");
          return Column(
            children: [
              SizedBox(height: 10),
              Container(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: filteredList.expand<Widget>((product) {
                      return product['checkboxData']
                          ?.map<Widget>((checkboxItem) {
                        final TextEditingController priceController =
                        TextEditingController(
                            text: checkboxItem['price'].toString());
                        final TextEditingController amountController =
                        TextEditingController(
                            text: checkboxItem['amount'].toString());
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showDetailsDialog(
                                                context: context,
                                                product: product,
                                                checkboxItem: checkboxItem);
                                          },
                                          child: Image.asset(
                                            'assets/images/iconinfo.png',
                                            width: 24.0,
                                            height: 24.0,
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 0.02,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _showEditProductDialog(
                                                context,
                                                product,
                                                checkboxItem,
                                                priceController,
                                                amountController);
                                          },
                                          child: Image.asset(
                                            'assets/images/05.png',
                                            width: 24.0,
                                            height: 24.0,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.17,
                                    height: 40,
                                    child: Center(
                                      child: CustomText(
                                        text: "${checkboxItem['name']}",
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.17,
                                    height: 40,
                                    child: Center(
                                      child: CustomText(
                                        text: "${double.parse(checkboxItem['price']).toInt()}", // تحويل String إلى double ثم إلى int
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.17,
                                    height: 40,
                                    child: Center(
                                      child: CustomText(
                                        text: "${checkboxItem['amount']}",
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * 0.17,
                                    height: 40,
                                    child: Center(
                                      child: CustomText(
                                        text: product['name'],
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Divider(
                              height: 5,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        );
                      })?.toList() ??
                          [];
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
  void _showDetailsDialog({
    required BuildContext context,
    required Map<String, dynamic> product,
    required Map<String, dynamic> checkboxItem,
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
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 0.4,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: checkboxItem['mark'] ?? "غير محدد",
                            color: words,
                          ),
                          CustomText(
                            text: " : العلامة التجارية",
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: product['fromYear'] ?? "غير محدد",
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
                                text: "شهر",
                                color: words,
                              ),
                              SizedBox(width: 2),
                              CustomText(
                                text: "${checkboxItem['warranty']}",
                                // Display warranty
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: checkboxItem['note'].isNotEmpty
                                ? checkboxItem['note']
                                : 'لا يوجد',
                            color: words,
                          ),
                          CustomText(
                            text: " : الملاحظات",
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      if (checkboxItem['img'].isNotEmpty)
                        _buildImageRow(" ", checkboxItem['img'])
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

  Widget _buildImageRow(String label, String? base64Image) {
    Uint8List? decodedImage;
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        decodedImage = base64Decode(base64Image);
      } catch (e) {
        print("Error decoding base64: $e");
      }
    }
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        decodedImage != null
            ? Image.memory(
          decodedImage,
          width: 100,
          height: 100,
        )
            : Text(
          'لا يوجد صورة',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _showEditProductDialog(
      BuildContext context,
      Map<String, dynamic> product,
      Map<String, dynamic> checkboxItem,
      TextEditingController priceController,
      TextEditingController amountController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                Text("تعديل تفاصيل القطعة",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الكمية',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // تنفيذ العملية هنا
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('تأكيد'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        _showDeleteConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                        foregroundColor: Colors.white,
                      ),
                      child: Text('حذف'),
                    ),

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('هل أنت متأكد من أنك تريد حذف هذا العنصر؟'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                foregroundColor: Colors.white,
              ),
              child: Text('تأكيد الحذف'),
            ),
          ],
        );
      },
    );
  }











}
