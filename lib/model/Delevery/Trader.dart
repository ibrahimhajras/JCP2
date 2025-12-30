class Trader {
  final int traderId;
  final String traderName;
  final String traderPhone;
  final String traderCity;
  final int doneorder;

  Trader({
    required this.traderId,
    required this.traderName,
    required this.traderPhone,
    required this.traderCity,
    required this.doneorder,
  });

  factory Trader.fromMap(Map<String, dynamic> json) => Trader(
    traderId: json["trader_id"] ?? 0,
    traderName: json["trader_name"] ?? "",
    traderPhone: json["trader_phone"] ?? "",
    traderCity: json["trader_city"] ?? "",
    doneorder: json["doneorder"] ?? 0,
  );
  // ✅ تحويل البيانات إلى JSON عند الإرسال إلى الخادم
  Map<String, dynamic> toJson() {
    return {
      'trader_id': traderId,
      'trader_name': traderName,
      'trader_phone': traderPhone,
      'trader_city': traderCity,
      'doneorder': doneorder,
    };
  }

  @override
  String toString() {
    return '''
    Trader {
      traderId: $traderId,
      traderName: $traderName,
      traderPhone: $traderPhone,
      traderCity: $traderCity,
      doneorder: $doneorder
    }
    ''';
  }
}
