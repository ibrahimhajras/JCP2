import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/style/colors.dart';
import 'package:jcp/widget/Inallpage/CustomHeader.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../provider/ProfileProvider.dart';
import '../../style/custom_text.dart';
import '../../widget/FullScreenImageViewer.dart';
import '../../widget/Inallpage/CustomButton.dart';
import '../../widget/Inallpage/MenuIcon.dart';
import '../Drawer/Notification.dart';
import 'homeTrader.dart';

class TraderOrderWidget extends StatefulWidget {
  TraderOrderWidget({Key? key}) : super(key: key);

  @override
  State<TraderOrderWidget> createState() => _TraderOrderWidgetState();
}

class _TraderOrderWidgetState extends State<TraderOrderWidget> {
  late Stream<List<dynamic>> ordersStreamData;
  bool hasNewNotification = false;

  @override
  void initState() {
    super.initState();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String userId = profileProvider.getuser_id();
    ordersStreamData = ordersStream(userId);
    _checkForNotifications();
  }

  Stream<List<dynamic>> ordersStream(String userId) async* {
    while (true) {
      try {
        final orders = await fetchOrders(userId);
        yield orders;
      } catch (e) {
        yield [];
      }
      await Future.delayed(const Duration(seconds: 5));
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
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    final response = await http.get(
      Uri.parse(
          'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId'),
    );
    print(response.body);
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
                  return Center(
                      child: CustomText(text: 'فشل في تحميل الطلبيات'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: CustomText(text: 'لا يوجد طلبيات متاحة'));
                } else {
                  final allOrders = snapshot.data!;

                  final uniqueOrdersMap = <dynamic, dynamic>{};
                  for (var order in allOrders) {
                    uniqueOrdersMap[order['order_id']] = order;
                  }
                  final uniqueOrders = uniqueOrdersMap.values.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: uniqueOrders.length,
                    itemBuilder: (context, index) {
                      final order =
                          uniqueOrders[uniqueOrders.length - 1 - index];
                      return GestureDetector(
                        onTap: () async {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return Dialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: Center(child: RotatingImagePage()),
                                );
                              },
                            );

                            final orderDetails = await fetchOrderDetails(
                                order['order_id'].toString());
                            Navigator.pop(context);

                            print(orderDetails.toString());

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TraderOrderDetailsPage(
                                  orderDetails: orderDetails,
                                  anotherParameter: order['doneorder'],
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('فشل في تحميل تفاصيل الطلب')),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20),
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: order['doneorder'] == 0
                                ? Border.all(color: orange, width: 2.0)
                                : Border.all(color: green, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomText(
                                      text: order['order_id'].toString(),
                                      size: 16,
                                      color: Colors.black,
                                      weight: FontWeight.bold,
                                    ),
                                    CustomText(
                                      text: ':رقم الطلب  ',
                                      size: 14,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                CustomText(
                                  text: '${order['time']}',
                                  size: 18,
                                ),
                              ],
                            ),
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
      title: "الطلبيات" ?? "",
      notificationIcon: _buildNotificationIcon(size),
      menuIcon: _buildMenuIcon(context, size),
    );
  }

  Widget _buildNotificationIcon(Size size) {
    return GestureDetector(
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
        height: size.width * 0.1,
        width: size.width * 0.1,
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
    );
  }

  Widget _buildMenuIcon(BuildContext context, Size size) {
    return MenuIcon(
      size: size,
      onTap: () {
        Scaffold.of(context).openEndDrawer();
      },
    );
  }
}

class TraderOrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> orderDetails;
  final int anotherParameter;

  const TraderOrderDetailsPage(
      {super.key, required this.orderDetails, required this.anotherParameter});

  @override
  State<TraderOrderDetailsPage> createState() => _TraderOrderDetailsPageState();
}

