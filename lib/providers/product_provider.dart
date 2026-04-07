import 'package:flutter/foundation.dart';

import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/category_repository.dart';
import 'package:shop/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({
    required ProductRepository productRepository,
    required CategoryRepository categoryRepository,
  })  : _productRepository = productRepository,
        _categoryRepository = categoryRepository;

  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductModel> _catalogProducts = const <ProductModel>[];
  List<ProductModel> _popularProducts = const <ProductModel>[];
  List<ProductModel> _flashSaleProducts = const <ProductModel>[];
  List<ProductModel> _bestSellerProducts = const <ProductModel>[];
  List<ProductModel> _mostPopularProducts = const <ProductModel>[];
  List<CategoryModel> _discoverCategories = const <CategoryModel>[];
  final Set<String> _bookmarkedProductIds = <String>{};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get catalogProducts => _catalogProducts;
  List<ProductModel> get popularProducts => _popularProducts;
  List<ProductModel> get flashSaleProducts => _flashSaleProducts;
  List<ProductModel> get bestSellerProducts => _bestSellerProducts;
  List<ProductModel> get mostPopularProducts => _mostPopularProducts;
  List<ProductModel> get bookmarkedProducts => _catalogProducts
      .where((product) => _bookmarkedProductIds.contains(product.id))
      .toList();
  List<CategoryModel> get discoverCategories => _discoverCategories;
  int get bookmarkedCount => _bookmarkedProductIds.length;

  bool isBookmarked(String productId) => _bookmarkedProductIds.contains(productId);

  void toggleBookmark(ProductModel product) {
    if (_bookmarkedProductIds.contains(product.id)) {
      _bookmarkedProductIds.remove(product.id);
    } else {
      _bookmarkedProductIds.add(product.id);
      if (_catalogProducts.every((item) => item.id != product.id)) {
        _catalogProducts = <ProductModel>[product, ..._catalogProducts];
      }
    }
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _productRepository.getCatalogProducts(),
        _productRepository.getPopularProducts(),
        _productRepository.getFlashSaleProducts(),
        _productRepository.getBestSellerProducts(),
        _productRepository.getMostPopularProducts(),
        _categoryRepository.getDiscoverCategories(),
      ]);

      _catalogProducts = results[0] as List<ProductModel>;
      _popularProducts = results[1] as List<ProductModel>;
      _flashSaleProducts = results[2] as List<ProductModel>;
      _bestSellerProducts = results[3] as List<ProductModel>;
      _mostPopularProducts = results[4] as List<ProductModel>;
      _discoverCategories = results[5] as List<CategoryModel>;
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
