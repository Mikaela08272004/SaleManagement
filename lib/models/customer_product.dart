import 'package:hive/hive.dart';
import 'product.dart';

part 'customer_product.g.dart';

@HiveType(typeId: 4)
class CustomerProduct extends HiveObject {
  @HiveField(0)
  final Product product;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  final DateTime purchaseDate;

  CustomerProduct({
    required this.product,
    required this.quantity,
    DateTime? purchaseDate,
  }) : purchaseDate = purchaseDate ?? DateTime.now();

  double get total => product.price * quantity;
} 