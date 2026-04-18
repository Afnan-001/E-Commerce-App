import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/services/order_invoice_service.dart';
import 'package:shop/core/services/order_export_service.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({
    required AdminRepository adminRepository,
    OrderExportService? orderExportService,
    OrderInvoiceService? orderInvoiceService,
  }) : _adminRepository = adminRepository,
       _orderExportService = orderExportService ?? const OrderExportService(),
       _orderInvoiceService = orderInvoiceService ?? OrderInvoiceService();

  final AdminRepository _adminRepository;
  final OrderExportService _orderExportService;
  final OrderInvoiceService _orderInvoiceService;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasLoadedData = false;
  String? _errorMessage;
  List<ProductModel> _products = const <ProductModel>[];
  List<OrderModel> _orders = const <OrderModel>[];
  List<CategoryModel> _categories = const <CategoryModel>[];
  List<HomeBannerModel> _homeBanners = const <HomeBannerModel>[];

  static const List<_SeedCategory> _discoverCategorySeed = <_SeedCategory>[
    _SeedCategory(id: 'dogs', title: 'Dogs', sortOrder: 0),
    _SeedCategory(id: 'cats', title: 'Cats', sortOrder: 1),
    _SeedCategory(
      id: 'dogs_clothing_accessories',
      title: 'Clothing & Accessories',
      parentId: 'dogs',
      sortOrder: 10,
    ),
    _SeedCategory(
      id: 'dogs_harness_bodybelts',
      title: 'Harness & Bodybelts',
      parentId: 'dogs',
      sortOrder: 11,
    ),
    _SeedCategory(
      id: 'dogs_collars_leashes_chains',
      title: 'Collars, Leashes & Chains',
      parentId: 'dogs',
      sortOrder: 12,
    ),
    _SeedCategory(
      id: 'dogs_beds_mats',
      title: 'Beds & Mats',
      parentId: 'dogs',
      sortOrder: 13,
    ),
    _SeedCategory(
      id: 'dogs_feeding_bowls',
      title: 'Feeding Bowls',
      parentId: 'dogs',
      sortOrder: 14,
    ),
    _SeedCategory(
      id: 'dogs_cages_houses',
      title: 'Cages & Houses',
      parentId: 'dogs',
      sortOrder: 15,
    ),
    _SeedCategory(
      id: 'dogs_bones_munchies',
      title: 'Bones & Munchies',
      parentId: 'dogs',
      sortOrder: 16,
    ),
    _SeedCategory(
      id: 'dogs_toys',
      title: 'Toys',
      parentId: 'dogs',
      sortOrder: 17,
    ),
    _SeedCategory(
      id: 'dogs_food_all',
      title: 'Dog Food (All)',
      parentId: 'dogs',
      sortOrder: 18,
    ),
    _SeedCategory(
      id: 'dogs_dry_food',
      title: 'Dry Food',
      parentId: 'dogs',
      sortOrder: 19,
    ),
    _SeedCategory(
      id: 'dogs_wet_food',
      title: 'Wet Food',
      parentId: 'dogs',
      sortOrder: 20,
    ),
    _SeedCategory(
      id: 'dogs_treats_biscuits',
      title: 'Treats & Biscuits',
      parentId: 'dogs',
      sortOrder: 21,
    ),
    _SeedCategory(
      id: 'dogs_gravy_jelly',
      title: 'Gravy & Jelly',
      parentId: 'dogs',
      sortOrder: 22,
    ),
    _SeedCategory(
      id: 'dogs_supplements',
      title: 'Supplements',
      parentId: 'dogs',
      sortOrder: 23,
    ),
    _SeedCategory(
      id: 'dogs_shampoos_dry_bath',
      title: 'Shampoos & Dry Bath',
      parentId: 'dogs',
      sortOrder: 24,
    ),
    _SeedCategory(
      id: 'dogs_combs_brushes',
      title: 'Combs / Brushes',
      parentId: 'dogs',
      sortOrder: 25,
    ),
    _SeedCategory(
      id: 'cats_beds_mats',
      title: 'Beds & Mats',
      parentId: 'cats',
      sortOrder: 30,
    ),
    _SeedCategory(
      id: 'cats_feeding_bowls',
      title: 'Feeding Bowls',
      parentId: 'cats',
      sortOrder: 31,
    ),
    _SeedCategory(
      id: 'cats_cages_houses',
      title: 'Cages & Houses',
      parentId: 'cats',
      sortOrder: 32,
    ),
    _SeedCategory(
      id: 'cats_toys',
      title: 'Toys',
      parentId: 'cats',
      sortOrder: 33,
    ),
    _SeedCategory(
      id: 'cats_food_all',
      title: 'Cat Food (All)',
      parentId: 'cats',
      sortOrder: 34,
    ),
    _SeedCategory(
      id: 'cats_treats_biscuits',
      title: 'Treats & Biscuits',
      parentId: 'cats',
      sortOrder: 35,
    ),
    _SeedCategory(
      id: 'cats_gravy_jelly',
      title: 'Gravy & Jelly',
      parentId: 'cats',
      sortOrder: 36,
    ),
    _SeedCategory(
      id: 'cats_supplements',
      title: 'Supplements',
      parentId: 'cats',
      sortOrder: 37,
    ),
    _SeedCategory(
      id: 'cats_shampoos_dry_bath',
      title: 'Shampoos & Dry Bath',
      parentId: 'cats',
      sortOrder: 38,
    ),
    _SeedCategory(
      id: 'cats_combs_brushes',
      title: 'Combs / Brushes',
      parentId: 'cats',
      sortOrder: 39,
    ),
  ];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get hasLoadedData => _hasLoadedData;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<CategoryModel> get categories => _categories;
  List<HomeBannerModel> get homeBanners => _homeBanners;

  Future<void> loadAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _adminRepository.getCategories(),
        _adminRepository.getProducts(),
        _adminRepository.getOrders(),
        _adminRepository.getHomeBanners(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
      _orders = results[2] as List<OrderModel>;
      final loadedBanners = results[3] as List<HomeBannerModel>;
      _homeBanners = loadedBanners;
      _hasLoadedData = true;
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> uploadImage(XFile file) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = await _adminRepository.uploadProductImage(file);
      return imageUrl;
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> uploadCategoryImage(XFile file) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageUrl = await _adminRepository.uploadCategoryImage(file);
      return imageUrl;
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveProduct(ProductModel product) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.saveProduct(product);
      await loadAdminData();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveCategory(CategoryModel category) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.saveCategory(category);
      await loadAdminData();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> syncDiscoverCategoryStructure() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = _discoverCategorySeed
          .map(
            (item) => CategoryModel(
              id: item.id,
              title: item.title,
              parentId: item.parentId,
              isActive: true,
              sortOrder: item.sortOrder,
            ),
          )
          .toList();
      await _adminRepository.upsertCategories(payload);
      await loadAdminData();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<int> uploadBundledCategoryImagesAndAttach() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final assetPaths = await _resolveCategoryAssetPaths();

      if (assetPaths.isEmpty) {
        return 0;
      }

      final uploaded = await _adminRepository.uploadCategoryAssets(assetPaths);
      if (uploaded.isEmpty) {
        return 0;
      }

      final currentCategories = _categories.isEmpty
          ? await _adminRepository.getCategories()
          : _categories;
      if (currentCategories.isEmpty) {
        return 0;
      }

      final urlByKey = <String, String>{};
      uploaded.forEach((assetPath, url) {
        final fileName = assetPath.split('/').last;
        final dot = fileName.lastIndexOf('.');
        final stem = dot > 0 ? fileName.substring(0, dot) : fileName;
        urlByKey[_normalizeKey(stem)] = url;
      });

      final updates = <CategoryModel>[];
      for (final category in currentCategories) {
        final candidates = _categoryImageCandidates(category);
        String? matchedUrl;
        for (final key in candidates) {
          final hit = urlByKey[_normalizeKey(key)];
          if ((hit ?? '').isNotEmpty) {
            matchedUrl = hit;
            break;
          }
        }

        if ((matchedUrl ?? '').isNotEmpty) {
          updates.add(
            CategoryModel(
              id: category.id,
              title: category.title,
              image: matchedUrl,
              svgSrc: matchedUrl,
              parentId: category.parentId,
              subCategories: category.subCategories,
              isActive: category.isActive,
              sortOrder: category.sortOrder,
            ),
          );
        }
      }

      if (updates.isNotEmpty) {
        await _adminRepository.upsertCategories(updates);
      }

      await loadAdminData();
      return updates.length;
    } catch (error) {
      _errorMessage = error.toString();
      return 0;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.deleteCategory(categoryId);
      await loadAdminData();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.deleteProduct(productId);
      await loadAdminData();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.updateOrderStatus(orderId, status);
      await loadAdminData();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<String?> uploadBannerImage(XFile file) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _adminRepository.uploadBannerImage(file);
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveHomeBanner(HomeBannerModel banner) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.saveHomeBanner(banner);
      await loadAdminData();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteHomeBanner(String bannerId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _adminRepository.deleteHomeBanner(bannerId);
      await loadAdminData();
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<OrderExportResult?> exportOrders() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _orderExportService.exportOrders(_orders);
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<OrderInvoiceResult?> exportInvoice(OrderModel order) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _orderInvoiceService.saveInvoice(order);
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}

extension on AdminProvider {
  Future<List<String>> _resolveCategoryAssetPaths() async {
    final discovered = <String>{};

    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      for (final asset in manifest.listAssets()) {
        if (asset.startsWith('assets/images/categories/')) {
          discovered.add(asset);
        }
      }
    } catch (_) {
      // Fallback to legacy manifest format below.
    }

    if (discovered.isEmpty) {
      try {
        final manifest = await rootBundle.loadString('AssetManifest.json');
        final decoded = jsonDecode(manifest);
        if (decoded is Map<String, dynamic>) {
          for (final key in decoded.keys) {
            if (key.startsWith('assets/images/categories/')) {
              discovered.add(key);
            }
          }
        }
      } catch (_) {
        // Keep fallback path probing below.
      }
    }

    if (discovered.isEmpty) {
      const expected = <String>[
        'assets/images/categories/dogs.png',
        'assets/images/categories/cats.png',
        'assets/images/categories/dogs_clothing_accessories.png',
        'assets/images/categories/dogs_harness_bodybelts.png',
        'assets/images/categories/dogs_collars_leashes_chains.png',
        'assets/images/categories/dogs_beds_mats.png',
        'assets/images/categories/dogs_feeding_bowls.png',
        'assets/images/categories/dogs_cages_houses.png',
        'assets/images/categories/dogs_bones_munchies.png',
        'assets/images/categories/dogs_toys.png',
        'assets/images/categories/dogs_food_all.png',
        'assets/images/categories/dogs_dry_food.png',
        'assets/images/categories/dogs_wet_food.png',
        'assets/images/categories/dogs_treats_biscuits.png',
        'assets/images/categories/dogs_gravy_jelly.png',
        'assets/images/categories/dogs_supplements.png',
        'assets/images/categories/dogs_shampoos_dry_bath.png',
        'assets/images/categories/dogs_combs_brushes.png',
        'assets/images/categories/cats_beds_mats.png',
        'assets/images/categories/cats_feeding_bowls.png',
        'assets/images/categories/cats_cages_houses.png',
        'assets/images/categories/cats_toys.png',
        'assets/images/categories/cats_food_all.png',
        'assets/images/categories/cats_treats_biscuits.png',
        'assets/images/categories/cats_gravy_jelly.png',
        'assets/images/categories/cats_supplements.png',
        'assets/images/categories/cats_shampoos_dry_bath.png',
        'assets/images/categories/cats_combs_brushes.png',
      ];
      for (final path in expected) {
        try {
          await rootBundle.load(path);
          discovered.add(path);
        } catch (_) {
          // Ignore missing expected asset.
        }
      }
    }

    final list = discovered.toList()..sort();
    return list;
  }

  String _normalizeKey(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  List<String> _categoryImageCandidates(CategoryModel category) {
    final normalizedTitle = _normalizeKey(category.title);
    final parentKey = _normalizeKey(category.parentId ?? '');
    final idKey = _normalizeKey(category.id);

    final keys = <String>{
      idKey,
      normalizedTitle,
      '${parentKey}_$normalizedTitle',
      '${parentKey}_$idKey',
    };

    if (idKey.startsWith('dogs_')) {
      final dogVariant = idKey.replaceFirst('dogs_', 'dog_');
      keys.add(dogVariant);
      if (dogVariant.contains('food_all')) {
        keys.add(dogVariant.replaceAll('food_all', 'dogfood'));
      }
    }
    if (idKey.startsWith('cats_')) {
      final catVariant = idKey.replaceFirst('cats_', 'cat_');
      keys.add(catVariant);
      if (catVariant.contains('food_all')) {
        keys.add(catVariant.replaceAll('food_all', 'catfood'));
      }
    }
    if (idKey.contains('food_all')) {
      keys.add(idKey.replaceAll('food_all', 'dogfood'));
      keys.add(idKey.replaceAll('food_all', 'catfood'));
      keys.add(idKey.replaceAll('food_all', 'food'));
    }

    return keys.where((element) => element.trim().isNotEmpty).toList();
  }
}

class _SeedCategory {
  const _SeedCategory({
    required this.id,
    required this.title,
    required this.sortOrder,
    this.parentId,
  });

  final String id;
  final String title;
  final String? parentId;
  final int sortOrder;
}
