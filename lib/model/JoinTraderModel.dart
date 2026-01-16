class JoinTraderModel {
  final String fName;
  final String lName;
  final String store;
  final String phone;
  final String full_address;
  final List<String> master;
  final List<String> parts_type;
  final List<String> activity_type;
  final String discountPercentage;
  final String deliveryLimit;
  final String location;
  final String normalPaymentInside;
  final String urgentPaymentInside;
  final String normalPaymentOutside;
  final String urgentPaymentOutside;

  // ✅ إضافة الحقول الجديدة
  final bool isOriginalCountry;
  final bool isCompany;
  final bool isCommercial;
  final bool isUsed;
  final bool isCommercial2;
  // ✅ الحقول المنفصلة الجديدة
  final bool isImageRequired;
  final bool isBrandRequired;
  final bool isEngineSizeRequired;
  final bool isYearRangeRequired;

  JoinTraderModel({
    required this.fName,
    required this.lName,
    required this.store,
    required this.phone,
    required this.full_address,
    required this.master,
    required this.parts_type,
    required this.activity_type,
    required this.discountPercentage,
    required this.deliveryLimit,
    required this.location,
    required this.normalPaymentInside,
    required this.urgentPaymentInside,
    required this.normalPaymentOutside,
    required this.urgentPaymentOutside,
    // ✅ إضافة الـ parameters الجديدة
    required this.isOriginalCountry,
    required this.isCompany,
    required this.isCommercial,
    required this.isUsed,
    required this.isCommercial2,
    // ✅ الحقول المنفصلة الجديدة
    required this.isImageRequired,
    required this.isBrandRequired,
    required this.isEngineSizeRequired,
    required this.isYearRangeRequired,
  });

  void printDetails() {
    print('--- Trader Details ---');
    print('Name: $fName $lName');
    print('Store: $store');
    print('Phone: $phone');
    print('Address: $full_address');
    print('Master: $master');
    print('Parts Type: $parts_type');
    print('Activity Type: $activity_type');
    print('Discount: $discountPercentage');
    print('Delivery Limit: $deliveryLimit');
    print('Location: $location');
    print('--- Permissions ---');
    print('Original Country: $isOriginalCountry');
    print('Company: $isCompany');
    print('Commercial: $isCommercial');
    print('Used: $isUsed');
    print('Commercial2: $isCommercial2');
    print('Image Required: $isImageRequired');
    print('Brand Required: $isBrandRequired');
    print('Engine Size Required: $isEngineSizeRequired');
    print('Year Range Required: $isYearRangeRequired');
    print('----------------------');
  }
}