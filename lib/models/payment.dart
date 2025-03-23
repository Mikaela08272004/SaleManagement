import 'package:hive/hive.dart';
import 'customer.dart';

part 'payment.g.dart';

@HiveType(typeId: 3)
class Payment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Customer customer;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String notes;

  Payment({
    String? id,
    required this.customer,
    required this.amount,
    required this.date,
    this.notes = '',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Payment copyWith({
    String? id,
    Customer? customer,
    double? amount,
    DateTime? date,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
} 