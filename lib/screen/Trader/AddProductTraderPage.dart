import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:jcp/model/JoinTraderModel.dart';
import 'package:jcp/provider/CarProvider.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/provider/ProfileTraderProvider.dart';
import 'package:jcp/provider/TextInputState.dart';
import 'package:jcp/screen/Trader/homeTrader.dart';
import 'package:jcp/widget/Inallpage/CustomButton.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/EngineSizeProvider.dart';
import '../../provider/ImageProviderNotifier.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import 'package:http/http.dart' as http;
import '../../widget/Inallpage/showConfirmationDialog.dart'
    show showConfirmationDialog;
import '../../widget/update.dart';

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

class AddProductTraderPage extends StatefulWidget {
  const AddProductTraderPage({super.key});

  @override
  State<AddProductTraderPage> createState() => _AddProductTraderPageState();
}

class _AddProductTraderPageState extends State<AddProductTraderPage> {
  TextEditingController name = TextEditingController();
  final List<File?> imageFiles = List.generate(5, (_) => null);
  final picker = ImagePicker();
  List<String> listName = [];
  List<String> list1 = [];
  String nameprodct = "";
  String selectedCar = '';
  List<String> parts = [];
  List<String> selectedEngineSizes = [];
  bool isForAllCars = true;

  final List<String> checkboxLabels = [
    "شركة",
    "تجاري",
    "تجاري2",
    "بلد المنشأ",
    "مستعمل"
  ];

  bool _hasPermission(JoinTraderModel? trader, int index) {
    if (trader == null) return false;

    switch (index) {
      case 0: // شركة
        return trader.isCompany;
      case 1: // تجاري
        return trader.isCommercial;
      case 2: // تجاري2
        return trader.isCommercial2;
      case 3: // بلد المنشأ
        return trader.isOriginalCountry;
      case 4: // مستعمل
        return trader.isUsed;
      default:
        return false;
    }
  }

  Future<String?> getLocalVersion() async {
    try {
      final String buildVersion =
          await rootBundle.loadString('assets/version.txt');
      return buildVersion.trim();
    } catch (e) {
      return null;
    }
  }

