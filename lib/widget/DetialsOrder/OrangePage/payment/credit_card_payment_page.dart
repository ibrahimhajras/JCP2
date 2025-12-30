// lib/pages/credit_card_payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jcp/widget/RotatingImagePage.dart';
import 'dart:convert';

import '../../../../style/colors.dart';
import '../../../../style/custom_text.dart';

class CreditCardPaymentPage extends StatefulWidget {
  final int orderId;
  final int billId;
  final String amount;

  const CreditCardPaymentPage({
    super.key,
    required this.orderId,
    required this.billId,
    required this.amount,
  });

  @override
  State<CreditCardPaymentPage> createState() => _CreditCardPaymentPageState();
}

class _CreditCardPaymentPageState extends State<CreditCardPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  bool _isLoading = false;
  String _cardType = '';

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      setState(() {
        _cardType = _getCardType(_cardNumberController.text);
      });
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
            onPressed: () => Navigator.pop(context),
          ),
          title: CustomText(
            text: 'الدفع',
            color: const Color(0xFF1E293B),
            size: 20,
            weight: FontWeight.bold,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // قسم البطاقة المرئية
                Container(
                  margin: const EdgeInsets.all(20),
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary1, primary2, primary3],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: red.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade400,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            Icon(
                              _getCardIcon(),
                              color: Colors.white.withOpacity(0.9),
                              size: 40,
                            ),
                          ],
                        ),
                        CustomText(
                          text: _cardNumberController.text.isEmpty
                              ? '•••• •••• •••• ••••'
                              : _cardNumberController.text,
                          color: Colors.white,
                          size: 22,
                          weight: FontWeight.w500,
                          letters: true,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: 'اسم حامل البطاقة',
                                  color: Colors.white.withOpacity(0.7),
                                  size: 10,
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  text: _cardHolderController.text.isEmpty
                                      ? 'الاسم الكامل'
                                      : _cardHolderController.text,
                                  color: Colors.white,
                                  size: 14,
                                  weight: FontWeight.w500,
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  text: 'تاريخ الانتهاء',
                                  color: Colors.white.withOpacity(0.7),
                                  size: 10,
                                  textAlign: TextAlign.end,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  text: _expiryController.text.isEmpty
                                      ? 'MM/YY'
                                      : _expiryController.text,
                                  color: Colors.white,
                                  size: 14,
                                  weight: FontWeight.w500,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // معلومات المبلغ
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomText(
                        text: 'المبلغ المطلوب',
                        size: 16,
                        color: const Color(0xFF64748B),
                      ),
                      CustomText(
                        text: '${widget.amount} دينار',
                        size: 20,
                        weight: FontWeight.bold,
                        color: red,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // حقول الإدخال
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: 'معلومات البطاقة',
                        size: 18,
                        weight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 16),
                      _buildCardNumber(),
                      const SizedBox(height: 16),
                      _buildText("اسم حامل البطاقة", _cardHolderController),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildExpiry()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCVV()),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // رسالة الأمان
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        text: 'جميع المعاملات مشفرة وآمنة',
                        color: Colors.grey.shade600,
                        size: 13,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // زر الدفع
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _onPayPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        disabledBackgroundColor: red.withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? SizedBox(
                          height: 24, width: 24, child: RotatingImagePage())
                          : CustomText(
                        text: "إتمام الدفع",
                        size: 18,
                        weight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // شعارات البطاقات
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCardBrand('Visa'),
                      const SizedBox(width: 12),
                      _buildCardBrand('MasterCard'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardNumber() {
    return TextFormField(
      controller: _cardNumberController,
      decoration: InputDecoration(
        labelText: "رقم البطاقة",
        hintText: "1234 5678 9012 3456",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.credit_card, color: red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(19),
        _CardNumberFormatter(),
      ],
      validator: (v) =>
      _validateCardNumber(v ?? "") ? null : "رقم البطاقة غير صحيح",
    );
  }

  Widget _buildText(String label, TextEditingController c) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        hintText: "أدخل $label",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.person_outline, color: red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: red, width: 2),
        ),
      ),
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildExpiry() {
    return TextFormField(
      controller: _expiryController,
      decoration: InputDecoration(
        labelText: "تاريخ الانتهاء",
        hintText: "MM/YY",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.calendar_today, color: red, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
        _ExpiryDateFormatter(),
      ],
      onChanged: (value) => setState(() {}),
      validator: (v) => _validateExpiry(v ?? "") ? null : "تاريخ غير صالح",
    );
  }

  Widget _buildCVV() {
    return TextFormField(
      controller: _cvvController,
      decoration: InputDecoration(
        labelText: "CVV",
        hintText: "123",
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.lock_outline, color: red, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4)
      ],
      validator: (v) => (v != null && v.length >= 3) ? null : "CVV غير صحيح",
    );
  }

  Widget _buildCardBrand(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: CustomText(
        text: name,
        size: 12,
        weight: FontWeight.w600,
        color: const Color(0xFF64748B),
      ),
    );
  }

  IconData _getCardIcon() {
    switch (_cardType) {
      case 'Visa':
      case 'MasterCard':
      case 'American Express':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  String _mapCardType(String pan) {
    if (pan.startsWith('4')) return '001'; // Visa
    if (RegExp(r'5[1-5]').hasMatch(pan) || RegExp(r'2[2-7]').hasMatch(pan))
      return '002'; // MasterCard
    if (RegExp(r'3[47]').hasMatch(pan)) return '003'; // Amex
    return '000'; // Unknown
  }

  String? _pares;

  Future<void> _onPayPressed() async {

  }

  bool _validateCardNumber(String input) {
    final clean = input.replaceAll(' ', '');
    if (clean.length < 13 || clean.length > 19) return false;
    int sum = 0;
    bool alt = false;
    for (int i = clean.length - 1; i >= 0; i--) {
      int n = int.parse(clean[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  String _getCardType(String input) {
    final clean = input.replaceAll(' ', '');
    if (clean.startsWith('4')) return 'Visa';
    if (RegExp(r'5[1-5]').hasMatch(clean) || RegExp(r'2[2-7]').hasMatch(clean))
      return 'MasterCard';
    if (RegExp(r'3[47]').hasMatch(clean)) return 'American Express';
    return 'Unknown';
  }

  bool _validateExpiry(String expiry) {
    if (expiry.length != 5 || !expiry.contains('/')) return false;
    final p = expiry.split('/');
    final m = int.tryParse(p[0]);
    final y = int.tryParse('20${p[1]}');
    if (m == null || y == null) return false;
    if (m < 1 || m > 12) return false;
    final now = DateTime.now();
    final d = DateTime(y, m + 1, 0);
    return d.isAfter(now);
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text.replaceAll(' ', '');
    final b = StringBuffer();
    for (int i = 0; i < t.length; i++) {
      if (i > 0 && i % 4 == 0) b.write(' ');
      b.write(t[i]);
    }
    final f = b.toString();
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final t = newValue.text.replaceAll('/', '');
    final b = StringBuffer();
    for (int i = 0; i < t.length && i < 4; i++) {
      if (i == 2) b.write('/');
      b.write(t[i]);
    }
    final f = b.toString();
    return TextEditingValue(
        text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}
