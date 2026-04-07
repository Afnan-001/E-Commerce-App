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
  List<ProductModel> _popularProducts = const <ProductModel>[];
  List<ProductModel> _flashSaleProducts = const <ProductModel>[];
  List<ProductModel> _bestSellerProducts = const <ProductModel>[];
  List<ProductModel> _mostPopularProducts = const <ProductModel>[];
  List<ProductModel> _bookmarkedProducts = const <ProductModel>[];
  List<CategoryModel> _discoverCategories = const <CategoryModel>[];

  bool get isLoading => _isLoading;
  List<ProductModel> get popularProducts => _popularProducts;
  List<ProductModel> get flashSaleProducts => _flashSaleProducts;
  List<ProductModel> get bestSellerProducts => _bestSellerProducts;
  List<ProductModel> get mostPopularProducts => _mostPopularProducts;
  List<ProductModel> get bookmarkedProducts => _bookmarkedProducts;
  List<CategoryModel> get discoverCategories => _discoverCategories;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    final results = await Future.wait<dynamic>(<Future<dynamic>>[
      _productRepository.getPopularProducts(),
      _productRepository.getFlashSaleProducts(),
      _productRepository.getBestSellerProducts(),
      _productRepository.getMostPopularProducts(),
      _productRepository.getBookmarkedProducts(),
      _categoryRepository.getDiscoverCategories(),
    ]);

    _popularProducts = results[0] as List<ProductModel>;
    _flashSaleProducts = results[1] as List<ProductModel>;
    _bestSellerProducts = results[2] as List<ProductModel>;
    _mostPopularProducts = results[3] as List<ProductModel>;
    _bookmarkedProducts = results[4] as List<ProductModel>;
    _discoverCategories = results[5] as List<CategoryModel>;

    _isLoading = false;
    notifyListeners();
  }
}
