import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/config/cloudinary_config.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin panel')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(defaultPadding),
            child: Text(
              'This area is only available for admin accounts.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin panel'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadAdminData(),
        child: ListView(
          padding: const EdgeInsets.all(defaultPadding),
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius:
                    const BorderRadius.all(Radius.circular(defaultBorderRadious)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pet shop admin',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    'Manage products, monitor orders, and keep grooming catalog details updated from this panel.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Categories',
                    value: adminProvider.categories.length.toString(),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _MetricCard(
                    label: 'Products',
                    value: adminProvider.products.length.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Orders',
                    value: adminProvider.orders.length.toString(),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                const Expanded(
                  child: _MetricCard(
                    label: 'Uploads',
                    value: 'Cloudinary',
                  ),
                ),
              ],
            ),
            _StatusCard(
              title: 'Firebase status',
              subtitle:
                  'Auth and Firestore are wired in code. Replace the placeholder firebase options with your real project config to go live.',
            ),
            const SizedBox(height: defaultPadding),
            _StatusCard(
              title: 'Cloudinary status',
              subtitle: CloudinaryConfig.isConfigured
                  ? 'Cloudinary is configured for product image uploads.'
                  : 'Add your cloud name and unsigned upload preset in lib/core/config/cloudinary_config.dart.',
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, adminCategoriesScreenRoute);
              },
              child: const Text('Manage categories'),
            ),
            const SizedBox(height: defaultPadding / 2),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, adminProductsScreenRoute);
              },
              child: const Text('Manage products'),
            ),
            const SizedBox(height: defaultPadding / 2),
            OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, adminOrdersScreenRoute);
              },
              child: const Text('Manage orders'),
            ),
            if (adminProvider.errorMessage != null) ...[
              const SizedBox(height: defaultPadding),
              Text(
                adminProvider.errorMessage!,
                style: const TextStyle(color: errorColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(label),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(subtitle),
        ],
      ),
    );
  }
}
