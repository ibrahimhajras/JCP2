class OrderModel {
  final int id;
  final String time;
  final int type;
  final int state;
  final String? carBrand;
  final String? carModel;
  final String? carYear;
  final String? carFuelType;
  final String? carEngineSize;
  final String? carChassisNumber;
  final String? billStatus;

  OrderModel({
    required this.id,
    required this.time,
    required this.type,
    required this.state,
    this.carBrand,
    this.carModel,
    this.carYear,
    this.carFuelType,
    this.carEngineSize,
    this.carChassisNumber,
    this.billStatus,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: int.parse(json['id'].toString()),
      time: json['time']?.toString() ?? '',
      type: int.parse(json['type'].toString()),
      state: int.parse(json['state'].toString()),
      carBrand: json['car_brand']?.toString(),
      carModel: json['car_model']?.toString(),
      carYear: json['car_year']?.toString(),
      carFuelType: json['car_fuel_type']?.toString(),
      carEngineSize: json['car_engine_size']?.toString(),
      carChassisNumber: json['car_chassis_number']?.toString(),
      billStatus: json['bill_status']?.toString(),
    );
  }

  String get carInfo {
    if (carBrand != null && carModel != null && carYear != null) {
      return '$carBrand $carModel ($carYear)';
    }
    return 'معلومات السيارة غير متوفرة';
  }

  String get fullCarInfo {
    if (carBrand == null) return 'معلومات السيارة غير متوفرة';

    List<String> info = [];
    if (carBrand != null && carBrand != 'N/A') info.add('$carBrand');
    if (carModel != null && carModel != 'N/A') info.add('$carModel');
    if (carYear != null && carYear != 'N/A') info.add('($carYear)');

    return info.join(' ');
  }

  String get engineInfo {
    List<String> info = [];
    if (carFuelType != null && carFuelType != 'N/A') info.add(carFuelType!);
    if (carEngineSize != null && carEngineSize != 'N/A') info.add(carEngineSize!);

    return info.isEmpty ? '' : info.join(' - ');
  }

  bool get hasCarInfo => carBrand != null && carBrand != 'N/A';


  bool get hasBill => billStatus != null;


  bool get isPaid => billStatus == 'Paid';

  bool get isUnpaid => billStatus == 'BillNew';
}