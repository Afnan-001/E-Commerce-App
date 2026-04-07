import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/admin_repository.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({
    required AdminRepository adminRepository,
  }) : _adminRepository = adminRepository;

  final AdminRepository _adminRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<ProductModel> _products = const <ProductModel>[];
  List<OrderModel> _orders = const <OrderModel>[];
  List<CategoryModel> _categories = const <CategoryModel>[];

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get products => _products;
  List<OrderModel> get orders => _orders;
  List<CategoryModel> get categories => _categories;

  Future<void> loadAdminData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _adminRepository.getCategories(),
        _adminRepository.getProducts(),
        _adminRepository.getOrders(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
      _orders = results[2] as List<OrderModel>;
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
}
