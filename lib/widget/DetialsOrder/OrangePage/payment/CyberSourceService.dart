// // lib/services/cybersource_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:crypto/crypto.dart';
// import 'dart:math' as math;
//
// class CyberSourceService {
//   static const String _baseUrl = 'https://api.cybersource.com';
//   static const String _merchantId = 'jordancarparts002';
//   static const String _apiKey = 'b4952701-bd20-48ed-8c4c-f47839ef6409';
//   static const String _sharedSecret = 'yp/x+Ut+ufiJB2CEOtn9UJqAbC5DV4oNx7TUPEzbmhw=';
//
//   bool _isMastercard(String cardNumber) {
//     return RegExp(r'^5[1-5]').hasMatch(cardNumber) || RegExp(r'^2[2-7]').hasMatch(cardNumber);
//   }
//
//   String _getCommerceIndicator(String eci, String cardNumber, String cavvOrAav) {
//     // If no 3DS data (CAVV/AAV), use regular internet commerce indicator
//     if (cavvOrAav.isEmpty) {
//       return "internet";
//     }
//
//     final bool isMastercard = _isMastercard(cardNumber);
//     final bool isVisa = cardNumber.startsWith('4');
//     final bool isAmex = RegExp(r'^3[47]').hasMatch(cardNumber);
//
//     // Map ECI to commerce indicator based on card network
//     switch (eci) {
//     // Visa ECI values
//       case '05': // Visa - Full authentication
//         return isVisa ? "vbv" : "spa"; // vbv = Verified by Visa
//       case '06': // Visa - Attempted authentication
//         return isVisa ? "vbv_attempted" : "spa_attempted";
//
//     // Mastercard ECI values
//       case '02': // Mastercard - Full authentication
//         return isMastercard ? "spa" : "vbv"; // spa = SecureCode (SPA)
//       case '01': // Mastercard - Attempted authentication
//         return isMastercard ? "spa_attempted" : "vbv_attempted";
//
//     // Amex ECI values
//       case '07': // Amex - Full authentication
//         return "aesk"; // American Express SafeKey
//
//     // 3DS 2.0 Protocol ECI values (more common with modern implementations)
//       case '00': // No authentication
//         return "internet";
//
//       default:
//       // Fallback based on card type
//         if (isMastercard) {
//           return "spa";
//         } else if (isVisa) {
//           return "vbv";
//         } else if (isAmex) {
//           return "aesk";
//         }
//         return "internet";
//     }
//   }
//
//   /// Determine authentication indicator based on 3DS version
//   String _getAuthenticationIndicator(String? paSpecificationVersion) {
//     if (paSpecificationVersion == null || paSpecificationVersion.isEmpty) {
//       return "01"; // 3DS 1.0 - Default
//     }
//
//     // Check if it's 3DS 2.x
//     if (paSpecificationVersion.startsWith("2.")) {
//       return "02"; // 3DS 2.x
//     }
//
//     return "01"; // 3DS 1.0
//   }
//
//   Future<Map<String, dynamic>> authorizePayment({
//     required String cardNumber,
//     required String expirationMonth,
//     required String expirationYear,
//     required String cvv,
//     required String firstName,
//     required String lastName,
//     required String amount,
//     required String currency,
//     required String authenticationTransactionId,
//     required String eci,
//     required String cavvOrAav,
//     required String xid,
//     required String uniqueEmail,
//     String? directoryServerTransactionId,
//     String? ucafCollectionIndicator,
//     String? paSpecificationVersion,
//     String? threeDSServerTransactionId,
//     String? acsTransactionId,
//     String? paresStatus,
//     String? veresEnrolled,
//   }) async {
//
//     print("🔧 بناء Authorization Request...");
//     print("   - Card: ${cardNumber.substring(0, 4)}****");
//     print("   - Amount: $amount $currency");
//     print("   - CVV: ${cvv.isNotEmpty ? '***' : 'EMPTY!'}");
//     print("   - CVV Length: ${cvv.length}");
//     print("   - Auth Transaction ID: $authenticationTransactionId");
//     print("   - ECI: $eci");
//
//     final commerceIndicator = _getCommerceIndicator(eci, cardNumber, cavvOrAav);
//     print("   - Commerce Indicator: $commerceIndicator");
//
//     final body = {
//       "clientReferenceInformation": {
//         "code": "AUTH_${DateTime.now().millisecondsSinceEpoch}"
//       },
//       "processingInformation": {
//         "commerceIndicator": commerceIndicator,
//         "capture": false, // Authorization only - capture separately
//       },
//
//       "paymentInformation": {
//         "card": {
//           "number": cardNumber,
//           "expirationMonth": expirationMonth,
//           "expirationYear": expirationYear,
//           // ⚠️ DO NOT send CVV when using 3DS - it's already verified!
//           // Only send CVV if no 3DS data (CAVV) is present
//           if (cavvOrAav.isEmpty && cvv.isNotEmpty) "securityCode": cvv
//         }
//       },
//
//       "orderInformation": {
//         "amountDetails": {
//           "totalAmount": amount,
//           "currency": currency
//         },
//         "billTo": {
//           "firstName": firstName,
//           "lastName": lastName,
//           "address1": "Jordan Street",
//           "locality": "Amman",
//           "administrativeArea": "AM",
//           "postalCode": "11111",
//           "country": "JO",
//           "email": uniqueEmail,
//           "phoneNumber": "962000000000"
//         }
//       },
//       "consumerAuthenticationInformation": _buildConsumerAuthInfo(
//         authenticationTransactionId: authenticationTransactionId,
//         eci: eci,
//         cavvOrAav: cavvOrAav,
//         xid: xid,
//         directoryServerTransactionId: directoryServerTransactionId,
//         ucafCollectionIndicator: ucafCollectionIndicator,
//         paSpecificationVersion: paSpecificationVersion,
//         threeDSServerTransactionId: threeDSServerTransactionId,
//         acsTransactionId: acsTransactionId,
//         paresStatus: paresStatus,
//         veresEnrolled: veresEnrolled,
//         cardNumber: cardNumber,
//       )
//     };
//
//     print("📦 Consumer Authentication Information:");
//     final authInfo = body["consumerAuthenticationInformation"] as Map<String, dynamic>;
//     authInfo.forEach((key, value) {
//       if (value is String && value.isNotEmpty) {
//         final displayValue = value.length > 50 ? "${value.substring(0, 50)}..." : value;
//         print("   - $key: $displayValue");
//       }
//     });
//
//     // 🔍 طباعة معلومات البطاقة للتأكد من CVV
//     print("\n🔍 Payment Information:");
//     final paymentInfo = body["paymentInformation"] as Map<String, dynamic>;
//     final cardInfo = paymentInfo["card"] as Map<String, dynamic>;
//     print("   - Card Number: ${cardInfo["number"]?.toString().substring(0, 4)}****");
//     print("   - Expiry: ${cardInfo["expirationMonth"]}/${cardInfo["expirationYear"]}");
//     print("   - Security Code Present: ${cardInfo.containsKey("securityCode")}");
//     if (cardInfo.containsKey("securityCode")) {
//       final sc = cardInfo["securityCode"]?.toString() ?? "";
//       print("   - Security Code Length: ${sc.length}");
//       print("   - Security Code Value: ${sc.isNotEmpty ? "***" : "EMPTY!"}");
//     }
//
//     final headers = await _buildHeaders("POST", "/pts/v2/payments", body);
//
//     try {
//       print("🌐 إرسال Authorization Request...");
//
//       // 🔍 DEBUG: Print the FULL JSON being sent
//       final jsonBody = jsonEncode(body);
//       print("\n📤 FULL JSON BODY:");
//       print(jsonBody.substring(0, jsonBody.length > 1000 ? 1000 : jsonBody.length));
//
//       final res = await http.post(
//         Uri.parse("$_baseUrl/pts/v2/payments"),
//         headers: headers,
//         body: jsonBody,
//       ).timeout(const Duration(seconds: 30));
//
//       print("📨 Authorization Response Status: ${res.statusCode}");
//
//       final json = jsonDecode(res.body);
//
//       if (res.statusCode == 201) {
//         // نجح التفويض
//         print("✅ Authorization نجح!");
//         print("   - Transaction ID: ${json["id"]}");
//         print("   - Status: ${json["status"]}");
//         print("   - Reconciliation ID: ${json["reconciliationId"]}");
//
//         return {
//           "success": true,
//           "data": json,
//           "transactionId": json["id"],
//           "reconciliationId": json["reconciliationId"],
//           "commerceIndicator": commerceIndicator,
//         };
//       } else {
//         // فشل التفويض
//         print("❌ Authorization فشل!");
//         print("   - Status Code: ${res.statusCode}");
//         print("   - Error: ${json["message"] ?? json["reason"]}");
//         if (json["errorInformation"] != null) {
//           print("   - Error Info: ${json["errorInformation"]}");
//         }
//
//         return {
//           "success": false,
//           "data": json,
//           "status": res.statusCode,
//           "message": json["message"] ?? json["reason"] ?? "Authorization failed"
//         };
//       }
//     } catch (e, stackTrace) {
//       print("💥 خطأ في Authorization Request: $e");
//       print("📍 Stack trace: $stackTrace");
//
//       return {
//         "success": false,
//         "error": e.toString(),
//       };
//     }
//   }
//
//   Map<String, dynamic> _buildConsumerAuthInfo({
//     required String authenticationTransactionId,
//     required String eci,
//     required String cavvOrAav,
//     required String xid,
//     String? directoryServerTransactionId,
//     String? ucafCollectionIndicator,
//     String? paSpecificationVersion,
//     String? threeDSServerTransactionId,
//     String? acsTransactionId,
//     String? paresStatus,
//     String? veresEnrolled,
//     required String cardNumber,
//   }) {
//
//     final authInfo = <String, dynamic>{
//       // 🎯 الحقول الأساسية (مطلوبة دائماً)
//       "authenticationTransactionId": authenticationTransactionId,
//       "eciRaw": eci,
//
//       // 🎯 Authentication Indicator (مطلوب لـ 3DS)
//       "authenticationIndicator": _getAuthenticationIndicator(paSpecificationVersion),
//
//       // 🎯 Return URLs (مطلوبة)
//       "returnUrl": "https://jordancarpart.com/Api/Bills/3ds_callback.php",
//       "termUrl": "https://jordancarpart.com/Api/Bills/3ds_callback.php",
//     };
//
//     // 🎯 إضافة CAVV/AAV للشبكات المدعومة
//     if (cavvOrAav.isNotEmpty) {
//       if (_isMastercard(cardNumber)) {
//         // Mastercard يستخدم UCAF
//         authInfo["ucafAuthenticationData"] = cavvOrAav;
//         print("🔶 إضافة UCAF Authentication Data لـ Mastercard");
//       } else {
//         // Visa, Amex, etc يستخدموا CAVV
//         authInfo["cavv"] = cavvOrAav;
//         print("🔷 إضافة CAVV لـ Visa/Amex");
//       }
//     }
//
//     // 🎯 إضافة XID (مطلوب لـ Visa والشبكات الأخرى عدا Mastercard أحياناً)
//     if (xid.isNotEmpty) {
//       authInfo["xid"] = xid;
//     }
//
//     // 🎯 Mastercard خصوصاً
//     if (_isMastercard(cardNumber)) {
//       if (directoryServerTransactionId != null && directoryServerTransactionId.isNotEmpty) {
//         authInfo["directoryServerTransactionId"] = directoryServerTransactionId;
//         print("🔶 إضافة Directory Server Transaction ID لـ Mastercard");
//       }
//
//       if (ucafCollectionIndicator != null) {
//         authInfo["ucafCollectionIndicator"] = ucafCollectionIndicator;
//         print("🔶 إضافة UCAF Collection Indicator: $ucafCollectionIndicator");
//       }
//     }
//
//     // 🎯 3DS 2.x Fields (مطلوبة للإصدار الجديد)
//     if (paSpecificationVersion != null && paSpecificationVersion.isNotEmpty) {
//       authInfo["specificationVersion"] = paSpecificationVersion;
//       print("🔧 إضافة 3DS Specification Version: $paSpecificationVersion");
//     }
//
//     if (threeDSServerTransactionId != null && threeDSServerTransactionId.isNotEmpty) {
//       authInfo["threeDSServerTransactionId"] = threeDSServerTransactionId;
//     }
//
//     if (acsTransactionId != null && acsTransactionId.isNotEmpty) {
//       authInfo["acsTransactionId"] = acsTransactionId;
//     }
//
//     // 🎯 إضافة PARes و VERes Status
//     if (paresStatus != null && paresStatus.isNotEmpty) {
//       authInfo["paresStatus"] = paresStatus;
//     }
//
//     if (veresEnrolled != null && veresEnrolled.isNotEmpty) {
//       authInfo["veresEnrolled"] = veresEnrolled;
//     }
//
//     // 🎯 إضافة Directory Server Transaction ID للشبكات الأخرى
//     if (!_isMastercard(cardNumber) && directoryServerTransactionId != null && directoryServerTransactionId.isNotEmpty) {
//       authInfo["directoryServerTransactionId"] = directoryServerTransactionId;
//     }
//
//     return authInfo;
//   }
//
//   Future<Map<String, String>> _buildHeaders(
//       String method, String endpoint, Map<String, dynamic> body) async {
//     final timestamp = _formatDate(DateTime.now());
//     final bodyString = jsonEncode(body);
//     final digest = sha256.convert(utf8.encode(bodyString));
//     final digestBase64 = base64.encode(digest.bytes);
//     final signature = _generateSignature(method, endpoint, digestBase64, timestamp);
//
//     return {
//       'Content-Type': 'application/json',
//       'Accept': 'application/hal+json;charset=utf-8',
//       'v-c-merchant-id': _merchantId,
//       'Date': timestamp,
//       'Host': 'api.cybersource.com',
//       'Digest': 'SHA-256=$digestBase64',
//       'Signature': signature,
//     };
//   }
//
//   String _generateSignature(String method, String endpoint, String digest, String date) {
//     final stringToSign = '(request-target): ${method.toLowerCase()} $endpoint\n'
//         'host: api.cybersource.com\n'
//         'date: $date\n'
//         'digest: SHA-256=$digest\n'
//         'v-c-merchant-id: $_merchantId';
//
//     final keyBytes = base64.decode(_sharedSecret);
//     final hmacSha256 = Hmac(sha256, keyBytes);
//     final signatureBytes = hmacSha256.convert(utf8.encode(stringToSign));
//     final signatureBase64 = base64.encode(signatureBytes.bytes);
//
//     return 'keyid="$_apiKey", algorithm="HmacSHA256", headers="(request-target) host date digest v-c-merchant-id", signature="$signatureBase64"';
//   }
//
//   String _formatDate(DateTime date) {
//     final utc = date.toUtc();
//     const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return '${days[utc.weekday - 1]}, ${utc.day.toString().padLeft(2, '0')} '
//         '${months[utc.month - 1]} ${utc.year} '
//         '${utc.hour.toString().padLeft(2, '0')}:${utc.minute.toString().padLeft(2, '0')}:${utc.second.toString().padLeft(2, '0')} GMT';
//   }
//
//   /// Capture funds from a previously authorized transaction
//   /// This must be called after a successful authorization to actually transfer the funds
//   Future<Map<String, dynamic>> capturePayment({
//     required String authorizationId,
//     required String amount,
//     required String currency,
//     required String authReconciliationId,
//     required String firstName,
//     required String lastName,
//     required String uniqueEmail,
//     String? commerceIndicator,
//
//   }) async {
//     print("💰 بناء Capture Request...");
//     print("   - Authorization ID: $authorizationId");
//     print("   - Amount: $amount $currency");
//     print("   - Auth Reconciliation ID: $authReconciliationId");
//     print("   - Commerce Indicator: ${commerceIndicator ?? 'internet'}");
//
//     final body = {
//       "clientReferenceInformation": {
//         "code": "CAPTURE_${DateTime.now().millisecondsSinceEpoch}"
//       },
//       "processingInformation": {
//         "reconciliationId": authReconciliationId,
//         "commerceIndicator": commerceIndicator ?? "internet",
//       },
//       "orderInformation": {
//         "amountDetails": {"totalAmount": amount, "currency": currency},
//         "billTo": {
//           "firstName": firstName,
//           "lastName": lastName,
//           "address1": "Jordan Street",
//           "locality": "Amman",
//           "administrativeArea": "AM",
//           "postalCode": "11111",
//           "country": "JO",
//           "email": uniqueEmail,
//           "phoneNumber": "962000000000"
//         }
//       },
//       "merchantInformation": {
//         "merchantDescriptor": {
//           "name": "JORDANCARPARTS",
//           "contact": "962000000000"
//         }
//       }
//     };
//
//     final endpoint = "/pts/v2/payments/$authorizationId/captures";
//     final headers = await _buildHeaders("POST", endpoint, body);
//
//     try {
//       print("🌐 إرسال Capture Request...");
//
//       final jsonBody = jsonEncode(body);
//       print("\n📤 CAPTURE JSON BODY:");
//       print(jsonBody);
//
//       final res = await http.post(
//         Uri.parse("$_baseUrl$endpoint"),
//         headers: headers,
//         body: jsonBody,
//       ).timeout(const Duration(seconds: 30));
//
//       print("📨 Capture Response Status: ${res.statusCode}");
//
//       final json = jsonDecode(res.body);
//
//       if (res.statusCode == 201) {
//         // نجح الـ Capture
//         print("✅ Capture نجح!");
//         print("   - Capture ID: ${json["id"]}");
//         print("   - Status: ${json["status"]}");
//         print("   - Reconciliation ID: ${json["reconciliationId"]}");
//
//         return {
//           "success": true,
//           "data": json,
//           "captureId": json["id"],
//           "reconciliationId": json["reconciliationId"],
//         };
//       } else {
//         // فشل الـ Capture
//         print("❌ Capture فشل!");
//         print("   - Status Code: ${res.statusCode}");
//         print("   - Error: ${json["message"] ?? json["reason"]}");
//         if (json["errorInformation"] != null) {
//           print("   - Error Info: ${json["errorInformation"]}");
//         }
//
//         return {
//           "success": false,
//           "data": json,
//           "status": res.statusCode,
//           "message": json["message"] ?? json["reason"] ?? "Capture failed"
//         };
//       }
//     } catch (e, stackTrace) {
//       print("💥 خطأ في Capture Request: $e");
//       print("📍 Stack trace: $stackTrace");
//
//       return {
//         "success": false,
//         "error": e.toString(),
//       };
//     }
//   }
// }