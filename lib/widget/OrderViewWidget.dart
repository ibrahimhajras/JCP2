import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:jcp/model/OrderModel.dart';
import 'package:jcp/style/colors.dart';
import 'package:jcp/style/custom_text.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/DetialsOrder/GreenPage/OrderDetailsPage_Green.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/Pay.dart';
import 'package:jcp/widget/DetialsOrder/RedPage/OrderDetailsPage_red2.dart';
import 'package:jcp/widget/DetialsOrder/OrangePage/OrderDetails_orange.dart';
import 'dart:convert';
import 'package:jcp/widget/DetialsOrder/RedPage/OrderDetails_red.dart';
import 'package:jcp/widget/Inallpage/showConfirmationDialog.dart';
import 'package:jcp/widget/RotatingImagePage.dart';
import 'DetialsOrder/GreenPage/OrderDetailsPage_Greenprivate.dart';
import 'DetialsOrder/OrangePage/OrderDetailsPage_Orangeprivate.dart';

class OrderViewWidget extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onDeleted;

  const OrderViewWidget({
    super.key,
    required this.order,
    this.onDeleted,
  });

  @override
  State<OrderViewWidget> createState() => _OrderViewWidgetState();
}

class _OrderViewWidgetState extends State<OrderViewWidget> {
  void deleteOrder(int orderId, BuildContext context) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/delete_order.php?order_id=$orderId');

