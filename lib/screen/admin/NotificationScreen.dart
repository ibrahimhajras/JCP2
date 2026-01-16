import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  TextEditingController _notificationController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _orderIdController = TextEditingController(text: "1");

  String _selectedType = 'maintenance';
  String _selectedTopic = 'all2';

  final List<Map<String, String>> _topics = [
    {'value': 'all2', 'label': 'الجميع (all2)'},
    {'value': 'User', 'label': 'المستخدمين (User)'},
    {'value': 'Trader', 'label': 'التجار (Trader)'},
    {'value': 'Driver', 'label': 'السائقين (Driver)'},
  ];

  final List<Map<String, String>> _notificationTypes = [
    {'value': 'maintenance', 'label': 'maintenance (صيانة - لا توجيه)'},
    {'value': 'home', 'label': 'home (الصفحة الرئيسية)'},
    {'value': 'private', 'label': 'private (الصفحة الخاصة)'},
    {'value': 'orders', 'label': 'orders (صفحة الطلبات)'},
    {'value': 'notifications', 'label': 'notifications (صفحة الإشعارات)'},
    {'value': 'stock_empty', 'label': 'stock_empty (صفحة نفاذ الكمية)'},
    {'value': 'invitation', 'label': 'invitation (صفحة القطع للتسعير)'},
    {'value': 'pending_parts', 'label': 'pending_parts (توجيه مباشر للقطع للتسعير)'},
    {'value': 'trader_orders', 'label': 'trader_orders (صفحة طلبيات التاجر)'},
    {'value': 'contact_us', 'label': 'contact_us (صفحة تواصل معنا)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Notifiction"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "عنوان الإشعار",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _titleController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "اكتب عنوان الإشعار هنا...",
                    hintTextDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "نص الإشعار",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _notificationController,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "اكتب نص الإشعار هنا...",
                    hintTextDirection: TextDirection.rtl,
                  ),
                ),
              ),

              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "تحديد الفئة (Topic)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTopic,
                    isExpanded: true,
                    items: _topics.map((Map<String, String> item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            item['label']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTopic = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "نوع الإشعار (Type)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    items: _notificationTypes.map((Map<String, String> item) {
                      return DropdownMenuItem<String>(
                        value: item['value'],
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            item['label']!,
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ),
              ),

              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "رقم الطلب (Order ID - اختياري)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _orderIdController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "أدخل رقم الطلب...",
                    hintTextDirection: TextDirection.rtl,
                  ),
                ),
              ),

              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  String notificationText = _notificationController.text.trim();
                  String title = _titleController.text.trim();
                  String orderId = _orderIdController.text.trim();

                  if (orderId.isEmpty) {
                    orderId = "1";
                  }

                  if (notificationText.isNotEmpty) {
                    final url = Uri.parse("https://jordancarpart.com/Api/send_to_all.php");
                    final body = jsonEncode({
                      "title": title,
                      "body": notificationText,
                      "type": _selectedType,
                      "orderid": orderId,
                      "topic": _selectedTopic,
                    });

                    try {
                      final response = await http.post(
                        url,
                        body: body,
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("✅ تم إرسال الإشعار بنجاح")),
                        );
                        _notificationController.clear();
                        _titleController.clear();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("❌ فشل في الإرسال: ${response.statusCode}")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❗ خطأ أثناء الإرسال: $e")),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("يرجى إدخال نص الإشعار!")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "إرسال",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
