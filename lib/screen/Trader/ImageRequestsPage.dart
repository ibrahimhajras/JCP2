import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/colors.dart';
import '../../style/custom_text.dart';
import '../../widget/RotatingImagePage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:image/image.dart' as img;

class ImageRequestsPage extends StatefulWidget {
  const ImageRequestsPage({super.key});

  @override
  State<ImageRequestsPage> createState() => _ImageRequestsPageState();
}

class _ImageRequestsPageState extends State<ImageRequestsPage> {
  List<Map<String, dynamic>> imageRequests = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchImageRequests();
  }

  Future<void> _fetchImageRequests() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = Provider.of<ProfileProvider>(context, listen: false);
      final traderId = user.user_id;

      final response = await http.get(
        Uri.parse(
            'https://jordancarpart.com/Api/get_image_requests.php?trader_id=$traderId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['status'] == 'success') {
          setState(() {
            imageRequests =
            List<Map<String, dynamic>>.from(data['requests'] ?? []);

            for (var request in imageRequests) {
              request['selected_images'] = <File>[];
              request['brand_controller'] = TextEditingController(
                  text: request['mark']?.toString() ?? '');
            }
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'حدث خطأ';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'حدث خطأ في الاتصال';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ في الاتصال';
        isLoading = false;
      });
    }
  }

  Future<void> _rejectRequest(int requestId) async {
    try {
      final response = await http.post(
        Uri.parse('https://jordancarpart.com/Api/update_image_request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'request_id': requestId,
          'action': 'reject',
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: 'تم رفض الطلب',
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            backgroundColor: red,
          ),
        );
        _fetchImageRequests();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              text: data['message'] ?? 'حدث خطأ',
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            backgroundColor: red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: CustomText(
            text: 'حدث خطأ في الاتصال',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          backgroundColor: red,
        ),
      );
    }
  }

  void _showRejectConfirmation(int requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                CustomText(
                  text: "هل انت متأكد من عدم توفر الصورة",
                  size: 16,
                  color: Colors.black,
                  weight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        elevation: 0,
                      ),
                      child: CustomText(
                        text: "لا",
                        color: Colors.white,
                        size: 14,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 20),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _rejectRequest(requestId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC41D1D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        elevation: 0,
                      ),
                      child: CustomText(
                        text: "نعم",
                        color: Colors.white,
                        size: 14,
                        weight: FontWeight.bold,
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
              text: "طلب صورة",
              color: Colors.white,
              size: 22,
              weight: FontWeight.w900,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  padding: const EdgeInsets.all(25.0),
                  color: Colors.transparent,
                  child: const Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            child: isLoading
                ? Center(child: RotatingImagePage())
                : errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: red),
                  const SizedBox(height: 16),
                  CustomText(
                    text: errorMessage!,
                    color: black,
                    size: 16,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchImageRequests,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                    ),
                    child: CustomText(
                      text: 'إعادة المحاولة',
                      color: white,
                    ),
                  ),
                ],
              ),
            )
                : imageRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  CustomText(
                    text: 'لا توجد طلبات صور حالياً',
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchImageRequests,
              color: green,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: imageRequests.length,
                itemBuilder: (context, index) {
                  final request = imageRequests[index];
                  return _buildRequestCard(request);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {

    if (request['selected_images'] == null) {
      request['selected_images'] = <File>[];
    }

    TextEditingController? brandController =
    request['brand_controller'] as TextEditingController?;
    if (brandController == null) {
      brandController =
          TextEditingController(text: request['mark']?.toString() ?? '');
      request['brand_controller'] = brandController;
    }

    String carInfo = [
      request['car_category'],
      request['car_model'],
      request['car_year'],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty && e != "N/A")
        .join(' ');


    String productType = request['product_type'] ?? '';
    String productTypeLabel = '';
    if (productType == 'agency' || productType.contains('شركة')) {
      productTypeLabel = '(شركة)';
    } else if (productType == 'commercial' || productType.contains('تجاري')) {
      productTypeLabel = '(تجاري)';
    } else if (productType == 'commercial2' || productType.contains('تجاري2')) {
      productTypeLabel = '(تجاري 2)';
    } else if (productType == 'origin' || productType.contains('بلد المنشأ')) {
      productTypeLabel = '(بلد المنشأ)';
    } else if (productType == 'used' || productType.contains('مستعمل')) {
      productTypeLabel = '(مستعمل)';
    } else if (productType.isNotEmpty) {
      productTypeLabel = '($productType)';
    }

    String productName = request['product_name'] ?? 'اسم القطعة غير متوفر';
    String displayName = productTypeLabel.isNotEmpty
        ? '$productName $productTypeLabel'
        : productName;


    List<File> images = request['selected_images'];
    bool hasImages = images.isNotEmpty;

    return GestureDetector(
      key: ValueKey(request['id'] ?? request.hashCode),
      onLongPress: () {
        _showRejectConfirmation(request['id']);
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  GestureDetector(
                    onTap: () {
                      _showEditDialog(request);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),

                      child: Image.asset(
                        "assets/images/05.png",
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        CustomText(
                          text: productName,
                          color: red,
                          size: 16,
                          weight: FontWeight.bold,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                        if (productTypeLabel.isNotEmpty)
                          CustomText(
                            text: productTypeLabel,
                            color: green,
                            size: 14,
                            weight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomText(
                text:
                carInfo.isNotEmpty ? carInfo : 'معلومات السيارة غير متوفرة',
                color: Colors.grey[700],
                size: 14,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: hasImages
                        ? () async {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return Center(child: RotatingImagePage());
                        },
                      );

                      TextEditingController? markCtrl =
                      request['brand_controller']
                      as TextEditingController?;
                      String mark = markCtrl?.text ?? "";

                      // Brand is now optional, no validation needed

                      bool success =
                      await _updateProduct(request, mark, images);

                      // Close loading dialog
                      if (context.mounted) {
                        Navigator.pop(context);
                      }

                      if (success) {
                        _fetchImageRequests();
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasImages ? green : Colors.grey,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 4),
                    ),
                    child: CustomText(
                      text: "إرسال",
                      color: Colors.white,
                      size: 12,
                      weight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StatefulBuilder(builder: (context, setStateInterface) {

                        return GestureDetector(
                          onTap: () async {
                            if (images.length >= 4) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: const Center(child: Text("الحد الأقصى 4 صور")),
                                      backgroundColor: red));
                              return;
                            }
                            _showMultiImagePicker(
                                context, request, setStateInterface);
                          },
                          child: images.isNotEmpty
                              ? SizedBox(
                            width: 50,
                            height: 50,

                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    images.last,

                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (images.length > 1)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      color: Colors.black54,
                                      child: Text("+${images.length - 1}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10)),
                                    ),
                                  )
                              ],
                            ),
                          )
                              : SvgPicture.asset(
                            "assets/svg/addphoto.svg",
                            width: 35,
                            height: 35,
                            colorFilter: const ColorFilter.mode(
                                Colors.grey, BlendMode.srcIn),
                          ),
                        );
                      }),
                      const SizedBox(width: 10),
                      StatefulBuilder(
                        builder: (context, setStateBrand) {
                          // Add listener to update border color when text changes
                          brandController?.removeListener(() {});
                          brandController?.addListener(() {
                            setStateBrand(() {});
                          });

                          bool hasText = brandController?.text.isNotEmpty ?? false;

                          return Container(
                            height: 40,
                            width: 150,
                            child: TextField(
                              controller: brandController,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: "العلامة التجارية",
                                hintStyle:
                                const TextStyle(fontSize: 12, color: Colors.grey),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    BorderSide(color: Colors.grey.shade400)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: hasText ? green : Colors.grey.shade400)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: hasText ? green : Colors.grey.shade400)),
                              ),
                              style: const TextStyle(fontSize: 14, fontFamily: 'Tajawal'),
                              onChanged: (val) {
                                request['local_mark'] = val;
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> request) {
    TextEditingController priceController =
    TextEditingController(text: request['price']?.toString() ?? '');
    TextEditingController noteController = TextEditingController(
        text: request['note']?.toString() ?? '');

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 7,
                  color: words,
                ),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(text: "تعديل", weight: FontWeight.bold, size: 18),
                  const SizedBox(height: 20),

                  TextField(
                    controller: priceController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "السعر",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: noteController,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "ملاحظات",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        request['price'] = priceController.text;
                        request['note'] = noteController.text;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: red,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: CustomText(
                        text: "تم",
                        color: Colors.white,
                        size: 16,
                        weight: FontWeight.bold),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> _showMultiImagePicker(BuildContext context,
      Map<String, dynamic> request, StateSetter setStateInterface) async {

    List<File> currentImages = request['selected_images'] ?? [];
    int remaining = 4 - currentImages.length;
    if (remaining <= 0) return;

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
                var status = await Permission.camera.request();
                if (status.isGranted) {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.camera, imageQuality: 80);
                  if (image != null) {
                    setStateInterface(() {
                      request['selected_images'].add(File(image.path));
                    });
                    setState(() {});
                  }
                }
              },
              child: Icon(Icons.photo_camera, size: 30, color: button),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // AssetPicker handles permissions internally

                try {
                  final List<AssetEntity>? result =
                  await AssetPicker.pickAssets(
                    context,
                    pickerConfig: AssetPickerConfig(
                      maxAssets: remaining,
                      requestType: RequestType.image,
                      themeColor: red,
                      textDelegate: const ArabicAssetPickerTextDelegate(),
                    ),
                  );

                  if (result != null) {
                    for (var asset in result) {
                      final file = await asset.file;
                      if (file != null) {
                        setStateInterface(() {
                          request['selected_images'].add(file);
                        });
                      }
                    }
                    setState(() {});
                  }
                } catch (e) {
                  print("AssetPicker Error: $e");
                }
              },
              child: Icon(Icons.photo_library, size: 30, color: button),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _updateProduct(
      Map<String, dynamic> request, String mark, List<File> images) async {
    try {
      String? base64Image = await _getMergedImageBase64(images);

      if (base64Image == null) {
        return false;
      }

      if (request['details_id'] == null ||
          request['parent_product_id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("خطأ: معلومات المنتج ناقصة")),
        );
        return false;
      }

      final url =
      Uri.parse('https://jordancarpart.com/Api/resolve_image_request.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          "request_id": request['id'],
          "product_id": request['parent_product_id'],
          "details_id": request['details_id'],
          "price": request['price'],
          "amount": request['amount'],
          "mark": mark,
          "img": base64Image,
          "warranty": "0",
          "number": "1",
          "note": request['note'] ?? "",
        }),
      );
      print("Response from resolve_image_request.php: ${response.body}");

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("تم التحديث وإرسال الإشعار بنجاح"),
              backgroundColor: Colors.green),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("فشل التحديث: ${responseData['message']}"),
              backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<String?> _getMergedImageBase64(List<File> images) async {
    if (images.isEmpty) return null;
    if (images.length == 1) {
      final bytes = await images[0].readAsBytes();
      return base64Encode(bytes);
    }

    try {
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
        mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);
        img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));
        int centerY = (targetSize * 2 - targetSize) ~/ 2;
        img.compositeImage(mergedImage, resizedImages[0],
            dstX: 0, dstY: centerY);
        img.compositeImage(mergedImage, resizedImages[1],
            dstX: targetSize, dstY: centerY);
      } else if (resizedImages.length == 3) {
        mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);
        img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));
        img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);
        img.compositeImage(mergedImage, resizedImages[1],
            dstX: targetSize, dstY: 0);
        int centerX = (targetSize * 2 - targetSize) ~/ 2;
        img.compositeImage(mergedImage, resizedImages[2],
            dstX: centerX, dstY: targetSize);
      } else {
        mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);
        img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));
        img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);
        img.compositeImage(mergedImage, resizedImages[1],
            dstX: targetSize, dstY: 0);
        img.compositeImage(mergedImage, resizedImages[2],
            dstX: 0, dstY: targetSize);
        img.compositeImage(mergedImage, resizedImages[3],
            dstX: targetSize, dstY: targetSize);
      }

      final jpgBytes = img.encodeJpg(mergedImage, quality: 85);
      return base64Encode(jpgBytes);
    } catch (e) {
      print("Error merging images: $e");
      return null;
    }
  }
}