class _TraderOrderDetailsPageState extends State<TraderOrderDetailsPage> {
  bool _isLoading = false;
  Map<String, dynamic>? customerInfo;
  bool _isLoadingCustomer = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomerInfo();
  }

  Future<void> _fetchCustomerInfo() async {
    final hdr = widget.orderDetails['hdr'] != null &&
            widget.orderDetails['hdr'].isNotEmpty
        ? widget.orderDetails['hdr'][0]
        : {};

    if (hdr.isEmpty || hdr['userId'] == null) {
      setState(() {
        _isLoadingCustomer = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://jordancarpart.com/Api/GETdetailsuser.php?user_id=${hdr['userId']}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            customerInfo = data['data'];
            _isLoadingCustomer = false;
          });
        } else {
          setState(() {
            _isLoadingCustomer = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingCustomer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ التحقق من أن orderDetails ليس null
    if (widget.orderDetails.isEmpty) {
      return Scaffold(
        backgroundColor: white,
        body: Column(
          children: [
            _buildDetailsHeader(MediaQuery.of(context).size),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inbox_outlined,
                        size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    CustomText(
                      text: 'لا توجد تفاصيل للطلب',
                      size: 18,
                      weight: FontWeight.bold,
                      color: Colors.grey[700]!,
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      text: 'تم حذف الطلب أو لا يوجد قطع متاحة',
                      size: 14,
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String id = profileProvider.getuser_id();

    final hdr = widget.orderDetails['hdr'] != null &&
            widget.orderDetails['hdr'].isNotEmpty
        ? widget.orderDetails['hdr'][0]
        : {};

    final items = (widget.orderDetails['items'] ?? [])
        .where((item) =>
            item != null &&
            item['product_details'] != null &&
            item['product_details']['user_id'].toString() == id)
        .toList();

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          _buildDetailsHeader(size),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (hdr.isNotEmpty) ...[
                    _buildSectionTitle('المركبة'),
                    _buildVehicleInfo(hdr, size),
                    const SizedBox(height: 10),
                    CustomText(
                      text: 'رقم الطلب : ${hdr['orderId']}',
                      size: 14,
                      weight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ] else
                    CustomText(
                        text: 'لا توجد تفاصيل للطلب',
                        size: 18,
                        weight: FontWeight.bold),
                  const SizedBox(height: 6),
                  Expanded(
                    child: items.isNotEmpty
                        ? SingleChildScrollView(
                            child: Column(
                              children: [
                                _buildTableHeader(),
                                ...items
                                    .map((item) => _buildItemRow(item, size))
                                    .toList(),
                                const SizedBox(height: 10),
                                _buildTotalCost(items),
                                _buildCustomerInfo(size),
                                const SizedBox(height: 20),
                                _isLoading
                                    ? RotatingImagePage()
                                    : widget.anotherParameter == 0
                                        ? CustomButton(
                                            text: 'تم',
                                            onPressed: () {
                                              updateDeliveryStatus(
                                                  hdr['orderId'], 1);
                                            },
                                          )
                                        : Container()
                              ],
                            ),
                          )
                        : Center(
                            child: CustomText(
                                text: 'لا توجد عناصر متاحة', size: 18),
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

  Future<void> updateDeliveryStatus(int orderId, int doneorder) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/update_delivery_status.php?order_id=$orderId&is_delivered=$doneorder');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          Navigator.pop(context);
        } else {}
      } else {}
    } catch (error) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDetailsHeader(Size size) {
    return Container(
      height: size.height * 0.20,
      width: size.width,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary1, primary2, primary3]),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomText(
              text: "تفاصيل الطلب",
              color: Colors.white,
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.2),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_forward_ios_rounded, color: white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(Size size) {
    if (_isLoadingCustomer) {
      return  Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: RotatingImagePage(),
          ),
        ),
      );
    }

    if (customerInfo == null) {
      return const SizedBox.shrink();
    }

    final customerName = customerInfo!['name']?.toString() ?? '';
    final customerPhone = customerInfo!['phone']?.toString() ?? '';
    final customerCity = customerInfo!['city']?.toString() ?? '';
    final addressDetails = customerInfo!['AddressDetail']?.toString() ?? '';

    if (customerName.isEmpty && customerPhone.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Center(
              child: CustomText(
                text: 'معلومات الزبون',
                size: 15,
                weight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (customerName.isNotEmpty)
                  _buildCustomerRow(Icons.person_outline, customerName),
                
                if (customerName.isNotEmpty && (customerPhone.isNotEmpty || customerCity.isNotEmpty))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),

                if (customerPhone.isNotEmpty)
                  _buildCustomerRow(Icons.phone_outlined, customerPhone, isPhone: true),

                if (customerPhone.isNotEmpty && (customerCity.isNotEmpty || addressDetails.isNotEmpty))
                   const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),

                if (customerCity.isNotEmpty || addressDetails.isNotEmpty)
                  _buildCustomerRow(
                    Icons.location_on_outlined, 
                    addressDetails.isNotEmpty ? '$customerCity - $addressDetails' : customerCity
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerRow(IconData icon, String text, {bool isPhone = false}) {
    // Add leading zero to phone numbers for display
    String displayText = text;
    if (isPhone && text.trim().isNotEmpty && !text.trim().startsWith('0')) {
      displayText = '0${text.trim()}';
    }
    
    return GestureDetector(
      onTap: isPhone ? () => _makePhoneCall(text) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: CustomText(
              text: displayText,
              size: 14,
              color: isPhone ? primary1 : const Color(0xFF444444),
              weight: FontWeight.w600,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary1.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary1, size: 18),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Add leading zero if not present
    String formattedNumber = phoneNumber.trim();
    if (!formattedNumber.startsWith('0')) {
      formattedNumber = '0$formattedNumber';
    }
    
    final Uri phoneUri = Uri(scheme: 'tel', path: formattedNumber);
      await launchUrl(phoneUri);
  }

  Widget _buildSectionTitle(String title) {
    return Center(
        child: Align(
      alignment: Alignment.center,
      child: CustomText(
        text: title,
        size: 14,
        weight: FontWeight.bold,
        color: Colors.black,
      ),
    ));
  }

  Widget _buildVehicleInfo(Map<String, dynamic> hdr, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomText(
                    color: const Color(0xFF8D8D92),
                    text: "${hdr["Enginetype"]}  "
                        "${hdr["Enginecategory"]}  "
                        "${hdr["Fueltype"]} "
                        "${hdr["Engineyear"]}  "
                        "${hdr["Enginesize"] == "N/A" ? "" : hdr["Enginesize"]}",
                  ),
                ],
              ),
              if (hdr['car_chassis_number'] != null &&
                  hdr['car_chassis_number'].toString().trim().isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: hdr['car_chassis_number'].toString().trim(),
                      color: const Color(0xFF8D8D92),
                    ),
                  ],
                ),
            ],
          )),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: CustomText(
              text: 'التفاصيل',
              size: 14,
              weight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              text: 'الحالة',
              size: 14,
              weight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: CustomText(
              text: 'السعر',
              size: 14,
              weight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: CustomText(
              text: 'اسم القطعة',
              size: 14,
              weight: FontWeight.bold,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, Size size) {
    double w = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Image.asset(
                'assets/images/iconinfo.png',
                width: 25,
                height: 25,
              ),
              onPressed: () {
                _showDetailsDialog(context: context, item: item);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              item['product_details']['name'] ?? '',
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: "Tajawal",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              (() {
                double? price = double.tryParse(
                    item['product_details']['price']?.toString() ?? '0');
                if (price == null || price == 0) return "غ.م";

                return (price == price.toInt())
                    ? price.toInt().toString()
                    : price.toStringAsFixed(2);
              })(),
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: "Tajawal",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item['product_info']['name'] ?? '',
              style: TextStyle(
                fontSize: w * 0.035,
                fontFamily: "Tajawal",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

        void _showDetailsDialog({
    required BuildContext context,
    required Map<String, dynamic> item,
  }) {
    final user =
        Provider.of<ProfileProvider>(context, listen: false).name.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Dialog(
              backgroundColor: grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 4,
                        color: words,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: grey,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15),
                            CustomText(
                              text: user,
                              size: 20,
                              color: green,
                              weight: FontWeight.bold,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomText(text: "الكفالة"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomText(text: "يوم", color: words),
                                          const SizedBox(width: 2),
                                          CustomText(
                                            text: item['product_details']
                                                        ['warranty']
                                                    ?.toString() ??
                                                "0",
                                            color: words,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomText(text: "العدد"),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CustomText(
                                            text: item['product_details']
                                                        ['number']
                                                    ?.toString() ??
                                                "0",
                                            color: words,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      CustomText(text: "العلامة التجارية"),
                                      CustomText(
                                        text: _getMarkValue(item),
                                        color: words,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                (item['product_details']['img'] != null && 
                                 item['product_details']['img'].toString().trim().isNotEmpty)
                                    ? _buildImageRow(
                                        "",
                                        'http://jordancarpart.com/${item['product_details']['img']}',
                                      )
                                    : const Text(
                                        "لا توجد صورة",
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text:
                                        "${item['product_info']['fromYear']} ${item['product_info']['Category']} ${item['product_info']['NameCar']} ${item['product_info']['engineSize']}-${item['product_info']['fuelType']}",
                                    color: words,
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                CustomText(
                                  text: " : نوع السيارة",
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomText(
                                    text: item['product_details']['note']
                                            .isNotEmpty
                                        ? item['product_details']['note']
                                        : "لا يوجد ملاحظات",
                                    color: words,
                                  ),
                                ),
                                CustomText(text: "الملاحظات"),
                              ],
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

  String _getMarkValue(Map<String, dynamic> item) {
    final mark = item['product_details']['mark'];

    if (mark == null) return "غير محدد";
    if (mark.toString().trim().isEmpty) return "غير محدد";

    return mark.toString();
  }

  Future<String> fetchImageUrl(int productId) async {
    final url =
        Uri.parse('http://jordancarpart.com/Api/getphoto.php?id=$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['image'];
    } else {
      throw Exception('فشل في تحميل الصورة');
    }
  }

  Widget _buildImageRow(String label, String? imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        imageUrl != null && imageUrl.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _showImageDialog(imageUrl);
                },
                child: Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: RotatingImagePage(),
                    );
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Text(
                      "لا توجد صورة",
                      style: TextStyle(fontSize: 16),
                    );
                  },
                ),
              )
            : const Text(
                "لا توجد صورة",
                style: TextStyle(fontSize: 16),
              ),
      ],
    );
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FullScreenImageViewer(imageUrl: imageUrl);
      },
    );
  }

  Widget _buildTotalCost(List<dynamic> items) {
    double totalUserProductsCost = items.map((item) {
      final priceStr = item['product_details']['price']?.toString().trim();

      if (priceStr == null || priceStr.isEmpty) return 0.0;

      double? price = double.tryParse(priceStr);
      return price ?? 0.0;
    }).fold(0, (prev, price) => prev + price);

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
                text: totalUserProductsCost > 0
                    ? totalUserProductsCost.toInt().toString()
                    : "0",
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
