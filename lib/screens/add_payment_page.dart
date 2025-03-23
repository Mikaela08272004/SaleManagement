import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../models/payment.dart';
import '../providers/payment_provider.dart';

class AddPaymentPage extends StatefulWidget {
  final Customer customer;

  const AddPaymentPage({
    super.key,
    required this.customer,
  });

  @override
  State<AddPaymentPage> createState() => _AddPaymentPageState();
}

class _AddPaymentPageState extends State<AddPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentProvider = PaymentProvider();
  DateTime _selectedDate = DateTime.now();
  double _currentAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmount);
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateAmount() {
    setState(() {
      _currentAmount = double.tryParse(_amountController.text) ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPaid = _paymentProvider.getTotalPaidForCustomer(widget.customer);
    final totalRemaining = widget.customer.totalAmount - totalPaid;
    final newRemaining = totalRemaining - _currentAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer and Product Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer: ${widget.customer.name}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Products: ${widget.customer.products.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    ...widget.customer.products.map((product) => Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text(
                        '${product.product.name} (${product.quantity}x)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )).toList(),
                    const SizedBox(height: 8),
                    Text(
                      'Total Amount: \₱${widget.customer.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Balance: \₱${totalRemaining.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter payment amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount > totalRemaining) {
                  return 'Amount cannot exceed remaining balance';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Payment Summary
            if (_currentAmount > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Current Balance:'),
                          Text('\₱${totalRemaining.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Payment Amount:'),
                          Text('\₱${_currentAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('New Balance:'),
                          Text(
                            '\₱${newRemaining.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: newRemaining > 0 ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final payment = Payment(
                    customer: widget.customer,
                    amount: _currentAmount,
                    date: _selectedDate,
                    notes: _notesController.text.trim(),
                  );

                  _paymentProvider.addPayment(payment);
                  Navigator.pop(context, payment);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Add Payment'),
            ),
          ],
        ),
      ),
    );
  }
} 