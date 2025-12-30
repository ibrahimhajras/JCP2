import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/provider/CarProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/widget/EditStockTitleWidget..dart';
import 'package:jcp/widget/FullScreenImageViewer.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';

class EditStockWidget extends StatefulWidget {
  const EditStockWidget({super.key});

  @override
  State<EditStockWidget> createState() => _EditStockWidgetState();
}

class _EditStockWidgetState extends State<EditStockWidget> {
  TextEditingController search = TextEditingController();
  bool isEditing = false;

  Future<String?> _mergeImages(List<File> images) async {
    if (images.isEmpty) return null;

    if (images.length == 1) {
      final bytes = await images[0].readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final resized = img.copyResize(decoded, width: 500, height: 500);
        return base64Encode(img.encodeJpg(resized, quality: 85));
      }
      return base64Encode(bytes);
    }

    List<img.Image> loadedImages = [];
    for (var file in images) {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        loadedImages.add(decoded);
      }
    }

    if (loadedImages.isEmpty) return null;
    if (loadedImages.length == 1) {
      return base64Encode(img.encodeJpg(loadedImages[0], quality: 85));
    }

    const int targetSize = 500;
    List<img.Image> resizedImages = loadedImages.map((image) {
      return img.copyResize(image, width: targetSize, height: targetSize);
    }).toList();

    img.Image mergedImage;

    if (resizedImages.length == 2) {
      // صورتين جنب بعض - مع خلفية بيضاء
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);

      // ملء الخلفية باللون الأبيض
      img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));

      // وضع الصورتين في النص عمودياً
      int centerY = (targetSize * 2 - targetSize) ~/ 2;
      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: centerY);
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: centerY);
    } else if (resizedImages.length == 3) {
      // 3 صور - 2 فوق و 1 تحت بالنص
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);

      // ملء الخلفية باللون الأبيض
      img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));

      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: 0);
      int centerX = (targetSize * 2 - targetSize) ~/ 2;
      img.compositeImage(mergedImage, resizedImages[2], dstX: centerX, dstY: targetSize);
    } else {
      // 4 صور - grid 2x2
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);
      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: 0);
      img.compositeImage(mergedImage, resizedImages[2], dstX: 0, dstY: targetSize);
      img.compositeImage(mergedImage, resizedImages[3], dstX: targetSize, dstY: targetSize);
    }

    final jpgBytes = img.encodeJpg(mergedImage, quality: 85);
    return base64Encode(jpgBytes);
  }

  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  Timer? _debounce;
  int _currentPage = 1;
  int _totalItems = 0;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  double _optionsWidth = 0.0;

  Future<List<Map<String, dynamic>>>? _productListFuture;

  @override
  void initState() {
    super.initState();
    searchFocus = FocusNode();
    fetchParts();
    search.addListener(_onSearchChanged);
    final user = Provider.of<ProfileProvider>(context, listen: false);

    searchQuery = search.text.toLowerCase().trim();
    Future.delayed(Duration.zero, () {
      Provider.of<CarProvider>(context, listen: false).reset();
      Provider.of<CarProvider>(context, listen: false).fetchCars(user.user_id);
    });
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    search.removeListener(_onSearchChanged);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    search.dispose();
    searchFocus.dispose();
    priceController.dispose();
    amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreItems();
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || (_currentPage * 100) >= _totalItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      final newItems = await fetchProducts(
        user.user_id.toString(),
        title,
        title1,
        title5,
        title4,
        title2,
        title3,
        page: _currentPage,
      );

      if (mounted && newItems.isNotEmpty) {
        setState(() {
          _currentPage++;
          _productListFuture = _productListFuture!.then((existingItems) {
            final existingIds = existingItems.map((e) => e['id']).toSet();
            final uniqueNewItems = newItems
                .where((item) => !existingIds.contains(item['id']))
                .toList();
            return [...existingItems, ...uniqueNewItems];
          });
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchProducts(
      String userId,
      String s1,
      String s2,
      String s3,
      String s4,
      String s5,
      String s6, {
        int page = 1,
      }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      Map<String, String> params = {
        'user_id': userId,
        'token': token ?? '',
        'page': page.toString(),
      };

      if (searchQuery.isNotEmpty) params['Nameproduct'] = searchQuery;
      if (s1.isNotEmpty && s1 != 'المركبة') params['fromYear'] = s1;
      if (s2.isNotEmpty && s2 != 'الفئة') params['Category'] = s2;
      if (s3.isNotEmpty && s3 != 'الحالة') params['name'] = s3;
      if (s4.isNotEmpty && s4 != 'الوقود') params['NameCar'] = s4;
      if (s5.isNotEmpty && s5 != 'من') params['engineSize'] = s5;
      if (s6.isNotEmpty && s6 != 'إلى') params['fuelType'] = s6;

      final url = Uri.parse('https://jordancarpart.com/Api/getproduct2.php')
          .replace(queryParameters: params);

      final response = await http.get(url);
      print(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          setState(() {
            _totalItems = jsonResponse['pagination']?['total'] ?? 0;
          });
          List<dynamic> data = jsonResponse['data'];
          return data.cast<Map<String, dynamic>>();
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_productListFuture == null) {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      setState(() {});
    }
  }

  String title = "",
      title1 = "",
      title2 = "",
      title3 = "",
      title4 = "",
      title5 = "";

  final List<String> list2 =
      ["من"] + List.generate(40, (index) => (1988 + index).toString());
  final List<String> list3 =
      ["إلى"] + List.generate(40, (index) => (1988 + index).toString());

  List<String> list4 = [
    "الوقود",
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'Plug in'
  ];

  List<String> list5 = [
    "الحالة",
    "شركة",
    "تجاري",
    "تجاري2",
    "بلد المنشأ",
    "مستعمل",
  ];

  bool _isDialogShown = false;
  bool hide = false;

  Future<bool> _deleteProduct(String productId, String detailsId) async {
    try {
      final url = Uri.parse(
          'https://jordancarpart.com/Api/deleteProduct.php?product_id=$productId&details_id=$detailsId');
      final response = await http.get(
        url,
      );
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              final user = Provider.of<ProfileProvider>(context, listen: false);
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

  Future<bool> saveChanges(
      String product_id,
      Map<String, dynamic> checkboxItem,
      String newPrice,
      String newAmount,
      String newMark,
      String newWarranty,
      String newNumber,
      String newNote,
      String? newImageBase64) async {

    final url = Uri.parse('https://jordancarpart.com/Api/updateproduct.php');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          "product_id": product_id,
          "details_id": checkboxItem['id']?.toString() ?? "",
          "price": newPrice,
          "amount": newAmount,
          "mark": newMark,
          "warranty": newWarranty,
          "number": newNumber,
          "note": newNote,
          "img": newImageBase64 ?? "",
        }),
      );

      print(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (responseData['success'] == true) {
          // Perform refresh immediately without dialog
          setState(() {
            final user = Provider.of<ProfileProvider>(context, listen: false);
            _productListFuture = fetchProducts(user.user_id.toString(), title,
                title1, title5, title4, title2, title3,
                page: _currentPage);
          });
          return true;
        } else {
          showConfirmationDialog(
            context: context,
            message: "فشل التحديث: ${responseData['message'] ?? 'خطأ غير معروف'}",
            confirmText: "حسناً",
            onConfirm: () {},
          );
          return false;
        }

      } else {
        showConfirmationDialog(
          context: context,
          message: "فشل الاتصال بالخادم. رمز الخطأ: ${response.statusCode}",
          confirmText: "حسناً",
          onConfirm: () {},
        );
        return false;
      }
    } catch (e) {
      showConfirmationDialog(
        context: context,
        message: "حدث خطأ: $e",
        confirmText: "حسناً",
        onConfirm: () {},
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Column(
      children: [
        _buildHeader(size, user), // الهيدر
        Expanded(
          child: Column(
            children: [
              _buildDropdownRow(),
              _buildSearchField(size),
              EditStockTitleWidget(
                totalItems: _totalItems,
              ),
              Expanded(
                child: _buildProductList(size, user.user_id),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size, ProfileProvider user) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: const BoxDecoration(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: "التعديل على البضاعة",
                  color: Colors.white,
                  size: 22,
                  weight: FontWeight.w900,
                ),
                const SizedBox(height: 5),
                CustomText(
                  text: user.name, // اسم المستخدم من ProfileProvider
                  color: Colors.white,
                  size: 18,
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
          Consumer<CarProvider>(
            builder: (context, carprovider, child) {
              return Row(
                children: [
                  _buildDropdown(
                      list4, title4, (val) => setState(() => title4 = val!)),
                  _buildDropdown(carprovider.categories, title1,
                          (val) => setState(() => title1 = val!)),
                  _buildDropdown(carprovider.carNames, title, (val) {
                    setState(() {
                      title = val!;
                      Provider.of<CarProvider>(context, listen: false)
                          .selectCar(val!);
                    });
                  }),
                ],
              );
            },
          ),
          Row(
            children: [
              _buildDropdown(
                  list5, title5, (val) => setState(() => title5 = val!)),
              _buildDropdown(
                  list3, title3, (val) => setState(() => title3 = val!)),
              _buildDropdown(
                  list2, title2, (val) => setState(() => title2 = val!)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
      List<String> items,
      String? selectedValue,
      ValueChanged<String?> onChanged,
      ) {
    List<String> uniqueItems =
    items.where((item) => item.isNotEmpty).toSet().toList();

    String? validValue = uniqueItems.contains(selectedValue)
        ? selectedValue
        : uniqueItems.isNotEmpty
        ? uniqueItems[0]
        : null;

    return Flexible(
      flex: 1,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.black, width: 0.5),
        ),
        color: Colors.white,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            items: uniqueItems.map((String value) {
              bool isDefault = [
                "المركبة",
                "الفئة",
                "الحالة",
                "من",
                "إلى",
                "الوقود"
              ].contains(value);
              return DropdownMenuItem<String>(
                value: value,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    text: value,
                    color: (validValue == value && !isDefault)
                        ? Colors.black
                        : Colors.grey,
                    size: 14,
                  ),
                ),
              );
            }).toList(),
            value: validValue,
            isExpanded: true,
            menuMaxHeight: 200,
            onChanged: (String? newValue) {
              if (newValue != null && uniqueItems.contains(newValue)) {
                onChanged(newValue);
              } else {
                onChanged(null);
              }
            },
            borderRadius: BorderRadius.circular(10),
            elevation: 10,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            iconSize: 24,
            iconEnabledColor: Colors.black,
            alignment: Alignment.centerRight,
          ),
        ),
      ),
    );
  }

  List<String> parts = [];
  String searchQuery = "";

  Future<void> fetchParts() async {
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/get_parts.php'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && mounted) {
          setState(() {
            parts = List<String>.from(
              jsonResponse['data'].map((item) => item['part_name_ar']),
            );
          });
        }
      }
    } on TimeoutException {
    } catch (error) {}
  }

  late FocusNode searchFocus;

  Color borderColor = Colors.grey;

  Widget _buildSearchField(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: MaterialButton(
                onPressed: () {
                  final user =
                  Provider.of<ProfileProvider>(context, listen: false);
                  setState(() {
                    _productListFuture = fetchProducts(
                      user.user_id.toString(),
                      title,
                      title1,
                      title5,
                      title4,
                      title2,
                      title3,
                      page: _currentPage,
                    );
                  });
                },
                child: CustomText(
                  text: "بحث",
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Center(
              child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  String query = textEditingValue.text.toLowerCase();

                  final startsWith = parts
                      .where((p) => p.toLowerCase().startsWith(query))
                      .toList();

                  final contains = parts
                      .where((p) =>
                  !p.toLowerCase().startsWith(query) &&
                      p.toLowerCase().contains(query))
                      .toList();

                  return [...startsWith, ...contains];
                },
                onSelected: (value) {
                  setState(() {
                    search.text = value;
                    searchQuery = value.toLowerCase();
                    borderColor = green;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      _optionsWidth = constraints.maxWidth;
                      controller.text = search.text;
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );

                      return TextField(
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          setState(() {
                            search.text = value;
                            searchQuery = value.toLowerCase().trim();
                            borderColor =
                            parts.contains(value.trim()) ? green : Colors.grey;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),

                          prefixIcon: search.text.isEmpty
                              ? const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "بحث تنبؤي",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontFamily: "Tajawal",
                                ),
                              ),
                            ),
                          )
                              : null,

                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor, width: 2),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: "Tajawal",
                        ),
                      );
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  final items = options.toList();

                  if (items.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: _optionsWidth,
                        height: items.length > 4 ? 200 : items.length * 55,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => onSelected(items[index]),
                              child: Container(
                                height: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: CustomText(
                                  text: items[index],
                                  size: 16,
                                  color: Colors.black,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildProductList(Size size, String userId) {
    return SizedBox(
      height: size.height * 0.8,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification.metrics.pixels >=
              scrollNotification.metrics.maxScrollExtent - 100 &&
              !_isLoadingMore &&
              (_currentPage * 100) < _totalItems) {
            _loadMoreItems();
            return true;
          }
          return false;
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _productListFuture,
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _currentPage == 1) {
              return Center(child: RotatingImagePage());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 50),
                    const SizedBox(height: 20),
                    CustomText(
                      text: "فشل تحميل البيانات",
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      text: "الرجاء المحاولة مرة أخرى",
                      size: 16,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final user = Provider.of<ProfileProvider>(context,
                            listen: false);
                        setState(() {
                          _currentPage = 1;
                          _productListFuture = fetchProducts(
                              user.user_id.toString(),
                              title,
                              title1,
                              title5,
                              title4,
                              title2,
                              title3,
                              page: _currentPage);
                        });
                      },
                      child: CustomText(text: "إعادة المحاولة"),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: CustomText(
                  text: "عليك اختيار صفات القطعة ثم الضغط على البحث",
                ),
              );
            }

            final list = snapshot.data!;
            List<Map<String, dynamic>> filteredList = List.from(list);

            // Check for zero quantity items
            bool hasZeroAmount = filteredList.any((product) {
              if (product['checkboxData'] != null &&
                  product['checkboxData'].isNotEmpty) {
                return (product['checkboxData'] as List<dynamic>)
                    .any((checkboxItem) {
                  return int.tryParse(checkboxItem['amount'].toString()) == 0;
                });
              }
              return false;
            });

            if (hasZeroAmount && !_isDialogShown) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _isDialogShown = true;
                showConfirmationDialog(
                  context: context,
                  message: "هناك منتجات انتهت كميتها.",
                  confirmText: "تم",
                  onConfirm: () {},
                  cancelText: '',
                );
              });
            }

            return Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: [
                      ...filteredList
                          .where((product) =>
                      product['checkboxData'] != null &&
                          product['checkboxData'].isNotEmpty)
                          .map((product) {
                        List<Map<String, dynamic>> checkboxData = (product[
                        'checkboxData'] as List<dynamic>)
                            .cast<Map<String, dynamic>>()
                          ..sort((a, b) {
                            int aAmount =
                                int.tryParse(a['amount'].toString()) ?? 0;
                            int bAmount =
                                int.tryParse(b['amount'].toString()) ?? 0;
                            return aAmount.compareTo(bAmount);
                          });

                        return checkboxData.map<Widget>((checkboxItem) {
                          final priceController = TextEditingController(
                            text: double.tryParse(checkboxItem['price'])
                                ?.toStringAsFixed(0) ??
                                checkboxItem['price'],
                          );

                          final amountController = TextEditingController(
                              text: checkboxItem['amount'].toString());

                          // تحديد اللون بناءً على الحالة
                          bool hasImage = checkboxItem['img'] != null &&
                              checkboxItem['img'].toString().isNotEmpty;
                          bool isComplete = hasImage; // Only check for image

                          // Debug: print image status
                          print('Product: ${product['name']}, Has Image: $hasImage, img value: ${checkboxItem['img']}');

                          int amount = int.tryParse(checkboxItem['amount'].toString()) ?? 0;

                          Color textColor;
                          if (amount <= 0) {
                            textColor = Colors.red;
                          } else if (isComplete) {
                            textColor = green;
                          } else {
                            textColor = Colors.black;
                          }

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
                                                  checkboxItem:
                                                  checkboxItem);
                                            },
                                            child: Image.asset(
                                              'assets/images/iconinfo.png',
                                              width: 24.0,
                                              height: 24.0,
                                            ),
                                          ),
                                          SizedBox(
                                              width: size.width * 0.02),
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
                                          ),
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
                                          color: textColor,
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
                                          color: textColor,
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
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: size.width * 0.17,
                                      child: Center(
                                        child: CustomText(
                                          text: product['name'],
                                          size: 15,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Divider(height: 5),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList();
                      })
                          .expand((widget) => widget)
                          .toList(),
                    ],
                  ),
                ),
                if (_isLoadingMore) Center(child: RotatingImagePage()),
                if ((_currentPage * 100) >= _totalItems &&
                    filteredList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      text: "تم عرض جميع القطع",
                      color: Colors.grey,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
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
                            const SizedBox(height: 15),
                            CustomText(
                              text: "تفاصيل القطعة",
                              size: 20,
                              weight: FontWeight.bold,
                            ),
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
                                          const SizedBox(width: 2),
                                          CustomText(
                                            text: checkboxItem['warranty']
                                                .toString(),
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
                                        text: checkboxItem['number'].toString(),
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
                                        text: _getMarkValue(checkboxItem['mark']),
                                        color: words,
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FutureBuilder<String>(
                                  future: fetchImageUrl(checkboxItem['id']),
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
                            const SizedBox(height: 20),
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
                                const SizedBox(width: 8),
                                CustomText(
                                  text: " : نوع السيارة",
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomText(
                                    textAlign: TextAlign.center,
                                    text: checkboxItem['note'].isNotEmpty
                                        ? checkboxItem['note']
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
  String _getMarkValue(dynamic mark) {
    if (mark == null) return "غير محدد";
    if (mark.toString().trim().isEmpty) return "غير محدد";
    return mark.toString();
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

  Widget _buildImageRow(String label, String? imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
          text: label,
          size: 16,
          weight: FontWeight.bold,
        ),
        const SizedBox(width: 10),
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

  bool isDeleting = false;

  void _showEditProductDialog(
      BuildContext context,
      Map<String, dynamic> product,
      Map<String, dynamic> checkboxItem,
      TextEditingController priceController,
      TextEditingController amountController) {
    TextEditingController markController =
    TextEditingController(text: checkboxItem['mark']?.toString() ?? '');
    TextEditingController warrantyController = TextEditingController(
        text: (checkboxItem['warranty']?.toString() ?? '') == "0"
            ? ""
            : (checkboxItem['warranty']?.toString() ?? ''));
    TextEditingController numberController =
    TextEditingController(text: checkboxItem['number']?.toString() ?? '');
    TextEditingController noteController =
    TextEditingController(text: checkboxItem['note']?.toString() ?? '');

    // Handle number selection
    int? selectedNumber;
    try {
      if (checkboxItem['number'] != null) {
        selectedNumber = int.parse(checkboxItem['number'].toString());
      }
    } catch (e) {
      selectedNumber = 1;
    }

    List<File> _selectedImages = [];
    final ImagePicker _picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {

            Future<void> _pickImage(ImageSource source) async {
              if (source == ImageSource.camera) {
                var status = await Permission.camera.status;
                if (status.isDenied) {
                  status = await Permission.camera.request();
                }
                if (status.isPermanentlyDenied) {
                  _showPermissionDialog(context);
                  return;
                }
                if (!status.isGranted) return;
              } else {
                // Gallery
                if (Platform.isAndroid) {
                  if (await Permission.photos.status.isDenied) {
                    await Permission.photos.request();
                  }
                  var status = await Permission.storage.status;
                  if (status.isDenied) {
                    status = await Permission.storage.request();
                  }

                  var photosStatus = await Permission.photos.status;

                  if (status.isPermanentlyDenied && photosStatus.isPermanentlyDenied) {
                    _showPermissionDialog(context);
                    return;
                  }

                  if (!status.isGranted && !photosStatus.isGranted) {
                    if (await Permission.photos.request().isGranted) {
                    } else if (await Permission.storage.request().isGranted) {
                    } else {
                      return;
                    }
                  }
                } else {
                  // iOS
                  var status = await Permission.photos.request();
                  if (status.isPermanentlyDenied) {
                    _showPermissionDialog(context);
                    return;
                  }
                  if (!status.isGranted) return;
                }
              }

              if (_selectedImages.length >= 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("يمكنك إضافة 4 صور كحد أقصى")),
                );
                return;
              }

              if (source == ImageSource.gallery) {
                int remaining = 4 - _selectedImages.length;
                final List<AssetEntity>? result = await AssetPicker.pickAssets(
                  context,
                  pickerConfig: AssetPickerConfig(
                    maxAssets: remaining,
                    requestType: RequestType.image,
                    themeColor: red, // Ensure 'red' is available or use Colors.red
                    textDelegate: const ArabicAssetPickerTextDelegate(),
                  ),
                );

                if (result != null && result.isNotEmpty) {
                  setState(() {
                    for (var asset in result) {
                      // We need to wait for file, but this is inside setState which is sync.
                      // Better to do async work outside setState.
                      // However, for simplicity in this structure:
                      asset.file.then((file) {
                        if (file != null && mounted) {
                          setState(() {
                            _selectedImages.add(file);
                          });
                        }
                      });
                    }
                  });
                }
              } else {
                final XFile? image = await _picker.pickImage(source: source);
                if (image != null) {
                  setState(() {
                    _selectedImages.add(File(image.path));
                  });
                }
              }
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 5, // Slightly thinner border for elegance
                          color: words,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "تعديل ${checkboxItem['name']}",
                            size: 16, // Smaller title
                            weight: FontWeight.bold,
                            color: green,
                          ),

                          Row(
                            children: [
                              Expanded(child: _buildCompactLabelField("العدد",
                                  DropdownButtonFormField<int>(
                                    dropdownColor: Colors.white,
                                    value: selectedNumber,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNumber = value;
                                        numberController.text = value.toString();
                                      });
                                    },
                                    items: List.generate(50,(i) => DropdownMenuItem(value: i + 1,child: Center(child: Text("${i + 1}",style: const TextStyle(fontSize: 12))))),
                                    decoration: _compactInputDecoration(),
                                    isExpanded: true,
                                  )
                              )),
                              const SizedBox(width: 5),
                              Expanded(child: _buildCompactLabelField("الكفالة (أيام)",
                                  TextFormField(
                                    controller: warrantyController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    decoration: _compactInputDecoration(),
                                    style: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                                  )
                              )),
                              const SizedBox(width: 5),
                              Expanded(child: _buildCompactLabelField("العلامة",
                                  TextFormField(
                                    controller: markController,
                                    textAlign: TextAlign.center,
                                    decoration: _compactInputDecoration(),
                                    style: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                                  )
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(child: _buildCompactLabelField("السعر",
                                  TextField(
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: _compactInputDecoration(),
                                    style: const TextStyle(fontSize: 12),
                                  )
                              )),
                              const SizedBox(width: 5),
                              Expanded(child: _buildCompactLabelField("الكمية",
                                  TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: _compactInputDecoration(),
                                    style: const TextStyle(fontSize: 12),
                                  )
                              )),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0, bottom: 2),
                                child: Text("الملاحظات", style: TextStyle(fontSize: 12, fontFamily: 'Tajawal', color: Colors.grey[700])),
                              ),
                              TextFormField(
                                controller: noteController,
                                maxLines: 2,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                decoration: _compactInputDecoration().copyWith(
                                  hintText: "إضافة ملاحظة...",
                                  hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                style: const TextStyle(fontSize: 12, fontFamily: 'Tajawal'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          GestureDetector(
                            onTap: () {
                              if (_selectedImages.length >= 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("الحد الأقصى 4 صور")),
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CupertinoAlertDialog(
                                    title: CustomText(text: "اختر الصورة"),
                                    content: CustomText(text: "الهاتف أو الكاميرا"),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _pickImage(ImageSource.camera);
                                        },
                                        child: Icon(Icons.photo_camera,
                                            size: 25, color: red),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await _pickImage(ImageSource.gallery);
                                        },
                                        child:  Icon(Icons.image,
                                            size: 25, color: red),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Column(
                              children: [
                                // Image Display Area
                                _selectedImages.isNotEmpty
                                    ? SizedBox(
                                  height: 70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: _selectedImages.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(_selectedImages[index],
                                                  height: 60, width: 60, fit: BoxFit.cover),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _selectedImages.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  color: Colors.white.withOpacity(0.7),
                                                  child: const Icon(Icons.close, color: Colors.red, size: 16),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                                    : Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: (checkboxItem['img'] != null && checkboxItem['img'].toString().isNotEmpty)
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      'http://jordancarpart.com/${checkboxItem['img']}',
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: RotatingImagePage(),
                                          ),
                                        );
                                      },
                                      errorBuilder: (c, e, s) => const Icon(
                                          Icons.camera_alt,
                                          size: 30,
                                          color: Colors.grey),
                                    ),
                                  )
                                      : const Icon(Icons.camera_alt,
                                      size: 30, color: Colors.grey),
                                ),

                                const SizedBox(height: 5),
                                if (_selectedImages.length < 4)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo, color: Colors.grey[600], size: 20),
                                      const SizedBox(width: 5),
                                      Text("اضافة صور (${_selectedImages.length}/4)", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Compact Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showConfirmationDialog(
                                    context: context,
                                    message: "تأكيد التعديلات؟",
                                    confirmText: "حفظ",
                                    onConfirm: () async {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      String newPrice = priceController.text;
                                      String newAmount = amountController.text;
                                      String newNumber = selectedNumber != null
                                          ? selectedNumber.toString()
                                          : numberController.text;

                                      String? newImageBase64;
                                      if (_selectedImages.isNotEmpty) {
                                        newImageBase64 = await _mergeImages(_selectedImages);
                                      }

                                      bool success = await saveChanges(
                                          product['id'].toString(),
                                          checkboxItem,
                                          newPrice,
                                          newAmount,
                                          markController.text,
                                          warrantyController.text.isEmpty ? "0" : warrantyController.text,
                                          newNumber,
                                          noteController.text,
                                          newImageBase64);

                                      if (mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                        if (success) {
                                          Navigator.of(context).pop();
                                        }
                                      }
                                    },
                                    cancelText: "إلغاء",
                                    onCancel: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(195, 29, 29, 1),
                                  minimumSize: const Size(100, 35),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("حفظ", style: TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Tajawal')),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () async {
                                  bool? deleteResult = await _confirmDelete(
                                      context, product, checkboxItem);
                                  if (deleteResult == true) {
                                    Navigator.of(context).pop();
                                    if (mounted) {
                                      setState(() {
                                        final user = Provider.of<ProfileProvider>(context, listen: false);
                                        _productListFuture = fetchProducts(user.user_id.toString(), title, title1, title5, title4.toLowerCase() == "gasoline" ? "Gasoline" : title4.toLowerCase(), title2, title3, page: _currentPage);
                                      });
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  minimumSize: const Size(80, 35),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("حذف", style: TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Tajawal')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black45,
                        child: Center(
                          child: RotatingImagePage(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _compactInputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      isDense: true,
    );
  }

  Widget _buildCompactLabelField(String label, Widget child) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontFamily: 'Tajawal', fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        child,
      ],
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
                                product['id'].toString(),
                                checkboxItem['id'].toString());

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
                          child: isDeleting
                              ? RotatingImagePage()
                              : CustomText(
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

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: CustomText(text: "صلاحيات مطلوبة"),
        content: CustomText(
            text:
            "التطبيق يحتاج للوصول إلى الصور/الكاميرا لإتمام هذه العملية. يرجى تفعيل الصلاحية من الإعدادات."),
        actions: [
          TextButton(
            child: CustomText(text: "إلغاء"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: CustomText(text: "الإعدادات", color: Colors.blue),
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
class ArabicAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const ArabicAssetPickerTextDelegate();

  @override
  String get languageCode => 'ar';

  @override
  String get confirm => 'تأكيد';

  @override
  String get cancel => 'إلغاء';

  @override
  String get edit => 'تعديل';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => 'فشل التحميل';

  @override
  String get original => 'الأصل';

  @override
  String get preview => 'معاينة';

  @override
  String get select => 'اختيار';

  @override
  String get emptyList => 'القائمة فارغة';

  @override
  String get unSupportedAssetType => 'نوع غير مدعوم';

  @override
  String get unableToAccessAll => 'لا يمكن الوصول لجميع الملفات';

  @override
  String get viewingLimitedAssetsTip => 'عرض الملفات المتاحة فقط';

  @override
  String get changeAccessibleLimitedAssets => 'تغيير الملفات المتاحة';

  @override
  String get accessAllTip =>
      'التطبيق يمكنه الوصول لبعض الملفات فقط. اذهب للإعدادات للسماح بالوصول لجميع الملفات.';

  @override
  String get goToSystemSettings => 'الذهاب للإعدادات';

  @override
  String get accessLimitedAssets => 'متابعة بصلاحيات محدودة';

  @override
  String get accessiblePathName => 'الملفات المتاحة';

  @override
  String durationIndicatorBuilder(Duration duration) {
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minute:$second';
  }

  @override
  String get sTypeAudioLabel => 'صوت';

  @override
  String get sTypeImageLabel => 'صورة';

  @override
  String get sTypeVideoLabel => 'فيديو';

  @override
  String get sTypeOtherLabel => 'أخرى';

  @override
  AssetPickerTextDelegate get semanticsTextDelegate => this;
}
