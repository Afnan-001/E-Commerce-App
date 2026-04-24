import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/delivery_settings_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminStoreSettingsScreen extends StatefulWidget {
  const AdminStoreSettingsScreen({super.key});

  @override
  State<AdminStoreSettingsScreen> createState() =>
      _AdminStoreSettingsScreenState();
}

class _AdminStoreSettingsScreenState extends State<AdminStoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _thresholdController;
  late final TextEditingController _feeController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AdminProvider>().deliverySettings;
    _thresholdController = TextEditingController(
      text: settings.freeDeliveryThreshold.toStringAsFixed(0),
    );
    _feeController = TextEditingController(
      text: settings.deliveryFee.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Delivery settings')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free delivery rule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Customers unlock free delivery when their cart subtotal before coupon discounts crosses the configured threshold.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _thresholdController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        double.tryParse((value ?? '').trim()) == null
                        ? 'Enter a valid threshold'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Free delivery threshold (Rs)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _feeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        double.tryParse((value ?? '').trim()) == null
                        ? 'Enter a valid fee'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Delivery fee (Rs)',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: adminProvider.isSaving ? null : _save,
                      child: Text(
                        adminProvider.isSaving ? 'Saving...' : 'Save settings',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final settings = DeliverySettingsModel(
      freeDeliveryThreshold:
          double.tryParse(_thresholdController.text.trim()) ?? 999,
      deliveryFee: double.tryParse(_feeController.text.trim()) ?? 49,
    );

    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.saveDeliverySettings(settings);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ?? 'Could not save delivery settings.',
          ),
        ),
      );
      return;
    }
    await context.read<ProductProvider>().loadInitialData();
    await context.read<CartProvider>().loadPricingConfig();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Delivery settings saved.')));
  }
}
