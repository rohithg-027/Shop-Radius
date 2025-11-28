import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../constants/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/data_provider.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final double totalAmount;

  const OrderConfirmationScreen({
    Key? key,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  static const uuid = Uuid();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _nameController.text = authProvider.currentUser!.name;
      _phoneController.text = authProvider.currentUser!.phone;
      _addressController.text = authProvider.currentUser!.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _placeOrder() {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final dataProvider = context.read<DataProvider>();

    // Create order items from cart
    List<OrderItem> orderItems = cartProvider.items
        .map((item) => OrderItem(
              productId: item.productId,
              name: item.name,
              quantity: item.quantity,
              price: item.price,
            ))
        .toList();

    // Get vendor ID (assuming first item's shop vendor)
    final vendorId = cartProvider.items.isNotEmpty
        ? cartProvider.items.first.shopId
        : 'vendor_default';

    // Create order
    final order = Order(
      id: uuid.v4(),
      customerId: authProvider.currentUser?.id ?? 'customer_default',
      vendorId: vendorId,
      items: orderItems,
      status: 'Pending',
      totalAmount: widget.totalAmount,
      createdAt: DateTime.now(),
      deliveryAddress: _addressController.text,
      customerName: _nameController.text,
      phoneNumber: _phoneController.text,
    );

    dataProvider.placeOrder(order);
    cartProvider.clearCart();

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed successfully!'),
        backgroundColor: AppTheme.success,
      ),
    );

    // Simulate order status updates
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        dataProvider.updateOrderStatus(order.id, 'Accepted');
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        dataProvider.updateOrderStatus(order.id, 'Completed');
      }
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Address',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: 'Delivery Address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Payment Method',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ...[
                    ('Cash on Delivery', Icons.money_rounded),
                    ('Digital Payment', Icons.account_balance_wallet_outlined),
                    ('UPI', Icons.qr_code_2_rounded),
                  ].map((method) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPaymentMethod = method.$1);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                method.$2,
                                color: _selectedPaymentMethod == method.$1
                                    ? AppTheme.primary
                                    : AppTheme.grey,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                method.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _selectedPaymentMethod == method.$1
                                        ? AppTheme.primary
                                        : AppTheme.greyLight,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: _selectedPaymentMethod == method.$1
                                    ? Center(
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Summary',
                            style:
                                Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '₹${(widget.totalAmount - 50).toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery Charges',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '₹50',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '₹${widget.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      child: const Text('Place Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
