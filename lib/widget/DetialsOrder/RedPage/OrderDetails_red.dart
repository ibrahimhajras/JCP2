import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:jcp/widget/FullScreenImageViewer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:jcp/provider/ImageProviderNotifier.dart';
import 'package:provider/provider.dart';
import '../../../screen/home/homeuser.dart' show HomePage;
import '../../../style/colors.dart';

class OrderDetailsPage extends StatefulWidget {
  final List<dynamic> items;
  final String order_id;

  const OrderDetailsPage(
      {super.key, required this.items, required this.order_id});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool _isUploading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ImageProviderNotifier>(context, listen: false).resetImages();
    });
  }

  Future<void> _fetchOrderItems() async {
    try {
      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/getItemsFromOrders.php?flag=1&order_id=${widget.order_id}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['order_items'] != null) {
          setState(() {
            _items = data['order_items'];
          });
        }
      }
    } catch (e) {
      print("Error fetching items: $e");
    }
  }


  Future<void> _pickImages(int itemIndex, int itemId) async {
    // Ensure index is within provider limits (0-4)
    if (itemIndex >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Center(child: Text('عذرا، لا يمكن إضافة صور لأكثر من 5 عناصر حاليا'))));
      return;
    }

    final imageProvider = Provider.of<ImageProviderNotifier>(context, listen: false);
    int currentCount = imageProvider.getImageCount(itemIndex);
    int remaining = 4 - currentCount;

    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('الحد الأقصى 4 صور'))),
      );
      return;
    }

    try {
      // Use ImagePicker - automatically uses Photo Picker on Android 13+
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 100);

      if (images.isNotEmpty) {
        List<File> files = [];
        int toAdd = images.length > remaining ? remaining : images.length;

        for (int i = 0; i < toAdd; i++) {
          files.add(File(images[i].path));
        }

        if (files.isNotEmpty) {
          imageProvider.addImages(itemIndex, files);

          if (images.length > remaining) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(child: Text("تم إضافة $remaining صور فقط (الحد الأقصى)")),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print("ImagePicker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text("حدث خطأ أثناء اختيار الصور")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImageFromCamera(int itemIndex, int itemId) async {
    if (itemIndex >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('عذرا، لا يمكن إضافة صور لأكثر من 5 عناصر حاليا'))),
      );
      return;
    }

    // التحقق من صلاحية الكاميرا
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text("يرجى تفعيل صلاحية الكاميرا من الإعدادات")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!status.isGranted) return;

    final imageProvider = Provider.of<ImageProviderNotifier>(context, listen: false);
    int currentCount = imageProvider.getImageCount(itemIndex);

    if (currentCount >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('الحد الأقصى 4 صور'))),
      );
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        imageProvider.addImage(itemIndex, File(image.path));
      }
    } catch (e) {
      print("Camera picker error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text("حدث خطأ أثناء التقاط الصورة")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog(int itemIndex, int itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("اختر الصور", style: TextStyle(fontFamily: 'Tajawal')),
          content: const Text("من الكاميرا أو المعرض", style: TextStyle(fontFamily: 'Tajawal')),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _pickImageFromCamera(itemIndex, itemId);
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
                await _pickImages(itemIndex, itemId);
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

  Future<void> _saveImages() async {
    setState(() {
      _isUploading = true;
    });

    final imageProvider = Provider.of<ImageProviderNotifier>(context, listen: false);

    try {
      for (int i = 0; i < _items.length; i++) {
        if (i >= 5) break;

        if (imageProvider.getImageCount(i) > 0) {
          var item = _items[i];
          var itemId = item['id'];

          String? mergedBase64 = await imageProvider.getMergedImageBase64(i);

          if (mergedBase64 != null) {
            final response = await http.post(
              Uri.parse('https://jordancarpart.com/Api/upload_order_item_images.php'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'order_item_id': itemId,
                'image': mergedBase64,
              }),
            );
            print("Response from upload_order_item_images.php: ${response.body}");

            if (response.statusCode != 200) {
              print("Error uploading for item $itemId: ${response.body}");
            }
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Center(
          child: CustomText(
            text: 'تم حفظ الصور بنجاح',
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: red,
      ));
      imageProvider.resetImages();

      // Refresh logic could be added here if needed
      await _fetchOrderItems();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CustomText(
          text: 'حدث خطأ أثناء الحفظ',
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
        backgroundColor: red,
      ));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }


  Widget _buildHeader(Size size) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary1, primary2, primary3]),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              text: "تفاصيل الطلب",
              color: Colors.white,
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(page: 2),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios_rounded, color: white),
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
      backgroundColor: white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(size),
                const SizedBox(height: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "قيد المراجعة ",
                          size: 20,
                          color: Colors.yellow[600],
                        ),
                        CustomText(
                          text: "${widget.order_id} طلبك رقم ",
                          size: 20,
                          color: Colors.yellow[600],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 15,
                      ),
                      child: CustomText(
                        text: "جاري العمل على تقديم أفضل سعر في اقرب وقت ...",
                        size: 18,
                        weight: FontWeight.w100,
                        textAlign: TextAlign.start,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: CustomText(
                        text: "اسم القطعة",
                        size: 20,
                        weight: FontWeight.w900,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: _items.map(
                              (e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: grey,
                                    ),
                                    child: Consumer<ImageProviderNotifier>(
                                      builder: (context, imageProvider, _) {
                                        int idx = _items.indexOf(e);
                                        bool hasServerImages = (e['images'] !=
                                            null &&
                                            (e['images'] as List).isNotEmpty);
                                        return TextFormField(
                                          readOnly: true,
                                          initialValue: e["name"],
                                          maxLines: null,
                                          textDirection: TextDirection.rtl, // Fix for mixed text (Arabic/Numbers)
                                          // textAlign: TextAlign.end, // Removed: RTL start is right aligned by default
                                          decoration: InputDecoration(
                                            prefixIcon: (hasServerImages)
                                                ? GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      FullScreenImageViewer(
                                                          imageUrl:
                                                          e['images']
                                                          [0]
                                                              .toString()),
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    8.0),
                                                child: ClipRRect(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(100),
                                                  child: Image.network(
                                                    e['images'][0]
                                                        .toString(),
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error,
                                                        stackTrace) =>
                                                    const Icon(Icons.error),
                                                  ),
                                                ),
                                              ),
                                            )
                                                : GestureDetector(
                                              onTap: () => _showImagePickerDialog(
                                                  _items.indexOf(e),
                                                  e['id']),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    12.0),
                                                child: SvgPicture.asset(
                                                  "assets/svg/addphoto.svg",
                                                  width: 28,
                                                  height: 28,
                                                  colorFilter:
                                                  ColorFilter.mode(
                                                      words,
                                                      BlendMode.srcIn),
                                                ),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: grey,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: grey,
                                                width: 2,
                                              ),
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            fillColor: const Color.fromRGBO(
                                                246, 246, 246, 1),
                                            hintText: e["name"],
                                            hintStyle: TextStyle(
                                              color: black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Tajawal",
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: "Tajawal",
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  // Display Images
                                  Consumer<ImageProviderNotifier>(
                                      builder: (context, imageProvider, _) {
                                        int idx = _items.indexOf(e);
                                        List<File> localFiles = (idx < 5)
                                            ? imageProvider.imageFiles[idx]
                                            : [];

                                        // Only show local files here as requested
                                        if (localFiles.isNotEmpty) {
                                          return Container(
                                            height: 80,
                                            padding:
                                            const EdgeInsets.symmetric(vertical: 5),
                                            child: ListView(
                                              scrollDirection: Axis.horizontal,
                                              reverse: true, // RTL
                                              children: [
                                                // New Images (Local)
                                                ...localFiles.map((file) => Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 4.0),
                                                  child: Stack(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (context) =>
                                                                FullScreenImageViewer(
                                                                    imageFile:
                                                                    file),
                                                          );
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(8),
                                                          child: Image.file(
                                                              file,
                                                              width: 70,
                                                              height: 70,
                                                              fit: BoxFit.cover),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            if (idx < 5) {
                                                              imageProvider
                                                                  .removeImage(
                                                                  idx,
                                                                  localFiles
                                                                      .indexOf(
                                                                      file));
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                shape: BoxShape
                                                                    .circle),
                                                            child: const Icon(
                                                                Icons.close,
                                                                color:
                                                                Colors.red,
                                                                size: 20),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const SizedBox();
                                        }
                                      })
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Consumer<ImageProviderNotifier>(
                    builder: (context, imageProvider, _) {
                      bool hasNewImages = false;
                      // Check if any of the indices 0-4 have images
                      for(int i=0; i<5; i++) {
                        if (imageProvider.getImageCount(i) > 0) {
                          hasNewImages = true;
                          break;
                        }
                      }

                      if (hasNewImages) {
                        return Column(
                          children: [
                            const SizedBox(height: 56,),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                              child: ElevatedButton(
                                onPressed: _isUploading ? null : _saveImages,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: red,
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: const Text("إرسال",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: "Tajawal")),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    }
                )
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: RotatingImagePage(),
              ),
            ),
        ],
      ),
    );
  }
}
