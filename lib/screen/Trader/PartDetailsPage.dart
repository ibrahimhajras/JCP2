import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:jcp/style/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/JoinTraderModel.dart';
import '../../provider/EngineSizeProvider.dart';
import '../../provider/ImageProviderNotifier.dart';
import '../../provider/ProfileProvider.dart';
import '../../provider/ProfileTraderProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomButton.dart';
import '../../widget/RotatingImagePage.dart' show RotatingImagePage;
import '../../widget/FullScreenImageViewer.dart';
import 'AddProductTraderPage.dart';

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

class PartDetailsPage extends StatefulWidget {
  final Map<String, dynamic> part;

  const PartDetailsPage({super.key, required this.part});

  @override
  State<PartDetailsPage> createState() => _PartDetailsPageState();
}

class _PartDetailsPageState extends State<PartDetailsPage> {
  final List<String> fromYearList =
      ["من"] + List.generate(40, (index) => (1988 + index).toString());
  final List<String> toYearList =
      ["إلى"] + List.generate(40, (index) => (1988 + index).toString());

  bool isLoading = false;
  bool isForAllCars = true;

  String selectedFromYear = "من";
  String selectedToYear = "إلى";
  List<String> selectedEngineSizes = [];
  String hintText2 = "michelin";

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
  final picker = ImagePicker();
  final List<bool> checkboxStates = List.generate(5, (_) => false);
  final List<bool> checkboxCompleted = List.generate(5, (_) => false);
  final List<bool> isFirstClick = List.generate(5, (_) => true);

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
                  color: checkboxStates[index] ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(sizeFactor * 10),
                  border: Border.all(
                    color: checkboxStates[index] ? Colors.grey : Colors.grey[50]!,
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
                onChanged: (_) => completeField(index), // ✅ تحديث الحالة عند الكتابة
                decoration: InputDecoration(
                  hintText: "إضافة ملاحظة",
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                                        imageProvider.removeImage(index, imgIndex);
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
                              text: "إضافة (${images.length}/${ImageProviderNotifier.maxImagesPerIndex})",
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

    final imageProvider = Provider.of<ImageProviderNotifier>(context, listen: false);
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
    // AssetPicker handles permissions internally

    final imageProvider = Provider.of<ImageProviderNotifier>(context, listen: false);
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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      if (mounted) {
        // تصفير الصور القديمة عند فتح الصفحة
        Provider.of<ImageProviderNotifier>(context, listen: false).resetImages();

        // تفعيل checkboxes بناءً على صلاحيات التاجر
        final traderProvider = Provider.of<ProfileTraderProvider>(context, listen: false);
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

        final engineProvider =
            Provider.of<EngineSizeProvider>(context, listen: false);
        await engineProvider.fetchEngineSizes();

        if (engineProvider.engineSizes.isNotEmpty && mounted) {
          setState(() {
            selectedEngineSizes = List.from(engineProvider.engineSizes);
          });
        }
      }
    });
  }

  Widget _buildHeader(Size size, BuildContext context) {
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: CustomText(
          text: title,
          size: 18,
          weight: FontWeight.bold,
          color: title == "المركبة" ? Colors.black : green,
        ),
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomText(
                  color: const Color(0xFF8D8D92),
                  text: "${widget.part['car_name'] ?? ''} "
                      "${widget.part['car_category'] ?? ''} "
                      "${widget.part['fuel_type'] ?? ''} "
                      "${widget.part['car_year'] ?? ''} "
                      "${widget.part['engine_size'] ?? ''}",
                ),
              ],
            ),
            if (widget.part['chassis_number'] != null &&
                widget.part['chassis_number'].toString().trim().isNotEmpty &&
                widget.part['chassis_number'] != "N/A")
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Center(
                  child: CustomText(
                    text: "${widget.part['chassis_number']}",
                    color: const Color(0xFF8D8D92),
                    size: 14,
                    weight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ));
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
                        color: !isForAllCars
                            ? red.withValues(alpha: 0.1)
                            : Colors.white,
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
                            ? green.withValues(alpha: 0.1)
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

  Widget _buildDropdownRow() {
    final size = MediaQuery.of(context).size;
    double sizeFactor = size.width * 0.0025;
    final traderData =
        Provider.of<ProfileTraderProvider>(context, listen: false).trader;
    final hideEngineSize =
        traderData != null && traderData.isEngineSizeRequired;
    final hideYearRange =
        traderData != null && traderData.isYearRangeRequired;

    // ✅ إخفاء الـ Row بالكامل إذا كانت كل العناصر مخفية
    if (hideEngineSize && hideYearRange) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // إخفاء dropdown حجم المحرك إذا كان isEngineSizeRequired == true
          if (!hideEngineSize)
            Consumer<EngineSizeProvider>(
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
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.red, width: 0.5),
                      ),
                      elevation: 1,
                      color: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          "",
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "Tajawal",
                            fontSize: sizeFactor * 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
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
                    child: Container(
                      // ✅ شيل الـ Card مؤقتاً وخلي container مع border
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 0.5),
                      ),
                      alignment: Alignment.center, // ✅ خليه في النص
                      child: FittedBox(
                        // ✅ يخلي النص دايمًا داخل المساحة
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_drop_down,
                                color: Colors.black54, size: 24),
                            const SizedBox(width: 6),
                            Text(
                              _getDisplayText(selectedEngineSizes,
                                  engineProvider.engineSizes),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: sizeFactor * 12,
                                color: Colors.black,
                                fontFamily: "Tajawal",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          // إخفاء dropdown السنوات إذا كان isYearRangeRequired == true
          if (!hideYearRange) ...[
            Expanded(
              child: _buildDropdown(
                items: toYearList,
                value: selectedToYear,
                onChanged: (value) {
                  setState(() {
                    selectedToYear = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: _buildDropdown(
                items: fromYearList,
                value: selectedFromYear,
                onChanged: (value) {
                  setState(() {
                    selectedFromYear = value!;
                  });
                },
              ),
            ),
          ],
        ],
      ),
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

  Widget _buildDropdown({
    required List<String> items,
    required String value,
    required Function(String?) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Align(
                alignment: Alignment.centerRight,
                child: CustomText(
                  text: item,
                  size: 14,
                  color: Colors.black,
                  textAlign: TextAlign.right,
                ),
              ),
            );
          }).toList(),
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          icon: const Icon(Icons.arrow_drop_down,
              color: Colors.black54, size: 24),
          alignment: Alignment.centerRight,
        ),
      ),
    );
  }

  final List<String> checkboxLabels = [
    "شركة",
    "تجاري",
    "تجاري2",
    "بلد المنشأ",
    "مستعمل"
  ];

  // ✅ دالة للتحقق من الصلاحيات بناءً على الـ Boolean Flags
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double sizeFactor = size.width * 0.0025;
    final trader = Provider.of<ProfileTraderProvider>(context).trader;

    return  GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
    },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(size, context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("المركبة"),
                        _buildVehicleInfo(),
                        _buildSectionTitle(widget.part['part_name']),
                        _buildDropdownRow(),
                        if (widget.part['is_chassis_required'] == 1 ||
                            widget.part['is_chassis_required'] == '1')
                          _buildChassisOptionsWidget(sizeFactor),
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
                                        text: "الملاحظات",
                                        color: Colors.black,
                                        size: 12),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: CustomText(
                                        text: "الكمية",
                                        color: Colors.black,
                                        size: 16),
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
                        const SizedBox(height: 16),
                        Center(
                          child: CustomButton(
                            text: "اضافة",
                            onPressed: () async {
                              final user = Provider.of<ProfileProvider>(context,
                                  listen: false);
                              String user_id = user.user_id.toString();
                              bool allFieldsValid = true;
                              String errorMessage = '';

                              final traderCheck =
                                  Provider.of<ProfileTraderProvider>(context,
                                          listen: false)
                                      .trader;
                              final isEngineSizeHidden = traderCheck != null &&
                                  traderCheck.isEngineSizeRequired;

                              if (!isEngineSizeHidden &&
                                  selectedEngineSizes.isEmpty) {
                                allFieldsValid = false;
                                errorMessage = "يرجى اختيار ح.المحرك قبل الإضافة.";
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading)
              const ModalBarrier(
                color: Colors.black45,
                dismissible: false,
              ),
             if (isLoading)
              Center(
                child: RotatingImagePage(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> submitData(String user_id) async {
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

    // ✅ إذا كانت السنوات مخفية، استخدم سنة السيارة تلقائياً
    String finalFromYear = selectedFromYear;
    String finalToYear = selectedToYear;

    if (isYearRangeHidden) {
      String carYear = widget.part['car_year']?.toString() ?? '';
      if (carYear.isNotEmpty) {
        finalFromYear = carYear;
        finalToYear = carYear;
      }
    } else {
      // التحقق من السنوات فقط إذا كانت ظاهرة
      if (selectedFromYear == "من" || selectedToYear == "إلى") {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: ".يرجى اختيار من سنة وإلى سنة قبل الإضافة",
              color: Colors.white,
            ),
            backgroundColor: red,
          ),
        );
        return;
      }

      // التحقق من أن سنة السيارة ضمن النطاق المختار
      int? carYear = int.tryParse(widget.part['car_year']?.toString() ?? '');
      int fromYear = int.parse(selectedFromYear);
      int toYear = int.parse(selectedToYear);

      if (carYear != null && (carYear < fromYear || carYear > toYear)) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text:
                  "سنة السيارة ($carYear) ليست ضمن النطاق المحدد (من $fromYear إلى $toYear)",
              color: Colors.white,
            ),
            backgroundColor: red,
          ),
        );
        return;
      }
    }

    // التحقق من أن حجم المحرك ضمن القائمة المختارة (فقط إذا كان الـ dropdown ظاهر)
    final traderForEngineCheck =
        Provider.of<ProfileTraderProvider>(context, listen: false).trader;
    final isEngineSizeHiddenForSubmit =
        traderForEngineCheck != null && traderForEngineCheck.isEngineSizeRequired;

    if (!isEngineSizeHiddenForSubmit) {
      String? carEngineSize = widget.part['engine_size']?.toString().trim();
      if (carEngineSize != null &&
          carEngineSize.isNotEmpty &&
          !selectedEngineSizes.contains(carEngineSize)) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text:
                  "حجم محرك السيارة ($carEngineSize) ليس ضمن الأحجام المحددة",
              color: Colors.white,
            ),
            backgroundColor: red,
          ),
        );
        return;
      }
    }

    bool isChassisRequired = widget.part['is_chassis_required'] == 1 ||
        widget.part['is_chassis_required'] == '1';

    Map<String, dynamic> data = {
      'user_id': user_id,
      'time': DateTime.now().toString(),
      'name': widget.part['part_name'],
      'NameCar': widget.part['fuel_type'],
      'Category': widget.part['car_category'],
      'fromYear': widget.part['car_name'],
      'toYear': selectedEngineSizes,
      'fuelType': finalToYear,  // ✅ استخدام القيمة النهائية
      'engineSize': finalFromYear,  // ✅ استخدام القيمة النهائية
      'checkboxData': [],
      'token': token,
      'is_for_all_cars': isChassisRequired ? (isForAllCars ? 1 : 0) : null,
    };

    final imageProvider =
        Provider.of<ImageProviderNotifier>(context, listen: false);

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
        final trader = Provider.of<ProfileTraderProvider>(context, listen: false).trader;
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
          if (trader.isBrandRequired && markControllers[i].text.trim().isEmpty) {
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
            text: "يرجى ملء البيانات المطلوبة قبل الإرسال ",
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

      if (response.statusCode == 200) {
        Provider.of<ImageProviderNotifier>(context, listen: false)
            .resetImages();

        Navigator.pop(context, true);
      } else {}
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
