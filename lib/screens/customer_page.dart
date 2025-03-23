import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../providers/customer_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/product_provider.dart';
import 'add_customer_page.dart';
import 'customer_details_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final _customerProvider = CustomerProvider();
  final _paymentProvider = PaymentProvider();
  final _productProvider = ProductProvider();

  @override
  Widget build(BuildContext context) {
    final customers = _customerProvider.customers;
    final products = _productProvider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      body: customers.isEmpty
          ? const Center(
              child: Text('No customers added yet'),
            )
          : ListView.builder(
              itemCount: customers.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final customer = customers[index];
                final totalPaid = _paymentProvider.getTotalPaidForCustomer(customer);
                final remainingBalance = customer.totalAmount - totalPaid;

                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailsPage(customer: customer),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.shopping_cart, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '${customer.products.length} Products',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.attach_money, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Total Amount: \₱${customer.totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                size: 16,
                                color: remainingBalance > 0 ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remaining Balance: \₱${remainingBalance.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: remainingBalance > 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (remainingBalance > 0) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: totalPaid / customer.totalAmount,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Payment Progress: ${((totalPaid / customer.totalAmount) * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (products.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please add some products first'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => AddCustomerPage(products: products),
            ),
          );

          if (result == true) {
            setState(() {});
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 