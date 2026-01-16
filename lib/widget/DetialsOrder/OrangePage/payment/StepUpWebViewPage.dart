// /*import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../../RotatingImagePage.dart';
//
// class StepUpWebViewPage extends StatefulWidget {
//   final String acsUrl;
//   final String pareq;
//   final String transactionId;
//
//   const StepUpWebViewPage({
//     Key? key,
//     required this.acsUrl,
//     required this.pareq,
//     required this.transactionId,
//   }) : super(key: key);
//
//   @override
//   State<StepUpWebViewPage> createState() => _StepUpWebViewPageState();
// }
//
// class _StepUpWebViewPageState extends State<StepUpWebViewPage> {
//   late final WebViewController _controller;
//   bool _isLoading = true;
//   bool _isCompleted = false;
//   Timer? _pollingTimer;
//   int _pollingAttempts = 0;
//   bool _isPolling = false;
//   bool _challengeStarted = false;
//   int _pageLoadCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     print("🏦 تهيئة StepUp WebView...");
//     print("   - ACS URL: ${widget.acsUrl}");
//     print("   - Transaction ID: ${widget.transactionId}");
//     print("   - PAReq طول: ${widget.pareq.length}");
//
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) {
//             print("📄 بدء تحميل الصفحة: $url");
//             setState(() => _isLoading = true);
//
//             if (url.contains('wibmo.com') ||
//                 url.contains('cardinalcommerce.com') ||
//                 url.contains('ACS') ||
//                 url.contains('challenge')) {
//               _challengeStarted = true;
//               print("🏛️ بدء صفحة التحدي البنكي");
//             }
//           },
//           onPageFinished: (url) async {
//             _pageLoadCount++;
//             print("✅ انتهاء تحميل الصفحة ${_pageLoadCount}: $url");
//             setState(() => _isLoading = false);
//
//             // انتظار قبل استخراج البيانات
//             await Future.delayed(const Duration(milliseconds: 1500));
//
//             // استخراج فقط بعد بدء التحدي وفي صفحات محددة
//             if (_challengeStarted && _shouldExtractData(url)) {
//               print("🔍 محاولة استخراج البيانات من الصفحة...");
//               await _extractAuthResponse();
//             }
//           },
//           onNavigationRequest: (request) {
//             print("🔗 طلب التنقل إلى: ${request.url}");
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..addJavaScriptChannel(
//         'FlutterCallback',
//         onMessageReceived: (message) {
//           print("📨 رسالة من JavaScript: ${message.message}");
//           _handleMessage(message.message);
//         },
//       );
//
//     _loadChallenge();
//   }
//
//   bool _shouldExtractData(String url) {
//     // استخراج البيانات فقط من صفحات محددة
//     return url.contains('TermURL') ||
//         url.contains('callback') ||
//         url.contains('return') ||
//         url.contains('response') ||
//         (_pageLoadCount >= 2 && _challengeStarted);
//   }
//
//   void _handleMessage(String message) {
//     if (_isCompleted) return;
//
//     try {
//       final data = jsonDecode(message);
//       print("🔍 تحليل رسالة JavaScript: $data");
//
//       // التحقق من Error 4100
//       if (data['ErrorNumber'] == 4100 ||
//           (data['error'] != null && data['error'].toString().contains('4100'))) {
//         print("⚠️ Error 4100 مُكتشف - بدء نظام Polling");
//         if (!_isPolling) {
//           _startPolling();
//         }
//         return;
//       }
//
//       // التحقق من نجاح العملية
//       if (data['success'] == true) {
//         String? auth = data['cres'] ??
//             data['CRes'] ??
//             data['authenticationResponse'] ??
//             data['pares'];
//
//         if (auth != null && auth.length > 100) {
//           print("✅ تم استلام Authentication Response من JavaScript");
//           _completeAuth(auth);
//           return;
//         }
//       }
//
//       // التحقق من خطأ
//       if (data['error'] != null && !data['error'].toString().contains('4100')) {
//         print("❌ خطأ من JavaScript: ${data['error']}");
//         _showError(data['error'].toString());
//       }
//     } catch (e) {
//       print("⚠️ فشل في تحليل رسالة JavaScript: $e");
//     }
//   }
//
//   void _completeAuth(String authResponse) {
//     if (_isCompleted) return;
//
//     _pollingTimer?.cancel();
//     _isCompleted = true;
//
//     print("🎉 اكتمل التحقق بنجاح!");
//     print("📜 طول Response: ${authResponse.length}");
//
//     if (mounted) {
//       Navigator.of(context).pop({
//         'success': true,
//         'cres': authResponse,
//         'authenticationResponse': authResponse,
//         'pares': authResponse,
//         'md': widget.transactionId,
//       });
//     }
//   }
//
//   void _startPolling() {
//     if (_isPolling) return;
//
//     _isPolling = true;
//     _pollingAttempts = 0;
//     print("🔄 بدء نظام Polling...");
//
//     _pollingTimer = Timer.periodic(
//       const Duration(seconds: 2), // كل ثانيتين
//           (timer) async {
//         _pollingAttempts++;
//         print("🔍 محاولة Polling ${_pollingAttempts}/60...");
//
//         if (_pollingAttempts > 60) { // 2 دقيقة
//           timer.cancel();
//           if (!_isCompleted) {
//             print("⏰ انتهت مدة Polling");
//             _showError("انتهى وقت التحقق من البنك");
//           }
//           return;
//         }
//
//         try {
//           final url = 'https://jordancarpart.com/Api/Bills/get_pares.php?tid=${widget.transactionId}';
//           print("📡 Polling Request إلى: $url");
//
//           final res = await http.get(Uri.parse(url))
//               .timeout(const Duration(seconds: 8));
//
//           print("📨 Polling Response Status: ${res.statusCode}");
//
//           if (res.statusCode == 200) {
//             final data = jsonDecode(res.body);
//             print("📊 Polling Response Data: $data");
//
//             if (data['success'] == true) {
//               String? auth = data['cres'] ??
//                   data['pares'] ??
//                   data['authenticationResponse'];
//
//               if (auth != null && auth.length > 100) {
//                 print("✅ Polling نجح! استلام Response");
//                 timer.cancel();
//                 _completeAuth(auth);
//                 return;
//               } else {
//                 print("⚠️ Response فارغ أو قصير: ${auth?.length ?? 0}");
//               }
//             } else {
//               print("⏳ Polling لم يجد النتيجة بعد: ${data['message']}");
//             }
//           } else {
//             print("⚠️ Polling HTTP Error: ${res.statusCode}");
//           }
//         } catch (e) {
//           print("❌ خطأ في Polling: $e");
//         }
//       },
//     );
//   }
//
//   void _loadChallenge() {
//     print("🔧 تحميل Challenge Form...");
//
//     final html = '''
// <!DOCTYPE html>
// <html>
// <head>
//     <meta charset="UTF-8">
//     <meta name="viewport" content="width=device-width, initial-scale=1.0">
//     <title>3D Secure Authentication</title>
//     <style>
//         body {
//             font-family: Arial, sans-serif;
//             background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
//             margin: 0;
//             padding: 20px;
//             display: flex;
//             justify-content: center;
//             align-items: center;
//             min-height: 100vh;
//         }
//         .loading {
//             text-align: center;
//             color: white;
//             background: rgba(0,0,0,0.2);
//             padding: 30px;
//             border-radius: 15px;
//         }
//         .spinner {
//             border: 4px solid #f3f3f3;
//             border-top: 4px solid #667eea;
//             border-radius: 50%;
//             width: 50px;
//             height: 50px;
//             animation: spin 1s linear infinite;
//             margin: 20px auto;
//         }
//         @keyframes spin {
//             0% { transform: rotate(0deg); }
//             100% { transform: rotate(360deg); }
//         }
//     </style>
// </head>
// <body>
//     <div class="loading">
//         <div class="spinner"></div>
//         <h3>🔐 جاري الاتصال بالبنك...</h3>
//         <p>يرجى الانتظار بينما نقوم بتوجيهك إلى صفحة البنك الآمنة</p>
//         <p><small>Transaction ID: ${widget.transactionId}</small></p>
//     </div>
//
//     <form id="challengeForm" method="POST" action="${widget.acsUrl}" style="display:none;">
//         <input type="hidden" name="creq" value="${widget.pareq}" />
//         <input type="hidden" name="threeDSSessionData" value="${widget.transactionId}" />
//         <input type="hidden" name="MD" value="${widget.transactionId}" />
//     </form>
//
//     <script>
//         console.log('🚀 Starting 3DS Challenge');
//         console.log('ACS URL:', '${widget.acsUrl}');
//         console.log('Transaction ID:', '${widget.transactionId}');
//
//         setTimeout(function() {
//             console.log('📤 Submitting challenge form');
//             document.getElementById('challengeForm').submit();
//         }, 1000);
//     </script>
// </body>
// </html>
// ''';
//
//     _controller.loadHtmlString(html);
//   }
//
//   Future<void> _extractAuthResponse() async {
//     if (_isCompleted) return;
//
//     try {
//       print("🔍 بدء استخراج Authentication Response...");
//
//       final result = await _controller.runJavaScriptReturningResult(r'''
//       (function(){
//         try {
//           var bodyText = document.body.innerText || '';
//           var htmlText = document.documentElement.innerHTML || '';
//
//           console.log("📄 Extracting from page");
//           console.log("Body length:", bodyText.length);
//           console.log("HTML length:", htmlText.length);
//
//           // التحقق من ErrorNumber 4100
//           var errorInputs = document.querySelectorAll('input[name*="error"], input[name*="Error"]');
//           for (var i = 0; i < errorInputs.length; i++) {
//             var errorMsg = errorInputs[i].value || '';
//             console.log("Error input:", errorMsg);
//
//             if (errorMsg.includes('4100')) {
//               console.log("⏳ ErrorNumber 4100 - Need to poll");
//               return JSON.stringify({
//                 success: false,
//                 error: "4100",
//                 needsPolling: true
//               });
//             }
//           }
//
//           // البحث عن Error في النص
//           if (bodyText.includes('4100') || htmlText.includes('4100')) {
//             console.log("⏳ ErrorNumber 4100 found in text");
//             return JSON.stringify({
//               success: false,
//               error: "4100",
//               needsPolling: true
//             });
//           }
//
//           // البحث عن CRes/PaRes في جميع الـ inputs
//           var inputs = document.querySelectorAll('input');
//           console.log("🔍 Inputs found:", inputs.length);
//
//           for (var i = 0; i < inputs.length; i++) {
//             var inp = inputs[i];
//             var name = (inp.name || inp.id || '').toLowerCase();
//             var val = inp.value || '';
//
//             if (val.length > 50) {
//               console.log("Input [" + name + "]:", val.substring(0, 50) + "...");
//             }
//
//             // تجاهل CReq وError messages
//             if (name.includes('creq') || name.includes('error')) {
//               continue;
//             }
//
//             // البحث عن CRes/PaRes/AuthenticationResponse
//             if ((name.includes('cres') ||
//                  name.includes('pares') ||
//                  name.includes('response') ||
//                  name.includes('authenticationresponse')) &&
//                 val.length > 100) {
//               console.log("✅ Found authentication response");
//               return JSON.stringify({
//                 success: true,
//                 authenticationResponse: val,
//                 source: 'input_' + name
//               });
//             }
//           }
//
//           // البحث في أي input طويل
//           for (var j = 0; j < inputs.length; j++) {
//             var input = inputs[j];
//             var value = input.value || '';
//             var inputName = (input.name || input.id || '').toLowerCase();
//
//             if (inputName.includes('creq') || inputName.includes('error')) {
//               continue;
//             }
//
//             if (value.length > 200) {
//               console.log("✅ Found long value in:", inputName);
//               return JSON.stringify({
//                 success: true,
//                 authenticationResponse: value,
//                 source: 'long_input'
//               });
//             }
//           }
//
//           // البحث في النص المرئي
//           if (bodyText.length > 500 && (bodyText.includes('success') || bodyText.includes('complete'))) {
//             console.log("📋 Page seems completed, but no response found");
//           }
//
//           return JSON.stringify({
//             success: false,
//             error: "Response not found yet",
//             bodyLength: bodyText.length,
//             htmlLength: htmlText.length
//           });
//
//         } catch(e) {
//           console.log("❌ JavaScript error:", e);
//           return JSON.stringify({
//             success: false,
//             error: "JavaScript error: " + e.toString()
//           });
//         }
//       })();
//     ''');
//
//       print("📊 JavaScript Result: $result");
//
//       String cleaned = result.toString();
//       if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
//         cleaned = cleaned.substring(1, cleaned.length - 1);
//       }
//       cleaned = cleaned.replaceAll(r'\"', '"');
//
//       final data = jsonDecode(cleaned);
//
//       if (data['success'] == true && data['authenticationResponse'] != null) {
//         print("✅ استخراج ناجح من الصفحة");
//         _completeAuth(data['authenticationResponse']);
//       } else if (data['error'] == '4100' || data['needsPolling'] == true) {
//         print("⚠️ Error 4100 - بدء Polling");
//         if (!_isPolling) {
//           _startPolling();
//         }
//       } else {
//         print("⏳ لم يتم العثور على Response بعد: ${data['error']}");
//
//         // محاولة Polling إذا كانت الصفحة تبدو مكتملة
//         if (!_isPolling && _challengeStarted && _pageLoadCount >= 2) {
//           print("🔄 بدء Polling احتياطي");
//           _startPolling();
//         }
//       }
//     } catch (e, stack) {
//       print("❌ خطأ في استخراج Response: $e");
//       print("📍 Stack: $stack");
//
//       // بدء Polling في حالة الخطأ
//       if (!_isPolling && _challengeStarted) {
//         print("🔄 بدء Polling بسبب الخطأ");
//         _startPolling();
//       }
//     }
//   }
//
//   void _showError(String message) {
//     if (!mounted || _isCompleted) return;
//
//     print("❌ عرض خطأ للمستخدم: $message");
//
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         title: const Text('خطأ في التحقق'),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.of(context).pop({
//                 'success': false,
//                 'error': message,
//               });
//             },
//             child: const Text('حسناً'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (!didPop && !_isCompleted) {
//           print("🔙 المستخدم يحاول العودة");
//           Navigator.of(context).pop({
//             'success': false,
//             'error': 'تم الإلغاء',
//           });
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text("التحقق من البنك"),
//           backgroundColor: const Color(0xFF667eea),
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (ctx) => AlertDialog(
//                   title: const Text('إلغاء؟'),
//                   content: const Text('هل تريد إلغاء عملية التحقق من البنك؟'),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(ctx),
//                       child: const Text('لا'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(ctx);
//                         Navigator.of(context).pop({
//                           'success': false,
//                           'error': 'تم الإلغاء',
//                         });
//                       },
//                       child: const Text('نعم'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         body: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
//             if (_isLoading)
//               Container(
//                 color: Colors.white.withOpacity(0.9),
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       RotatingImagePage(),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'جاري التحميل...',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       if (_isPolling)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 10),
//                           child: Text(
//                             'جاري التحقق من النتيجة... ($_pollingAttempts/60)',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     print("🧹 تنظيف StepUp WebView");
//     _pollingTimer?.cancel();
//     _isCompleted = true;
//     super.dispose();
//   }
// }*