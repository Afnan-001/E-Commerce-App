import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/order_item_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/route/route_constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().currentUser;
    if (_nameController.text.isEmpty) {
      _nameController.text = user?.name ?? '';
    }
    if (_phoneController.text.isEmpty) {
      _phoneController.text = user?.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final authProvider = context.watch<AuthProvider>();
    final deliveryFee = cartProvider.items.isEmpty ? 0.0 : 49.0;
    final total = cartProvider.subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartProvider.items.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: Text(
                  'Your cart is empty. Add products before placing an order.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                      ),
                      validator: (value) =>
                          value == null || value.trim().length < 10
                          ? 'Enter a valid phone number'
                          : null,
                    ),
                    const SizedBox(height: defaultPadding),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address',
                      ),
                      minLines: 3,
                      maxLines: 4,
                      validator: (value) =>
                          value == null || value.trim().length < 10
                          ? 'Enter a complete address'
                          : null,
                    ),
                    const SizedBox(height: defaultPadding * 1.5),
                    Text(
                      'Order summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: defaultPadding),
                    ...cartProvider.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: defaultPadding / 2,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} x${item.quantity}',
                              ),
                            ),
                            Text('Rs ${item.totalPrice.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: defaultPadding * 2),
                    _SummaryRow(
                      label: 'Subtotal',
                      value: 'Rs ${cartProvider.subtotal.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    _SummaryRow(
                      label: 'Delivery',
                      value: 'Rs ${deliveryFee.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const _SummaryRow(
                      label: 'Payment',
                      value: 'Cash on Delivery',
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    _SummaryRow(
                      label: 'Total',
                      value: 'Rs ${total.toStringAsFixed(0)}',
                      isEmphasized: true,
                    ),
                    if (orderProvider.errorMessage != null) ...[
                      const SizedBox(height: defaultPadding),
                      Text(
                        orderProvider.errorMessage!,
                        style: const TextStyle(color: errorColor),
                      ),
                    ],
                    const SizedBox(height: defaultPadding * 1.5),
                    ElevatedButton(
                      onPressed: orderProvider.isLoading
                          ? null
                          : () async {
                              final scaffoldMessenger = ScaffoldMessenger.of(
                                context,
                              );
                              final orderNotifier = context
                                  .read<OrderProvider>();
                              final cartNotifier = context.read<CartProvider>();
                              final navigator = Navigator.of(context);

                              if (!_formKey.currentState!.validate()) {
                                return;
                              }

                              final currentUser = authProvider.currentUser;
                              if (currentUser == null) {
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in before placing an order.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final order = OrderModel(
                                id: '',
                                userId: currentUser.uid,
                                customerName: _nameController.text.trim(),
                                phoneNumber: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                                items: cartProvider.items
                                    .map(OrderItemModel.fromCartItem)
                                    .toList(),
                                subtotal: cartProvider.subtotal,
                                deliveryCharge: deliveryFee,
                                totalPrice: total,
                              );

                              final result = await orderNotifier.placeOrder(
                                order,
                              );
                              if (!mounted || result == null) {
                                return;
                              }

                              await Printing.layoutPdf(
                                onLayout: (format) async => result.invoiceBytes,
                                name:
                                    'petsworld_invoice_${result.order.id}.pdf',
                              );

                              if (!mounted) {
                                return;
                              }

                              final cartCleared = await cartNotifier.clear();
                              if (!mounted) {
                                return;
                              }
                              if (!cartCleared) {
                                scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      cartNotifier.errorMessage ??
                                          'Order placed, but cart could not be removed from Firestore.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              navigator.pushNamedAndRemoveUntil(
                                ordersScreenRoute,
                                (route) => false,
                              );
                            },
                      child: Text(
                        orderProvider.isLoading
                            ? 'Placing order...'
                            : 'Place COD order',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasized
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyLarge;
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
