// // lib/services/cybersource_3ds_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// class ThreeDSResult {
//   final String authenticationTransactionId;
//   final String? acsUrl;
//   final String? pareq;
//   final String? token;
//   final String? stepUpUrl; // ✅ أضف هذا
//   final String status;
//   final String? eci;
//   final String? cavvOrAav;
//   final String? xid;
//   final String? directoryServerTransactionId;
//   final Map<String, dynamic>? raw;
//
//   ThreeDSResult({
//     required this.authenticationTransactionId,
//     required this.status,
//     this.acsUrl,
//     this.pareq,
//     this.token,
//     this.stepUpUrl, // ✅ أضف هذا
//     this.eci,
//     this.cavvOrAav,
//     this.xid,
//     this.directoryServerTransactionId,
//     this.raw,
//   });
// }
// class CyberSource3DSService {
//   static const String base = "https://jordancarpart.com/Api/Bills";
//
//   Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
//     final uri = Uri.parse("$base/$path");
//
//
//     try {
//       final res = await http
//           .post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body))
//           .timeout(const Duration(seconds: 30));
//
//
//
//
//       final json = jsonDecode(res.body);
//
//       if (res.statusCode >= 200 && res.statusCode < 300 && json is Map) {
//         if (json["success"] == true) return Map<String, dynamic>.from(json);
//
//         final status = json["status"];
//         final details = json["response"];
//         throw Exception("Cybersource error (HTTP:$status) → $details");
//       }
//       throw Exception("HTTP ${res.statusCode} → ${res.body}");
//     } catch (e) {
//
//       rethrow;
//     }
//   }
//
//   Future<Map<String, dynamic>> setup({
//     required String orderId,
//     required String amount,
//     required String currency,
//     required String number,
//     required String expMonth,
//     required String expYear,
//     String? cardType,
//     String? phone,
//   }) async {
//     final body = {
//       "order_id": orderId,
//       "amount": amount,
//       "currency": currency,
//       "cardNumber": number,
//       "expirationMonth": expMonth,
//       "expirationYear": expYear,
//       if (cardType != null) "cardType": cardType,
//       if (phone != null) "buyerMobile": phone,
//     };
//     return await _post("payer_auth_setup.php", body);
//   }
//
//   Future<ThreeDSResult> enroll({
//     required String orderId,
//     required String amount,
//     required String currency,
//     required String number,
//     required String expMonth,
//     required String expYear,
//     String? firstName,
//     String? lastName,
//     String? email,
//     String? phone,
//     String? cardType,
//     String? referenceId,
//   }) async {
//     final resp = await _post("payer_auth_enroll.php", {
//       "order_id": orderId,
//       "amount": amount,
//       "currency": currency,
//       "cardNumber": number,
//       "expirationMonth": expMonth,
//       "expirationYear": expYear,
//       if (firstName != null) "firstName": firstName,
//       if (lastName != null) "lastName": lastName,
//       if (email != null) "email": email,
//       if (phone != null) "phone": phone,
//       if (cardType != null) "cardType": cardType,
//       if (referenceId != null) "referenceId": referenceId,
//     });
//
//     if (resp["success"] != true) {
//       throw Exception(resp["message"] ?? "Enrollment failed");
//     }
//
//     final data = Map<String, dynamic>.from(resp["data"] ?? {});
//     final cai = Map<String, dynamic>.from(data["consumerAuthenticationInformation"] ?? {});
//     return ThreeDSResult(
//       authenticationTransactionId: (cai["authenticationTransactionId"] ?? "") as String,
//       status: (data["status"] ?? "PENDING_AUTHENTICATION") as String,
//       acsUrl: cai["acsUrl"] as String?,
//       pareq: cai["pareq"] as String?,
//       token: cai["token"] as String?,
//       raw: data,
//     );
//   }
//
//   Future<ThreeDSResult> authenticate({
//     required String authenticationTransactionId,
//     required String number,
//     required String expMonth,
//     required String expYear,
//     required String amount,
//     required String currency,
//   }) async {
//     final resp = await _post("payer_auth_authenticate.php", {
//       "transactionId": authenticationTransactionId,
//       "cardNumber": number,
//       "expirationMonth": expMonth,
//       "expirationYear": expYear,
//       "amount": amount,
//       "currency": currency,
//     });
//
//     if (resp["success"] != true) {
//       throw Exception(resp["message"] ?? "Authenticate failed");
//     }
//
//     final data = Map<String, dynamic>.from(resp["data"] ?? {});
//     final cai = Map<String, dynamic>.from(data["consumerAuthenticationInformation"] ?? {});
//
//     final newAuthId = cai["authenticationTransactionId"] as String? ?? authenticationTransactionId;
//
//     return ThreeDSResult(
//       authenticationTransactionId: newAuthId,
//       status: (data["status"] ?? "PENDING_AUTHENTICATION") as String,
//       acsUrl: cai["acsUrl"] as String?,
//       pareq: cai["pareq"] as String?,
//       token: cai["token"] as String?,
//       stepUpUrl: cai["stepUpUrl"] as String?,
//       raw: data,  // ✅ مهم: نرجع raw data عشان نوصل لـ accessToken
//     );
//   }
//
//   Future<ThreeDSResult> validateAuth({
//     required String authenticationTransactionId,
//     required String amount,
//     required String currency,
//     String? pares,
//   }) async {
//     final body = {
//       "authenticationTransactionId": authenticationTransactionId,
//       "amount": amount,
//       "currency": currency,
//     };
//     if (pares != null) body["pares"] = pares;
//
//     final resp = await _post("payer_auth_validate.php", body);
//
//     if (resp["success"] != true) {
//       throw Exception(resp["message"] ?? "Validation failed");
//     }
//
//     final data = Map<String, dynamic>.from(resp["data"] ?? {});
//     final cai = Map<String, dynamic>.from(data["consumerAuthenticationInformation"] ?? {});
//
//     String? eci = cai["eci"] ?? cai["eciRaw"] ?? cai["commerceIndicator"];
//     String? cavv = cai["cavv"] ?? cai["authenticationValue"];
//     String? xid = cai["xid"] ?? cai["threeDSServerTransactionId"];
//     String? dsTransId = cai["directoryServerTransactionId"];
//
//     return ThreeDSResult(
//       authenticationTransactionId: authenticationTransactionId,
//       status: (data["status"] ?? "AUTHENTICATED") as String,
//       eci: eci,
//       cavvOrAav: cavv,
//       xid: xid,
//       directoryServerTransactionId: dsTransId,
//       raw: data,
//     );
//   }
//
// }