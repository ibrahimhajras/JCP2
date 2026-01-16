// // lib/pages/credit_card_payment_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:jcp/widget/RotatingImagePage.dart';
// import 'dart:convert';
// import 'dart:math' as math;
//
// import '../../../../style/colors.dart';
// import '../../../../style/custom_text.dart';
// import 'CyberSourceService.dart';
// import 'StepUpWebViewPage.dart';
// import 'cybersource_3ds_service.dart';
//
// class CreditCardPaymentPage extends StatefulWidget {
//   final int orderId;
//   final int billId;
//   final String amount;
//
//   const CreditCardPaymentPage({
//     super.key,
//     required this.orderId,
//     required this.billId,
//     required this.amount,
//   });
//
//   @override
//   State<CreditCardPaymentPage> createState() => _CreditCardPaymentPageState();
// }
//
// class _CreditCardPaymentPageState extends State<CreditCardPaymentPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _cardNumberController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();
//   final _cardHolderController = TextEditingController();
//
//   final _threeDS = CyberSource3DSService();
//   final _authService = CyberSourceService();
//
//   bool _isLoading = false;
//   String _cardType = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _cardNumberController.addListener(() {
//       setState(() {
//         _cardType = _getCardType(_cardNumberController.text);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _cardNumberController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     _cardHolderController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F7FA),
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: Colors.transparent,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: CustomText(
//             text: 'الدفع',
//             color: const Color(0xFF1E293B),
//             size: 20,
//             weight: FontWeight.bold,
//           ),
//           centerTitle: true,
//         ),
//         body: SingleChildScrollView(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Container(
//                   margin: const EdgeInsets.all(20),
//                   height: 200,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [primary1, primary2, primary3],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: red.withOpacity(0.4),
//                         blurRadius: 20,
//                         offset: const Offset(0, 10),
//                       ),
//                     ],
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 40,
//                               decoration: BoxDecoration(
//                                 color: Colors.amber.shade400,
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             Icon(
//                               _getCardIcon(),
//                               color: Colors.white.withOpacity(0.9),
//                               size: 40,
//                             ),
//                           ],
//                         ),
//                         CustomText(
//                           text: _cardNumberController.text.isEmpty
//                               ? '•••• •••• •••• ••••'
//                               : _cardNumberController.text,
//                           color: Colors.white,
//                           size: 22,
//                           weight: FontWeight.w500,
//                           letters: true,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 CustomText(
//                                   text: 'اسم حامل البطاقة',
//                                   color: Colors.white.withOpacity(0.7),
//                                   size: 10,
//                                   textAlign: TextAlign.start,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 CustomText(
//                                   text: _cardHolderController.text.isEmpty
//                                       ? 'الاسم الكامل'
//                                       : _cardHolderController.text,
//                                   color: Colors.white,
//                                   size: 14,
//                                   weight: FontWeight.w500,
//                                   textAlign: TextAlign.start,
//                                 ),
//                               ],
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 CustomText(
//                                   text: 'تاريخ الانتهاء',
//                                   color: Colors.white.withOpacity(0.7),
//                                   size: 10,
//                                   textAlign: TextAlign.end,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 CustomText(
//                                   text: _expiryController.text.isEmpty
//                                       ? 'MM/YY'
//                                       : _expiryController.text,
//                                   color: Colors.white,
//                                   size: 14,
//                                   weight: FontWeight.w500,
//                                   textAlign: TextAlign.end,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // معلومات المبلغ
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       CustomText(
//                         text: 'المبلغ المطلوب',
//                         size: 16,
//                         color: const Color(0xFF64748B),
//                       ),
//                       CustomText(
//                         text: '${widget.amount} دينار',
//                         size: 20,
//                         weight: FontWeight.bold,
//                         color: red,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // حقول الإدخال
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CustomText(
//                         text: 'معلومات البطاقة',
//                         size: 18,
//                         weight: FontWeight.bold,
//                         color: const Color(0xFF1E293B),
//                         textAlign: TextAlign.start,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildCardNumber(),
//                       const SizedBox(height: 16),
//                       _buildText("اسم حامل البطاقة", _cardHolderController),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(child: _buildExpiry()),
//                           const SizedBox(width: 16),
//                           Expanded(child: _buildCVV()),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // رسالة الأمان
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.lock_outline,
//                         color: Color(0xFF64748B),
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       CustomText(
//                         text: 'جميع المعاملات مشفرة وآمنة',
//                         color: Colors.grey.shade600,
//                         size: 13,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 // زر الدفع
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: SizedBox(
//                     width: double.infinity,
//                     height: 56,
//                     child: ElevatedButton(
//                       onPressed: _onPayPressed,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: red,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: CustomText(
//                         text: "إتمام الدفع",
//                         size: 18,
//                         weight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildCardBrand('Visa', _cardType == 'Visa'),
//                       const SizedBox(width: 12),
//                       _buildCardBrand('MasterCard', _cardType == 'MasterCard'),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCardNumber() {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: TextFormField(
//         textDirection: TextDirection.ltr,
//         textAlign: TextAlign.left,
//         controller: _cardNumberController,
//         decoration: InputDecoration(
//           labelText: "رقم البطاقة",
//           hintText: "1234 5678 9012 3456",
//           filled: true,
//           fillColor: Colors.white,
//           prefixIcon: Icon(Icons.credit_card, color: red),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: red, width: 2),
//           ),
//         ),
//         keyboardType: TextInputType.number,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(19),
//           _CardNumberFormatter(),
//         ],
//         validator: (v) =>
//             _validateCardNumber(v ?? "") ? null : "رقم البطاقة غير صحيح",
//       ),
//     );
//   }
//
//   Widget _buildText(String label, TextEditingController c) {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: TextFormField(
//         textDirection: TextDirection.ltr,
//         controller: c,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: "أدخل $label",
//           filled: true,
//           fillColor: Colors.white,
//           prefixIcon: Icon(Icons.person_outline, color: red),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: red, width: 2),
//           ),
//         ),
//         onChanged: (value) => setState(() {}),
//       ),
//     );
//   }
//
//   Widget _buildExpiry() {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: TextFormField(
//         textDirection: TextDirection.ltr,
//         controller: _expiryController,
//         decoration: InputDecoration(
//           labelText: "تاريخ الانتهاء",
//           hintText: "MM/YY",
//           filled: true,
//           fillColor: Colors.white,
//           prefixIcon: Icon(Icons.calendar_today, color: red, size: 20),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: red, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.red),
//           ),
//         ),
//         textAlign: TextAlign.center,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(4),
//           _ExpiryDateFormatter(),
//         ],
//         onChanged: (value) => setState(() {}),
//         validator: (v) => _validateExpiry(v ?? "") ? null : "تاريخ غير صالح",
//       ),
//     );
//   }
//
//   Widget _buildCVV() {
//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: TextFormField(
//         textDirection: TextDirection.ltr,
//         controller: _cvvController,
//         decoration: InputDecoration(
//           labelText: "CVV",
//           hintText: "123",
//           filled: true,
//           fillColor: Colors.white,
//           prefixIcon: Icon(Icons.lock_outline, color: red, size: 20),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: Colors.grey.shade200),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide(color: red, width: 2),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.red),
//           ),
//         ),
//         textAlign: TextAlign.center,
//         keyboardType: TextInputType.number,
//         obscureText: true,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(4)
//         ],
//         validator: (v) => (v != null && v.length >= 3) ? null : "CVV غير صحيح",
//       ),
//     );
//   }
//
//   Widget _buildCardBrand(String name, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? red : Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isSelected ? red : Colors.grey.shade200,
//           width: 2,
//         ),
//         boxShadow: isSelected
//             ? [
//                 BoxShadow(
//                   color: red.withOpacity(0.4),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ]
//             : [],
//       ),
//       child: CustomText(
//         text: name,
//         size: 12,
//         weight: FontWeight.w600,
//         color: isSelected ? Colors.white : const Color(0xFF64748B),
//       ),
//     );
//   }
//
//   IconData _getCardIcon() {
//     switch (_cardType) {
//       case 'Visa':
//       case 'MasterCard':
//       case 'American Express':
//         return Icons.credit_card;
//       default:
//         return Icons.credit_card_outlined;
//     }
//   }
//
//   String _mapCardType(String pan) {
//     if (pan.startsWith('4')) return '001'; // Visa
//     if (RegExp(r'^5[1-5]').hasMatch(pan) || RegExp(r'^2[2-7]').hasMatch(pan))
//       return '002'; // MasterCard
//     if (RegExp(r'^3[47]').hasMatch(pan)) return '003'; // Amex
//     return '000'; // Unknown
//   }
//
//   String? _pares;
//
//   Future<void> _onPayPressed() async {
//     if (!(_formKey.currentState?.validate() ?? false)) return;
//
//     setState(() => _isLoading = true);
//     _showLoadingDialog();
//     try {
//       print(
//           "🚀 بدء عملية الدفع - Order ID: ${widget.orderId}, Amount: ${widget.amount}");
//
//       final cardNumber = _cardNumberController.text.replaceAll(' ', '');
//       final parts = _expiryController.text.split('/');
//       final expMonth = parts[0];
//       final expYear = '20${parts[1]}';
//       final cvv = _cvvController.text.trim();
//       final amount = (double.tryParse(widget.amount) ?? 0).toStringAsFixed(2);
//       final currency = "JOD";
//       print("🔐 CVV ENTERED: '$cvv'");
//       print("🔐 CVV LENGTH: ${cvv.length}");
//       final nameParts = (_cardHolderController.text.trim().isEmpty)
//           ? ["Customer", "Name"]
//           : _cardHolderController.text.trim().split(RegExp(r"\s+"));
//       final firstName = nameParts.first;
//       final lastName = nameParts.length > 1 ? nameParts.last : "Name";
//
//       print(
//           "💳 معلومات البطاقة: ${cardNumber.substring(0, 4)}**** - ${_getCardType(cardNumber)} - المبلغ: $amount $currency");
//       print("👤 اسم العميل: $firstName $lastName");
//
//       final uniqueEmail =
//           "user_${cardNumber.substring(cardNumber.length - 4)}@jordancarpart.com";
//
//       print("📧 Email: $uniqueEmail");
//
//       print("\n🔧 Step 1: بدء Setup Service...");
//       final setupResp = await _threeDS.setup(
//         orderId: "${widget.orderId}",
//         amount: amount,
//         currency: currency,
//         number: cardNumber,
//         expMonth: expMonth,
//         expYear: expYear,
//         cardType: _mapCardType(cardNumber),
//       );
//       print("✅ Setup مكتمل - Success: ${setupResp["success"]}");
//       if (setupResp["data"]?["consumerAuthenticationInformation"]
//               ?["referenceId"] !=
//           null) {
//         print(
//             "🆔 Reference ID: ${setupResp["data"]["consumerAuthenticationInformation"]["referenceId"]}");
//       }
//
//       print("\n📝 Step 2: بدء Enrollment Check...");
//       final enroll = await _threeDS.enroll(
//         orderId: "${widget.orderId}",
//         amount: amount,
//         currency: currency,
//         number: cardNumber,
//         expMonth: expMonth,
//         expYear: expYear,
//         firstName: firstName,
//         lastName: lastName,
//         email: uniqueEmail,
//         phone: "962000000000",
//         cardType: _mapCardType(cardNumber),
//         referenceId: setupResp["data"]?["consumerAuthenticationInformation"]
//             ?["referenceId"],
//       );
//       print("✅ Enrollment مكتمل:");
//       print("   - Transaction ID: ${enroll.authenticationTransactionId}");
//       print("   - Status: ${enroll.status}");
//       print("   - ACS URL موجود: ${(enroll.acsUrl?.isNotEmpty ?? false)}");
//
//       print("\n🔐 Step 3: بدء Authentication Request...");
//       final auth = await _threeDS.authenticate(
//         authenticationTransactionId: enroll.authenticationTransactionId,
//         number: cardNumber,
//         expMonth: expMonth,
//         expYear: expYear,
//         amount: amount,
//         currency: currency,
//       );
//       print("✅ Authentication مكتمل:");
//       print("   - Status: ${auth.status}");
//       print(
//           "   - ACS URL: ${auth.acsUrl?.isNotEmpty ?? false ? 'موجود' : 'غير موجود'}");
//       print("   - PAReq طول: ${auth.pareq?.length ?? 0}");
//
//       if ((auth.acsUrl ?? "").isNotEmpty) {
//         print("\n🏦 Step 4: بدء StepUp Challenge (Bank Authentication)...");
//         print("🌐 فتح صفحة البنك للتحقق من الهوية...");
//
//         final stepUpResult =
//             await Navigator.of(context).push<Map<String, dynamic>>(
//           MaterialPageRoute(
//             builder: (_) => StepUpWebViewPage(
//               acsUrl: auth.acsUrl!,
//               pareq: auth.pareq!,
//               transactionId: auth.authenticationTransactionId,
//             ),
//           ),
//         );
//
//         print("🔙 عودة من StepUp Challenge...");
//
//         if (stepUpResult == null || stepUpResult["success"] != true) {
//           print("❌ StepUp فشل أو تم إلغاؤه");
//           print("📄 StepUp Result: $stepUpResult");
//           throw Exception("تم إلغاء عملية التحقق من البنك");
//         } else {
//           _pares = stepUpResult["pares"] as String?;
//           print("✅ StepUp مكتمل بنجاح!");
//           print("📜 PaRes طول: ${_pares?.length ?? 0}");
//           if (_pares != null && _pares!.isNotEmpty) {
//             print(
//                 "🔐 PaRes بداية: ${_pares!.substring(0, math.min(50, _pares!.length))}...");
//           }
//         }
//       } else {
//         print("\n⚡ StepUp غير مطلوب - Frictionless Authentication!");
//         print("🎯 البنك وافق مباشرة بدون تحدي");
//       }
//
//       print("\n🔍 Step 5: بدء Validation Service...");
//       final validated = await _threeDS.validateAuth(
//         authenticationTransactionId: auth.authenticationTransactionId,
//         amount: amount,
//         currency: currency,
//         pares: _pares,
//       );
//       print("✅ Validation مكتمل:");
//       print("   - Status: ${validated.status}");
//       print("   - Raw Data موجود: ${validated.raw != null}");
//
//       if (validated.status == "AUTHENTICATION_FAILED" ||
//           validated.status == "FAILED" ||
//           validated.status == "REJECTED") {
//         print("❌ Authentication فشل!");
//         print("   - Validation Status: ${validated.status}");
//         throw Exception(
//             "فشل في مصادقة 3DS. الرجاء التحقق من بيانات البطاقة والمحاولة مرة أخرى");
//       }
//
//       if (validated.status != "AUTHENTICATION_SUCCESSFUL" &&
//           validated.status != "AUTHENTICATED" &&
//           validated.status != "SUCCESS") {
//         print("⚠️ تحذير: حالة المصادقة غير متوقعة: ${validated.status}");
//         print("   - سيتم المتابعة ولكن قد يفشل التفويض");
//       }
//
//       print("\n📊 استخراج بيانات 3DS للـ Authorization...");
//       final raw = validated.raw ?? {};
//       final authInfo = (raw['consumerAuthenticationInformation'] ?? {})
//           as Map<String, dynamic>;
//
//       final cavvOrAav = validated.cavvOrAav ??
//           authInfo['cavv'] ??
//           authInfo['ucafAuthenticationData'] ??
//           authInfo['authenticationValue'] ??
//           '';
//
//       final xid = validated.xid ??
//           authInfo['xid'] ??
//           authInfo['threeDSServerTransactionId'] ??
//           '';
//
//       // Improved ECI extraction with validation
//       String eci = validated.eci ??
//           authInfo['eciRaw'] ??
//           authInfo['eci'] ??
//           authInfo['commerceIndicator'] ??
//           '';
//
//       // Validate and set default ECI based on card type if missing
//       if (eci.isEmpty) {
//         // Default ECI based on card network (full authentication assumed)
//         if (cardNumber.startsWith('4')) {
//           eci = '05'; // Visa default
//         } else if (RegExp(r'^5[1-5]').hasMatch(cardNumber) ||
//             RegExp(r'^2[2-7]').hasMatch(cardNumber)) {
//           eci = '02'; // Mastercard default
//         } else if (RegExp(r'^3[47]').hasMatch(cardNumber)) {
//           eci = '07'; // Amex default
//         } else {
//           eci = '05'; // Generic default
//         }
//         print("⚠️ ECI was empty, using default: $eci");
//       }
//
//       // البيانات الإضافية (مطلوبة لـ Mastercard و 3DS 2.x)
//       final directoryServerTransactionId =
//           validated.directoryServerTransactionId ??
//               authInfo['directoryServerTransactionId'];
//
//       final threeDSServerTransactionId = authInfo['threeDSServerTransactionId'];
//       final acsTransactionId = authInfo['acsTransactionId'];
//       final paresStatus = authInfo['paresStatus'] ?? 'Y';
//       final veresEnrolled = authInfo['veresEnrolled'] ?? 'Y';
//       final specificationVersion = authInfo['specificationVersion'] ??
//           authInfo['paSpecificationVersion'] ??
//           "2.2.0";
//
//       print("📋 بيانات 3DS المستخرجة:");
//       print("   - ECI: '$eci'");
//       print("   - CAVV/AAV طول: ${cavvOrAav.length}");
//       print("   - XID طول: ${xid.length}");
//       print(
//           "   - Directory Server TxnID: ${directoryServerTransactionId != null ? 'موجود' : 'غير موجود'}");
//       print(
//           "   - 3DS Server TxnID: ${threeDSServerTransactionId != null ? 'موجود' : 'غير موجود'}");
//       print("   - PARes Status: '$paresStatus'");
//       print("   - VERes Enrolled: '$veresEnrolled'");
//       print("   - Specification Version: '$specificationVersion'");
//
//       // Validate critical 3DS data before authorization
//       if (cavvOrAav.isEmpty) {
//         print("⚠️ تحذير: CAVV/AAV فارغ - قد يفشل التفويض");
//         print("   - سيتم المحاولة بدون 3DS authentication data");
//       }
//
//       if (eci.isEmpty) {
//         print("⚠️ تحذير: ECI فارغ - قد يفشل التفويض");
//       }
//
//       String? ucafCollectionIndicator;
//       if (RegExp(r'^5[1-5]').hasMatch(cardNumber) ||
//           RegExp(r'^2[2-7]').hasMatch(cardNumber)) {
//         ucafCollectionIndicator =
//             eci.isNotEmpty ? eci.substring(eci.length - 1) : '2';
//         print("🔶 Mastercard detected!");
//         print("   - UCAF Collection Indicator: '$ucafCollectionIndicator'");
//         print(
//             "   - UCAF Authentication Data طول: ${(authInfo['ucafAuthenticationData']?.toString() ?? '').length}");
//       } else if (cardNumber.startsWith('4')) {
//         print("🔷 Visa detected!");
//         print("   - CAVV طول: ${cavvOrAav.length}");
//       }
//
//       print("\n💰 Step 6: بدء Authorization النهائي...");
//       print("🔗 إرسال جميع بيانات 3DS إلى Authorization...");
//
//       final authFinal = await _authService.authorizePayment(
//           cardNumber: cardNumber,
//           expirationMonth: expMonth,
//           expirationYear: expYear,
//           cvv: cvv,
//           firstName: firstName,
//           lastName: lastName,
//           amount: amount,
//           currency: currency,
//           authenticationTransactionId: auth.authenticationTransactionId,
//           eci: eci,
//           cavvOrAav: cavvOrAav,
//           xid: xid,
//           directoryServerTransactionId: directoryServerTransactionId,
//           ucafCollectionIndicator: ucafCollectionIndicator,
//           paSpecificationVersion: specificationVersion,
//           threeDSServerTransactionId: threeDSServerTransactionId,
//           acsTransactionId: acsTransactionId,
//           paresStatus: paresStatus,
//           veresEnrolled: veresEnrolled,
//           uniqueEmail: uniqueEmail);
//
//       print("🎯 Authorization Response:");
//       print("   - Success: ${authFinal["success"]}");
//       if (authFinal["data"] != null) {
//         print("   - Status: ${authFinal["data"]["status"]}");
//         print("   - ID: ${authFinal["data"]["id"]}");
//         if (authFinal["data"]["errorInformation"] != null) {
//           print("   - Error: ${authFinal["data"]["errorInformation"]}");
//         }
//       }
//
//       // ✅ التحقق من الـ status - يجب أن يكون AUTHORIZED وليس DECLINED
//       final authStatus =
//           authFinal["data"]?["status"]?.toString().toUpperCase() ?? "";
//
//       if (authFinal["success"] == true &&
//           (authStatus == "AUTHORIZED" || authStatus == "PENDING")) {
//         final authorizationId = authFinal["data"]["id"];
//         final authReconciliationId = authFinal["reconciliationId"];
//         final authCommerceIndicator = authFinal["commerceIndicator"];
//
//         print("🎉 Authorization نجح! Transaction ID: $authorizationId");
//         print("   - Reconciliation ID: $authReconciliationId");
//         print("   - Commerce Indicator: $authCommerceIndicator");
//         print("   - Status: $authStatus");
//
//         // ✅ التحقق من وجود reconciliationId قبل المتابعة
//         if (authReconciliationId == null || authReconciliationId.isEmpty) {
//           print("⚠️ WARNING: reconciliationId مفقود - قد يفشل Capture");
//           throw Exception(
//               "فشل في الحصول على Reconciliation ID من البنك. يرجى المحاولة مرة أخرى.");
//         }
//
//         print("\n⏳ انتظار 5 ثواني للسماح بمعالجة Authorization...");
//         await Future.delayed(const Duration(seconds: 5));
//
//         print("\n💰 Step 7: بدء Capture لتحصيل الأموال...");
//
//         final authAmount = authFinal["data"]["orderInformation"]
//             ?["amountDetails"]?["totalAmount"];
//         if (authAmount != null && authAmount != amount) {
//           print(
//               "⚠️ WARNING: Capture amount ($amount) differs from auth amount ($authAmount)");
//         }
//
//         final captureResult = await _authService.capturePayment(
//             authorizationId: authorizationId,
//             amount: amount,
//             currency: currency,
//             authReconciliationId: authReconciliationId,
//             firstName: firstName,
//             lastName: lastName,
//             commerceIndicator: authCommerceIndicator,
//             uniqueEmail: uniqueEmail);
//
//         print("🎯 Capture Response:");
//         print("   - Success: ${captureResult["success"]}");
//         if (captureResult["data"] != null) {
//           print("   - Status: ${captureResult["data"]["status"]}");
//           print("   - Capture ID: ${captureResult["data"]["id"]}");
//           if (captureResult["data"]["errorInformation"] != null) {
//             print("   - Error: ${captureResult["data"]["errorInformation"]}");
//           }
//         }
//
//         // Step 8️⃣ — Handle Result
//         if (captureResult["success"] == true) {
//           final captureId = captureResult["data"]["id"];
//           final captureReconciliationId = captureResult["reconciliationId"];
//           print("🎉 تم تحصيل الأموال بنجاح! Capture ID: $captureId");
//
//           // Step 8️⃣ — Notify backend about successful payment
//           print("\n📡 Step 8: إرسال إشعار للـ Backend بنجاح الدفع...");
//           try {
//             final notificationResult = await _notifyBackendPayment(
//               billId: widget.billId,
//               transactionId: authorizationId,
//               captureId: captureId,
//               reconciliationId: captureReconciliationId,
//               amount: amount,
//               currency: currency,
//               cardType: _getCardType(cardNumber),
//             );
//
//             print("📬 Backend Notification Response:");
//             print("   - Success: ${notificationResult["success"]}");
//             if (notificationResult["success"] == true) {
//               print("   - Bill Status Updated ✅");
//               print("   - Order Processing Triggered ✅");
//             } else {
//               print("   - Warning: Backend update failed");
//               print("   - Error: ${notificationResult["error"]}");
//             }
//           } catch (e) {
//             print("⚠️ Backend notification failed: $e");
//             // Continue even if notification fails - payment was successful
//           }
//
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("تم الدفع والتحصيل بنجاح ✅"),
//                 backgroundColor: Colors.green,
//               ),
//             );
//             Navigator.of(context).pop();
//           }
//         } else {
//           final errorMsg = captureResult["data"]?["errorInformation"]
//                   ?["message"] ??
//               "فشل تحصيل الأموال";
//           final errorReason = captureResult["data"]?["errorInformation"]
//                   ?["reason"] ??
//               "CAPTURE_FAILED";
//
//           print("❌ Capture فشل!");
//           print("   - Reason: $errorReason");
//           print("   - Message: $errorMsg");
//           print("🔍 Response كامل: ${captureResult["data"]}");
//
//           throw Exception("فشل تحصيل الأموال: $errorReason - $errorMsg");
//         }
//       } else {
//         // ❌ Authorization فشل أو تم رفضه
//         final errorMsg = authFinal["data"]?["errorInformation"]?["message"] ??
//             "فشل التفويض النهائي";
//         final errorReason = authFinal["data"]?["errorInformation"]?["reason"] ??
//             "UNKNOWN_ERROR";
//
//         print("❌ Authorization فشل!");
//         print("   - Status: $authStatus");
//         print("   - Reason: $errorReason");
//         print("   - Message: $errorMsg");
//         print("🔍 Response كامل: ${authFinal["data"]}");
//
//         // تحليل نوع الخطأ وإعطاء رسالة واضحة
//         String userMessage;
//
//         if (authStatus == "DECLINED") {
//           // البطاقة مرفوضة
//           if (errorReason.contains("DECISION_PROFILE_REJECT")) {
//             print(
//                 "🚫 رفض من Decision Manager - ربما بطاقة اختبار أو سياسة أمان");
//             userMessage =
//                 "عذراً، لا يمكن معالجة هذه البطاقة. يرجى استخدام بطاقة أخرى أو التواصل مع البنك.";
//           } else if (errorReason.contains("INSUFFICIENT_FUNDS")) {
//             userMessage = "رصيد البطاقة غير كافٍ. يرجى استخدام بطاقة أخرى.";
//           } else if (errorReason.contains("EXPIRED_CARD")) {
//             userMessage = "البطاقة منتهية الصلاحية. يرجى استخدام بطاقة أخرى.";
//           } else if (errorReason.contains("INVALID_CARD")) {
//             userMessage =
//                 "البطاقة غير صالحة. يرجى التحقق من المعلومات المدخلة.";
//           } else {
//             userMessage =
//                 "تم رفض عملية الدفع من قبل البنك. يرجى المحاولة ببطاقة أخرى أو التواصل مع البنك.";
//           }
//         } else if (errorReason.contains("CONSUMER_AUTHENTICATION")) {
//           print("🚨 خطأ في 3DS Authentication - تحقق من البيانات المرسلة");
//           userMessage = "فشل التحقق الأمني. يرجى المحاولة مرة أخرى.";
//         } else {
//           userMessage = "حدث خطأ أثناء معالجة الدفع. يرجى المحاولة مرة أخرى.";
//         }
//
//         throw Exception(userMessage);
//       }
//     } catch (e, st) {
//       print("💥 خطأ في عملية الدفع: $e");
//       print("📍 Stack trace: $st");
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("خطأ: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         Navigator.of(context, rootNavigator: true)
//             .pop(); // Close loading dialog
//       }
//       print("🏁 انتهاء عملية الدفع\n");
//     }
//   }
//
//   void _showLoadingDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       barrierColor: Colors.black.withOpacity(0.7),
//       builder: (BuildContext context) {
//         return WillPopScope(
//           onWillPop: () async => false,
//           child: Dialog(
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             child: Container(
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 30,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Bank icon with pulse animation
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [primary1, primary2],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: red.withOpacity(0.3),
//                           blurRadius: 20,
//                           offset: const Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: const Icon(
//                       Icons.account_balance,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Loading spinner
//                   SizedBox(
//                     height: 50,
//                     width: 50,
//                     child: RotatingImagePage(),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Loading text
//                   CustomText(
//                     text: 'جاري معالجة الدفع',
//                     size: 20,
//                     weight: FontWeight.bold,
//                     color: const Color(0xFF1E293B),
//                   ),
//                   const SizedBox(height: 12),
//                   CustomText(
//                     text: 'يرجى الانتظار وعدم إغلاق التطبيق',
//                     size: 14,
//                     color: const Color(0xFF64748B),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//
//                   // Security badge
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.lock_outline,
//                         color: Color(0xFF10B981),
//                         size: 16,
//                       ),
//                       const SizedBox(width: 6),
//                       CustomText(
//                         text: 'اتصال آمن ومشفر',
//                         size: 12,
//                         color: const Color(0xFF10B981),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   bool _validateCardNumber(String input) {
//     final clean = input.replaceAll(' ', '');
//     if (clean.length < 13 || clean.length > 19) return false;
//     int sum = 0;
//     bool alt = false;
//     for (int i = clean.length - 1; i >= 0; i--) {
//       int n = int.parse(clean[i]);
//       if (alt) {
//         n *= 2;
//         if (n > 9) n -= 9;
//       }
//       sum += n;
//       alt = !alt;
//     }
//     return sum % 10 == 0;
//   }
//
//   String _getCardType(String input) {
//     final clean = input.replaceAll(' ', '');
//     if (clean.startsWith('4')) return 'Visa';
//     if (RegExp(r'^5[1-5]').hasMatch(clean) ||
//         RegExp(r'^2[2-7]').hasMatch(clean)) return 'MasterCard';
//     if (RegExp(r'^3[47]').hasMatch(clean)) return 'American Express';
//     return 'Unknown';
//   }
//
//   bool _validateExpiry(String expiry) {
//     if (expiry.length != 5 || !expiry.contains('/')) return false;
//     final p = expiry.split('/');
//     final m = int.tryParse(p[0]);
//     final y = int.tryParse('20${p[1]}');
//     if (m == null || y == null) return false;
//     if (m < 1 || m > 12) return false;
//     final now = DateTime.now();
//     final d = DateTime(y, m + 1, 0);
//     return d.isAfter(now);
//   }
//
//   Future<Map<String, dynamic>> _notifyBackendPayment({
//     required int billId,
//     required String transactionId,
//     required String captureId,
//     required String reconciliationId,
//     required String amount,
//     required String currency,
//     required String cardType,
//   }) async {
//     const url = "https://jordancarpart.com/Api/Bills/payment_success.php";
//     const credentials = "YWRtaW46YWRtaW4xMjM="; // base64 of admin:admin123
//
//     final body = {
//       "bill_id": billId.toString(),
//       "transaction_id": transactionId,
//       "capture_id": captureId,
//       "reconciliation_id": reconciliationId,
//       "amount": amount,
//       "currency": currency,
//       "card_type": cardType,
//       "payment_method": "cybersource_3ds",
//       "status": "completed",
//     };
//
//     try {
//       print("📤 Sending payment notification to backend...");
//       print("   - Bill ID: $billId");
//       print("   - Transaction ID: $transactionId");
//       print("   - Amount: $amount");
//
//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Basic $credentials',
//             },
//             body: jsonEncode(body),
//           )
//           .timeout(const Duration(seconds: 30));
//
//       print("📨 Backend Response Status: ${response.statusCode}");
//       print("📨 Backend Response Body: ${response.body}");
//       print("📨 Backend Response Headers: ${response.headers}");
//
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         return {
//           "success": jsonResponse["success"] ?? false,
//           "message": jsonResponse["message"] ?? "",
//         };
//       } else {
//         return {
//           "success": false,
//           "error": "HTTP ${response.statusCode}: ${response.body}",
//         };
//       }
//     } catch (e) {
//       print("❌ Backend notification error: $e");
//       return {
//         "success": false,
//         "error": e.toString(),
//       };
//     }
//   }
// }
//
// class _CardNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final t = newValue.text.replaceAll(' ', '');
//     final b = StringBuffer();
//     for (int i = 0; i < t.length; i++) {
//       if (i > 0 && i % 4 == 0) b.write(' ');
//       b.write(t[i]);
//     }
//     final f = b.toString();
//     return TextEditingValue(
//         text: f, selection: TextSelection.collapsed(offset: f.length));
//   }
// }
//
// class _ExpiryDateFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final t = newValue.text.replaceAll('/', '');
//     final b = StringBuffer();
//     for (int i = 0; i < t.length && i < 4; i++) {
//       if (i == 2) b.write('/');
//       b.write(t[i]);
//     }
//     final f = b.toString();
//     return TextEditingValue(
//         text: f, selection: TextSelection.collapsed(offset: f.length));
//   }
// }
