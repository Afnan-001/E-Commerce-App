import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final featuredProducts = productProvider.featuredProducts;
    final allProducts = productProvider.catalogProducts;
    final categories = productProvider.discoverCategories;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: _HomeBanner(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Wrap(
                  spacing: defaultPadding,
                  runSpacing: defaultPadding,
                  children: categories
                      .map(
                        (category) => _CategoryTile(
                          title: category.title,
                          onTap: () {
                            Navigator.pushNamed(context, discoverScreenRoute);
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'Featured products',
                subtitle: 'Highlighted items for quick browsing',
              ),
            ),
            if (featuredProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text('No featured products found yet.'),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: defaultPadding),
                    itemBuilder: (context, index) {
                      final product = featuredProducts[index];
                      return SizedBox(
                        width: 180,
                        child: ProductCard(
                          image: product.image,
                          brandName: product.categoryName,
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: 'All products',
                subtitle: '${allProducts.length} item${allProducts.length == 1 ? '' : 's'} in the catalog',
              ),
            ),
            if (allProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: Text('No products found. Add products from the admin panel.'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(defaultPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.64,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = allProducts[index];
                      return ProductCard(
                        image: product.image,
                        brandName: product.categoryName,
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
                    childCount: allProducts.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1D6), Color(0xFFFFD8C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet care week',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Static offers keep the home page simple while the catalog comes live from Firestore.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: const Text('Free delivery on orders above Rs 999'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        defaultPadding,
        defaultPadding,
        defaultPadding,
        defaultPadding / 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - (defaultPadding * 3)) / 2;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.all(Radius.circular(defaultBorderRadious)),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.pets_rounded, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
