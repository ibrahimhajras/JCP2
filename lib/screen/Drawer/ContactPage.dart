import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:jcp/model/CommentModel.dart';
import 'package:jcp/provider/ProfileProvider.dart';
import 'package:jcp/screen/home/homeuser.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';

import '../../widget/Inallpage/CustomButton.dart';

// Arabic Text Delegate for Asset Picker
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

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _feedBack = TextEditingController();
  final TextEditingController _feedMessage = TextEditingController();
  bool isLoading = false;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  static const int _maxImages = 5;

  Future<void> _pickImageFromCamera() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "الحد الأقصى $_maxImages صور",
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final remaining = _maxImages - _selectedImages.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: "الحد الأقصى $_maxImages صور",
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final List<AssetEntity>? result = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: remaining,
        requestType: RequestType.image,
        themeColor: const Color.fromRGBO(195, 29, 29, 1),
        textDelegate: const ArabicAssetPickerTextDelegate(),
      ),
    );

    if (result != null && result.isNotEmpty) {
      for (var asset in result) {
        final file = await asset.file;
        if (file != null && _selectedImages.length < _maxImages) {
          setState(() {
            _selectedImages.add(file);
          });
        }
      }
    }
  }

  void _showImagePickerDialog() {
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
                await _pickImageFromCamera();
              },
              child: const Icon(
                Icons.photo_camera,
                size: 30,
                color: Color.fromRGBO(195, 29, 29, 1),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickMultipleImages();
              },
              child: const Icon(
                Icons.photo_library,
                size: 30,
                color: Color.fromRGBO(195, 29, 29, 1),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> submitComment(CommentModel comment, BuildContext context) async {
    setState(() => isLoading = true);

    try {
      List<String> imagesBase64 = [];

      for (final image in _selectedImages) {
        final bytes = await image.readAsBytes();
        imagesBase64.add(base64Encode(bytes));
      }

      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/contactUs.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": comment.title,
          "comment": comment.comment,
          "name": comment.name,
          "address": comment.address,
          "user_id": comment.uid,
          "phone": comment.phone,
          "time": DateTime.now().toIso8601String(),
          "images": imagesBase64,
        }),
      );

      setState(() => isLoading = false);

      final data = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        _selectedImages.clear();
        _feedBack.clear();
        _feedMessage.clear();

        if (!mounted) return;
        final size = MediaQuery.of(context).size;
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: size.height * 0.5,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.03),
                    Center(
                      child: Image.asset(
                        "assets/images/done-icon 1.png",
                        height: size.height * 0.15,
                        width: size.width * 0.3,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    CustomText(
                      text: "تم ارسال ملاحضاتك بنجاح",
                      size: size.width * 0.06,
                    ),
                    SizedBox(height: size.height * 0.02),
                    Expanded(
                      child: CustomText(
                        text: "سوف يتم التواصل معك في اقرب وقت",
                        size: size.width * 0.06,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    MaterialButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePage(page: 3)),
                              (Route<dynamic> route) => false,
                        );
                      },
                      height: size.height * 0.06,
                      minWidth: size.width * 0.7,
                      color: const Color.fromRGBO(195, 29, 29, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: CustomText(
                        text: "رجوع",
                        color: white,
                        size: size.width * 0.05,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      } else {
        throw Exception("API error");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل الإرسال")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<ProfileProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          return true;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(page: 3),
            ),
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      height: size.height * 0.20,
                      width: size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [primary1, primary2, primary3]),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: "تواصل معنا",
                              color: Colors.white,
                              size: size.width * 0.06,
                            ),
                            SizedBox(width: size.width * 0.2),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: IconButton(
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const HomePage(page: 3),
                                      ),
                                    );
                                  }
                                },
                                icon: Icon(Icons.arrow_forward_ios_rounded,
                                    color: white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: "الموضوع", size: 18),
                          CustomHintTextField(
                            hintText: " الموضوع ",
                            controller: _feedBack,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: "الرسالة", size: 18),
                          CustomHintTextField(
                            hintText: " الرسالة ",
                            controller: _feedMessage,
                            maxLines: 10,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: "إضافة صور (اختياري)", size: 18),
                          const SizedBox(height: 8),
                          _buildImageSection(size),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 35),
                      child: CustomButton(
                        height: 50,
                        minWidth: size.width * 0.9,
                        text: "ارسل",
                        onPressed: () async {
                          final comment = CommentModel(
                            title: _feedBack.text,
                            comment: _feedMessage.text,
                            name: user.name,
                            address: user.city,
                            uid: user.user_id,
                            phone: user.phone,
                            time: DateTime.now(),
                          );

                          await submitComment(comment, context);
                          _feedBack.clear();
                          _feedMessage.clear();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        const ModalBarrier(color: Colors.black54, dismissible: false),
        Center(
          child: RotatingImagePage(),
        ),
      ],
    );
  }

  Widget _buildImageSection(Size size) {
    return Card(
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white,
      child: Container(
        width: size.width,
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if (_selectedImages.isNotEmpty) ...[
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImages[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            GestureDetector(
              onTap: _showImagePickerDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromRGBO(195, 29, 29, 0.5),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_rounded,
                      color: Color.fromRGBO(195, 29, 29, 1),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    CustomText(
                      text: _selectedImages.isEmpty
                          ? "اضغط لإضافة صور"
                          : "إضافة صورة أخرى (${_selectedImages.length}/$_maxImages)",
                      color: const Color.fromRGBO(195, 29, 29, 1),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomHintTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final int maxLines;

  const CustomHintTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  _CustomHintTextFieldState createState() => _CustomHintTextFieldState();
}

class _CustomHintTextFieldState extends State<CustomHintTextField> {
  late FocusNode _focusNode;
  late String currentHintText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    currentHintText = widget.hintText;

    _focusNode.addListener(() {
      setState(() {
        if (_focusNode.hasFocus) {
          currentHintText = ''; // إخفاء hint عند التركيز
        } else if (widget.controller.text.isEmpty) {
          currentHintText = widget.hintText; // إعادة hint إذا كان الحقل فارغًا
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
    return Card(
      shadowColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: Colors.white,
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
          hintText: currentHintText,
          suffixIcon: widget.maxLines == 1
              ? const Icon(Icons.chat_bubble_outline_rounded)
              : null,
        ),
        textAlign: TextAlign.end,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 16,
          fontFamily: "Tajawal",
        ),
      ),
    );
  }
}
