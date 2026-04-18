import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (authProvider.isAdmin &&
        adminProvider.products.isEmpty &&
        !adminProvider.isLoading) {
      Future.microtask(adminProvider.loadAdminData);
    }

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage products')),
        body: const Center(
          child: Text('Admin access is required to manage products.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage products'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadAdminData(),
        child: adminProvider.products.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(defaultPadding),
                children: const [
                  SizedBox(height: defaultPadding * 3),
                  Center(
                    child: Text(
                      'No products found yet. Add your first pet product to Firestore from this screen.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: adminProvider.products.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: defaultPadding),
                itemBuilder: (context, index) {
                  final product = adminProvider.products[index];
                  return Container(
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 72,
                              height: 72,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(defaultBorderRadious),
                                ),
                                child: NetworkImageWithLoader(product.imageUrl),
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(
                                    product.brandName.isEmpty
                                        ? product.categoryName
                                        : product.brandName,
                                  ),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(
                                    'Rs ${product.price.toStringAsFixed(0)}'
                                    '${product.salePrice != null ? '  Sale Rs ${product.salePrice!.toStringAsFixed(0)}' : ''}',
                                  ),
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(
                                    'Stock: ${product.stockQuantity} | ${product.isActive ? 'Active' : 'Hidden'}',
                                  ),
                                  if (product.packOptions.isNotEmpty) ...[
                                    const SizedBox(height: defaultPadding / 4),
                                    Text(
                                      'Packs: ${product.packOptions.map((option) => '${option.label} (${option.stockQuantity})').join(', ')}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: defaultPadding / 4),
                                  Text(
                                    'Featured: ${product.isFeatured ? 'Yes' : 'No'} | Best Seller: ${product.isPopular ? 'Yes' : 'No'} | New Arrival: ${product.isNewArrival ? 'Yes' : 'No'}',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    adminProductFormScreenRoute,
                                    arguments: product,
                                  );
                                },
                                child: const Text('Edit'),
                              ),
                            ),
                            const SizedBox(width: defaultPadding),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: adminProvider.isSaving
                                    ? null
                                    : () async {
                                        final shouldDelete =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete product?'),
                                              content: Text(
                                                'Remove ${product.title} from the catalog?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      false,
                                                    );
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      dialogContext,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (shouldDelete == true && context.mounted) {
                                          final admin =
                                              context.read<AdminProvider>();
                                          final products =
                                              context.read<ProductProvider>();
                                          await admin.deleteProduct(product.id);
                                          if (context.mounted) {
                                            await products.loadInitialData();
                                          }
                                        }
                                      },
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, adminProductFormScreenRoute);
        },
        label: const Text('Add product'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
