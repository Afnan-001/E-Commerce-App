import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/checkout/views/address_selection_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;
    final deliveryFee = items.isEmpty ? 0.0 : 49.0;
    final total = cartProvider.subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(title: Text('Cart (${cartProvider.totalItems})')),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      'Add grooming products, food, or pet essentials to start your order.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: defaultPadding),
                    SizedBox(
                      width: 220,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            entryPointScreenRoute,
                            (route) => false,
                          );
                        },
                        child: const Text('Continue shopping'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(defaultPadding),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: defaultPadding),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Container(
                        padding: const EdgeInsets.all(defaultPadding),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(defaultBorderRadious),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 84,
                              height: 84,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultBorderRadious),
                                ),
                                child: NetworkImageWithLoader(
                                  item.product.imageUrl,
                                ),
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(item.product.brandName),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(
                                    'Rs ${item.unitPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFF31B0D8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: defaultPadding / 2),
                                  Row(
                                    children: [
                                      _QuantityButton(
                                        icon: Icons.remove,
                                        onTap: () {
                                          cartProvider.updateQuantity(
                                            item.product.id,
                                            item.quantity - 1,
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: defaultPadding / 2,
                                        ),
                                        child: Text('${item.quantity}'),
                                      ),
                                      _QuantityButton(
                                        icon: Icons.add,
                                        onTap: () {
                                          cartProvider.updateQuantity(
                                            item.product.id,
                                            item.quantity + 1,
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          cartProvider.removeFromCart(
                                            item.product.id,
                                          );
                                        },
                                        child: const Text('Remove'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      top: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      _PriceRow(
                        label: 'Subtotal',
                        value: 'Rs ${cartProvider.subtotal.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: defaultPadding / 4),
                      _PriceRow(
                        label: 'Delivery',
                        value: 'Rs ${deliveryFee.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      _PriceRow(
                        label: 'Total',
                        value: 'Rs ${total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      const SizedBox(height: defaultPadding),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddressSelectionScreen(),
                            ),
                          );
                        },
                        child: const Text('Proceed to checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = isBold
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

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
