class ItemModel {
  String? name;

  ItemModel({
    this.name,
  });

  ItemModel.copy({
    String? name,

  }) {
    this.name = name ?? this.name;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      name: map['name'],
    );
  }
}
