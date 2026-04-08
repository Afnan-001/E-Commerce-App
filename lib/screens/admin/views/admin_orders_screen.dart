import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (authProvider.isAdmin &&
        adminProvider.orders.isEmpty &&
        !adminProvider.isLoading) {
      Future.microtask(adminProvider.loadAdminData);
    }

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage orders')),
        body: const Center(
          child: Text('Admin access is required to manage orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage orders'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadAdminData(),
        child: adminProvider.orders.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(defaultPadding),
                children: const [
                  SizedBox(height: defaultPadding * 3),
                  Center(
                    child: Text(
                      'No orders found yet. Customer orders will appear here after checkout is connected.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: adminProvider.orders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: defaultPadding),
                itemBuilder: (context, index) {
                  final order = adminProvider.orders[index];
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
                        Text(order.customerName),
                        Text(order.phoneNumber),
                        const SizedBox(height: defaultPadding / 2),
                        Text(order.address),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          'Items: ${order.items.length} | Total: Rs ${order.total.toStringAsFixed(0)}',
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          'Payment: ${order.paymentStatus}',
                        ),
                        const SizedBox(height: defaultPadding),
                        DropdownButtonFormField<OrderStatus>(
                          initialValue: order.orderStatus,
                          decoration:
                              const InputDecoration(labelText: 'Order status'),
                          items: OrderStatus.values
                              .map(
                                (status) => DropdownMenuItem<OrderStatus>(
                                  value: status,
                                  child: Text(status.name.toUpperCase()),
                                ),
                              )
                              .toList(),
                          onChanged: adminProvider.isSaving
                              ? null
                              : (status) {
                                  if (status == null ||
                                      status == order.orderStatus) {
                                    return;
                                  }
                                  context
                                      .read<AdminProvider>()
                                      .updateOrderStatus(order.id, status);
                                },
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
