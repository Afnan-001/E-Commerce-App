import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({
    super.key,
    required this.categoryTitle,
  });

  final String categoryTitle;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = _productsForCategory(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle.trim().isEmpty ? 'Category' : categoryTitle),
      ),
      body: products.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: SectionEmptyState(
                  title: 'No products yet',
                  message:
                      'Products added to this category will appear here automatically.',
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(defaultPadding),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.68,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  image: product.image,
                  brandName: product.brandName,
                  title: product.title,
                  price: product.price,
                  priceAfetDiscount: product.priceAfetDiscount,
                  dicountpercent: product.dicountpercent,
                  isSaved: productProvider.isBookmarked(product.id),
                  onToggleSaved: () {
                    context.read<ProductProvider>().toggleBookmark(product);
                  },
                  press: () {
                    Navigator.pushNamed(
                      context,
                      productDetailsScreenRoute,
                      arguments: product,
                    );
                  },
                );
              },
            ),
    );
  }

  List<ProductModel> _productsForCategory(ProductProvider productProvider) {
    final normalized = categoryTitle.trim().toLowerCase();
    if (normalized.isEmpty) {
      return productProvider.catalogProducts;
    }

    return productProvider.catalogProducts.where((product) {
      final productCategory = product.category.trim().toLowerCase();
      return productCategory == normalized ||
          productCategory.contains(normalized);
    }).toList();
  }
}
