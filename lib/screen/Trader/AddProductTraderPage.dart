import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/widget/Inallpage/CustomButton.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
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
  File? _imageFile;
  String? _base64Image;
  final List<String> checkboxLabels = [
    "شركة",
    "تجاري",
    "تجاري 2",
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
                if (!value && checkboxCompleted[index]) {
                  checkboxStates[index] = false;
                  showInfoBox = "";
                } else {
                  checkboxStates[index] = value;
                  if (!value) {
                    showInfoBox = "";
                  } else {
                    showInfoBox = "";
                    checkboxCompleted[index] = true;
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
          buildTextField(
            sizeFactor,
            priceControllers[index],
            'السعر',
            isEnabled: checkboxStates[index],
          ),
          buildTextField(
            sizeFactor,
            amountControllers[index],
            'الكمية',
            isEnabled: checkboxStates[index],
          ),
          Padding(
            padding: EdgeInsets.all(sizeFactor * 8.0),
            child: IconButton(
              icon: Image.asset(
                'assets/images/11.png',
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

  Widget buildTextField(
    double sizeFactor,
    TextEditingController controller,
    String hintText, {
    bool isEnabled = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizeFactor * 8.0),
      child: Container(
        width: sizeFactor * 50,
        height: sizeFactor * 50,
        decoration: BoxDecoration(
          color: isEnabled ? grey : grey,
          borderRadius: BorderRadius.circular(sizeFactor * 10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: sizeFactor * 8.0),
          child: TextField(
            enabled: isEnabled,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(fontSize: sizeFactor * 12),
              contentPadding: EdgeInsets.zero,
            ),
            textAlign: TextAlign.center,
            controller: controller,
          ),
        ),
      ),
    );
  }

  Future<void> submitData(String user_id) async {
    setState(() {
      isLoading = true;
    });
    print(user_id);
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
    };

    for (int i = 0; i < 5; i++) {
      if (checkboxStates[i]) {
        if (priceControllers[i].text.isEmpty ||
            amountControllers[i].text.isEmpty ||
            warrantyControllers[i].text.isEmpty || // تحقق من تعبئة الكفالة
            markControllers[i].text.isEmpty || // تحقق من تعبئة العلامة التجارية
            double.tryParse(priceControllers[i].text) == null ||
            double.tryParse(priceControllers[i].text)! <= 0 ||
            double.tryParse(amountControllers[i].text) == null ||
            double.tryParse(amountControllers[i].text)! <= 0) {
          // إظهار رسالة خطأ إذا كانت الحقول غير مكتملة
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يرجى ملء جميع الحقول المطلوبة للسعر والكمية والعلامة التجارية والكفالة.'),
              backgroundColor: Colors.red,
            ),
          );
          return; // إيقاف العملية إذا كانت الحقول غير مكتملة
        }

        // تحويل الصورة إلى Base64 إذا كانت موجودة
        String? imgBase64;
        if (imageFiles[i] != null) {
          final bytes = await imageFiles[i]!.readAsBytes();
          imgBase64 = base64Encode(bytes);
        }

        // إضافة البيانات إلى القائمة
        data['checkboxData'].add({
          'name': checkboxLabels[i],
          'price': priceControllers[i].text,
          'amount': amountControllers[i].text,
          'warranty': warrantyControllers[i].text,
          'mark': markControllers[i].text,
          'note': noteControllers[i].text,
          'img': imgBase64 ?? '', // إضافة الصورة المشفرة بالـ Base64
        });
      }
    }

    // تحقق مما إذا كانت checkboxData فارغة قبل الإرسال
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
      return; // إيقاف التنفيذ إذا لم يتم تقديم بيانات checkbox
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
        isLoading = false; // إنهاء التحميل
      });
    }
  }
  Widget buildHeader(Size size) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: size.height * 0.05,
                left: size.width * 0.03,
                right: size.width * 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TraderInfoPage(),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: white,
                    size: size.width * 0.07,
                  ),
                ),
              ],
            ),
          ),
          CustomText(
            text: "إضافة معلومات قطعة",
            color: Colors.white,
            size: size.height * 0.025,
          ),
        ],
      ),
    );
  }

  Widget buildForm(Size size, String user_id) {
    double sizeFactor = size.width * 0.0025;
    return Container(
      height: size.height * 0.79,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTextInput(
                "إسم القطعة", name, "مثال: كفه أمامية سفلية يمين", sizeFactor),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCheckboxColumn("مستعمل", 4, sizeFactor),
                buildCheckboxColumn("بلد المنشأ", 3, sizeFactor),
                buildCheckboxColumn("تجاري 2", 2, sizeFactor),
                buildCheckboxColumn("تجاري", 1, sizeFactor),
                buildCheckboxColumn("شركة", 0, sizeFactor),
              ],
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
                            decoration: InputDecoration(
                              labelText: 'بالأشهر',
                              border: OutlineInputBorder(),
                            ),
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
                            decoration: InputDecoration(
                              labelText: 'مثال:',
                              hintText: 'العلامة التجارية',
                              border: OutlineInputBorder(),
                            ),
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
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: sizeFactor * 20),
              Text(
                'صورة القطعة (اختياري)',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: sizeFactor * 16, fontWeight: FontWeight.bold),
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
                              await _getImage(ImageSource.camera,
                                  index); // استخدم الفهرس لتحديد الصورة
                            },
                            child: Icon(
                              Icons.photo_camera,
                              size: 30,
                              color: Colors.red,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _getImage(ImageSource.gallery,
                                  index); // استخدم الفهرس لتحديد الصورة
                            },
                            child: Icon(
                              Icons.image,
                              size: 30,
                              color: Colors.red,
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
        imageFiles[index] = File(pickedFile.path); // تخزين الصورة حسب العنصر
      });
      try {
        final bytes = await imageFiles[index]!.readAsBytes();
        String base64Image = base64Encode(bytes);
        print("Image successfully encoded to Base64 for index $index.");
      } catch (e) {
        print("Error reading the image: $e");
      }
    }
  }

  Widget buildTextInput(String label, TextEditingController controller,
      String hint, double sizeFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizeFactor * 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(right: sizeFactor * 6.5),
            child: CustomText(text: label, size: sizeFactor * 18),
          ),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizeFactor * 10)),
            shadowColor: Colors.black,
            color: white,
            child: TextFormField(
              textAlign: TextAlign.center,
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: sizeFactor * 16,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
    );
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
              color: white,
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