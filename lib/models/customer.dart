import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'customer_product.dart';
import 'product.dart';

part 'customer.g.dart';

@HiveType(typeId: 2)
class Customer extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<CustomerProduct> products;

  @HiveField(3)
  final double totalAmount;

  @HiveField(4)
  final double initialPayment;

  @HiveField(5)
  final IconData? icon;

  Customer({
    String? id,
    required this.name,
    List<CustomerProduct>? products,
    required this.totalAmount,
    this.initialPayment = 0,
    this.icon,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    products = products ?? [];

  double get remainingAmount => totalAmount - initialPayment;

  Customer copyWith({
    String? id,
    String? name,
    List<CustomerProduct>? products,
    double? totalAmount,
    double? initialPayment,
    IconData? icon,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      initialPayment: initialPayment ?? this.initialPayment,
      icon: icon ?? this.icon,
    );
  }

  void addProduct(CustomerProduct product) {
    products.add(product);
  }

  double get totalProductsAmount {
    return products.fold(
      0.0,
      (sum, product) => sum + (product.product.price * product.quantity),
    );
  }
} 