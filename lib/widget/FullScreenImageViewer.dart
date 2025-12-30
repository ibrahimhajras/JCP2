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
      backgroundColor: Colors.transparent,
      elevation: 0, 
      insetPadding: const EdgeInsets.all(0),
      child: Container(
        color: Colors.transparent,
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 5.0,
          child: Column(
            children: [
              // Top tap area to close
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              
              // Image area - no closing on tap
              GestureDetector(
                onTap: () {}, // Prevent closing when tapping on image
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    imageFile != null 
                      ? Image.file(
                          imageFile!,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          imageUrl!,
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
                    
                    // Watermark Overlay
                    IgnorePointer(
                      child: Opacity(
                        opacity: 0.3,
                        child: SvgPicture.asset(
                          'assets/svg/logo-04.svg',
                          width: MediaQuery.of(context).size.width * 0.5,
                          colorFilter: const ColorFilter.mode(
                            Colors.white, 
                            BlendMode.srcIn
                          ), 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bottom tap area to close
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
