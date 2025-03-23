import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/payment.dart';
import '../models/customer_product.dart';
import '../providers/customer_provider.dart';
import '../providers/payment_provider.dart';

class AddCustomerPage extends StatefulWidget {
  final List<Product> products;

  const AddCustomerPage({
    super.key,
    required this.products,
  });

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialPaymentController = TextEditingController();
  final _customerProvider = CustomerProvider();
  final _paymentProvider = PaymentProvider();
  final List<CustomerProduct> _selectedProducts = [];
  double _totalAmount = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _initialPaymentController.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    setState(() {
      _totalAmount = _selectedProducts.fold(
        0.0,
        (sum, item) => sum + (item.product.price * item.quantity),
      );
    });
  }

  void _addProduct(Product product) {
    showDialog<void>(
      context: context,
      builder: (context) {
        int quantity = 1;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text('Add ${product.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Price: \₱${product.price.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: quantity > 1
                          ? () => setState(() => quantity--)
                          : null,
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => quantity++),
                    ),
                  ],
                ),
                Text(
                  'Total: \₱${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectedProducts.add(
                    CustomerProduct(
                      product: product,
                      quantity: quantity,
                    ),
                  );
                  _updateTotalAmount();
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedProducts.removeAt(index);
      _updateTotalAmount();
    });
  }

  void _addCustomer() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one product'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create the customer
    final customer = Customer(
      name: _nameController.text.trim(),
      products: List<CustomerProduct>.from(_selectedProducts),
      totalAmount: _totalAmount,
      initialPayment: double.tryParse(_initialPaymentController.text.trim()) ?? 0,
    );

    // Add the customer
    _customerProvider.addCustomer(customer);

    // Create initial payment if amount is provided
    final initialPaymentText = _initialPaymentController.text.trim();
    if (initialPaymentText.isNotEmpty) {
      final initialPayment = double.parse(initialPaymentText);
      if (initialPayment > 0) {
        final payment = Payment(
          customer: customer,
          amount: initialPayment,
          date: DateTime.now(),
          notes: 'Initial payment',
        );
        _paymentProvider.addPayment(payment);
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Selected Products
            Text(
              'Selected Products',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_selectedProducts.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No products selected'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedProducts.length,
                itemBuilder: (context, index) {
                  final item = _selectedProducts[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.product.name),
                      subtitle: Text(
                        'Quantity: ${item.quantity} × \$${item.product.price.toStringAsFixed(2)} = \₱${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeProduct(index),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Product'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.products.length,
                        itemBuilder: (context, index) {
                          final product = widget.products[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('\₱${product.price.toStringAsFixed(2)}'),
                            onTap: () {
                              Navigator.pop(context);
                              _addProduct(product);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
            
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Amount:'),
                          Text(
                            '\₱${_totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _initialPaymentController,
                decoration: const InputDecoration(
                  labelText: 'Initial Payment (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payments),
                  prefixText: '\₱',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null; // Optional field
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > _totalAmount) {
                    return 'Amount cannot exceed total amount';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _addCustomer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
} 