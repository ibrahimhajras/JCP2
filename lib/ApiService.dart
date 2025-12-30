import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model/Delevery/Orders.dart';

class ApiService {
  static const String apiUrl = "https://your-api-url.com/get_orders.php"; // Replace with your API URL

  static Future<List<Order>> fetchOrders() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return OrderResponse.fromMap(jsonResponse).data;
    } else {
      throw Exception("Failed to load orders");
    }
  }
}
