import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../models/customer.dart';
import 'base_provider.dart';

class PaymentProvider extends BaseProvider<Payment> with ChangeNotifier {
  static final PaymentProvider _instance = PaymentProvider._internal();
  factory PaymentProvider() => _instance;
  
  PaymentProvider._internal() : super('payments');

  List<Payment> get payments => getAllForCurrentUser();

  List<Payment> getPaymentsForCustomer(Customer customer) {
    return payments.where((payment) => payment.customer.id == customer.id).toList();
  }

  double getTotalPaidForCustomer(Customer customer) {
    final customerPayments = getPaymentsForCustomer(customer);
    return customerPayments.fold(0, (sum, payment) => sum + payment.amount);
  }

  Future<void> addPayment(Payment payment) async {
    await put(payment.id, payment);
    notifyListeners();
  }

  Future<void> updatePayment(Payment payment) async {
    await put(payment.id, payment);
    notifyListeners();
  }

  Future<void> deletePayment(String paymentId) async {
    await delete(paymentId);
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    notifyListeners();
  }
} 