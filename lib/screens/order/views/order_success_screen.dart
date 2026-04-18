import 'package:flutter/material.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/route/route_constants.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.order,
    this.invoiceMessage,
  });

  final OrderModel order;
  final String? invoiceMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? 'assets/Illustration/success.png'
                      : 'assets/Illustration/success_dark.png',
                  height: MediaQuery.of(context).size.height * 0.26,
                ),
                const SizedBox(height: defaultPadding),
                Text(
                  'Order placed successfully',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding / 2),
                Text(
                  'Order ID: ${order.orderId}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: defaultPadding),
                if ((invoiceMessage ?? '').isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious),
                      ),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Text(invoiceMessage!),
                  ),
                  const SizedBox(height: defaultPadding),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadious),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        label: 'Payment',
                        value: order.paymentMethod.name.toUpperCase(),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Status',
                        value: order.paymentStatus.name.toUpperCase(),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Total',
                        value: 'Rs ${order.total.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Deliver to',
                        value: order.deliveryAddress.shortAddress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: defaultPadding * 1.5),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      entryPointScreenRoute,
                      (route) => false,
                    );
                  },
                  child: const Text('Continue shopping'),
                ),
                const SizedBox(height: defaultPadding / 2),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ordersScreenRoute,
                      (route) => route.isFirst,
                    );
                  },
                  child: const Text('View orders'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
