class Item {
  final int id;
  final int productId;
  final String name;
  final double price;
  final int amount;
  final int warranty;
  final String mark;
  final String note;
  final String img;
  final String createdAt;
  final int userId;
  final int active;
  final ProductInfo productInfo;

  Item({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.amount,
    required this.warranty,
    required this.mark,
    required this.note,
    required this.img,
    required this.createdAt,
    required this.userId,
    required this.active,
    required this.productInfo,
  });

  /// 📝 تحويل من JSON إلى كائن Item
  factory Item.fromMap(Map<String, dynamic> json) => Item(
    id: json["id"] ?? 0,
    productId: json["product_id"] ?? 0,
    name: json["name"] ?? "",
    price: double.tryParse(json["price"].toString()) ?? 0.0,
    amount: int.tryParse(json["amount"].toString()) ?? 0,
    warranty: int.tryParse(json["warranty"].toString()) ?? 0,
    mark: json["mark"]?.toString() ?? "",
    note: json["note"] ?? "",
    img: json["img"] ?? "",
    createdAt: json["created_at"] ?? "",
    userId: int.tryParse(json["user_id"].toString()) ?? 0,
    active: int.tryParse(json["active"].toString()) ?? 0,
    productInfo: ProductInfo.fromMap(json["product_info"] ?? {}),
  );

  /// 🔄 تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_id": productId,
      "name": name,
      "price": price,
      "amount": amount,
      "warranty": warranty,
      "mark": mark,
      "note": note,
      "img": img,
      "created_at": createdAt,
      "user_id": userId,
      "active": active,
      "product_info": productInfo.toJson(),
    };
  }

  @override
  String toString() {
    return '''
    Item {
      id: $id,
      productId: $productId,
      name: $name,
      price: $price,
      amount: $amount,
      warranty: $warranty,
      mark: $mark,
      note: $note,
      img: $img,
      createdAt: $createdAt,
      userId: $userId,
      active: $active,
      productInfo: ${productInfo.toString()}
    }
    ''';
  }
}
class ProductInfo {
  final int id;
  final String name;
  final String nameCar;
  final String category;
  final String fromYear;
  final String toYear;
  final String fuelType;
  final String engineSize;
  final String createdAt;
  final String userId;
  final String time;

  ProductInfo({
    required this.id,
    required this.name,
    required this.nameCar,
    required this.category,
    required this.fromYear,
    required this.toYear,
    required this.fuelType,
    required this.engineSize,
    required this.createdAt,
    required this.userId,
    required this.time,
  });

  /// 📝 تحويل من JSON إلى كائن ProductInfo
  factory ProductInfo.fromMap(Map<String, dynamic> json) => ProductInfo(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    nameCar: json["NameCar"] ?? "",
    category: json["Category"] ?? "",
    fromYear: json["fromYear"] ?? "",
    toYear: json["toYear"] ?? "",
    fuelType: json["fuelType"] ?? "",
    engineSize: json["engineSize"] ?? "",
    createdAt: json["created_at"] ?? "",
    userId: json["user_id"]?.toString() ?? "",
    time: json["time"] ?? "",
  );

  /// 🔄 تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "NameCar": nameCar,
      "Category": category,
      "fromYear": fromYear,
      "toYear": toYear,
      "fuelType": fuelType,
      "engineSize": engineSize,
      "created_at": createdAt,
      "user_id": userId,
      "time": time,
    };
  }

  @override
  String toString() {
    return '''
    ProductInfo {
      id: $id,
      name: $name,
      nameCar: $nameCar,
      category: $category,
      fromYear: $fromYear,
      toYear: $toYear,
      fuelType: $fuelType,
      engineSize: $engineSize,
      createdAt: $createdAt,
      userId: $userId,
      time: $time
    }
    ''';
  }
}
