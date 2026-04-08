import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenDiscover, this.onOpenCategory});

  final VoidCallback? onOpenDiscover;
  final ValueChanged<String>? onOpenCategory;

  static const String _bannerCatImage = 'assets/images/home/banner_cat.png';
  static const String _bannerDogImage = 'assets/images/home/banner_dog.png';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final topSelling = productProvider.catalogProducts.take(8).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBackground = isDark
        ? const Color(0xFF11131A)
        : const Color(0xFFF3EFE8);

    return Container(
      color: pageBackground,
      child: CustomScrollView(
        slivers: [
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
                children: [
                  const _SearchStrip(),
                  const SizedBox(height: defaultPadding),
                  _PromoBanner(
                    banner: productProvider.homeBanner,
                    onTapShopNow: () {
                      if (onOpenDiscover != null) {
                        onOpenDiscover!.call();
                        return;
                      }
                      Navigator.pushNamed(context, discoverScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding * 1.2),
                  _HomeSectionHeader(
                    title: 'Categories',
                    actionText: 'See All',
                    onTapAction: () {
                      if (onOpenDiscover != null) {
                        onOpenDiscover!.call();
                        return;
                      }
                      Navigator.pushNamed(context, discoverScreenRoute);
                    },
                  ),
                  const SizedBox(height: defaultPadding * 0.75),
                  _CategoryRow(
                    categories: productProvider.discoverCategories,
                    onCategoryTap: (categoryTitle) {
                      if (onOpenCategory != null) {
                        onOpenCategory!.call(categoryTitle);
                        return;
                      }
                      Navigator.pushNamed(context, discoverScreenRoute);
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                defaultPadding,
                0,
                defaultPadding,
                defaultPadding * 0.75,
              ),
              child: _HomeSectionHeader(
                title: 'Top Selling',
                actionText: 'See All',
                onTapAction: () {
                  if (onOpenDiscover != null) {
                    onOpenDiscover!.call();
                    return;
                  }
                  Navigator.pushNamed(context, discoverScreenRoute);
                },
              ),
            ),
          ),
          if (topSelling.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: _InlineInfo(
                  text:
                      'No products yet. Add products in admin panel to fill Top Selling.',
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SizedBox(
                height: 278,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: topSelling.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: defaultPadding),
                  itemBuilder: (context, index) {
                    final product = topSelling[index];
                    return _TopSellingCard(
                      product: product,
                      isSaved: productProvider.isBookmarked(product.id),
                      onToggleSaved: () async {
                        final success = await context
                            .read<ProductProvider>()
                            .toggleBookmark(product);
                        if (!context.mounted || success) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.read<ProductProvider>().errorMessage ??
                                  'Could not update saved products.',
                            ),
                          ),
                        );
                      },
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: product,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
        ],
      ),
    );
  }
}

class _SearchStrip extends StatelessWidget {
  const _SearchStrip();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
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
                children: [
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
        _HeaderIconButton(
          icon: Icons.tune_rounded,
          onTap: null,
        ),
        const SizedBox(width: 8),
        const _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: null,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.banner, required this.onTapShopNow});

  final HomeBannerModel banner;
  final VoidCallback onTapShopNow;

  @override
  Widget build(BuildContext context) {
    final ctaText = banner.buttonText.trim().isEmpty
        ? 'Shop Now'
        : banner.buttonText.trim();
    return Container(
      height: 170,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        gradient: LinearGradient(
          colors: [Color(0xFFF4A000), Color(0xFFDC8600)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -8,
            bottom: -12,
            child: _BannerAnimalImage(
              imageUrl: banner.leftImageUrl,
              fallbackAssetPath: HomeScreen._bannerCatImage,
              fallbackIcon: Icons.pets_outlined,
            ),
          ),
          Positioned(
            right: -8,
            bottom: -12,
            child: _BannerAnimalImage(
              imageUrl: banner.rightImageUrl,
              fallbackAssetPath: HomeScreen._bannerDogImage,
              fallbackIcon: Icons.pets_rounded,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 114,
                vertical: 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    banner.highlightText,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    banner.dateText,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                    onTap: onTapShopNow,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 136),
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ctaText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF6A4300),
                        ),
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
}

class _BannerAnimalImage extends StatelessWidget {
  const _BannerAnimalImage({
    required this.imageUrl,
    required this.fallbackAssetPath,
    required this.fallbackIcon,
  });

  final String imageUrl;
  final String fallbackAssetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 134,
      child: Transform.scale(
        scale: 1.22,
        alignment: Alignment.bottomCenter,
        child: imageUrl.trim().isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _BannerFallback(fallbackIcon: fallbackIcon);
                },
              )
            : Image.asset(
                fallbackAssetPath,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return _BannerFallback(fallbackIcon: fallbackIcon);
                },
              ),
      ),
    );
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback({required this.fallbackIcon});

  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Icon(fallbackIcon, color: Colors.white, size: 34),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    required this.actionText,
    required this.onTapAction,
  });

  final String title;
  final String actionText;
  final VoidCallback onTapAction;

  @override
  Widget build(BuildContext context) {
    final titleColor = Theme.of(
      context,
    ).textTheme.titleLarge?.color?.withValues(alpha: 0.95);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
        ),
        TextButton(onPressed: onTapAction, child: Text(actionText)),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.categories, required this.onCategoryTap});

  final List<CategoryModel> categories;
  final ValueChanged<String> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final data = categories.take(4).toList();
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: defaultPadding / 2),
        itemBuilder: (context, index) {
          final item = data[index];
          return _CategoryCircleItem(
            item: item,
            onTap: () => onCategoryTap(item.title),
          );
        },
      ),
    );
  }
}

