import 'package:flutter/material.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';

class ProgressWidget extends StatefulWidget {
  final String? msg;
  const ProgressWidget({Key? key, this.msg}) : super(key: key);

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat();

    _animation = CurvedAnimation(parent: _controller!, curve: Curves.ease);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 10,
      backgroundColor: Colors.transparent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _animation!,
              child: Center(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Image.asset(
                      'assets/images/logo-loading.png',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 6.0,
            ),
            if (widget.msg != null)
              CustomText(
                text: widget.msg!,
                color: white,
              ),
          ],
        ),
      ),
    );
  }
}
