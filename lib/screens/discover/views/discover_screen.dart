import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/category_tile.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    this.initialCategoryTitle,
    this.filterSeed = 0,
  });

  final String? initialCategoryTitle;
  final int filterSeed;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedCategoryTitle;
  String _searchQuery = '';
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabChange);
    _syncInitialSelection();
  }

  @override
  void didUpdateWidget(covariant DiscoverScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterSeed != widget.filterSeed ||
        oldWidget.initialCategoryTitle != widget.initialCategoryTitle) {
      setState(() {
        _searchQuery = '';
      });
      _syncInitialSelection();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _currentTabIndex == _tabController.index) {
      return;
    }

    setState(() {
      _currentTabIndex = _tabController.index;
      final availableLabels = _sectionsForTab(
            context.read<ProductProvider>().discoverCategories,
            _currentTabIndex,
          )
          .expand((section) => section.categories)
          .map((category) => category.title.toLowerCase())
          .toSet();
      if (_selectedCategoryTitle != null &&
          !availableLabels.contains(_selectedCategoryTitle!.toLowerCase())) {
        _selectedCategoryTitle = null;
      }
    });
  }

  void _syncInitialSelection() {
    final normalized = widget.initialCategoryTitle?.trim().toLowerCase();
    final belongsToCats = normalized != null &&
        _petTypeForCategory(
              context.read<ProductProvider>().discoverCategories,
              normalized,
            ) ==
            'cats';
    final targetIndex = belongsToCats ? 1 : 0;

    _currentTabIndex = targetIndex;
    _selectedCategoryTitle = widget.initialCategoryTitle?.trim().isEmpty == true
        ? null
        : widget.initialCategoryTitle?.trim();
    if (_tabController.index != targetIndex) {
      _tabController.index = targetIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final tabSections = _sectionsForTab(
      productProvider.discoverCategories,
      _currentTabIndex,
    );
    final products = _filteredProducts(productProvider);
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = mediaQuery.padding.bottom;
    final categoryCrossAxisCount = width >= 1100
        ? 5
        : width >= 760
        ? 4
        : 3;
    final categoryTileSize = width >= 1100
        ? 96.0
        : width >= 760
        ? 92.0
        : 84.0;
    final categoryTileMainExtent = categoryTileSize + 64;
    final productCrossAxisCount = width >= 1100
        ? 4
        : width >= 760
        ? 3
        : 2;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding,
                  defaultPadding,
                  12,
                ),
                child: SearchForm(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = (value ?? '').trim();
                    });
                  },
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _DiscoverTabHeaderDelegate(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    0,
                    defaultPadding,
                    10,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.all(Radius.circular(18)),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 22),
                      labelColor: Colors.white,
                      unselectedLabelColor:
                          Theme.of(context).textTheme.bodyMedium?.color ??
                          (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.black54),
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: const <Tab>[
                        Tab(text: 'Dogs'),
                        Tab(text: 'Cats'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ..._buildCategorySections(
              context,
              productProvider.discoverCategories,
              tabSections,
              categoryCrossAxisCount,
              categoryTileSize,
              categoryTileMainExtent,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding * 1.25,
                  defaultPadding,
                  defaultPadding / 2,
                ),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: width >= 760 ? width * 0.6 : width * 0.72,
                      ),
                      child: Text(
                        _selectedCategoryTitle ?? 'Everything in store',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.all(Radius.circular(999)),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Text(
                        '${products.length} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      _selectedCategoryTitle == null
                          ? 'Browse the whole catalog.'
                          : 'Filtered by category.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedCategoryTitle != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    defaultPadding,
                    0,
                    defaultPadding,
                    6,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategoryTitle = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Clear category filter'),
                    ),
                  ),
                ),
              ),
            if (products.isEmpty)
              SliverToBoxAdapter(
                child: SectionEmptyState(
                  title: _searchQuery.isEmpty
                      ? 'No products in this category'
                      : 'No matching products',
                  message: _searchQuery.isEmpty
                      ? 'Products in this category will appear here automatically.'
                      : 'Try another product name, brand, or category keyword.',
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  defaultPadding,
                  0,
                  defaultPadding,
                  defaultPadding + safeBottom + 20,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: productCrossAxisCount,
                    mainAxisSpacing: defaultPadding,
                    crossAxisSpacing: defaultPadding,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
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
                  }, childCount: products.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategorySections(
    BuildContext context,
    List<CategoryModel> categories,
    List<_PetSection> tabSections,
    int categoryCrossAxisCount,
    double categoryTileSize,
    double categoryTileMainExtent,
  ) {
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            defaultPadding,
            4,
            defaultPadding,
            10,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Browse categories',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                _currentTabIndex == 0 ? 'For dogs' : 'For cats',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ];

    for (final section in tabSections) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              defaultPadding,
              defaultPadding,
              defaultPadding,
              defaultPadding / 2,
            ),
            child: Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: categoryCrossAxisCount,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              mainAxisExtent: categoryTileMainExtent,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = section.categories[index];

              return CategoryTile(
                label: category.title,
                imageUrl: (category.image ?? '').trim().isNotEmpty
                    ? category.image
                    : category.svgSrc,
                size: categoryTileSize,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    categoryProductsScreenRoute,
                    arguments: <String, String>{
                      'categoryTitle': category.title,
                      'petType': _currentTabIndex == 0 ? 'dogs' : 'cats',
                    },
                  );
                },
              );
            }, childCount: section.categories.length),
          ),
        ),
      );
    }

    return slivers;
  }

  List<_PetSection> _sectionsForTab(
    List<CategoryModel> categories,
    int tabIndex,
  ) {
    final petType = tabIndex == 0 ? 'dogs' : 'cats';
    final parent = _petParentCategory(categories, petType);
    if (parent == null) {
      return const <_PetSection>[];
    }

    final lifestyle = <CategoryModel>[];
    final food = <CategoryModel>[];
    final grooming = <CategoryModel>[];

    for (final category in parent.subCategories) {
      final normalized = _normalizedCategoryKey(category.title);
      if (_isGroomingCategory(normalized)) {
        grooming.add(category);
      } else if (_isFoodCategory(normalized)) {
        food.add(category);
      } else {
        lifestyle.add(category);
      }
    }

    final sections = <_PetSection>[];
    if (lifestyle.isNotEmpty) {
      sections.add(
        _PetSection(title: 'Lifestyle & Accessories', categories: lifestyle),
      );
    }
    if (food.isNotEmpty) {
      sections.add(_PetSection(title: 'Food Essentials', categories: food));
    }
    if (grooming.isNotEmpty) {
      sections.add(_PetSection(title: 'Grooming', categories: grooming));
    }
    return sections;
  }

  CategoryModel? _petParentCategory(
    List<CategoryModel> categories,
    String petType,
  ) {
    final normalizedPet = _normalizedCategoryKey(petType);
    for (final category in categories) {
      final normalizedTitle = _normalizedCategoryKey(category.title);
      final normalizedId = _normalizedCategoryKey(category.id);
      if (normalizedTitle == normalizedPet ||
          normalizedTitle == normalizedPet.replaceAll('s', '') ||
          normalizedId == normalizedPet ||
          normalizedId == normalizedPet.replaceAll('s', '')) {
        return category;
      }
    }
    return null;
  }

  String? _petTypeForCategory(List<CategoryModel> categories, String label) {
    final normalized = _normalizedCategoryKey(label);
    for (final parent in categories) {
      final parentKey = _normalizedCategoryKey(parent.title);
      if (parentKey == 'dogs' || parentKey == 'cats') {
        final hasMatch = parent.subCategories.any(
          (category) =>
              _normalizedCategoryKey(category.title) == normalized ||
              _normalizedCategoryKey(category.id) == normalized,
        );
        if (hasMatch) {
          return parentKey;
        }
      }
    }
    return null;
  }

  bool _isFoodCategory(String normalizedTitle) {
    return normalizedTitle.contains('food') ||
        normalizedTitle.contains('treat') ||
        normalizedTitle.contains('gravy') ||
        normalizedTitle.contains('supplement') ||
        normalizedTitle.contains('biscuit');
  }

  bool _isGroomingCategory(String normalizedTitle) {
    return normalizedTitle.contains('shampoo') ||
        normalizedTitle.contains('comb') ||
        normalizedTitle.contains('brush') ||
        normalizedTitle.contains('groom');
  }

  List<ProductModel> _filteredProducts(ProductProvider productProvider) {
    final selectedCategoryTitle = _selectedCategoryTitle?.trim();
    if (selectedCategoryTitle == null || selectedCategoryTitle.isEmpty) {
      return productProvider.searchInCatalog(
        _searchQuery,
        source: productProvider.catalogProducts,
      );
    }

    final normalizedTitle = selectedCategoryTitle.toLowerCase();
    final petType = _currentTabIndex == 0 ? 'dogs' : 'cats';
    final matchedCategory = _matchFirestoreCategory(
      productProvider.discoverCategories,
      selectedCategoryTitle,
      preferredPetType: petType,
    );
    final matchedId = matchedCategory?.id.trim().toLowerCase();
    final matchedTitle = matchedCategory?.title.trim().toLowerCase();

    final normalizedPetType = petType.toLowerCase();
    final ambiguousAcrossPets = _isCategorySharedAcrossDogsAndCats(
      normalizedTitle,
    );
    final filteredByCategory = productProvider.catalogProducts.where((product) {
      final normalizedCategory = product.category.trim().toLowerCase();
      final containsBaseLabel = normalizedCategory.contains(normalizedTitle);
      final containsMatchedTitle =
          matchedTitle != null && normalizedCategory.contains(matchedTitle);
      final equalsMatchedId =
          matchedId != null && normalizedCategory == matchedId;
      final containsMatchedId =
          matchedId != null && normalizedCategory.contains(matchedId);
      final containsPetType = normalizedCategory.contains(normalizedPetType);

      if (!ambiguousAcrossPets) {
        return containsBaseLabel ||
            containsMatchedTitle ||
            equalsMatchedId ||
            containsMatchedId;
      }

      return (containsMatchedId || equalsMatchedId || containsMatchedTitle) ||
          ((containsBaseLabel || containsMatchedTitle) && containsPetType);
    }).toList();

    return productProvider.searchInCatalog(
      _searchQuery,
      source: filteredByCategory,
    );
  }

  CategoryModel? _matchFirestoreCategory(
    List<CategoryModel> categories,
    String label, {
    String? preferredPetType,
  }) {
    final normalized = _normalizedCategoryKey(label);
    final flattened = _flattenCategories(categories);
    final byId = <String, CategoryModel>{
      for (final category in flattened) category.id: category,
    };
    CategoryModel? bestMatch;
    var bestScore = -1;

    for (final category in flattened) {
      final titleKey = _normalizedCategoryKey(category.title);
      final idKey = _normalizedCategoryKey(category.id);
      if (titleKey.contains(normalized) ||
          normalized.contains(titleKey) ||
          idKey.contains(normalized) ||
          normalized.contains(idKey)) {
        var score = 0;
        if (titleKey == normalized || idKey == normalized) {
          score += 3;
        }
        if (preferredPetType != null && preferredPetType.isNotEmpty) {
          final normalizedPet = _normalizedCategoryKey(preferredPetType);
          if (idKey.startsWith('${normalizedPet}_')) {
            score += 5;
          }
          final parent = category.parentId == null
              ? null
              : byId[category.parentId!];
          final parentTitle = parent == null
              ? ''
              : _normalizedCategoryKey(parent.title);
          if (parentTitle == normalizedPet) {
            score += 8;
          }
        }
        if (score > bestScore) {
          bestScore = score;
          bestMatch = category;
        }
      }
    }
    return bestMatch;
  }

  List<CategoryModel> _flattenCategories(List<CategoryModel> categories) {
    final flat = <CategoryModel>[];
    void collect(List<CategoryModel> nodes) {
      for (final node in nodes) {
        flat.add(node);
        if (node.subCategories.isNotEmpty) {
          collect(node.subCategories);
        }
      }
    }

    collect(categories);
    return flat;
  }

  String _normalizedCategoryKey(String value) {
    final lowered = value.toLowerCase().trim();
    return lowered
        .replaceAll('(all)', '')
        .replaceAll('/', ' ')
        .replaceAll('&', ' ')
        .replaceAll(',', ' ')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isCategorySharedAcrossDogsAndCats(String normalizedTitle) {
    const shared = <String>{
      'beds mats',
      'feeding bowls',
      'cages houses',
      'toys',
      'treats biscuits',
      'gravy jelly',
      'supplements',
      'shampoos dry bath',
      'combs brushes',
    };
    return shared.contains(normalizedTitle);
  }
}

class _PetSection {
  const _PetSection({required this.title, required this.categories});

  final String title;
  final List<CategoryModel> categories;
}

class _DiscoverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _DiscoverTabHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 72;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: maxExtent,
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DiscoverTabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
