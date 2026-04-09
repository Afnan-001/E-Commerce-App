import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/home_banner_card.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenDiscover, this.onOpenCategory});

  final VoidCallback? onOpenDiscover;
  final ValueChanged<String>? onOpenCategory;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categories = productProvider.discoverCategories;
    final flashSaleProducts = productProvider.flashSaleProducts;
    final bestSellers = productProvider.popularProducts;
    final newArrivals = productProvider.newArrivals;
    final allProducts = productProvider.catalogProducts;
    final banner = productProvider.homeBanner;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF11131A) : const Color(0xFFF8F3EC),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                defaultPadding,
                defaultPadding / 2,
                defaultPadding,
                defaultPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SearchStrip(),
                  const SizedBox(height: defaultPadding),
                  _HeroBanner(
                    banner: banner,
                    onTapShopNow: () => _openDiscover(context),
                  ),
                  const SizedBox(height: defaultPadding),
                  const _TrustBadgesRow(),
                ],
              ),
            ),
          ),
          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: _HomeSection(
                header: _SectionHeader(
                  title: 'Shop by Category',
                  actionText: 'See all',
                  onTapAction: () => _openDiscover(context),
                ),
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CategoryChip(
                        label: category.title,
                        onTap: () => _openCategory(context, category.title),
                      );
                    },
                  ),
                ),
              ),
            ),
          if (flashSaleProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _HomeSection(
                header: _SectionHeader(
                  title: 'Flash Sale',
                  actionText: 'See all',
                  titleColor: errorColor,
                  leading: const Icon(
                    Icons.flash_on_rounded,
                    color: errorColor,
                  ),
                  badge: 'LIMITED TIME',
                  badgeColor: const Color(0xFFFFECE8),
                  badgeTextColor: errorColor,
                  onTapAction: () => _openDiscover(context),
                ),
                child: _HorizontalProductList(products: flashSaleProducts),
              ),
            ),
          if (bestSellers.isNotEmpty)
            SliverToBoxAdapter(
              child: _HomeSection(
                header: _SectionHeader(
                  title: 'Best Sellers',
                  actionText: 'See all',
                  titleColor: warningColor,
                  leading: const Icon(Icons.star_rounded, color: warningColor),
                  onTapAction: () => _openDiscover(context),
                ),
                child: _HorizontalProductList(products: bestSellers),
              ),
            ),
          if (newArrivals.isNotEmpty)
            SliverToBoxAdapter(
              child: _HomeSection(
                header: _SectionHeader(
                  title: 'New Arrivals',
                  actionText: 'See all',
                  leading: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFE2893C),
                  ),
                  onTapAction: () => _openDiscover(context),
                ),
                child: _HorizontalProductList(products: newArrivals),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                defaultPadding,
                defaultPadding,
                defaultPadding,
                defaultPadding / 2,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'All Products',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFFFF1EB),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(999),
                      ),
                    ),
                    child: Text(
                      '${allProducts.length} items',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (allProducts.isEmpty)
            const SliverToBoxAdapter(
              child: SectionEmptyState(
                title: 'No products yet',
                message:
                    'Add products in the admin panel and they will appear here automatically.',
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: defaultPadding,
                  crossAxisSpacing: defaultPadding,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = allProducts[index];
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
                }, childCount: allProducts.length),
              ),
            ),
        ],
      ),
    );
  }

  void _openDiscover(BuildContext context) {
    if (onOpenDiscover != null) {
      onOpenDiscover!.call();
      return;
    }
    Navigator.pushNamed(context, discoverScreenRoute);
  }

  void _openCategory(BuildContext context, String categoryTitle) {
    if (onOpenCategory != null) {
      onOpenCategory!.call(categoryTitle);
      return;
    }
    Navigator.pushNamed(context, discoverScreenRoute);
  }
}

class _SearchStrip extends StatelessWidget {
  const _SearchStrip();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            onTap: () {
              Navigator.pushNamed(context, searchScreenRoute);
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1E28) : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3140)
                      : const Color(0xFFE0DDD6),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const _HeaderIconButton(icon: Icons.favorite_border_rounded),
        const SizedBox(width: 8),
        const _HeaderIconButton(icon: Icons.shopping_bag_outlined),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1E28) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF2B3040) : const Color(0xFFE4E4E4),
        ),
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Icon(icon, size: 20),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.banner, required this.onTapShopNow});

  final HomeBannerModel banner;
  final VoidCallback onTapShopNow;

  @override
  Widget build(BuildContext context) {
    return HomeBannerCard(banner: banner, onTapShopNow: onTapShopNow);
  }
}

class _TrustBadgesRow extends StatelessWidget {
  const _TrustBadgesRow();

  static const List<({IconData icon, String title})> _items =
      <({IconData icon, String title})>[
        (
          icon: Icons.local_shipping_outlined,
          title: 'Free delivery over Rs 499',
        ),
        (icon: Icons.verified_outlined, title: '100% genuine products'),
        (icon: Icons.support_agent_rounded, title: '24/7 pet care support'),
        (icon: Icons.assignment_return_outlined, title: 'Easy 7-day returns'),
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return _TrustBadgeCard(icon: item.icon, title: item.title);
        },
      ),
    );
  }
}

class _TrustBadgeCard extends StatelessWidget {
  const _TrustBadgeCard({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 172,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3040) : const Color(0xFFECE2D8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Icon(icon, color: primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({required this.header, required this.child});

  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              defaultPadding,
              0,
              defaultPadding,
              defaultPadding * 0.75,
            ),
            child: header,
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTapAction,
    this.leading,
    this.badge,
    this.titleColor,
    this.badgeColor,
    this.badgeTextColor,
  });

  final String title;
  final String actionText;
  final VoidCallback onTapAction;
  final Widget? leading;
  final String? badge;
  final Color? titleColor;
  final Color? badgeColor;
  final Color? badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 8)],
        Flexible(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
        ),
        if (badge != null) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor ?? primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeTextColor ?? primaryColor,
              ),
            ),
          ),
        ],
        const Spacer(),
        TextButton(onPressed: onTapAction, child: Text(actionText)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1E28) : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          border: Border.all(
            color: isDark ? const Color(0xFF2B3040) : const Color(0xFFE9DFD4),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF303544),
          ),
        ),
      ),
    );
  }
}

class _HorizontalProductList extends StatelessWidget {
  const _HorizontalProductList({required this.products});

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    return SizedBox(
      height: 255,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 150,
            child: ProductCard(
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
            ),
          );
        },
      ),
    );
  }
}
