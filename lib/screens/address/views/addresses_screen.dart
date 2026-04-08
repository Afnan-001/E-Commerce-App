import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/providers/address_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';

import 'address_form_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final addressProvider = context.watch<AddressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved addresses'),
      ),
      body: !authProvider.isAuthenticated
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in to manage your delivery addresses.',
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
            )
          : addressProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : addressProvider.addresses.isEmpty
                  ? _EmptyAddressView(
                      onAdd: () => _openAddressForm(context),
                    )
                  : RefreshIndicator(
                      onRefresh: () => context.read<AddressProvider>().loadAddresses(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(defaultPadding),
                        itemCount: addressProvider.addresses.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: defaultPadding),
                        itemBuilder: (context, index) {
                          final address = addressProvider.addresses[index];
                          return _AddressCard(
                            address: address,
                            onEdit: () => _openAddressForm(
                              context,
                              initialAddress: address,
                            ),
                            onDelete: () => _confirmDelete(context, address.id),
                            onSetDefault: address.isDefault
                                ? null
                                : () => _setDefaultAddress(context, address.id),
                          );
                        },
                      ),
                    ),
      floatingActionButton: authProvider.isAuthenticated
          ? FloatingActionButton.extended(
              onPressed: () => _openAddressForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add address'),
            )
          : null,
    );
  }

  Future<void> _openAddressForm(
    BuildContext context, {
    AddressModel? initialAddress,
  }) async {
    final result = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(initialAddress: initialAddress),
      ),
    );

    if (result == null || !context.mounted) return;

    try {
      if (initialAddress == null) {
        await context.read<AddressProvider>().addAddress(result);
      } else {
        await context.read<AddressProvider>().updateAddress(result);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            initialAddress == null
                ? 'Address added successfully.'
                : 'Address updated successfully.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to save address right now.'),
        ),
      );
    }
  }

  Future<void> _setDefaultAddress(BuildContext context, String addressId) async {
    try {
      await context.read<AddressProvider>().setDefaultAddress(addressId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default address updated.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to set default address.')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, String addressId) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete address?'),
            content: const Text(
              'This address will be removed from your profile.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !context.mounted) return;

    try {
      await context.read<AddressProvider>().deleteAddress(addressId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted successfully.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete address.')),
      );
    }
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onSetDefault;

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
              const Spacer(),
              if (address.isDefault)
                const Text(
                  'Default',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: defaultPadding / 2),
          Text(
            '${address.fullName} • ${address.phoneNumber}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(address.fullAddress),
          const SizedBox(height: defaultPadding / 2),
          Wrap(
            spacing: defaultPadding / 2,
            children: [
              OutlinedButton(
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
              OutlinedButton(
                onPressed: onDelete,
                child: const Text('Delete'),
              ),
              OutlinedButton(
                onPressed: onSetDefault,
                child: const Text('Set default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAddressView extends StatelessWidget {
  const _EmptyAddressView({
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
              'Add your first address to speed up checkout.',
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
