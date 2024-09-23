class ProductItemsModel {
  final String id;
  final String name;
  final double price;
  final int amount;
  final int warranty;
  final String img;
  final String mark;
  final String info;
  final String type;

  ProductItemsModel({
    required this.id,
    required this.name,
    required this.price,
    required this.amount,
    required this.warranty,
    required this.img,
    required this.mark,
    required this.info,
    required this.type,
  });

  // Factory constructor to create an instance from a JSON map
  factory ProductItemsModel.fromJson(Map<String, dynamic> json) {
    return ProductItemsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: double.parse(json['price'].toString()),
      amount: int.parse(json['amount'].toString()),
      warranty: int.parse(json['warranty'].toString()),
      img: json['img'] as String,
      mark: json['mark'] as String,
      info: json['info'] as String,
      type: json['type'] as String,
    );
  }

  // Method to convert the ProductItemsModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'amount': amount,
      'warranty': warranty,
      'img': img,
      'mark': mark,
      'info': info,
      'type': type,
    };
  }

  // Named constructor for creating an instance with default data
  factory ProductItemsModel.data({
    required String name,
    required double price,
    required int amount,
    required int warranty,
    required String img,
    required String mark,
    required String info,
    required String type,
  }) {
    return ProductItemsModel(
      id: '', // Default value
      name: name,
      price: price,
      amount: amount,
      warranty: warranty,
      img: img,
      mark: mark,
      info: info,
      type: type,
    );
  }
}