class _CategoryCircleItem extends StatelessWidget {
  const _CategoryCircleItem({required this.item, required this.onTap});

  final CategoryModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark ? const Color(0xFF171A22) : Colors.white;
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: const BorderRadius.all(Radius.circular(999)),
              border: Border.all(
                color: isDark ? const Color(0xFF2B3040) : const Color(0xFFE4E4E4),
              ),
            ),
            child: _CategoryIcon(
              title: item.title,
              iconSource: item.svgSrc ?? item.image,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.title, required this.iconSource});

  final String title;
  final String? iconSource;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.9);
    final source = (iconSource ?? '').trim();
    if (source.startsWith('http')) {
      return ClipOval(child: NetworkImageWithLoader(source, radius: 999));
    }

    if (source.endsWith('.svg')) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: SvgPicture.asset(
          source,
          colorFilter: ColorFilter.mode(
            iconColor ?? const Color(0xFF2B6B63),
            BlendMode.srcIn,
          ),
          errorBuilder: (context, error, stackTrace) => Icon(
            _fallbackIconForTitle(title),
            color: iconColor ?? const Color(0xFF2B6B63),
          ),
        ),
      );
    }

    if (source.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          source,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            _fallbackIconForTitle(title),
            color: iconColor ?? const Color(0xFF2B6B63),
          ),
        ),
      );
    }

    return Icon(
      _fallbackIconForTitle(title),
      color: iconColor ?? const Color(0xFF2B6B63),
    );
  }

  IconData _fallbackIconForTitle(String value) {
    final key = value.toLowerCase();
    if (key.contains('cat')) return Icons.pets_outlined;
    if (key.contains('dog')) return Icons.pets_rounded;
    if (key.contains('bird')) return Icons.flutter_dash_rounded;
    if (key.contains('fish')) return Icons.set_meal_rounded;
    if (key.contains('groom')) return Icons.content_cut_rounded;
    if (key.contains('access')) return Icons.shopping_bag_outlined;
    return Icons.pets;
  }
}

class _TopSellingCard extends StatelessWidget {
  const _TopSellingCard({
    required this.product,
    required this.isSaved,
    required this.onToggleSaved,
    required this.onTap,
  });

  final ProductModel product;
  final bool isSaved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.78);
    final iconColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.88);
    return SizedBox(
      width: 188,
      child: Material(
        color: isDark ? const Color(0xFF171A22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              border: Border.all(
                color: isDark ? const Color(0xFF2B3040) : const Color(0xFFE7E7E7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          child: NetworkImageWithLoader(product.imageUrl),
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: InkWell(
                          onTap: onToggleSaved,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(999),
                          ),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF262B36).withValues(alpha: 0.96)
                                  : Colors.white.withValues(alpha: 0.95),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 16,
                            color: isSaved
                                ? primaryColor
                                : (iconColor ?? blackColor80),
                          ),
                        ),
                      ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                if (product.salePrice != null &&
                    product.salePrice! < product.price)
                  Row(
                    children: [
                      Text(
                        'Rs ${product.salePrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF1F8E7A),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                        Text(
                          'Rs ${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Rs ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFF1F8E7A),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  product.brandName.isEmpty ? 'PetsWorld' : product.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: secondaryText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineInfo extends StatelessWidget {
  const _InlineInfo({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A22) : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(14)),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3040) : const Color(0xFFE6E6E6),
        ),
      ),
      child: Text(text),
    );
  }
}
