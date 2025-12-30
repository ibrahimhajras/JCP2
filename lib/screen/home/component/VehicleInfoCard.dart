import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../style/colors.dart';

class VehicleInfoCard extends StatelessWidget {
  final String? brand;
  final String? model;
  final String? year;
  final String? fuelType;
  final String? engineSize;
  final String? chassisNumber;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const VehicleInfoCard({
    Key? key,
    this.brand,
    this.model,
    this.year,
    this.fuelType,
    this.engineSize,
    this.chassisNumber,
    required this.onTap,
    this.onEdit,
  }) : super(key: key);

  bool get hasVehicleInfo =>
      brand != null &&
          model != null &&
          year != null &&
          fuelType != null &&
          engineSize != null;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 400;

    if (!hasVehicleInfo) {
      return _buildEmptyCard(size, isSmallScreen, isMediumScreen);
    }

    return _buildFilledCard(size, isSmallScreen, isMediumScreen);
  }

  Widget _buildEmptyCard(Size size, bool isSmallScreen, bool isMediumScreen) {
    final double horizontalMargin = size.width * 0.04;
    final double verticalMargin = size.height * 0.008;
    final double horizontalPadding = size.width * 0.035;
    final double verticalPadding = size.height * 0.015;
    final double borderRadius = isSmallScreen ? 14.0 : 16.0;
    final double titleFontSize =
    isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final double subtitleFontSize =
    isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final double iconSize =
    isSmallScreen ? 28.0 : (isMediumScreen ? 32.0 : 35.0);
    final double iconPadding = isSmallScreen ? 12.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: verticalMargin,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: red.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: red.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر معلومات المركبة',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: size.height * 0.006),
                  Text(
                    'اضغط هنا لإضافة تفاصيل سيارتك',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: subtitleFontSize,
                      color: Colors.grey.shade600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary1,
                    primary2,
                    primary3,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: red.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledCard(Size size, bool isSmallScreen, bool isMediumScreen) {
    final double horizontalMargin = size.width * 0.04;
    final double verticalMargin = size.height * 0.008;
    final double containerPadding = size.width * 0.040;
    final double heightPadding = size.height * 0.035;

    final double borderRadius = isSmallScreen ? 14.0 : 16.0;
    final double titleFontSize =
    isSmallScreen ? 17.0 : (isMediumScreen ? 18.0 : 19.0);
    final double valueFontSize =
    isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 17.0);

    String vehicleInfo =
    '${brand ?? ''} ${model ?? ''} ${year ?? ''} ${fuelType ?? ''} '
        '${(engineSize == null || engineSize == "N/A" ) ? "" : engineSize}'
        .trim();

    bool hasChassisNumber = chassisNumber != null &&
        chassisNumber != "N/A" &&
        chassisNumber!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: containerPadding,),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'معلومات المركبة',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.018,
                horizontal: size.width * 0.04,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    vehicleInfo.isEmpty ? "لم يتم اختيار المركبة بعد" : vehicleInfo,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    minFontSize: 8,
                    stepGranularity: 0.5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasChassisNumber) ...[
                    SizedBox(height: size.height * 0.008),
                    AutoSizeText(
                      '$chassisNumber',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: valueFontSize * 0.9,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 8,
                      stepGranularity: 0.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
