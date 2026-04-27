import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/category_tile.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/models/category_model.dart';
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
  void dispose() {
    _tabController
      ..removeListener(_handleTabChange)
      ..dispose();
    super.dispose();
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

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _currentTabIndex == _tabController.index) {
      return;
    }

    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  void _syncInitialSelection() {
    final normalized = widget.initialCategoryTitle?.trim().toLowerCase();
    final belongsToCats =
        normalized != null &&
        _petTypeForCategory(
              context.read<ProductProvider>().discoverCategories,
              normalized,
            ) ==
            'cats';
    final targetIndex = belongsToCats ? 1 : 0;

    _currentTabIndex = targetIndex;
    if (_tabController.index != targetIndex) {
      _tabController.index = targetIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final tabSections = _filterSectionsForQuery(
      _sectionsForTab(productProvider.discoverCategories, _currentTabIndex),
      _searchQuery,
    );
    final hasQuery = _searchQuery.trim().isNotEmpty;
    final width = MediaQuery.of(context).size.width;
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
              hasQuery: hasQuery,
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
    double categoryTileMainExtent, {
    required bool hasQuery,
  }) {
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                hasQuery
                    ? 'Search results'
                    : _currentTabIndex == 0
                    ? 'For dogs'
                    : 'For cats',
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

    if (tabSections.isEmpty) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: SectionEmptyState(
              title: hasQuery ? 'No matching categories' : 'No categories yet',
              message: hasQuery
                  ? 'Try another keyword like food, toys, bowls, grooming, or beds.'
                  : 'Categories added from the admin panel will appear here automatically.',
            ),
          ),
        ),
      );
      return slivers;
    }

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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
                  final fullCategoryTitle = _fullCategoryPath(
                    category,
                    categories,
                  );
                  Navigator.pushNamed(
                    context,
                    categoryProductsScreenRoute,
                    arguments: <String, String>{
                      'categoryTitle': fullCategoryTitle,
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
    if (food.isNotEmpty) {
      sections.add(_PetSection(title: 'Food Essentials', categories: food));
    }
    if (lifestyle.isNotEmpty) {
      sections.add(
        _PetSection(title: 'Lifestyle & Accessories', categories: lifestyle),
      );
    }
    if (grooming.isNotEmpty) {
      sections.add(_PetSection(title: 'Grooming', categories: grooming));
    }
    return sections;
  }

  List<_PetSection> _filterSectionsForQuery(
    List<_PetSection> sections,
    String query,
  ) {
    final normalized = _normalizedCategoryKey(query);
    if (normalized.isEmpty) {
      return sections;
    }

    final filtered = <_PetSection>[];
    for (final section in sections) {
      final matches = section.categories.where((category) {
        final title = _normalizedCategoryKey(category.title);
        final id = _normalizedCategoryKey(category.id);
        return title.contains(normalized) || id.contains(normalized);
      }).toList();

      if (matches.isNotEmpty) {
        filtered.add(_PetSection(title: section.title, categories: matches));
      }
    }
    return filtered;
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

  String _fullCategoryPath(
    CategoryModel category,
    List<CategoryModel> categories,
  ) {
    if (category.parentId == null || category.parentId!.trim().isEmpty) {
      return category.title;
    }

    final byId = <String, CategoryModel>{
      for (final item in _flattenCategories(categories)) item.id: item,
    };
    final parent = byId[category.parentId!];
    if (parent == null) {
      return category.title;
    }

    return '${parent.title} > ${category.title}';
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
