import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/payment.dart';
import '../providers/customer_provider.dart';
import '../providers/payment_provider.dart';
import 'add_payment_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _customerProvider = CustomerProvider();
  final _paymentProvider = PaymentProvider();

  @override
  Widget build(BuildContext context) {
    final customers = _customerProvider.customers;

    if (customers.isEmpty) {
      return const Center(
        child: Text('No customers available'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Payments'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final customer = customers[index];
          final totalPaid = _paymentProvider.getTotalPaidForCustomer(customer);
          final remainingBalance = customer.totalAmount - totalPaid;

          return Card(
            child: ListTile(
              title: Text(customer.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${customer.products.length} Products'),
                  Text(
                    'Remaining: \₱${remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: remainingBalance > 0 ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerPaymentDetailsPage(customer: customer),
                  ),
                ).then((_) => setState(() {})); // Refresh the list when returning
              },
            ),
          );
        },
      ),
    );
  }
}

class CustomerPaymentDetailsPage extends StatefulWidget {
  final Customer customer;

  const CustomerPaymentDetailsPage({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerPaymentDetailsPage> createState() => _CustomerPaymentDetailsPageState();
}

class _CustomerPaymentDetailsPageState extends State<CustomerPaymentDetailsPage> {
  final _paymentProvider = PaymentProvider();

  @override
  Widget build(BuildContext context) {
    final payments = _paymentProvider.getPaymentsForCustomer(widget.customer);
    final totalPaid = _paymentProvider.getTotalPaidForCustomer(widget.customer);
    final remainingBalance = widget.customer.totalAmount - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer.name),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Products: ${widget.customer.products.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...widget.customer.products.map((product) => Text(
                          '${product.product.name} (${product.quantity}x)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )).toList(),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total: \₱${widget.customer.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Paid: \₱${totalPaid.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: remainingBalance > 0 ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Remaining Balance: \₱${remainingBalance.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: remainingBalance > 0 ? Colors.red : Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: payments.isEmpty
                ? const Center(
                    child: Text('No payments recorded'),
                  )
                : ListView.builder(
                    itemCount: payments.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            '\₱${payment.amount.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${payment.date.toString().split('.')[0]}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (payment.notes.isNotEmpty)
                                Text(
                                  'Notes: ${payment.notes}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: remainingBalance > 0 
          ? FloatingActionButton(
              onPressed: () async {
                final choice = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add Payment'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Remaining Balance: \₱${remainingBalance.toStringAsFixed(2)}'),
                          const SizedBox(height: 16),
                          const Text('Choose payment option:'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'custom'),
                          child: const Text('Custom Amount'),
                        ),
                        TextButton(
                          onPressed: remainingBalance <= 0
                              ? null
                              : () => Navigator.pop(context, 'full'),
                          child: const Text('Pay Full Balance'),
                        ),
                      ],
                    );
                  },
                );

                if (choice == null) return;

                Payment? result;
                if (choice == 'full' && remainingBalance > 0) {
                  result = Payment(
                    customer: widget.customer,
                    amount: remainingBalance,
                    date: DateTime.now(),
                    notes: 'Full balance payment',
                  );
                } else if (choice == 'custom') {
                  result = await Navigator.push<Payment>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPaymentPage(customer: widget.customer),
                    ),
                  );
                }

                if (result != null) {
                  _paymentProvider.addPayment(result);
                  setState(() {}); // Refresh the UI
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 