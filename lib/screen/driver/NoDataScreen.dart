import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  const NoDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة توضيحية
            Container(
              width: MediaQuery.of(context).size.width / 1.8,
              child: Image.asset(
                'assets/images/notfoundorder.png',
                fit: BoxFit.cover, // تأكد من أن الصورة تتلاءم مع الحاوية
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد طلبات',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                fontSize: 18, // حجم الخط
              ),
            ),
          ],
        ),
      ),
    );
  }
}