import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import 'base_provider.dart';

class CustomerProvider extends BaseProvider<Customer> with ChangeNotifier {
  static final CustomerProvider _instance = CustomerProvider._internal();
  factory CustomerProvider() => _instance;
  
  CustomerProvider._internal() : super('customers');

  List<Customer> get customers => getAllForCurrentUser();

  Future<void> addCustomer(Customer customer) async {
    await put(customer.id, customer);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    await put(customer.id, customer);
    notifyListeners();
  }

  Future<void> deleteCustomer(String customerId) async {
    await delete(customerId);
    notifyListeners();
  }

  @override
  Future<void> initialize() async {
    await super.initialize();
    notifyListeners();
  }
} 