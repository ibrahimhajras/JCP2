import 'dart:async'; // Import for Timer
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/widget/EditStockTitleWidget..dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';

class EditStockWidget extends StatefulWidget {
  const EditStockWidget({super.key});

  @override
  State<EditStockWidget> createState() => _EditStockWidgetState();
}

class _EditStockWidgetState extends State<EditStockWidget> {
  TextEditingController search = TextEditingController(text: "بحث");
  bool isEditing = false;
  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Timer? _debounce;

  Future<List<Map<String, dynamic>>>? _productListFuture;

  @override
  void initState() {
    super.initState();
    search.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    search.dispose();
    priceController.dispose();
    amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_productListFuture == null) {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      setState(() {
        _productListFuture = fetchProducts(user.user_id);
      });
    }
  }

  String title = "",
      title1 = "",
      title2 = "",
      title3 = "",
      title4 = "",
      title5 = "";

  List<String> listNmae = [
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

  bool _isDialogShown = false;
  bool hide = false;

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
          print('تم الحذف بنجاح');
          if (mounted) {
            setState(() {
              final user = Provider.of<ProfileProvider>(context, listen: false);
              _productListFuture = fetchProducts(user.user_id);
            });
          }

          return true;
        } else {
          print('فشل الحذف: ${responseData['message']}');
          return false;
        }
      } else {
        print('فشل الحذف. الرمز: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('خطأ أثناء الحذف: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
        'http://jordancarpart.com/Api/getproduct2.php?user_id=$userId&token=$token');
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
    final url = Uri.parse('https://jordancarpart.com/Api/updateproduct2.php');
    final response = await http.post(
      url,
      headers: {
        'Access-Control-Allow-Headers': '*',
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json; charset=UTF-8',
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
        final user = Provider.of<ProfileProvider>(context, listen: false);
        _productListFuture = fetchProducts(user.user_id);
      });
    } else {
      print('Failed to update the product');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return SingleChildScrollView(
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
                    EditStockTitleWidget(),
                    _buildProductList(size, user.user_id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, ProfileProvider user) {
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
              top: size.height * 0.075,
              left: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                SizedBox(width: size.width * 0.2),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: "التعديل على البضاعة",
                      color: Color.fromRGBO(255, 255, 255, 1),
                      size: 22,
                      weight: FontWeight.w900,
                    ),
                    SizedBox(height: 5),
                    CustomText(
                      text: user.name,
                      color: Color.fromRGBO(255, 255, 255, 1),
                      size: 18,
                    ),
                  ],
                ),
                Spacer(),
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
              _buildDropdown(list4, (val) => setState(() => title4 = val!)),
              _buildDropdown(list1, (val) => setState(() => title1 = val!)),
              _buildDropdown(listNmae, (val) => setState(() => title = val!)),
            ],
          ),
          Row(
            children: [
              _buildDropdown(list5, (val) => setState(() => title5 = val!)),
              _buildDropdown(list3, (val) => setState(() => title3 = val!)),
              _buildDropdown(list2, (val) => setState(() => title2 = val!)),
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
        color: Colors.white70,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            value: items[0],
            isExpanded: true,
            menuMaxHeight: 200,
            onChanged: onChanged,
            borderRadius: BorderRadius.circular(10),
            elevation: 10,
            style: TextStyle(color: Colors.black),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            iconSize: 24,
            iconEnabledColor: Colors.black,
            alignment: Alignment.centerRight,
            dropdownColor: Colors.white,
          ),
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
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
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
                    hide
                        ? Container()
                        : const Icon(
                            Icons.search,
                            color: Colors.black,
                          ),
                    CustomText(
                      text: search.text.isEmpty ? "" : search.text,
                      color: Colors.black,
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
            style: const TextStyle(
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
      future: _productListFuture,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: RotatingImagePage());
        } else if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا يوجد منتجات'));
        } else {
          final list = snapshot.data!;
          List<Map<String, dynamic>> filteredList = List.from(list);
          bool isFilterApplied = false;
          if (search.text.isNotEmpty && search.text != 'بحث') {
            filteredList = filteredList.where((product) {
              return product['name'] != null &&
                  product['name']
                      .toString()
                      .toLowerCase()
                      .contains(search.text.toLowerCase());
            }).toList();
            isFilterApplied = true; // الفلتر تم تطبيقه
          }
          if (title.isNotEmpty && title != 'اختر المركبة') {
            filteredList = filteredList.where((product) {
              return product['fromYear'] == title;
            }).toList();
            isFilterApplied = true; // الفلتر تم تطبيقه
          }
          if (title1.isNotEmpty && title1 != 'اختر الفئة') {
            filteredList = filteredList.where((product) {
              return product['Category'] == title1;
            }).toList();
            isFilterApplied = true;
          }
          if (title2.isNotEmpty &&
              title2 != 'من' &&
              title3.isNotEmpty &&
              title3 != 'إلى') {
            int fromYear = int.parse(title2);
            int toYear = int.parse(title3);
            filteredList = filteredList.where((product) {
              int productFromYear =
                  int.tryParse(product['engineSize']?.toString() ?? '0') ?? 0;
              int productToYear =
                  int.tryParse(product['fuelType']?.toString() ?? '0') ?? 0;
              return productFromYear >= fromYear && productToYear <= toYear;
            }).toList();
            isFilterApplied = true;
          }

          if (title4.isNotEmpty && title4 != 'نوع الوقود') {
            filteredList = filteredList.where((product) {
              return product['NameCar'] == title4;
            }).toList();
            isFilterApplied = true;
          }
          if (title5.isNotEmpty && title5 != 'حالة القطعة') {
            filteredList = filteredList.expand<Map<String, dynamic>>((product) {
              if (product['checkboxData'] != null &&
                  product['checkboxData'].isNotEmpty) {
                var checkboxData = (product['checkboxData'] as List<dynamic>)
                    .cast<Map<String, dynamic>>();

                var filteredCheckboxData = checkboxData.where((checkboxItem) {
                  return checkboxItem['name'] == title5;
                }).toList();

                if (filteredCheckboxData.isNotEmpty) {
                  return [
                    {
                      ...product,
                      'checkboxData': filteredCheckboxData,
                    }
                  ];
                }
              }
              return [];
            }).toList();
          } else {
            filteredList = filteredList.map<Map<String, dynamic>>((product) {
              return {
                ...product,
                'checkboxData': product['checkboxData'] ?? [],
              };
            }).toList();
          }
          _checkAndShowOutOfStockDialog(filteredList);

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
                                            size: 15,
                                            color: black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.17,
                                        height: 40,
                                        child: Center(
                                          child: CustomText(
                                            text:
                                                "${double.parse(checkboxItem['price']).toInt()}",
                                            size: 15,
                                            color: black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.17,
                                        height: 40,
                                        child: Center(
                                          child: CustomText(
                                            text: "${checkboxItem['amount']}",
                                            size: 15,
                                            color: black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: size.width * 0.17,
                                        child: Center(
                                          child: CustomText(
                                            text: product['name'],
                                            size: 15,
                                            color: black,
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

  void _checkAndShowOutOfStockDialog(List<Map<String, dynamic>> filteredList) {
    if (_isDialogShown) return;

    Set<String> outOfStockProductNames = {};

    for (var product in filteredList) {
      if (product['checkboxData'] != null &&
          product['checkboxData'].isNotEmpty) {
        for (var checkboxItem in product['checkboxData']) {
          int amount = int.tryParse(checkboxItem['amount'].toString()) ?? 0;
          if (amount == -1) {
            outOfStockProductNames.add(product['name']);
            break;
          }
        }
      }
    }

    if (outOfStockProductNames.isNotEmpty) {
      _isDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOutOfStockDialog(outOfStockProductNames);
      });
    }
  }

  void _showOutOfStockDialog(Set<String> outOfStockProductNames) {
    showConfirmationDialog(
      context: context,
      message:
          'القطعة التالية انتهت كميتها ، يرجى تحديثها:\n${outOfStockProductNames.join(', ')}',
      confirmText: 'حسناً',
      onConfirm: () {
        Navigator.of(context).pop();
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * 0.9, // ضبط عرض مناسب
                    height: constraints.maxHeight * 0.5, // ضبط ارتفاع مناسب
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
                      child: SingleChildScrollView(
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
                            SizedBox(height: 25),
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
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        decodedImage != null
            ? GestureDetector(
                onTap: () {
                  _showImageDialog(decodedImage!);
                },
                child: Image.memory(
                  decodedImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Text(
                'لا يوجد صورة',
                style: TextStyle(fontSize: 16),
              ),
      ],
    );
  }

  void _showImageDialog(Uint8List decodedImage) {
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
              child: Image.memory(
                decodedImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  bool isDeleting = false; // متغير جديد للحذف
  void _showEditProductDialog(
      BuildContext context,
      Map<String, dynamic> product,
      Map<String, dynamic> checkboxItem,
      TextEditingController priceController,
      TextEditingController amountController) {
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
                    Text(
                      "تعديل تفاصيل القطعة",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
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
                            showConfirmationDialog(
                              context: context,
                              message:
                                  'هل تريد تأكيد التعديلات على هذه القطعة؟',
                              confirmText: 'تأكيد',
                              onConfirm: () {
                                String newPrice = priceController.text;
                                String newAmount = amountController.text;
                                saveChanges(
                                  product['id'].toString(),
                                  checkboxItem,
                                  newPrice,
                                  newAmount,
                                );
                                Navigator.of(context).pop();
                              },
                              cancelText: 'إلغاء',
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(195, 29, 29, 1),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('تأكيد'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            // استدعاء دالة تأكيد الحذف
                            bool? deleteResult = await _confirmDelete(
                                context, product, checkboxItem);

                            if (deleteResult == true) {
                              // إغلاق الـ Dialog الحالي
                              Navigator.of(context).pop();

                              // تحديث قائمة المنتجات
                              if (mounted) {
                                setState(() {
                                  final user = Provider.of<ProfileProvider>(
                                      context,
                                      listen: false);
                                  _productListFuture =
                                      fetchProducts(user.user_id);
                                });
                              }
                            }
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
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context,
      Map<String, dynamic> product, Map<String, dynamic> checkboxItem) {
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
                      child: Text(
                        'هل أنت متأكد من أنك تريد حذف هذا العنصر؟',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
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
                          child: Text(
                            'إلغاء',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.03),
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isDeleting = true; // بدء حالة التحميل
                            });
                            bool deleteSuccess = await _deleteProduct(
                                product['id'].toString(),
                                checkboxItem['id'].toString());

                            setState(() {
                              isDeleting = false; // إيقاف حالة التحميل
                            });

                            Navigator.of(context).pop(deleteSuccess);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: isDeleting
                              ? RotatingImagePage()
                              : Text(
                                  'تأكيد الحذف',
                                  style: TextStyle(color: white, fontSize: 15),
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
}