  Future<String?> getServerVersion() async {
    final url = Uri.parse('https://jordancarpart.com/Api/getversion.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['version']['mobileversion'].toString();
        }
      }
    } catch (e) {}
    return null;
  }

  Future<void> checkAndUpdate(BuildContext context) async {
    String? localVersion = await getLocalVersion();
    String? serverVersion = await getServerVersion();

    if (localVersion != null &&
        serverVersion != null &&
        localVersion != serverVersion) {
      showConfirmationDialog(
        context: context,
        message: "تم إصدار نسخة جديدة من التطبيق. يرجى التحديث الآن",
        confirmText: "تحديث الآن",
        onConfirm: () {
          launchUrl(Uri.parse(
              "https://play.google.com/store/apps/details?id=com.zaid.Jcp.car"));
        },
        cancelText: null,
        onCancel: null,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        checkAndUpdate(context);
        final user = Provider.of<ProfileProvider>(context, listen: false);

        // تفعيل checkboxes بناءً على صلاحيات التاجر
        final traderProvider =
            Provider.of<ProfileTraderProvider>(context, listen: false);
        final trader = traderProvider.trader;
        for (int i = 0; i < 5; i++) {
          if (_hasPermission(trader, i)) {
            checkboxStates[i] = true;
            amountControllers[i].text = "1000";
          } else {
            checkboxStates[i] = false;
          }
        }
        setState(() {});

        Provider.of<CarProvider>(context, listen: false).reset();
        Provider.of<CarProvider>(context, listen: false)
            .fetchCars(user.user_id);

        final engineProvider =
            Provider.of<EngineSizeProvider>(context, listen: false);
        await engineProvider.fetchEngineSizes();

        if (engineProvider.engineSizes.isNotEmpty && mounted) {
          setState(() {
            selectedEngineSizes = List.from(engineProvider.engineSizes);
          });
        }

        Provider.of<ImageProviderNotifier>(context, listen: false)
            .resetImages();
        Provider.of<TextInputState>(context, listen: false).clear();
        setState(() {
          isForAllCars = true;
        });
        await fetchParts();
      }
    });
  }

  Future<void> fetchParts() async {
    try {
      final response = await http.get(
        Uri.parse('https://jordancarpart.com/Api/get_parts.php'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          if (mounted) {
            setState(() {
              parts = List<String>.from(
                jsonResponse['data'].map((item) => item['part_name_ar']),
              );
            });
          }
        } else {
          print('Error: API response success = false');
        }
      } else {
        print('Failed to fetch parts: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching parts: $error');
    }
  }

  final List<String> titles = List.filled(6, "");
  final List<String> fromYearList =
      ["من"] + List.generate(40, (index) => (1988 + index).toString());
  final List<String> toYearList =
      ["إلى"] + List.generate(40, (index) => (1988 + index).toString());

  int? activeCheckboxIndex;

  final List<String> fuelTypeList = [
    'الوقود',
    'Gasoline',
    'Diesel',
    'Electric',
    'Hybrid',
    'plug in'
  ];

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
  List<int?> selectedNumbers = List.filled(5, null);

  final List<bool> checkboxStates = List.generate(5, (_) => false);
  final List<bool> checkboxCompleted = List.generate(5, (_) => false);
  final List<bool> isFirstClick = List.generate(5, (_) => true);

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildHeader(size),
              ),
              Positioned(
                top: size.height * 0.2,
                left: 0,
                right: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: buildForm(size, user.user_id),
                ),
              ),
              if (isLoading) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCheckboxRow(String label, int index, double sizeFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizeFactor * 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Image.asset(
                checkboxStates[index]
                    ? checkboxCompleted[index]
                        ? 'assets/images/addgreen.png'
                        : 'assets/images/addorange.png'
                    : 'assets/images/original.png',
                width: sizeFactor * 30,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();

                if (checkboxStates[index]) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        backgroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 7,
                                color: words,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(255, 255, 255, 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildFields(index, sizeFactor),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: CustomText(
                                      text: "تم",
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {}
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: sizeFactor * 2.0,
                horizontal: sizeFactor * 10.0,
              ),
              child: Container(
                width: sizeFactor * 50,
                height: sizeFactor * 50,
                decoration: BoxDecoration(
                  color:
                      checkboxStates[index] ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(sizeFactor * 10),
                  border: Border.all(
                    color:
                        checkboxStates[index] ? Colors.grey : Colors.grey[50]!,
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: IgnorePointer(
                  ignoring: !checkboxStates[index],
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: amountControllers[index].text.isEmpty
                          ? "1000"
                          : amountControllers[index].text,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      icon: const SizedBox(),
                      alignment: Alignment.center,
                      items: [
                        // خيار "متوفر" بقيمة 1000
                        DropdownMenuItem<String>(
                          value: "1000",
                          child: Center(
                            child: Text(
                              "متوفر",
                              style: TextStyle(
                                fontSize: sizeFactor * 12,
                                fontFamily: 'Tajawal',
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // الأرقام من 1 إلى 50
                        ...List.generate(50, (i) => (i + 1).toString())
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: sizeFactor * 12,
                                  fontFamily: 'Tajawal',
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      selectedItemBuilder: (BuildContext context) {
                        return [
                          // عرض "متوفر" للقيمة 1000
                          Center(
                            child: Text(
                              "متوفر",
                              style: TextStyle(
                                fontSize: sizeFactor * 12,
                                fontFamily: 'Tajawal',
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // عرض الأرقام من 1 إلى 50
                          ...List.generate(50, (i) => (i + 1).toString())
                              .map((String value) {
                            return Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: sizeFactor * 12,
                                  fontFamily: 'Tajawal',
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ];
                      },
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            amountControllers[index].text = newValue;
                            completeField(index);
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomTextField(
              sizeFactor: sizeFactor,
              controller: priceControllers[index],
              hintText: '',
              isEnabled: checkboxStates[index],
              onChanged: (value) => completeField(index),
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              text: label,
              textAlign: TextAlign.center,
              color: Colors.black,
              size: sizeFactor * 12,
            ),
          ),
        ],
      ),
    );
  }

  void completeField(int index) {
    // التحقق من السعر والكمية (دائماً مطلوب)
    bool hasPriceAndAmount = priceControllers[index].text.isNotEmpty &&
        amountControllers[index].text.isNotEmpty &&
        double.tryParse(priceControllers[index].text) != null &&
        double.tryParse(amountControllers[index].text) != null;

    if (!hasPriceAndAmount) {
      setState(() {
        checkboxCompleted[index] = false;
      });
      return;
    }

    // التحقق من الصورة (دائماً مطلوبة للون الأخضر) - الآن نتحقق من وجود صورة واحدة على الأقل
    final imageProvider =
        Provider.of<ImageProviderNotifier>(context, listen: false);
    bool isImagePresent = imageProvider.imageFiles[index].isNotEmpty;
    if (!isImagePresent) {
      setState(() {
        checkboxCompleted[index] = false;
      });
      return;
    }

    // التحقق من العلامة التجارية (مطلوبة فقط إذا isBrandRequired = true)
    final trader =
        Provider.of<ProfileTraderProvider>(context, listen: false).trader;
    if (trader != null && trader.isBrandRequired) {
      bool isMarkPresent = markControllers[index].text.trim().isNotEmpty;
      if (!isMarkPresent) {
        setState(() {
          checkboxCompleted[index] = false;
        });
        return;
      }
    }

    setState(() {
      checkboxCompleted[index] = true;
    });
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black54, dismissible: false),
        Center(child: RotatingImagePage()),
      ],
    );
  }

  Future<void> submitData(String user_id) async {
    final carProvider = Provider.of<CarProvider>(context, listen: false);
    final imageProvider =
        Provider.of<ImageProviderNotifier>(context, listen: false);

    setState(() {
      isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // التحقق من إعداد إخفاء السنوات
    final traderCheck =
        Provider.of<ProfileTraderProvider>(context, listen: false).trader;
    final isYearRangeHidden =
        traderCheck != null && traderCheck.isYearRangeRequired;

    // ✅ تحديد قيم السنوات النهائية
    String finalToYear = titles[4]; // "إلى"
    String finalFromYear = titles[5]; // "من"

    // إذا كانت السنوات مخفية، استخدم سنة السيارة من الاختيار
    if (isYearRangeHidden && titles[2].isNotEmpty && titles[2] != "المركبة") {
      // استخراج السنة من اسم السيارة إذا كانت موجودة
      // أو استخدام قيمة افتراضية
      finalToYear = titles[2]; // يمكن تعديلها حسب البنية
      finalFromYear = titles[2];
    }

    Map<String, dynamic> data = {
      'user_id': user_id,
      'time': DateTime.now().toString(),
      'name': name.text,
      'NameCar': formatFuelType(titles[0]),
      'Category': titles[1],
      'fromYear': titles[2],
      'toYear': selectedEngineSizes,
      'fuelType': finalToYear, // ✅ استخدام القيمة النهائية
      'engineSize': finalFromYear, // ✅ استخدام القيمة النهائية
      'checkboxData': [],
      'token': token,
      'is_for_all_cars':
          carProvider.isChassisRequired ? (isForAllCars ? 1 : 0) : null,
    };

    for (int i = 0; i < 5; i++) {
      // الآن نعتمد على وجود سعر بدلاً من الـ checkbox
      final hasPrice = priceControllers[i].text.isNotEmpty &&
          double.tryParse(priceControllers[i].text) != null &&
          double.tryParse(priceControllers[i].text)! > 0;

      if (hasPrice) {
        // التحقق من الكمية
        if (amountControllers[i].text.isEmpty ||
            double.tryParse(amountControllers[i].text) == null ||
            double.tryParse(amountControllers[i].text)! <= 0) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: CustomText(
              text: "يرجى إضافة الكمية لـ ${checkboxLabels[i]}",
              color: Colors.white,
            ),
            backgroundColor: red,
          ));
          return;
        }

        // ✅ التحقق من الصورة والعلامة التجارية بشكل منفصل
        final trader =
            Provider.of<ProfileTraderProvider>(context, listen: false).trader;
        if (trader != null) {
          // التحقق من الصورة إذا كانت مطلوبة - الآن نتحقق من وجود صورة واحدة على الأقل
          if (trader.isImageRequired && imageProvider.imageFiles[i].isEmpty) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: CustomText(
                text: "يرجى إضافة صورة القطعة (${checkboxLabels[i]})",
                color: Colors.white,
              ),
              backgroundColor: red,
            ));
            return;
          }

          // التحقق من العلامة التجارية إذا كانت مطلوبة
          if (trader.isBrandRequired &&
              markControllers[i].text.trim().isEmpty) {
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: CustomText(
                text: "يرجى إضافة العلامة التجارية (${checkboxLabels[i]})",
                color: Colors.white,
              ),
              backgroundColor: red,
            ));
            return;
          }
        }

        // دمج الصور بصورة واحدة
        String? imgBase64;
        if (imageProvider.imageFiles[i].isNotEmpty) {
          imgBase64 = await imageProvider.getMergedImageBase64(i);
        }

        data['checkboxData'].add({
          'name': checkboxLabels[i],
          'price': priceControllers[i].text,
          'amount': amountControllers[i].text,
          'warranty': warrantyControllers[i].text,
          'mark': markControllers[i].text,
          'note': noteControllers[i].text,
          'img': imgBase64 ?? '',
          'selectNumber': selectedNumbers[i] ?? 1,
        });
      }
    }

    if (data['checkboxData'].isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "يرجى ملء البيانات المطلوبة قبل الإرسال",
            color: Colors.white,
          ),
          backgroundColor: red,
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
        imageProvider.resetImages();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TraderInfoPage(),
          ),
        );
      } else {}
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildChassisOptionsWidget(double sizeFactor) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizeFactor * 20,
        vertical: sizeFactor * 5,
      ),
      child: Container(
        padding: EdgeInsets.all(sizeFactor * 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          border: Border.all(color: green, width: 1.5),
          borderRadius: BorderRadius.circular(sizeFactor * 10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isForAllCars = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: sizeFactor * 10,
                        horizontal: sizeFactor * 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            !isForAllCars ? red.withOpacity(0.1) : Colors.white,
                        border: Border.all(
                          color: !isForAllCars ? red : Colors.grey[400]!,
                          width: !isForAllCars ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(sizeFactor * 8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            !isForAllCars
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: !isForAllCars ? red : Colors.grey[600],
                            size: sizeFactor * 18,
                          ),
                          SizedBox(width: sizeFactor * 6),
                          Flexible(
                            child: CustomText(
                              text: "خاص",
                              color: !isForAllCars ? red : Colors.black87,
                              size: sizeFactor * 12,
                              weight: !isForAllCars
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sizeFactor * 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isForAllCars = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: sizeFactor * 10,
                        horizontal: sizeFactor * 8,
                      ),
                      decoration: BoxDecoration(
                        color: isForAllCars
                            ? green.withOpacity(0.1)
                            : Colors.white,
                        border: Border.all(
                          color: isForAllCars ? green : Colors.grey[400]!,
                          width: isForAllCars ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(sizeFactor * 8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isForAllCars
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isForAllCars ? green : Colors.grey[600],
                            size: sizeFactor * 18,
                          ),
                          SizedBox(width: sizeFactor * 6),
                          Flexible(
                            child: CustomText(
                              text: "عام",
                              color: isForAllCars ? green : Colors.black87,
                              size: sizeFactor * 12,
                              weight: isForAllCars
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
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
      child: Padding(
        padding: EdgeInsets.only(
          top: size.height * 0.075,
          left: 10,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 40),
            CustomText(
              text: "إضافة قطعة",
              color: Colors.white,
              size: 22,
              weight: FontWeight.w900,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child:
                      Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
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
            const SizedBox(height: 20),
            TextInputWidget(
              label: "إسم القطعة",
              controller: name,
              hint: "مثال: كفه أمامية سفلية يمين",
              sizeFactor: 1.0,
              suggestions: parts,
            ),
            Consumer<CarProvider>(
              builder: (context, carProvider, child) {
                return buildDropdownRow(
                  [
                    fuelTypeList,
                    carProvider.categories,
                    carProvider.carNames,
                  ],
                  [0, 1, 2],
                  sizeFactor,
                );
              },
            ),
            Consumer<EngineSizeProvider>(
              builder: (context, engineProvider, child) {
                final traderData =
                    Provider.of<ProfileTraderProvider>(context, listen: false)
                        .trader;
                final hideEngineSize =
                    traderData != null && traderData.isEngineSizeRequired;
                final hideYearRange =
                    traderData != null && traderData.isYearRangeRequired;

                // ✅ إخفاء الـ Row بالكامل إذا كانت كل العناصر مخفية
                if (hideEngineSize && hideYearRange) {
                  return const SizedBox.shrink();
                }

                return buildDropdownRow(
                  [
                    hideEngineSize
                        ? <String>[]
                        : (engineProvider.engineSizes.isEmpty
                            ? ["ح.المحرك"]
                            : engineProvider.engineSizes),
                    toYearList,
                    fromYearList,
                  ],
                  [3, 4, 5],
                  sizeFactor,
                  hideEngineSize: hideEngineSize,
                  hideYearRange: hideYearRange,
                );
              },
            ),
            Consumer<CarProvider>(
              builder: (context, carProvider, child) {
                if (carProvider.isChassisRequired) {
                  return Center(child: _buildChassisOptionsWidget(sizeFactor));
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: sizeFactor * 10),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizeFactor * 10,
                vertical: sizeFactor * 5,
              ),
              child: Container(
                height: size.height * 0.07,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: CustomText(
                            text: "الملاحظات", color: Colors.black, size: 12),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: CustomText(
                            text: "الكمية", color: Colors.black, size: 16),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: CustomText(
                            text: "السعر", color: Colors.black, size: 16),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: CustomText(
                          text: "الكمية",
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(checkboxLabels.length, (index) {
                  final label = checkboxLabels[index];
                  if (_hasPermission(trader, index)) {
                    return buildCheckboxRow(label, index, sizeFactor);
                  }
                  return const SizedBox.shrink();
                }),
              ),
            ),
            SizedBox(height: sizeFactor * 10),
            SizedBox(height: sizeFactor * 25),
            CustomButton(
              text: "اضافة",
              onPressed: () async {
                bool allFieldsValid = true;
                String errorMessage = '';

                // التحقق من حجم المحرك فقط إذا كان الـ dropdown ظاهر
                final traderCheck =
                    Provider.of<ProfileTraderProvider>(context, listen: false)
                        .trader;
                final isEngineSizeHidden =
                    traderCheck != null && traderCheck.isEngineSizeRequired;

                if (!isEngineSizeHidden && selectedEngineSizes.isEmpty) {
                  allFieldsValid = false;
                  errorMessage = "يرجى اختيار ح.المحرك قبل الإضافة.";
                }

                if (!parts.contains(name.text)) {
                  allFieldsValid = false;
                  errorMessage = "يرجى اختيار قيمة من الخيارات الموجودة.";
                }

                if (name.text.isEmpty) {
                  allFieldsValid = false;
                  errorMessage = "يرجى إدخال اسم القطعة.";
                }

                for (int i = 0; i < titles.length; i++) {
                  if (i == 3) continue;

                  if (titles[i].isEmpty ||
                      titles[i] == "المركبة" ||
                      titles[i] == "الفئة" ||
                      titles[i] == "من" ||
                      titles[i] == "إلى" ||
                      titles[i] == "الوقود") {
                    allFieldsValid = false;
                    errorMessage = 'يرجى اختيار قيمة لكل من القائمة المنسدلة.';
                    break;
                  }
                }

                if (allFieldsValid) {
                  await submitData(user_id);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: CustomText(
                          text: errorMessage,
                          color: Colors.white,
                        ),
                        backgroundColor: red,
                      ),
                    );
                  }
                }
              },
            ),
            SizedBox(height: sizeFactor * 25),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 50),
          ],
        ),
      ),
    );
  }

  String hintText2 = "michelin";

  String formatFuelType(String fuel) {
    return fuel.toLowerCase() == "gasoline" ? "Gasoline" : fuel.toLowerCase();
  }

  Widget buildFields(int index, double sizeFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomText(
              text: "${checkboxLabels[index]}",
              color: green,
              size: 18,
            ),
            SizedBox(height: sizeFactor * 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(text: "العدد", size: sizeFactor * 10),
                      DropdownButtonFormField<int>(
                        dropdownColor: Colors.white,
                        value: selectedNumbers[index] ?? 1,
                        onChanged: (value) {
                          setState(() {
                            selectedNumbers[index] = value!;
                          });
                        },
                        items: List.generate(
                          50,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Center(
                              child: CustomText(
                                text: "${i + 1}",
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                          ),
                        ),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        isExpanded: true,
                        alignment: Alignment.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(text: "الكفالة", size: sizeFactor * 10),
                      TextFormField(
                        controller: warrantyControllers[index],
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          label: Align(
                            alignment: Alignment.centerRight, // ✅ محاذاة لليمين
                            child: Text(
                              "بالأيام",
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomText(
                        text: "العلامة التجارية",
                        size: sizeFactor * 10,
                      ),
                      TextFormField(
                        controller: markControllers[index],
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: hintText2,
                          hintMaxLines: 2,
                          // ✅ يعرض سطرين بدل سطر واحد
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Tajawal',
                            overflow: TextOverflow
                                .ellipsis, // لو حبيت تبقيه مقطوع بـ "..." عند اللزوم
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: const OutlineInputBorder(),
                        ),
                        onTap: () {
                          hintText2 = "";
                        },
                        style: const TextStyle(fontFamily: 'Tajawal'),
                        onChanged: (value) {
                          completeField(index);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sizeFactor * 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: RichText(
                  text: TextSpan(
                    text: "إضافة ملاحظة",
                    style: TextStyle(
                      fontSize: sizeFactor * 10,
                      color: Colors.black,
                      fontFamily: 'Tajawal',
                    ),
                    children: [
                      TextSpan(
                        text: " إن وجد", // ملاحظة المسافة قبل "إن"
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sizeFactor * 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: sizeFactor * 5),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizeFactor * 10,
                vertical: sizeFactor * 1,
              ),
              child: TextFormField(
                controller: noteControllers[index],
                maxLines: 3,
                maxLength: 50,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,

                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                onChanged: (_) => completeField(index),
                // ✅ تحديث الحالة عند الكتابة

                decoration: InputDecoration(
                  hintText: "إضافة ملاحظة",
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  hintStyle: TextStyle(
                    fontSize: sizeFactor * 12,
                    color: Colors.grey,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
            SizedBox(height: sizeFactor * 5),
            CustomText(
              text: "صور القطعة",
              size: sizeFactor * 16,
            ),
            SizedBox(height: sizeFactor * 2),
            Consumer<ImageProviderNotifier>(
              builder: (context, imageProvider, child) {
                final images = imageProvider.imageFiles[index];
                return Column(
                  children: [
                    if (images.isNotEmpty) ...[
                      SizedBox(
                        height: 70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: images.asMap().entries.map((entry) {
                            int imgIndex = entry.key;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      images[imgIndex],
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        imageProvider.removeImage(
                                            index, imgIndex);
                                        completeField(index);
                                      },
                                      child: Container(
                                        color: Colors.white.withOpacity(0.7),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    GestureDetector(
                      onTap: () => _showImagePickerDialog(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: red.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_rounded,
                              color: red,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            CustomText(
                              text:
                                  "إضافة (${images.length}/${ImageProviderNotifier.maxImagesPerIndex})",
                              color: red,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: sizeFactor * 20),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera(int index) async {
    // التحقق من صلاحية الكاميرا
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(context);
      return;
    }

    if (!status.isGranted) return;

    final imageProvider =
        Provider.of<ImageProviderNotifier>(context, listen: false);
    if (!imageProvider.canAddMore(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "الحد الأقصى ${ImageProviderNotifier.maxImagesPerIndex} صور",
            color: Colors.white,
          ),
          backgroundColor: red,
        ),
      );
      return;
    }

    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageProvider.addImage(index, File(pickedFile.path));
      completeField(index);
    }
  }

  Future<void> _pickMultipleImages(int index) async {
    // AssetPicker handles permissions automatically

    final imageProvider =
        Provider.of<ImageProviderNotifier>(context, listen: false);
    final remaining = imageProvider.getRemainingSlots(index);
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "الحد الأقصى ${ImageProviderNotifier.maxImagesPerIndex} صور",
            color: Colors.white,
          ),
          backgroundColor: red,
        ),
      );
      return;
    }

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: remaining,
        requestType: RequestType.image,
        themeColor: red,
        textDelegate: const ArabicAssetPickerTextDelegate(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      List<File> newImages = [];
      for (var asset in result) {
        final file = await asset.file;
        if (file != null) {
          newImages.add(file);
        }
      }
      if (newImages.isNotEmpty) {
        imageProvider.addImages(index, newImages);
        completeField(index);
      }
    }
  }

  void _showImagePickerDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: CustomText(text: "اختر الصور"),
          content: CustomText(text: "من الكاميرا أو المعرض"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickImageFromCamera(index);
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
                await _pickMultipleImages(index);
              },
              child: Icon(
                Icons.photo_library,
                size: 30,
                color: button,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDisplayText(List<String> selectedSizes, List<String> allSizes) {
    if (selectedSizes.isEmpty) {
      return "ح.المحرك";
    }

    if (selectedSizes.length == allSizes.length) {
      return "كل الأحجام";
    }

    if (selectedSizes.length > 3) {
      return selectedSizes.take(3).join(", ") + "...";
    }

    return selectedSizes.join(", ");
  }

  Widget buildDropdownRow(
      List<List<String>> options, List<int> selectedIndices, double sizeFactor,
      {bool hideEngineSize = false, bool hideYearRange = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: sizeFactor * 20, vertical: sizeFactor * 10),
      child: Row(
        children: options.asMap().entries.map((entry) {
          int index = entry.key;
          List<String> optionList = entry.value;

          // إذا كان هذا هو dropdown أحجام المحرك
          if (selectedIndices[index] == 3) {
            // إخفاء dropdown حجم المحرك إذا كان hideEngineSize == true
            if (hideEngineSize) {
              return const SizedBox.shrink();
            }
            return Consumer<EngineSizeProvider>(
              builder: (context, engineProvider, child) {
                if (engineProvider.isLoading) {
                  return Expanded(
                    flex: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sizeFactor * 10),
                        side: const BorderSide(color: Colors.black, width: 0.5),
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: RotatingImagePage(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (engineProvider.error.isNotEmpty) {
                  return Expanded(
                    flex: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sizeFactor * 10),
                        side: const BorderSide(color: Colors.red, width: 0.5),
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "",
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "Tajawal",
                            fontSize: sizeFactor * 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext context) {
                          return MultiSelectDropdown(
                            items: engineProvider.engineSizes,
                            selectedValues: selectedEngineSizes,
                            onSelectionChanged: (List<String> selected) {
                              setState(() {
                                selectedEngineSizes = selected;
                              });
                            },
                          );
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sizeFactor * 10),
                        side: const BorderSide(color: Colors.black, width: 0.5),
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black54, size: 24),
                            const SizedBox(width: 6),
                            Expanded(
                              child: AutoSizeText(
                                _getDisplayText(selectedEngineSizes,
                                    engineProvider.engineSizes),
                                maxLines: 1,
                                minFontSize: 8,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: sizeFactor * 9,
                                  color: Colors.black,
                                  fontFamily: "Tajawal",
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // ✅ إخفاء dropdown السنوات إذا كان hideYearRange == true
          String currentValue = titles[selectedIndices[index]];
          if (hideYearRange &&
              (currentValue == "من" || currentValue == "إلى")) {
            return const SizedBox.shrink();
          }

          // باقي الـ dropdowns كما هي
          if (optionList.isEmpty) {
            optionList = [''];
          }

          String initialValue = titles[selectedIndices[index]];
          if (!optionList.contains(initialValue)) {
            initialValue = optionList.first;
          }

          List<String> defaultValues = [
            "المركبة",
            "الفئة",
            "حالة القطعة",
            "من",
            "إلى",
            "الوقود"
          ];

          return Expanded(
            flex: 1,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(sizeFactor * 10),
                side: const BorderSide(color: Colors.black, width: 0.5),
              ),
              elevation: 1,
              color: Colors.white,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  items: optionList.map((String value) {
                    bool isDefault = defaultValues.contains(value);
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AutoSizeText(
                          value,
                          maxLines: 1,
                          minFontSize: 8,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: sizeFactor * 14,
                            color: (initialValue == value && !isDefault)
                                ? Colors.black
                                : Colors.grey,
                            fontFamily: "Tajawal",
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  value: initialValue,
                  isExpanded: true,
                  menuMaxHeight: sizeFactor * 200,
                  onChanged: (val) {
                    setState(() {
                      titles[selectedIndices[index]] = val!;
                      if (selectedIndices[index] == 2 && index == 2) {
                        // عند تغيير السيارة، إعادة تعيين اختيار رقم الشاصي والفئة
                        isForAllCars = true; // القيمة الافتراضية: عام
                        titles[1] = "الفئة"; // إعادة تعيين الفئة
                        Provider.of<CarProvider>(context, listen: false)
                            .selectCar(val);
                      }
                      // عند اختيار الفئة، تحقق من متطلبات رقم الشاصي
                      if (selectedIndices[index] == 1 &&
                          index == 1 &&
                          titles[2].isNotEmpty &&
                          titles[2] != "المركبة") {
                        Provider.of<CarProvider>(context, listen: false)
                            .checkChassisRequirement(titles[2], val);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(sizeFactor * 10),
                  elevation: 10,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Tajawal",
                    fontSize: sizeFactor * 12,
                  ),
                  icon: const Icon(Icons.arrow_drop_down,
                      color: Colors.black54, size: 24),
                  iconEnabledColor: Colors.black,
                  alignment: Alignment.centerRight,
                ),
              ),
            ),
          );
        }).toList(),
      ),
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

class TextInputWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final double sizeFactor;
  final List<String> suggestions;

  const TextInputWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.sizeFactor,
    required this.suggestions,
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
    Update.checkAndUpdate(context);
    _focusNode = FocusNode();
    currentHint = widget.hint;

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          currentHint = '';
        } else if (widget.controller.text.isEmpty) {
          currentHint = widget.hint;
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
    double visibleHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.sizeFactor * 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: widget.sizeFactor * 6.5),
              child: CustomText(
                text: widget.label,
                color: Colors.black,
                size: widget.sizeFactor * 19,
              ),
            ),
            Consumer<TextInputState>(
              builder: (context, textInputState, child) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.sizeFactor * 10),
                  ),
                  shadowColor: Colors.black,
                  color: Colors.white,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase();
                      return widget.suggestions
                          .where((item) => item.toLowerCase().contains(query));
                    },
                    onSelected: (String selection) {
                      widget.controller.text = selection;
                      textInputState.setBorderColor(green); // أخضر عند الاختيار
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: textInputState.borderColor, width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: textInputState.borderColor, width: 2),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: textInputState.borderColor, width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          hintText: currentHint,
                          hintStyle: const TextStyle(
                            color: Color(0xFF8D8D92),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          hintTextDirection: TextDirection.rtl,
                        ),
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: widget.sizeFactor * 16,
                          fontFamily: "Tajawal",
                        ),
                        textDirection: TextDirection.rtl,
                        onChanged: (text) {
                          final suggestions = widget.suggestions;
                          if (suggestions.contains(text.trim())) {
                            textInputState.setBorderColor(green);
                          } else {
                            textInputState.setBorderColor(red);
                          }
                        },
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<String> onSelected,
                        Iterable<String> options) {
                      final itemCount = options.length;
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: visibleHeight * 0.35,
                            color: Colors.white,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: itemCount,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: ListTile(
                                    title: Center(
                                      child: CustomText(
                                        text: option,
                                        textDirection: TextDirection.rtl,
                                        size: widget.sizeFactor *
                                            16, // حجم الخط متناسب
                                      ),
                                    ),
                                    onTap: () {
                                      onSelected(option);
                                      widget.controller.text = option;
                                      textInputState.setBorderColor(green);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final double sizeFactor;
  final TextEditingController controller;
  final String hintText;
  final bool isEnabled;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.sizeFactor,
    required this.controller,
    required this.hintText,
    this.isEnabled = true,
    this.onChanged,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _showDoneButton = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _showDoneButton = _focusNode.hasFocus;
      });
    });
    // إضافة مستمع لتحديث الحالة عند الكتابة
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: widget.sizeFactor * 2.0,
        horizontal: widget.sizeFactor * 10.0,
      ),
      child: Container(
        width: widget.sizeFactor * 50,
        height: widget.sizeFactor * 50,
        decoration: BoxDecoration(
          color: widget.isEnabled ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(widget.sizeFactor * 10),
          border: Border.all(
            // تغيير لون الإطار إلى الأخضر إذا كان الحقل يحتوي على نص
            color: widget.controller.text.isNotEmpty
                ? green
                : (widget.isEnabled ? Colors.grey : Colors.grey[50]!),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.zero,
          child: TextField(
            focusNode: _focusNode,
            enabled: widget.isEnabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: _focusNode.hasFocus ? '' : widget.hintText,
              hintStyle: TextStyle(
                fontSize: widget.sizeFactor * 12,
                color: widget.isEnabled ? Colors.black : Colors.grey,
              ),
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

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items;
  final List<String> selectedValues;
  final Function(List<String>) onSelectionChanged;

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _MultiSelectDropdownState createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  late List<String> selectedItems;

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.selectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomText(
              text: "اختر حجم المحرك",
              color: Colors.black,
              size: 18,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        checkColor: WidgetStateProperty.all(Colors.white),
                        fillColor: WidgetStateProperty.resolveWith<Color?>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return green;
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(text: "كل الأحجام"),
                      ),
                      value: selectedItems.length == widget.items.length,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedItems = List.from(widget.items);
                          } else {
                            selectedItems.clear();
                          }
                          widget.onSelectionChanged(selectedItems);
                        });
                      },
                    ),
                  );
                } else {
                  final item = widget.items[index - 1];
                  final isAllSelected =
                      selectedItems.length == widget.items.length;

                  return Theme(
                    data: Theme.of(context).copyWith(
                      checkboxTheme: CheckboxThemeData(
                        fillColor: WidgetStateProperty.resolveWith((states) {
                          if (isAllSelected) return Colors.grey;
                          if (states.contains(WidgetState.selected))
                            return green;
                          return null;
                        }),
                        checkColor: WidgetStateProperty.all(Colors.white),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Align(
                        alignment: Alignment.topLeft,
                        child: CustomText(
                          text: item,
                          color: isAllSelected ? Colors.grey : Colors.black,
                        ),
                      ),
                      value: selectedItems.contains(item),
                      onChanged: isAllSelected
                          ? null
                          : (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedItems.add(item);
                                } else {
                                  selectedItems.remove(item);
                                }

                                if (selectedItems.length ==
                                    widget.items.length) {
                                  selectedItems = List.from(widget.items);
                                }

                                widget.onSelectionChanged(selectedItems);
                              });
                            },
                    ),
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CustomText(
                text: "تم",
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 35,
          )
        ],
      ),
    );
  }
}
