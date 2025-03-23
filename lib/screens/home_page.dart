import 'package:flutter/material.dart';
import '../providers/customer_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/product_provider.dart';
import '../models/payment.dart';
import 'add_payment_page.dart';
import 'customer_page.dart';
import 'product_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerProvider = CustomerProvider();
    final paymentProvider = PaymentProvider();
    final productProvider = ProductProvider();

    // Calculate statistics
    final totalCustomers = customerProvider.customers.length;
    final totalProducts = productProvider.products.length;
    
    double totalSales = 0;
    double totalReceived = 0;
    for (final customer in customerProvider.customers) {
      totalSales += customer.totalAmount;
      totalReceived += paymentProvider.getTotalPaidForCustomer(customer);
    }
    final totalPending = totalSales - totalReceived;

    // Get recent payments
    List<Payment> recentPayments = [];
    for (final customer in customerProvider.customers) {
      recentPayments.addAll(paymentProvider.getPaymentsForCustomer(customer));
    }
    recentPayments.sort((a, b) => b.date.compareTo(a.date));
    if (recentPayments.length > 5) {
      recentPayments = recentPayments.sublist(0, 5);
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Welcome Section
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Quick Stats Cards
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Customers',
                  value: totalCustomers.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerPage()),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Products',
                  value: totalProducts.toString(),
                  icon: Icons.inventory,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductPage()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Financial Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FinancialRow(
                    title: 'Total Sales',
                    amount: totalSales,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _FinancialRow(
                    title: 'Received',
                    amount: totalReceived,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  _FinancialRow(
                    title: 'Pending',
                    amount: totalPending,
                    color: Colors.orange,
                  ),
                  if (totalSales > 0) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: totalReceived / totalSales,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Collection Progress: ${((totalReceived / totalSales) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Payments
          const Text(
            'Recent Payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recentPayments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No payments recorded yet'),
              ),
            )
          else
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentPayments.length,
                itemBuilder: (context, index) {
                  final payment = recentPayments[index];
                  return ListTile(
                    title: Text(payment.customer.name),
                    subtitle: Text(
                      payment.date.toString().split('.')[0],
                    ),
                    trailing: Text(
                      '\₱${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialRow extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _FinancialRow({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          '\₱${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
} 