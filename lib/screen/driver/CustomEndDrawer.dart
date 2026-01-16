import 'package:flutter/material.dart';

class CustomEndDrawer extends StatelessWidget {
  const CustomEndDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height/1.5,
        child: Column(
          children: [
            /// Drawer Header
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.png", width: 80, height: 80), // Add your logo
                  const SizedBox(height: 8),
                  const Text(
                    "قطع سيارات الأردن",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Jordan Car Part",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            /// Menu Items
            _buildMenuItem(Icons.person, "الصفحة الشخصية"),
            _buildMenuItem(Icons.lightbulb_outline, "رؤيتنا"),
            _buildMenuItem(Icons.headset_mic, "تواصل معنا"),

            const Spacer(),

            /// Social Media Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton("assets/facebook.png"),
                const SizedBox(width: 10),
                _socialButton("assets/instagram.png"),
              ],
            ),

            const SizedBox(height: 20),

            /// Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle logout
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("تسجيل الخروج", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Helper Widget for Menu Items
  Widget _buildMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        // Handle navigation
      },
    );
  }

  /// Helper Widget for Social Buttons
  Widget _socialButton(String assetPath) {
    return InkWell(
      onTap: () {
        // Handle social media action
      },
      child: Image.asset(assetPath, width: 30, height: 30),
    );
  }
}
