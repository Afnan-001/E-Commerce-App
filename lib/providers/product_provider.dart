import 'package:flutter/foundation.dart';

import 'package:shop/models/category_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/category_repository.dart';
import 'package:shop/repositories/product_repository.dart';
import 'package:shop/repositories/user_data_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
    required UserDataRepository userDataRepository,
  }) : _productRepository = productRepository,
       _categoryRepository = categoryRepository,
       _userDataRepository = userDataRepository;

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final UserDataRepository _userDataRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductModel> _catalogProducts = const <ProductModel>[];
  List<ProductModel> _featuredProducts = const <ProductModel>[];
  List<HomeBannerModel> _homeBanners = const <HomeBannerModel>[];
  static const List<CategoryModel> _fallbackCategories = <CategoryModel>[
    CategoryModel(id: 'Dog', title: 'Dog'),
    CategoryModel(id: 'Cat', title: 'Cat'),
    CategoryModel(id: 'Grooming', title: 'Grooming'),
    CategoryModel(id: 'Accessories', title: 'Accessories'),
  ];
  List<CategoryModel> _discoverCategories = _fallbackCategories;
  final Set<String> _bookmarkedProductIds = <String>{};
  String? _userId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get catalogProducts => _catalogProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<HomeBannerModel> get homeBanners => _homeBanners;
  List<ProductModel> get popularProducts =>
      _catalogProducts.where((product) => product.isPopular).toList();
  List<ProductModel> get flashSaleProducts => _catalogProducts
      .where(
        (product) =>
            (product.dicountpercent ?? 0) > 0 ||
            (product.salePrice != null && product.salePrice! < product.price),
      )
      .toList();
  List<ProductModel> get bestSellerProducts => popularProducts;
  List<ProductModel> get mostPopularProducts => popularProducts;
  List<ProductModel> get newArrivals => _catalogProducts
      .where((product) => product.isNewArrival)
      .toList();

  List<ProductModel> get bookmarkedProducts => _catalogProducts
      .where((product) => _bookmarkedProductIds.contains(product.id))
      .toList();
  List<CategoryModel> get discoverCategories => _discoverCategories;
  int get bookmarkedCount => _bookmarkedProductIds.length;

  bool isBookmarked(String productId) =>
      _bookmarkedProductIds.contains(productId);

  Future<void> syncUserData(String? userId) async {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _bookmarkedProductIds.clear();
    notifyListeners();

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      final savedIds = await _userDataRepository.getSavedProductIds(userId);
      _bookmarkedProductIds
        ..clear()
        ..addAll(savedIds);
    } catch (error) {
      _errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<bool> toggleBookmark(ProductModel product) async {
    if (_userId == null || _userId!.isEmpty) {
      _errorMessage = 'Please log in to save products to Firestore.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    final previousBookmarkIds = Set<String>.from(_bookmarkedProductIds);
    final previousCatalog = List<ProductModel>.from(_catalogProducts);
    if (_bookmarkedProductIds.contains(product.id)) {
      _bookmarkedProductIds.remove(product.id);
    } else {
      _bookmarkedProductIds.add(product.id);
      if (_catalogProducts.every((item) => item.id != product.id)) {
        _catalogProducts = <ProductModel>[product, ..._catalogProducts];
      }
    }

    notifyListeners();

    try {
      if (previousBookmarkIds.contains(product.id)) {
        await _userDataRepository.removeSavedProduct(
          userId: _userId!,
          productId: product.id,
        );
      } else {
        await _userDataRepository.saveProduct(
          userId: _userId!,
          product: product,
        );
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _bookmarkedProductIds
        ..clear()
        ..addAll(previousBookmarkIds);
      _catalogProducts = previousCatalog;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _productRepository.getCatalogProducts(),
        _productRepository.getFeaturedProducts(),
        _productRepository.getHomeBanners(),
        _categoryRepository.getDiscoverCategories(),
      ]);

      _catalogProducts = results[0] as List<ProductModel>;
      _featuredProducts = results[1] as List<ProductModel>;
      final loadedBanners = results[2] as List<HomeBannerModel>;
      final loadedCategories = results[3] as List<CategoryModel>;
      _homeBanners =
          loadedBanners.where((banner) => banner.isActive).toList();
      _discoverCategories = loadedCategories.isEmpty
          ? _fallbackCategories
          : loadedCategories;
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _catalogProducts = await _productRepository.getCatalogProducts(
        category: category,
      );
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ProductModel> searchInCatalog(
    String query, {
    List<ProductModel>? source,
  }) {
    final normalized = query.trim().toLowerCase();
    final items = source ?? _catalogProducts;
    if (normalized.isEmpty) {
      return items;
    }

    return items.where((product) {
      final name = product.name.toLowerCase();
      final category = product.category.toLowerCase();
      final description = product.description.toLowerCase();
      final brand = product.brandName.toLowerCase();
      return name.contains(normalized) ||
          category.contains(normalized) ||
          description.contains(normalized) ||
          brand.contains(normalized);
    }).toList();
  }
}
