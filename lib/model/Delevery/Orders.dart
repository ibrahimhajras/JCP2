import 'dart:convert';

import 'Item.dart';
import 'Trader.dart';

class OrderResponse {
  final bool success;
  final List<Order> data;

  OrderResponse({required this.success, required this.data});

  factory OrderResponse.fromJson(String str) =>
      OrderResponse.fromMap(json.decode(str));

  factory OrderResponse.fromMap(Map<String, dynamic> json) => OrderResponse(
    success: json["success"] ?? false,
    data: json["data"] != null
        ? List<Order>.from(
      json["data"].map((x) => Order.fromMap(x)),
    )
        : [],
  );
}

class Order {
  final int userId;
  final String? deleverPersion;
  final String? note;
  final String? carid;
  final String deliveryType;
  final String totalCost;
  final String customerName;
  final String customerPhone;
  final String customerCity;
  final int deliveryId;
  final int orderId;
  final String payMethod;
  final String orderTime;
  final int totalItems;
  final String fuelType;
  final String engineSize;
  final int engineYear;
  final String engineCategory;
  final String engineType;
  final List<Item> itemsDetails;
  final List<Trader> traderDetails;

  Order({
    required this.userId,
    required this.deleverPersion,
    required this.note,
    required this.carid,
    required this.deliveryType,
    required this.totalCost,
    required this.customerName,
    required this.customerPhone,
    required this.customerCity,
    required this.deliveryId,
    required this.orderId,
    required this.payMethod,
    required this.orderTime,
    required this.totalItems,
    required this.fuelType,
    required this.engineSize,
    required this.engineYear,
    required this.engineCategory,
    required this.engineType,
    required this.itemsDetails,
    required this.traderDetails,
  });

  factory Order.fromMap(Map<String, dynamic> json) => Order(
    userId: json["userId"] ?? 0,
    deleverPersion: _parseFirstNameFromJson(json["delever_persion"]),
    note: json["note"] ?? "",
    carid: json["carid"] ?? "",
    deliveryType: json["deliveryType"] ?? "",
    totalCost: json["totalCost"] ?? "0",
    customerName: json["customer_name"] ?? "",
    customerPhone: json["customer_phone"] ?? "",
    customerCity: json["customer_city"] ?? "",
    deliveryId: json["delivery_id"] ?? 0,
    orderId: json["orderid"] ?? 0,
    payMethod: json["paymethod"] ?? "",
    orderTime: json["order_time"] ?? "",
    totalItems: json["total_items"] ?? 0,
    fuelType: json["Fueltype"] ?? "",
    engineSize: json["Enginesize"] ?? "",
    engineYear: json["Engineyear"] ?? 0,
    engineCategory: json["Enginecategory"] ?? "",
    engineType: json["Enginetype"] ?? "",
    itemsDetails: json["items_details"] != null
        ? List<Item>.from(
        json["items_details"].expand((x) =>
        (x["product_details"] != null
            ? List<Item>.from(
            x["product_details"].map((y) => Item.fromMap(y)))
            : [])))
        : [],
    traderDetails: json["trader_details"] != null
        ? List<Trader>.from(
        json["trader_details"].map((x) => Trader.fromMap(x)))
        : [],
  );

  static String? _parseFirstNameFromJson(dynamic data) {
    if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
      return data.first["name"]?.toString() ?? "";
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "delever_persion": deleverPersion,
      "note": note,
      "carid": carid,
      "deliveryType": deliveryType,
      "totalCost": totalCost,
      "customer_name": customerName,
      "customer_phone": customerPhone,
      "customer_city": customerCity,
      "delivery_id": deliveryId,
      "orderid": orderId,
      "paymethod": payMethod,
      "order_time": orderTime,
      "total_items": totalItems,
      "Fueltype": fuelType,
      "Enginesize": engineSize,
      "Engineyear": engineYear,
      "Enginecategory": engineCategory,
      "Enginetype": engineType,
      "items_details": [
        {
          "product_details":
          itemsDetails.map((item) => item.toJson()).toList()
        }
      ],
      "trader_details": traderDetails.map((trader) => trader.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return '''
  Order {
    userId: $userId,
    deleverPersion: $deleverPersion,
    note: $note,
    carid: $carid,
    deliveryType: $deliveryType,
    totalCost: $totalCost,
    customerName: $customerName,
    customerPhone: $customerPhone,
    customerCity: $customerCity,
    deliveryId: $deliveryId,
    orderId: $orderId,
    payMethod: $payMethod,
    orderTime: $orderTime,
    totalItems: $totalItems,
    fuelType: $fuelType,
    engineSize: $engineSize,
    engineYear: $engineYear,
    engineCategory: $engineCategory,
    engineType: $engineType,
    itemsDetails: ${itemsDetails.map((item) => item.toString()).toList()},
    traderDetails: ${traderDetails.map((trader) => trader.toString()).toList()}
  }
  ''';
  }
}
