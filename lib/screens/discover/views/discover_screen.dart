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

  static const List<_PetSection> _dogsSections = <_PetSection>[
    _PetSection(
      title: 'Lifestyle & Accessories',
      categories: <String>[
        'Clothing & Accessories',
        'Harness & Bodybelts',
        'Collars, Leashes & Chains',
        'Beds & Mats',
        'Feeding Bowls',
        'Cages & Houses',
        'Bones & Munchies',
        'Toys',
      ],
    ),
    _PetSection(
      title: 'Food Essentials',
      categories: <String>[
        'Dog Food (All)',
        'Dry Food',
        'Wet Food',
        'Treats & Biscuits',
        'Gravy & Jelly',
        'Supplements',
      ],
    ),
    _PetSection(
      title: 'Grooming',
      categories: <String>['Shampoos & Dry Bath', 'Combs / Brushes'],
    ),
  ];

  static const List<_PetSection> _catsSections = <_PetSection>[
    _PetSection(
      title: 'Lifestyle & Accessories',
      categories: <String>[
        'Beds & Mats',
        'Feeding Bowls',
        'Cages & Houses',
        'Toys',
      ],
    ),
    _PetSection(
      title: 'Food Essentials',
      categories: <String>[
        'Cat Food (All)',
        'Treats & Biscuits',
        'Gravy & Jelly',
        'Supplements',
      ],
    ),
    _PetSection(
      title: 'Grooming',
      categories: <String>['Shampoos & Dry Bath', 'Combs / Brushes'],
    ),
  ];

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
      final availableLabels = _tabSections
          .expand((section) => section.categories)
          .map((label) => label.toLowerCase())
          .toSet();
      if (_selectedCategoryTitle != null &&
          !availableLabels.contains(_selectedCategoryTitle!.toLowerCase())) {
        _selectedCategoryTitle = null;
      }
    });
  }

  void _syncInitialSelection() {
    final normalized = widget.initialCategoryTitle?.trim().toLowerCase();
    final belongsToCats =
        normalized != null &&
        _catsSections.any(
          (section) => section.categories.any(
            (category) => category.toLowerCase() == normalized,
          ),
        );
    final targetIndex = belongsToCats ? 1 : 0;

    _currentTabIndex = targetIndex;
    _selectedCategoryTitle = widget.initialCategoryTitle?.trim().isEmpty == true
        ? null
        : widget.initialCategoryTitle?.trim();
    if (_tabController.index != targetIndex) {
      _tabController.index = targetIndex;
    }
  }

  List<_PetSection> get _tabSections =>
      _currentTabIndex == 0 ? _dogsSections : _catsSections;

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = _filteredProducts(productProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(defaultPadding),
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
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: primaryColor,
                    indicatorWeight: 3,
                    labelColor: primaryColor,
                    unselectedLabelColor:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black54),
                    labelStyle: const TextStyle(
                      fontSize: 16,
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
            ..._buildCategorySections(
              context,
              productProvider.discoverCategories,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  defaultPadding,
                  defaultPadding,
                  defaultPadding,
                  defaultPadding / 2,
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      _selectedCategoryTitle ?? 'All pet products',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3DC),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                      child: Text(
                        '${products.length} items',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6F5128),
                        ),
                      ),
                    ),
                    if (_selectedCategoryTitle != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryTitle = null;
                          });
                        },
                        child: const Text('Clear filter'),
                      ),
                  ],
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
                      ? 'Admin-added products will appear here automatically when they match this category.'
                      : 'Try another product name, brand, or category keyword.',
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
  ) {
    final slivers = <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            defaultPadding,
            defaultPadding / 2,
            defaultPadding,
            defaultPadding / 2,
          ),
          child: Text(
            'Browse categories',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ];

    for (final section in _tabSections) {
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
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final label = section.categories[index];
              final matchedCategory = _matchFirestoreCategory(
                categories,
                label,
                preferredPetType: _currentTabIndex == 0 ? 'dogs' : 'cats',
              );
              final isSelected =
                  _selectedCategoryTitle?.toLowerCase() == label.toLowerCase();

              return DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(18)),
                  border: isSelected
                      ? Border.all(color: primaryColor, width: 1.5)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CategoryTile(
                    label: label,
                    imageUrl: (matchedCategory?.image ?? '').trim().isNotEmpty
                        ? matchedCategory?.image
                        : matchedCategory?.svgSrc,
                    size: 80,
                    onTap: () {
                      setState(() {
                        _selectedCategoryTitle = label;
                      });
                    },
                  ),
                ),
              );
            }, childCount: section.categories.length),
          ),
        ),
      );
    }

    return slivers;
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
  final List<String> categories;
}

class _DiscoverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _DiscoverTabHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kTextTabBarHeight;

  @override
  double get maxExtent => kTextTabBarHeight;

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
