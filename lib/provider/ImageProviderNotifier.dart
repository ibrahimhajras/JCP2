import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageProviderNotifier with ChangeNotifier {
  static const int maxImagesPerIndex = 4;

  // قائمة من القوائم - كل index يمكن أن يحتوي على 1-4 صور
  final List<List<File>> _imageFiles = List.generate(5, (_) => []);

  List<List<File>> get imageFiles => _imageFiles;

  /// دمج الصور بصورة واحدة وإرجاع base64
  /// الصور تترتب: 1 صورة = كاملة، 2 صور = جنب بعض، 3-4 صور = شبكة 2x2
  Future<String?> getMergedImageBase64(int index) async {
    final images = _imageFiles[index];
    if (images.isEmpty) return null;

    // إذا صورة واحدة فقط، نرجعها مباشرة
    if (images.length == 1) {
      final bytes = await images[0].readAsBytes();
      return base64Encode(bytes);
    }

    // تحميل كل الصور
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

    // تحديد حجم موحد لكل صورة
    const int targetSize = 500;

    // تغيير حجم الصور لتكون متساوية
    List<img.Image> resizedImages = loadedImages.map((image) {
      return img.copyResize(image, width: targetSize, height: targetSize);
    }).toList();

    img.Image mergedImage;

    if (resizedImages.length == 2) {
      // صورتين جنب بعض أفقياً - نفس الحجم القديم
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);
      
      // ملء الخلفية باللون الأبيض
      img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));
      
      // وضع الصورتين في النص عمودياً
      int centerY = (targetSize * 2 - targetSize) ~/ 2; // = targetSize / 2
      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: centerY);
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: centerY);
    } else if (resizedImages.length == 3) {
      // 3 صور - 2 فوق و 1 تحت بالنص
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);

      // ملء الخلفية باللون الأبيض
      img.fill(mergedImage, color: img.ColorRgb8(255, 255, 255));

      // الصورة الأولى - أعلى يسار
      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);

      // الصورة الثانية - أعلى يمين
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: 0);

      // الصورة الثالثة - أسفل بالنص (centered)
      int centerX = (targetSize * 2 - targetSize) ~/ 2; // = targetSize / 2
      img.compositeImage(mergedImage, resizedImages[2], dstX: centerX, dstY: targetSize);
    } else {
      // 4 صور - شبكة 2x2
      mergedImage = img.Image(width: targetSize * 2, height: targetSize * 2);

      // الصورة الأولى - أعلى يسار
      img.compositeImage(mergedImage, resizedImages[0], dstX: 0, dstY: 0);

      // الصورة الثانية - أعلى يمين
      img.compositeImage(mergedImage, resizedImages[1], dstX: targetSize, dstY: 0);

      // الصورة الثالثة - أسفل يسار
      img.compositeImage(mergedImage, resizedImages[2], dstX: 0, dstY: targetSize);

      // الصورة الرابعة - أسفل يمين
      img.compositeImage(mergedImage, resizedImages[3], dstX: targetSize, dstY: targetSize);
    }

    // تحويل لـ base64
    final jpgBytes = img.encodeJpg(mergedImage, quality: 85);
    return base64Encode(jpgBytes);
  }

  // إضافة صورة واحدة لـ index معين
  void addImage(int index, File imageFile) {
    if (_imageFiles[index].length < maxImagesPerIndex) {
      _imageFiles[index].add(imageFile);
      notifyListeners();
    }
  }

  // إضافة عدة صور لـ index معين
  void addImages(int index, List<File> images) {
    final remaining = maxImagesPerIndex - _imageFiles[index].length;
    final toAdd = images.take(remaining).toList();
    _imageFiles[index].addAll(toAdd);
    notifyListeners();
  }

  // حذف صورة معينة من index معين
  void removeImage(int index, int imageIndex) {
    if (imageIndex >= 0 && imageIndex < _imageFiles[index].length) {
      _imageFiles[index].removeAt(imageIndex);
      notifyListeners();
    }
  }

  // الحصول على عدد الصور لـ index معين
  int getImageCount(int index) {
    return _imageFiles[index].length;
  }

  // التحقق إذا كان يمكن إضافة صور أخرى
  bool canAddMore(int index) {
    return _imageFiles[index].length < maxImagesPerIndex;
  }

  // الحصول على عدد الصور المتبقية المسموحة
  int getRemainingSlots(int index) {
    return maxImagesPerIndex - _imageFiles[index].length;
  }

  // مسح صور index معين
  void clearImages(int index) {
    _imageFiles[index].clear();
    notifyListeners();
  }

  void resetImages() {
    for (int i = 0; i < _imageFiles.length; i++) {
      _imageFiles[i].clear();
    }
    notifyListeners();
  }
}
