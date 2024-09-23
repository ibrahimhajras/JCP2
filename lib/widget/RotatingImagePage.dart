import 'package:flutter/material.dart';

class RotatingImagePage extends StatefulWidget {
  @override
  _RotatingImagePageState createState() => _RotatingImagePageState();
}

class _RotatingImagePageState extends State<RotatingImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  @override
  void dispose() {
    _controller.dispose(); // التخلص من AnimationController عند الخروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        height: 60,
        width: 60,
        child: Image.asset(
          'assets/images/logo-loading.png',
        ),
      ),
    );
  }
}
