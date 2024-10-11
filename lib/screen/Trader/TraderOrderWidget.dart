import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/screen/Drawer/Notification.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/Inallpage/CustomButton.dart';

class TraderOrderWidget extends StatefulWidget {
  final String user_id;

  TraderOrderWidget(this.user_id, {Key? key}) : super(key: key);

  @override
  State<TraderOrderWidget> createState() => _TraderOrderWidgetState();
}

class _TraderOrderWidgetState extends State<TraderOrderWidget> {
  late Stream<List<dynamic>> ordersStreamData;
  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();
    ordersStreamData = ordersStream(widget.user_id);
    _checkForNotifications();
  }

  Stream<List<dynamic>> ordersStream(String userId) async* {
    while (true) {
      try {
        final orders = await fetchOrders(userId);
        yield orders;
      } catch (e) {
        yield [];
        print('Error fetching orders: $e');
      }
      await Future.delayed(Duration(seconds: 10));
    }
  }

  Future<void> _checkForNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    List<Map<String, dynamic>> notificationList =
        notifications.map((notification) {
      return jsonDecode(notification) as Map<String, dynamic>;
    }).toList();

    bool hasUnread =
        notificationList.any((notification) => notification['isRead'] == false);

    setState(() {
      hasNewNotification = hasUnread;
    });
  }

  Future<List<dynamic>> fetchOrders(String userId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/showallordersoftrader.php?trader_id=$userId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final List<dynamic> orders = responseData['orders'];
          return orders;
        } else {
          print('Failed to load orders: ${responseData['message']}');
          return [];
        }
      } else {
        print('لا يوجد طلبيات');
        return [];
      }
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> orderDetails = json.decode(response.body);
      return orderDetails;
    } else {
      throw Exception('Failed to load order details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildHeader(size),
          Expanded(
            child: StreamBuilder<List<dynamic>>(
              stream: ordersStreamData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: RotatingImagePage());
                } else if (snapshot.hasError) {
                  return Center(child: Text('فشل في تحميل الطلبيات'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('لا يوجد طلبيات متاحة'));
                } else {
                  final orders = snapshot.data!;
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return GestureDetector(
                        onTap: () async {
                          try {
                            final orderDetails = await fetchOrderDetails(
                                order['order_id'].toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TraderOrderDetailsPage(
                                    orderDetails: orderDetails),
                              ),
                            );
                          } catch (e) {
                            // التعامل مع الخطأ
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('فشل في تحميل تفاصيل الطلب')),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 20),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order['time']}', // عرض التاريخ
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'رقم الطلب : ${order['order_id']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return CustomHeader(
      size: MediaQuery.of(context).size,
      title: "الطلبيات",
      notificationIcon: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationPage(),
              )).then((_) {
            _checkForNotifications();
          });
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Color.fromRGBO(246, 246, 246, 0.26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              hasNewNotification
                  ? 'assets/images/notification-on.png'
                  : 'assets/images/notification-off.png',
            ),
          ),
        ),
      ),
      menuIcon: GestureDetector(
        onTap: () {
          Scaffold.of(context).openEndDrawer();
        },
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Color.fromRGBO(246, 246, 246, 0.26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(
              Icons.menu,
              color: Color.fromRGBO(246, 246, 246, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class TraderOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;

  TraderOrderDetailsPage({required this.orderDetails});

  @override
  State<TraderOrderDetailsPage> createState() => _TraderOrderDetailsPageState();
}

class _TraderOrderDetailsPageState extends State<TraderOrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String id = profileProvider.getuser_id();
    print(id);
    print(widget.orderDetails);
    final hdr = widget.orderDetails['hdr'] != null &&
            widget.orderDetails['hdr'].isNotEmpty
        ? widget.orderDetails['hdr'][0]
        : {};
    final items = (widget.orderDetails['items'] ?? [])
        .where((item) => item['user_id'].toString() == id)
        .toList();

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildDetailsHeader(size),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hdr.isNotEmpty) ...[
                    _buildSectionTitle('المركبة'),
                    SizedBox(height: 10),
                    _buildVehicleInfo(hdr, size),
                    SizedBox(height: 10),
                    Text(
                      'رقم الطلب : ${hdr['orderId']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ] else
                    Text(
                      'لا توجد تفاصيل للطلب',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 16),
                  Expanded(
                    child: items.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildTableHeader(),
                                ...items
                                    .map((item) => _buildItemRow(item, size))
                                    .toList(),
                                SizedBox(height: 20),
                                _buildTotalCost(hdr),
                                SizedBox(height: 20),
                                CustomButton(
                                  text: 'تم',
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              'لا توجد عناصر متاحة',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsHeader(Size size) {
    return Container(
      height: size.height * 0.2,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: [
            Color(0xFFB02D2D),
            Color(0xFFC41D1D),
            Color(0xFF7D0A0A),
          ],
          stops: [0.1587, 0.3988, 0.9722],
        ),
        image: DecorationImage(
          image: AssetImage("assets/images/card.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: size.height * 0.05,
              left: 10,
              right: 10,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 246, 246, 0.26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(246, 246, 246, 0.26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu,
                        color: Color.fromRGBO(246, 246, 246, 1),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: size.width * 0.3,
              ),
              Text(
                "تفاصيل الطلب",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
        child: Align(
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ));
  }

  Widget _buildVehicleInfo(Map<String, dynamic> hdr, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hdr["Enginetype"].toString(), // عرض نوع المحرك
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16, color: Colors.black), // تنسيق النص
                ),
              ),
              Expanded(
                child: Text(
                  hdr["Enginecategory"].toString(),
                  // عرض فئة المحرك
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Expanded(
                child: Text(
                  hdr["Fueltype"].toString(), // عرض نوع الوقود
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Expanded(
                child: Text(
                  hdr["Engineyear"].toString(), // عرض سنة المحرك
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Expanded(
                child: Text(
                  hdr["Enginesize"].toString(), // عرض حجم المحرك
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'الكفالة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'الحالة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'السعر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'اسم القطعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildWarrantyIcon(context, item),
          Expanded(
            flex: 2,
            child: Text(
              item['itemType'] ?? '',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['price']?.toString() ?? '',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              item['itemName'] ?? '',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarrantyIcon(BuildContext context, Map<String, dynamic> item) {
    return IconButton(
      icon: Image.asset(
        'assets/images/iconinfo.png', // تأكد من وضع الصورة في المسار الصحيح
        width: 25,
        height: 25,
      ),
      onPressed: () {
        _showWarrantyDialog(context, item);
      },
    );
  }

  void _showWarrantyDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    width: constraints.maxWidth * 0.9, // ضبط العرض
                    height: constraints.maxHeight * 0.5, // ضبط الارتفاع
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 7,
                        color: words,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "تفاصيل القطعة",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: item['mark'] ?? "غير محدد",
                                  color: words,
                                ),
                                CustomText(
                                  text: " : العلامة التجارية",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: "شهر",
                                      color: words,
                                    ),
                                    SizedBox(width: 2),
                                    CustomText(
                                      text: "${item['itemWarranty']}",
                                      color: words,
                                    ),
                                  ],
                                ),
                                CustomText(
                                  text: " : مدة الكفالة",
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: item['itemNote']?.isNotEmpty ?? false
                                      ? item['itemNote']
                                      : 'لا يوجد',
                                  color: words,
                                ),
                                CustomText(
                                  text: " : الملاحظات",
                                ),
                              ],
                            ),
                            SizedBox(height: 25),
                            if (item['item'] != null &&
                                item['item'].toString().isNotEmpty)
                              _buildImageRow(" ", item['item'])
                            else
                              CustomText(
                                text: "لا يوجد صورة",
                                color: words,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageRow(String label, String? base64Image) {
    Uint8List? decodedImage;
    if (base64Image != null && base64Image.isNotEmpty) {
      try {
        decodedImage = base64Decode(base64Image);
      } catch (e) {
        print("Error decoding base64: $e");
      }
    }
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        decodedImage != null
            ? GestureDetector(
                onTap: () {
                  _showImageDialog(decodedImage!);
                },
                child: Image.memory(
                  decodedImage,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              )
            : Text(
                'لا يوجد صورة',
                style: TextStyle(fontSize: 16),
              ),
      ],
    );
  }

  void _showImageDialog(Uint8List decodedImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: Image.memory(
                decodedImage,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalCost(Map<String, dynamic> hdr) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              CustomText(
                text: "دينار أردني  ",
                size: 18,
              ),
              CustomText(
                text: "${hdr['totalCost']}",
                size: 18,
              ),
              CustomText(
                text: "  المجموع",
                color: red,
                weight: FontWeight.w900,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
