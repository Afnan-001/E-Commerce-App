import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.discoverCategories;
    final selectedCategoryTitle = categories
        .where((item) => item.id == _selectedCategoryId)
        .map((item) => item.title)
        .fold<String?>(null, (previous, element) => previous ?? element);
    final products = _selectedCategoryId == null
        ? productProvider.catalogProducts
        : productProvider.catalogProducts
            .where((item) => item.categoryId == _selectedCategoryId)
            .toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: SearchForm(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding,
                  vertical: defaultPadding / 2,
                ),
                child: Text(
                  'Browse categories',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            if (categories.isEmpty)
              const SliverToBoxAdapter(
                child: SectionEmptyState(
                  title: 'No categories yet',
                  message:
                      'Categories added by admin will appear here automatically.',
                ),
              )
            else
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Row(
                    children: [
                      _DiscoverChip(
                        label: 'All',
                        isActive: _selectedCategoryId == null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = null;
                          });
                        },
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding:
                              const EdgeInsets.only(left: defaultPadding / 2),
                          child: _DiscoverChip(
                            label: category.title,
                            isActive: _selectedCategoryId == category.id,
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCategoryId == null
                          ? 'All pet products'
                          : selectedCategoryTitle ?? 'Category products',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: defaultPadding / 4),
                    Text(
                      'Showing ${products.length} item${products.length == 1 ? '' : 's'} from your live catalog.',
                    ),
                  ],
                ),
              ),
            ),
            if (products.isEmpty)
              const SliverToBoxAdapter(
                child: SectionEmptyState(
                  title: 'No products in this category',
                  message:
                      'Admin-added products will appear here as soon as they match this category.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  0,
                  defaultPadding,
                  defaultPadding,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.66,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverChip extends StatelessWidget {
  const _DiscoverChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(
            color:
                isActive ? Colors.transparent : Theme.of(context).dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive
                ? Colors.white
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
