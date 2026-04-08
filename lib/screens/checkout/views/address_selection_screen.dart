import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/providers/address_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/address/views/address_form_screen.dart';

class AddressSelectionScreen extends StatelessWidget {
  const AddressSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select address')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please sign in to select a delivery address.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                  child: const Text('Go to login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final selected = addressProvider.selectedAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select delivery address'),
        actions: [
          TextButton(
            onPressed: () => _openAddressForm(context),
            child: const Text('Add new'),
          ),
        ],
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressProvider.addresses.isEmpty
              ? _EmptyAddressState(onAdd: () => _openAddressForm(context))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(defaultPadding),
                        itemCount: addressProvider.addresses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: defaultPadding),
                        itemBuilder: (context, index) {
                          final item = addressProvider.addresses[index];
                          final isSelected = item.id == selected?.id;
                          return InkWell(
                            onTap: () {
                              context
                                  .read<AddressProvider>()
                                  .selectAddressForCheckout(item.id);
                            },
                            borderRadius: const BorderRadius.all(
                              Radius.circular(defaultBorderRadious),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(defaultPadding),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).dividerColor,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultBorderRadious),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<AddressProvider>()
                                          .selectAddressForCheckout(item.id);
                                    },
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context).dividerColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: defaultPadding / 2),
                                  Expanded(
                                    child: _AddressSummary(address: item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(defaultPadding),
                      child: Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, addressesScreenRoute);
                            },
                            child: const Text('Manage addresses'),
                          ),
                          const SizedBox(height: defaultPadding / 2),
                          ElevatedButton(
                            onPressed: selected == null
                                ? null
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Order will be delivered to ${selected.shortAddress}. Order placement API is the next step.',
                                        ),
                                      ),
                                    );
                                  },
                            child: const Text('Place order'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Future<void> _openAddressForm(BuildContext context) async {
    final formResult = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (_) => const AddressFormScreen(),
      ),
    );

    if (formResult == null || !context.mounted) return;

    try {
      await context.read<AddressProvider>().addAddress(formResult);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save address right now.')),
      );
    }
  }
}

class _AddressSummary extends StatelessWidget {
  const _AddressSummary({
    required this.address,
  });

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious),
                ),
              ),
              child: Text(
                address.label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            if (address.isDefault) ...[
              const SizedBox(width: defaultPadding / 2),
              const Text('Default'),
            ],
          ],
        ),
        const SizedBox(height: defaultPadding / 2),
        Text(
          '${address.fullName} • ${address.phoneNumber}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 4),
        Text(address.fullAddress),
      ],
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'No saved addresses yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              'Add an address to continue checkout.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: onAdd,
              child: const Text('Add address'),
            ),
          ],
        ),
      ),
    );
  }
}
