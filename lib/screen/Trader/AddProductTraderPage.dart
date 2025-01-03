import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/widget/Inallpage/CustomButton.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;

class AddProductTraderPage extends StatefulWidget {
  const AddProductTraderPage({super.key});

  @override
  State<AddProductTraderPage> createState() => _AddProductTraderPageState();
}

class _AddProductTraderPageState extends State<AddProductTraderPage> {
  TextEditingController name = TextEditingController();
  final List<File?> imageFiles = List.generate(5, (_) => null);
  final picker = ImagePicker();

  String nameprodct = "";
  final List<String> checkboxLabels = [
    "شركة",
    "تجاري",
    "تجاري2",
    "بلد المنشأ",
    "مستعمل"
  ];

  final List<String> titles = List.filled(6, "");
  final List<String> NameCar = [
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
  final List<String> Category = [
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
    'Trackhawk',
    'Hellcat',
    'Vantage',
    'GranTurismo',
    'Speed',
    'SuperSport',
    'Performante',
    'Spider',
    'Superleggera'
  ];

  final List<String> fromYearList = ["من", "2010", "2011", "2025"];
  final List<String> toYearList = ["إلى", "2010", "2011", "2025"];
  final List<String> fuelTypeList = [
    'نوع الوقود',
    'بنزين',
    'ديزل',
    'كهرباء',
    'هجين (بنزين/كهرباء)',
    'هجين (ديزل/كهرباء)'
  ];
  final List<String> engineSizeList = ["حجم المحرك", "0.8L", "1.0L", "5.0L"];
  final List<TextEditingController> priceControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> amountControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> warrantyControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> markControllers =
      List.generate(5, (_) => TextEditingController());
  final List<TextEditingController> noteControllers =
      List.generate(5, (_) => TextEditingController());

  final List<bool> checkboxStates = List.generate(5, (_) => false);
  final List<bool> checkboxCompleted = List.generate(5, (_) => false);

  String showInfoBox = "";
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildHeader(size),
                  SizedBox(height: size.height * 0.01),
                  buildForm(size, user.user_id),
                ],
              ),
            ),
          ),
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget buildCheckboxColumn(String label, int index, double sizeFactor) {
    return Flexible(
      child: Column(
        children: [
          MSHCheckbox(
            size: sizeFactor * 50,
            value: checkboxStates[index],
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor:
                  checkboxCompleted[index] ? Colors.green : Colors.red,
              uncheckedColor: Colors.grey[300]!,
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: (bool value) {
              setState(() {
                if (value) {
                  for (int i = 0; i < checkboxStates.length; i++) {
                    if (i != index && checkboxStates[i]) {
                      checkboxCompleted[i] = true;
                    }
                  }
                  checkboxStates[index] = true;
                  checkboxCompleted[index] = false;
                  showInfoBox = index.toString();
                } else {
                  checkboxStates[index] = false;
                  checkboxCompleted[index] = false;

                  if (showInfoBox == index.toString()) {
                    showInfoBox = "";
                  }
                }
              });
            },
          ),
          SizedBox(height: sizeFactor * 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black, fontSize: sizeFactor * 12),
          ),
          SizedBox(height: sizeFactor * 10),
          CustomTextField(
            sizeFactor: sizeFactor,
            controller: priceControllers[index],
            hintText: 'السعر',
            isEnabled: checkboxStates[index],
          ),
          CustomTextField(
            sizeFactor: sizeFactor,
            controller: amountControllers[index],
            hintText: 'الكمية',
            isEnabled: checkboxStates[index],
          ),
          Padding(
            padding: EdgeInsets.all(sizeFactor * 8.0),
            child: IconButton(
              icon: Image.asset(
                checkboxStates[index]
                    ? checkboxCompleted[index]
                        ? 'assets/images/addgreen.png'
                        : 'assets/images/addred.png'
                    : 'assets/images/original.png',
                width: sizeFactor * 40,
              ),
              onPressed: () {
                if (checkboxStates[index]) {
                  setState(() {
                    showInfoBox =
                        showInfoBox == index.toString() ? "" : index.toString();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black54, dismissible: false),
        Center(child: RotatingImagePage()),
      ],
    );
  }

  Future<void> submitData(String user_id) async {
    setState(() {
      isLoading = true;
    });
    print(user_id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    Map<String, dynamic> data = {
      'user_id': user_id,
      'time': DateTime.now().toString(),
      'name': name.text,
      'NameCar': titles[0],
      'Category': titles[1],
      'fromYear': titles[2],
      'toYear': titles[3],
      'fuelType': titles[4],
      'engineSize': titles[5],
      'checkboxData': [],
      'token': token
    };

    for (int i = 0; i < 5; i++) {
      if (checkboxStates[i]) {
        if (priceControllers[i].text.isEmpty ||
            amountControllers[i].text.isEmpty ||
            markControllers[i].text.isEmpty ||
            double.tryParse(priceControllers[i].text) == null ||
            double.tryParse(priceControllers[i].text)! <= 0 ||
            double.tryParse(amountControllers[i].text) == null ||
            double.tryParse(amountControllers[i].text)! <= 0) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'يرجى ملء جميع الحقول المطلوبة للسعر والكمية والعلامة التجارية والكفالة.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        String? imgBase64;
        if (imageFiles[i] != null) {
          final bytes = await imageFiles[i]!.readAsBytes();
          imgBase64 = base64Encode(bytes);
        }
        data['checkboxData'].add({
          'name': checkboxLabels[i],
          'price': priceControllers[i].text,
          'amount': amountControllers[i].text,
          'warranty': warrantyControllers[i].text,
          'mark': markControllers[i].text,
          'note': noteControllers[i].text,
          'img': imgBase64 ?? '',
        });
      }
    }
    if (data['checkboxData'].isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى ملء البيانات المطلوبة قبل الإرسال.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String jsonData = jsonEncode(data);

    try {
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/saveproduct2.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonData,
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('تم إرسال البيانات بنجاح');
        print(jsonData);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => TraderInfoPage(),
            ));
      } else {
        print('فشل في إرسال البيانات: ${response.statusCode}');
      }
    } catch (error) {
      print('حدث خطأ أثناء الإرسال: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildHeader(Size size) {
    return CustomHeader(
      size: size,
      title: "إضافة معلومات قطعة",
      notificationIcon: SizedBox.shrink(),
      menuIcon: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_forward_ios_rounded,
          color: white,
          size: size.width * 0.06,
        ),
      ),
    );
  }

  Widget buildForm(Size size, String user_id) {
    final trader = Provider.of<ProfileTraderProvider>(context).trader;

    double sizeFactor = size.width * 0.0025;
    return Container(
      height: size.height * 0.79,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextInputWidget(
              label: "إسم القطعة",
              controller: name,
              hint: "مثال: كفه أمامية سفلية يمين",
              sizeFactor: 1.0, // أو أي قيمة تلائم حجم الشاشة
            ),
            buildDropdownRow(
                [fuelTypeList, Category, NameCar], [0, 1, 2], sizeFactor),
            buildDropdownRow([engineSizeList, toYearList, fromYearList],
                [3, 4, 5], sizeFactor),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: "نوع القطعة", size: sizeFactor * 18)
                ],
              ),
            ),
            SizedBox(height: sizeFactor * 25),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (trader != null &&
                      trader.master.contains(checkboxLabels[3]))
                    buildCheckboxColumn(checkboxLabels[3], 4, sizeFactor),
                  if (trader != null &&
                      trader.master.contains(checkboxLabels[0]))
                    buildCheckboxColumn(checkboxLabels[0], 3, sizeFactor),
                  if (trader != null &&
                      trader.master.contains(checkboxLabels[2]))
                    buildCheckboxColumn(checkboxLabels[2], 1, sizeFactor),
                  if (trader != null &&
                      trader.master.contains(checkboxLabels[4]))
                    buildCheckboxColumn(checkboxLabels[4], 2, sizeFactor),
                  if (trader != null &&
                      trader.master.contains(checkboxLabels[1]))
                    buildCheckboxColumn(checkboxLabels[1], 0, sizeFactor),
                ],
              ),
            ),
            SizedBox(height: sizeFactor * 10),
            if (showInfoBox.isNotEmpty)
              buildFields(int.parse(showInfoBox), sizeFactor),
            SizedBox(height: sizeFactor * 25),
            CustomButton(
              text: "اضافة",
              onPressed: () async {
                bool allFieldsValid = true;
                String errorMessage = '';

                if (name.text.isEmpty) {
                  allFieldsValid = false;
                  errorMessage = 'يرجى إدخال اسم القطعة.';
                }

                for (int i = 0; i < titles.length; i++) {
                  if (titles[i].isEmpty ||
                      titles[i] == "إختر المركبة" ||
                      titles[i] == "الفئة" ||
                      titles[i] == "من" ||
                      titles[i] == "إلى" ||
                      titles[i] == "نوع الوقود" ||
                      titles[i] == "حجم المحرك") {
                    allFieldsValid = false;
                    errorMessage = 'يرجى اختيار قيمة لكل من القائمة المنسدلة.';
                    break;
                  }
                }

                if (allFieldsValid) {
                  await submitData(user_id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget buildFields(int index, double sizeFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizeFactor * 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: sizeFactor * 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        CustomText(text: "الكفالة", size: sizeFactor * 16),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: sizeFactor * 10,
                              vertical: sizeFactor * 5),
                          child: TextFormField(
                            controller: warrantyControllers[index],
                            textDirection: TextDirection.rtl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'بالأشهر',
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: sizeFactor * 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        CustomText(
                            text: "العلامة التجارية", size: sizeFactor * 16),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: sizeFactor * 10,
                              vertical: sizeFactor * 5),
                          child: TextFormField(
                            controller: markControllers[index],
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            decoration: InputDecoration(
                              labelText: 'مثال:',
                              border: OutlineInputBorder(),
                            ),
                            style: TextStyle(fontFamily: 'Tajawal'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sizeFactor * 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'إضافة ملاحظة (إن وجد )',
                  style:
                      TextStyle(color: Colors.grey, fontSize: sizeFactor * 12),
                ),
              ),
              SizedBox(height: sizeFactor * 5),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: sizeFactor * 10, vertical: sizeFactor * 5),
                child: TextFormField(
                  controller: noteControllers[index],
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أدخل ملاحظة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: sizeFactor * 20),
              Padding(
                padding: EdgeInsets.only(top: 10, right: 20),
                child: CustomText(
                  text: "صورة القطعة (اختياري)",
                  color: Color.fromRGBO(0, 0, 0, 1),
                  size: 18,
                ),
              ),
              SizedBox(height: sizeFactor * 10),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text('إختر الصورة من'),
                        content: Text('الهاتف او الكاميرا'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _getImage(ImageSource.camera, index);
                            },
                            child: Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: button,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _getImage(ImageSource.gallery, index);
                            },
                            child: Icon(
                              Icons.image,
                              size: 30,
                              color: button,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: imageFiles[index] != null
                    ? Image.file(
                        imageFiles[index]!,
                        width: 100,
                        height: 100,
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                        size: sizeFactor * 40,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source, int index) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFiles[index] = File(pickedFile.path);
      });
      try {
        final bytes = await imageFiles[index]!.readAsBytes();
        base64Encode(bytes);
        print("Image successfully encoded to Base64 for index $index.");
      } catch (e) {
        print("Error reading the image: $e");
      }
    }
  }

  Widget buildDropdownRow(List<List<String>> options, List<int> selectedIndices,
      double sizeFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sizeFactor * 20, vertical: sizeFactor * 10),
      child: Row(
        children: options.asMap().entries.map((entry) {
          int index = entry.key;
          List<String> optionList = entry.value;
          String initialValue = titles[selectedIndices[index]];
          if (!optionList.contains(initialValue)) {
            initialValue = optionList.first;
          }
          return Flexible(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizeFactor * 10),
              ),
              color: Colors.white,
              child: DropdownButtonFormField<String>(
                padding: EdgeInsets.only(right: sizeFactor * 5),
                alignment: Alignment.center,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                  border: InputBorder.none,
                ),
                items: optionList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    alignment: Alignment.centerRight,
                    child: CustomText(
                        text: value, color: black, size: sizeFactor * 14),
                  );
                }).toList(),
                value: initialValue,
                isExpanded: true,
                menuMaxHeight: sizeFactor * 200,
                icon: Container(),
                iconSize: sizeFactor * 30.0,
                onChanged: (val) {
                  setState(() {
                    titles[selectedIndices[index]] = val!;
                  });
                },
                borderRadius: BorderRadius.circular(sizeFactor * 10),
                elevation: 10,
                style: TextStyle(color: black),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TextInputWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final double sizeFactor;

  const TextInputWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.sizeFactor,
  }) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late FocusNode _focusNode;
  late String currentHint;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    currentHint = widget.hint;

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          currentHint = ''; // إخفاء النص التلميحي عند التركيز
        } else if (widget.controller.text.isEmpty) {
          currentHint = widget.hint; // إعادة النص التلميحي إذا كان الحقل فارغًا
        }
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.sizeFactor * 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: widget.sizeFactor * 6.5),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.sizeFactor * 18,
              ),
            ),
          ),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.sizeFactor * 10),
            ),
            shadowColor: Colors.black,
            color: Colors.white,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: currentHint, // استخدام currentHint المتحكم فيه
                hintStyle: TextStyle(color: Color(0xFF8D8D92)),
              ),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: widget.sizeFactor * 16,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final double sizeFactor;
  final TextEditingController controller;
  final String hintText;
  final bool isEnabled;

  const CustomTextField({
    Key? key,
    required this.sizeFactor,
    required this.controller,
    required this.hintText,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.sizeFactor * 8.0),
      child: Container(
        width: widget.sizeFactor * 50,
        height: widget.sizeFactor * 50,
        decoration: BoxDecoration(
          color: widget.isEnabled ? Colors.white : Colors.white70,
          boxShadow: [
            BoxShadow(
              color: widget.isEnabled ? Colors.black : Colors.grey,
              spreadRadius: 0,
              blurRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: widget.sizeFactor * 0.0),
          child: TextField(
            focusNode: _focusNode,
            enabled: widget.isEnabled,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _focusNode.hasFocus ? '' : widget.hintText,
              hintStyle: TextStyle(
                  fontSize: widget.sizeFactor * 12,
                  color: widget.isEnabled ? Colors.black : Colors.grey),
              contentPadding: EdgeInsets.zero,
            ),
            textAlign: TextAlign.center,
            controller: widget.controller,
          ),
        ),
      ),
    );
  }
}
