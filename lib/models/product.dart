import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final String description;

  Product({
    String? id,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.description,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Product copyWith({
    String? id,
    String? imagePath,
    String? name,
    double? price,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Product &&
    runtimeType == other.runtimeType &&
    id == other.id;

  @override
  int get hashCode => id.hashCode;
} 