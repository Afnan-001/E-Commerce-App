import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/cart_pricing_summary_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/route_constants.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final items = cartProvider.items;
    final pricing = cartProvider.pricing;

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
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultPadding,
                      defaultPadding,
                      defaultPadding,
                      0,
                    ),
                    child: _FreeDeliveryBanner(pricing: pricing),
                  ),
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
                                    item.displayName,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(item.product.brandName),
                                  if (item.selectedOptionLabel
                                      .trim()
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: defaultPadding / 4,
                                      ),
                                      child: Text(
                                        'Pack: ${item.selectedOptionLabel}',
                                      ),
                                    ),
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
                                        onTap: () async {
                                          final success = await cartProvider
                                              .updateQuantity(
                                                item.id,
                                                item.quantity - 1,
                                              );
                                          if (!context.mounted || success) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cartProvider.errorMessage ??
                                                    'Unable to update your cart right now.',
                                              ),
                                            ),
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
                                        onTap: () async {
                                          final success = await cartProvider
                                              .updateQuantity(
                                                item.id,
                                                item.quantity + 1,
                                              );
                                          if (!context.mounted || success) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cartProvider.errorMessage ??
                                                    'Unable to update your cart right now.',
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () async {
                                          final success = await cartProvider
                                              .removeFromCart(item.id);
                                          if (!context.mounted || success) {
                                            return;
                                          }
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                cartProvider.errorMessage ??
                                                    'Unable to remove this item right now.',
                                              ),
                                            ),
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
                        value: 'Rs ${pricing.subtotal.toStringAsFixed(0)}',
                      ),
                      if (pricing.productDiscount > 0) ...[
                        const SizedBox(height: defaultPadding / 4),
                        _PriceRow(
                          label: 'Product savings',
                          value:
                              '-Rs ${pricing.productDiscount.toStringAsFixed(0)}',
                        ),
                      ],
                      const SizedBox(height: defaultPadding / 4),
                      _PriceRow(
                        label: 'Delivery',
                        value: pricing.deliveryCharge == 0
                            ? 'Free'
                            : 'Rs ${pricing.deliveryCharge.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      _PriceRow(
                        label: 'Total',
                        value: 'Rs ${pricing.total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                      const SizedBox(height: defaultPadding),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, checkoutScreenRoute);
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

class _FreeDeliveryBanner extends StatelessWidget {
  const _FreeDeliveryBanner({required this.pricing});

  final CartPricingSummaryModel pricing;

  @override
  Widget build(BuildContext context) {
    final progress = pricing.freeDeliveryThreshold <= 0
        ? 1.0
        : (pricing.subtotal / pricing.freeDeliveryThreshold)
              .clamp(0.0, 1.0)
              .toDouble();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0FF),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: const Color(0xFFDCCFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pricing.qualifiesForFreeDelivery
                ? 'Free delivery unlocked'
                : 'Add Rs ${pricing.amountLeftForFreeDelivery.toStringAsFixed(0)} more for free delivery',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
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
