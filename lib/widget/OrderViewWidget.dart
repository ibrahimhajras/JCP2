import 'package:flutter/material.dart';
import 'package:jcp/model/OrderModel.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/DetialsOrder/GreenPage/OrderDetailsPage_Green.dart';
import 'package:jcp/widget/DetialsOrder/RedPage/OrderDetailsPage_red2.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'dart:convert';
import 'package:jcp/widget/DetialsOrder/RedPage/OrderDetails_red.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DetialsOrder/GreenPage/OrderDetailsPage_Greenprivate.dart';
import 'DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';

class OrderViewWidget extends StatelessWidget {
  final OrderModel order;

  const OrderViewWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () async {
        if (order.state == 1 && order.type == 1 ||
            order.state == 4 && order.type == 1 ||
            order.state == 5 && order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> items = await fetchOrderItems(order.id.toString(), 1);
            print(items);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                    items: items, order_id: order.id.toString()),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
        if (order.state == 1 && order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> rawItems =
                await fetchOrderItems(order.id.toString(), 2);
            List<Map<String, dynamic>> items = rawItems.map((item) {
              return {
                'itemname': item['itemname'],
                'itemlink': item['itemlink'],
                'itemimg64': item['itemimg64'],
              };
            }).toList();
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage2(
                    items: items, order_id: order.id.toString()),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
        if (order.state == 2 && order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            Map<String, dynamic> orderData =
                await fetchOrderItemsOrange(order.id.toString(), 1);
            List<dynamic> order1 = orderData['order'];
            List<dynamic> orderItems = orderData['order_items'];

            print('Order Details:$order1');
            print('Order Items: $orderItems');
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage_Orange(
                    order1: order1, orderItems: orderItems),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
        if (order.state == 2 && order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> rawItems =
                await fetchOrderItems(order.id.toString(), 2);
            List<Map<String, dynamic>> items = rawItems.map((item) {
              return {
                'itemname': item['itemname'],
                'itemlink': item['itemlink'],
                'itemimg64': item['itemimg64'],
              };
            }).toList();
            Map<String, dynamic> orderData =
                await fetchOrderItemsOrangePrivate(order.id.toString());
            print("orderData" + orderData.toString());
            print("orderData" + order.id.toString());
            print(order.carId);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage_OrangePrivate(
                    orderData: orderData, items: items, carid: order.carId.toString(),),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
        //https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=33
        if (order.state == 3 && order.type == 1 ||
            order.state == 6 && order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            Map<String, dynamic> orderData =
                await fetchOrderItemsFromUser(order.id.toString());
            print(orderData);
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage_Green(
                    orderData: orderData,
                  ),
                ));
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
        if (order.state == 3 && order.type != 1 ||
            order.state == 6 && order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> rawItems =
                await fetchOrderItems(order.id.toString(), 2);
            List<Map<String, dynamic>> items = rawItems.map((item) {
              return {
                'itemname': item['itemname'],
                'itemlink': item['itemlink'],
                'itemimg64': item['itemimg64'],
              };
            }).toList();
            Map<String, dynamic> orderData =
                await fetchOrderItemsOrangePrivate(order.id.toString());
            print(orderData);
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage_Greenprivate(
                    orderData: orderData, items: items),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            print('Error fetching order items: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('فشل في جلب تفاصيل الطلب.')),
            );
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
        child: Container(
          height: size.height * 0.11,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: order.state == 1 || order.state == 4 || order.state == 5
                  ? red
                  : order.state == 2
                      ? orange
                      : order.state == 3 || order.state == 6
                          ? green
                          : red, // Default to red if none of the states match
              width: 3,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 5,
                left: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: order.state == 1 ||
                              order.state == 4 ||
                              order.state == 5
                          ? red
                          : order.state == 2
                              ? orange
                              : order.state == 3 || order.state == 6
                                  ? green
                                  : red, // Default to red if none of the states match
                      width: 3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.circle,
                      color: order.state == 1 ||
                              order.state == 4 ||
                              order.state == 5
                          ? red
                          : order.state == 2
                              ? orange
                              : order.state == 3 || order.state == 6
                                  ? green
                                  : red, // Default to red if none of the states match
                      size: 12,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: size.width * 0.03),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          text: order.carId,
                          size: 14,
                          weight: FontWeight.w900,
                          letters: true,
                        ),
                        CustomText(
                          text: " : رقم الشاصي",
                          size: 14,
                          weight: FontWeight.w900,
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomText(
                          text: order.time,
                          size: 16,
                          weight: FontWeight.w500,
                        ),
                        CustomText(
                          text: " : تاريخ الطلب",
                          size: 14,
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: order.state == 1
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        if (order.state == 1)
                          CustomText(
                            text: "... جاري العمل على طلبك",
                            size: 10,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: order.id.toString(),
                              size: 14,
                              weight: FontWeight.w500,
                            ),
                            CustomText(
                              text: " : رقم الطلب",
                              size: 14,
                              weight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPrivateOrderDetails(String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedprivateorder.php?order_id=$orderId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Response Data: $responseData');

        if (responseData.containsKey('data') &&
            (responseData['data'] as List).isNotEmpty) {
          Map<String, dynamic> orderDetails =
              responseData['data'][0]; // Extract the first element from 'data'

          return {
            'orderDetails': orderDetails, // Return the order details
          };
        } else {
          throw Exception('No data found for the given order ID');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }

  Future<List<dynamic>> fetchOrderItems(String orderId, int flag) async {
    // تكوين رابط الطلب مع المعايير
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getItemsFromOrders.php?order_id=$orderId&flag=$flag');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData.containsKey('order_items')) {
          return responseData['order_items'];
        } else if (responseData.containsKey('order_private_items')) {
          return responseData['order_private_items'];
        } else {
          throw Exception('Invalid response format: missing expected keys');
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order items: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrange(
      String orderId, int flag) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getorderacept.php?order_id=$orderId&flag=$flag');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('order') &&
            responseData.containsKey('order_items')) {
          return {
            'order': responseData['order'],
            'order_items': responseData['order_items']
          };
        } else {
          return {'order': [], 'order_items': []};
        }
      } else {
        throw Exception(
            'Failed to load order items, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order items: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsOrangePrivate(
      String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedprivateorder.php?order_id=$orderId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('data')) {
          List<dynamic> data = responseData['data'];
          if (data.isNotEmpty) {
            return data[0]; // Return the first element of 'data'
          } else {
            throw Exception('No data found for the given order ID');
          }
        } else {
          throw Exception('Invalid response format: missing "data" key');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsFromUser(String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId');

    try {
      print('URL being sent: $url');

      final response = await http.get(
        url,
        headers: {
          'Access-Control-Allow-Headers': '*',
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print('Response Data: $responseData');

        if (responseData.containsKey('hdr') &&
            responseData.containsKey('items')) {
          return {
            'header': responseData['hdr']
                [0], // Assuming there's only one header
            'items': responseData['items'], // List of items
          };
        } else {
          throw Exception(
              'Invalid response format: missing "hdr" or "items" keys');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      throw e;
    }
  }
}
