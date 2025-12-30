import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jcp/widget/RotatingImagePage.dart';

class FullScreenImageViewer extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;

  const FullScreenImageViewer({
    Key? key,
    this.imageUrl,
    this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          // Close button and background tap
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent, // Keep transparent to see background
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // Image with Zoom
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: imageFile != null
                  ? Image.file(
                imageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              )
                  : Image.network(
                imageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: RotatingImagePage());
                },
                errorBuilder: (BuildContext context, Object error,
                    StackTrace? stackTrace) {
                  return const Center(
                    child: Text(
                      'خطأ في تحميل الصورة',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "Tajawal",
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Watermark Overlay
          IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.3, // Adjust transparency as needed
                child: SvgPicture.asset(
                  'assets/svg/logo-04.svg',
                  width: MediaQuery.of(context).size.width * 0.5, // Adjust size
                  colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn
                  ),
                ),
              ),
            ),
          ),

          // Close Button (Icon)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
