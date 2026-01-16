class CategoryModel {
  final String id;
  final String carName;
  final String categoryName;
  final bool isChassisRequired;

  CategoryModel({
    required this.id,
    required this.carName,
    required this.categoryName,
    required this.isChassisRequired,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      carName: json['car_name']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      isChassisRequired: json['is_chassis_required']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_name': carName,
      'category_name': categoryName,
      'is_chassis_required': isChassisRequired ? '1' : '0',
    };
  }
}