    try {
      final response = await http.get(url);
      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (jsonResponse['success'] == true) {
          if (widget.onDeleted != null) widget.onDeleted!();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                text: "تم حذف الطلب بنجاح",
                color: Colors.white,
              ),
              backgroundColor: red,
            ),
          );
        }
      } else {
        
      }
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(widget.order);
    return GestureDetector(
      onLongPress: () {
        if (widget.order.state == 1 && widget.order.type == 1 ||
            widget.order.state == 4 && widget.order.type == 1 ||
            widget.order.state == 5 && widget.order.type == 1 ||
            widget.order.state == 1 && widget.order.type != 1) {
          showConfirmationDialog(
              context: context,
              message: "هل أنت متأكد من حذف الطلب",
              confirmText: "نعم",
              onCancel: () {},
              onConfirm: () {
                deleteOrder(widget.order.id, context); // استدعاء الـ API هنا
              },
              cancelText: "لا");
        }
      },
      onTap: () async {
        if (widget.order.state == 1 && widget.order.type == 1 ||
            widget.order.state == 4 && widget.order.type == 1 ||
            widget.order.state == 5 && widget.order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> items =
                await fetchOrderItems(widget.order.id.toString(), 1);
            
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage(
                    items: items, order_id: widget.order.id.toString()),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            
          }
        }
        if (widget.order.state == 1 && widget.order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> rawItems =
                await fetchOrderItems(widget.order.id.toString(), 2);
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
                    items: items, order_id: widget.order.id.toString()),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            
          }
        }
        if (widget.order.state == 2 && widget.order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );

          try {
            List<dynamic> orderItems2 = [];

            Map<String, dynamic> orderData =
                await fetchOrderItemsOrange(widget.order.id.toString(), 1);

            final response = await http.get(
              Uri.parse(
                  "https://jordancarpart.com/Api/gitnameorder.php?order_id=${widget.order.id}"),
            );

            if (response.statusCode == 200) {
              final Map<String, dynamic> jsonResponse =
                  json.decode(response.body);

              if (jsonResponse['success'] == true &&
                  jsonResponse.containsKey('items')) {
                orderItems2 = jsonResponse['items'];
              }
            }

            if (orderData.isNotEmpty &&
                orderData.containsKey('order') &&
                orderData.containsKey('order_items')) {
              Map<String, dynamic> order1 = orderData['order'];
              List<dynamic> orderItems = orderData['order_items'];

              Navigator.pop(context);
              print("--------------------------");
              print(orderData['order_items'].toString());
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage_Orange(
                    status: true,
                    order1: order1,
                    orderItems: orderItems,
                    nameproduct: orderItems2.isNotEmpty
                        ? orderItems2
                        : List.filled(orderItems.length, "غير معروف"),
                  ),
                ),
              );
            } else {
              throw Exception("Order data is missing required keys.");
            }
          } catch (e) {
            Navigator.pop(context);
            
          }
        }

        if (widget.order.state == 2 && widget.order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );

          try {
            final orderId = widget.order.id.toString();

            final billCheckResponse = await http.get(Uri.parse(
                "https://jordancarpart.com/Api/Bills/get_bill_by_order.php?order_id=$orderId"));
            
            final billData = jsonDecode(billCheckResponse.body);
            

            if (billCheckResponse.statusCode == 200 &&
                billData['success'] == true &&
                billData['bill_id'] != null) {
              Navigator.pop(context);

              int billId = int.tryParse(billData['bill_id'].toString()) ?? 0;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PayPage(
                    orderId: int.parse(orderId),
                    billId: billId,
                  ),
                ),
              );
              return;
            }

            List<dynamic> rawItems =
                await fetchOrderItems(widget.order.id.toString(), 2);

            List<Map<String, dynamic>> items = rawItems.map((item) {
              return {
                'itemname': item['itemname'],
                'itemlink': item['itemlink'],
                'itemimg64': item['itemimg64'],
              };
            }).toList();

            Map<String, dynamic> orderData =
                await fetchOrderItemsOrangePrivate(widget.order.id.toString());

            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsPage_OrangePrivate(
                  orderData: orderData,
                  items: items,
                  status: true,
                ),
              ),
            );
          } catch (e) {
            Navigator.pop(context);
            
          }
        }

        //https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=33
        if (widget.order.state == 3 && widget.order.type == 1 ||
            widget.order.state == 6 && widget.order.type == 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            Map<String, dynamic> orderData =
                await fetchOrderItemsFromUser(widget.order.id.toString());
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
            
          }
        }
        if (widget.order.state == 3 && widget.order.type != 1 ||
            widget.order.state == 6 && widget.order.type != 1) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(child: RotatingImagePage());
            },
          );
          try {
            List<dynamic> rawItems =
                await fetchOrderItems(widget.order.id.toString(), 2);
            List<Map<String, dynamic>> items = rawItems.map((item) {
              return {
                'itemname': item['itemname'],
                'itemlink': item['itemlink'],
                'itemimg64': item['itemimg64'],
              };
            }).toList();
            Map<String, dynamic> orderData =
                await fetchOrderItemsOrangePrivate(widget.order.id.toString());
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
            
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.01),
        child: Container(
          height: size.height * 0.11,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.order.state == 1 ||
                      widget.order.state == 4 ||
                      widget.order.state == 5
                  ? red
                  : widget.order.state == 2
                      ? orange
                      : widget.order.state == 3
                          ? (widget.order.billStatus == null ||
                                  widget.order.isPaid
                              ? green
                              : orange)
                          : widget.order.state == 6
                              ? green
                              : red,
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
                      color: widget.order.state == 1 ||
                              widget.order.state == 4 ||
                              widget.order.state == 5
                          ? red
                          : widget.order.state == 2
                              ? orange
                              : widget.order.state == 3
                                  ? (widget.order.billStatus == null ||
                                          widget.order.isPaid
                                      ? green
                                      : orange)
                                  : widget.order.state == 6
                                      ? green
                                      : red,
                      width: 3,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.circle,
                      color: widget.order.state == 1 ||
                              widget.order.state == 4 ||
                              widget.order.state == 5
                          ? red
                          : widget.order.state == 2
                              ? orange
                              : widget.order.state == 3
                                  ? (widget.order.billStatus == null ||
                                          widget.order.isPaid
                                      ? green
                                      : orange)
                                  : widget.order.state == 6
                                      ? green
                                      : red,
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
                        Expanded(
                          child: AutoSizeText(
                            widget.order.hasCarInfo
                                ? '${widget.order.carBrand ?? ''} '
                                        '${widget.order.carModel ?? ''} '
                                        '${widget.order.carYear ?? ''} '
                                        '${_capitalizeFirst(widget.order.carFuelType ?? '')} '
                                        '${(widget.order.carEngineSize == null || widget.order.carEngineSize == "N/A" || widget.order.carEngineSize!.isEmpty) ? '' : widget.order.carEngineSize!}'
                                    .trim()
                                : 'معلومات السيارة غير متوفرة',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Tajawal',
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            minFontSize: 10,
                            overflowReplacement: Text(
                              '...',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[700]),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        CustomText(
                          text: ": المركبة",
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
                          text: widget.order.time,
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
                      mainAxisAlignment: widget.order.state == 1 ||
                              widget.order.state == 2 &&
                                  widget.order.type != 1 ||
                              widget.order.state == 3 && widget.order.type != 1
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.end,
                      children: [
                        if (widget.order.state == 1 && widget.order.type == 1)
                          CustomText(
                            text: "... جاري العمل على طلبك",
                            size: 10,
                          ),
                        if (widget.order.type != 1)
                          CustomText(
                            text: "...طلب خاص",
                            size: 10,
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: widget.order.id.toString(),
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

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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

        if (responseData.containsKey('data') &&
            (responseData['data'] as List).isNotEmpty) {
          Map<String, dynamic> orderDetails = responseData['data'][0];

          return {
            'orderDetails': orderDetails,
          };
        } else {
          throw Exception('No data found for the given order ID');
        }
      } else {
        throw Exception(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      
      throw e;
    }
  }

  Future<List<dynamic>> fetchOrderItems(String orderId, int flag) async {
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

        if (responseData.containsKey('orders') &&
            (responseData['orders'] as List).isNotEmpty) {
          var order = responseData['orders'][0];

          return {'order': order, 'order_items': order['items'] ?? []};
        } else {
          return {'order': {}, 'order_items': []};
        }
      } else {
        throw Exception('Failed to load order items, status');
      }
    } catch (e) {
      
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
      
      throw e;
    }
  }

  Future<Map<String, dynamic>> fetchOrderItemsFromUser(String orderId) async {
    final url = Uri.parse(
        'https://jordancarpart.com/Api/getacceptedorderfromuser.php?order_id=$orderId');

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

        

        if (responseData.containsKey('hdr') &&
            responseData.containsKey('items')) {
          return {
            'header': responseData['hdr'][0],
            'items': responseData['items'],
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
      
      throw e;
    }
  }
}
