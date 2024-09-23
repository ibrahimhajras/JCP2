import 'package:flutter/material.dart';
import '../style/custom_text.dart';
import 'colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSize {
  final String title;
  final Color? color;
  final List<Widget>? widget;
  final Widget? lead;
  final double? shape;
  final double? elevation;

  AppBarWidget({
    Key? key,
    required this.title,
    this.color,
    this.widget,
    this.lead,
    this.shape,
    this.elevation,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: white,
      title: CustomText(
        text: title.toUpperCase(),
        weight: FontWeight.normal,
        size: 26,
      ),
      centerTitle: true,
      backgroundColor: color ?? primary1,
      actions: widget ?? [],
      leading: lead ?? null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shape != null ? shape! : 0),
      ),
      elevation: elevation != null ? elevation! : 0,
      shadowColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget get child => throw UnimplementedError();
}
