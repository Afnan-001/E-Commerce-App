import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage categories')),
        body: const Center(
          child: Text('Admin access is required to manage categories.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage categories'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<AdminProvider>().loadAdminData();
          if (context.mounted) {
            await context.read<ProductProvider>().loadInitialData();
          }
        },
        child: adminProvider.categories.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(defaultPadding),
                children: const [
                  SizedBox(height: defaultPadding * 3),
                  Center(
                    child: Text(
                      'No categories found yet. Add categories here and they will appear in the user app.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(defaultPadding),
                itemCount: adminProvider.categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: defaultPadding),
                itemBuilder: (context, index) {
                  final category = adminProvider.categories[index];
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
                          category.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 4),
                        Text(
                          'Sort: ${category.sortOrder} | ${category.isActive ? 'Active' : 'Hidden'}',
                        ),
                        if ((category.svgSrc ?? '').isNotEmpty) ...[
                          const SizedBox(height: defaultPadding / 4),
                          Text('Icon: ${category.svgSrc}'),
                        ],
                        const SizedBox(height: defaultPadding),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    adminCategoryFormScreenRoute,
                                    arguments: category,
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
                                        final shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete category?'),
                                              content: Text(
                                                'Remove ${category.title} from the catalog?',
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
                                          final product =
                                              context.read<ProductProvider>();
                                          await admin.deleteCategory(category.id);
                                          if (context.mounted) {
                                            await product.loadInitialData();
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
          Navigator.pushNamed(context, adminCategoryFormScreenRoute);
        },
        label: const Text('Add category'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
