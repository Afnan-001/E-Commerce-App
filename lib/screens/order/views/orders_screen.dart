import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/order_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final pendingOrders = orderProvider.pendingOrders;
    final completedOrders = orderProvider.completedOrders;
    final currentUserId = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Text(
                      orderProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
          : orderProvider.orders.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(defaultPadding),
                    child: Text(
                      'No orders yet. Your pending and completed COD orders will appear here.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      context.read<OrderProvider>().loadUserOrders(currentUserId),
                  child: ListView(
                    padding: const EdgeInsets.all(defaultPadding),
                    children: [
                      Text(
                        'Pending Orders',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      if (pendingOrders.isEmpty)
                        const _OrderSectionEmptyState(
                          message: 'No pending orders right now.',
                        )
                      else
                        ...pendingOrders.map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: defaultPadding,
                            ),
                            child: _OrderCard(order: order),
                          ),
                        ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        'Order History',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      if (completedOrders.isEmpty)
                        const _OrderSectionEmptyState(
                          message: 'Completed orders will appear here.',
                        )
                      else
                        ...completedOrders.map(
                          (order) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: defaultPadding,
                            ),
                            child: _OrderCard(order: order),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
  });

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'Order #${order.id}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding / 2),
          Text('Status: ${order.orderStatus.name.toUpperCase()}'),
          Text('Payment: ${order.paymentStatus}'),
          Text('Total: Rs ${order.totalPrice.toStringAsFixed(0)}'),
          const SizedBox(height: defaultPadding / 2),
          ...order.items.map(
            (item) => Text(
              '${item.name} x${item.quantity} - Rs ${item.lineTotal.toStringAsFixed(0)}',
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSectionEmptyState extends StatelessWidget {
  const _OrderSectionEmptyState({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(message),
    );
  }
}
