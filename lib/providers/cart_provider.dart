import 'package:flutter/foundation.dart';

import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/repositories/user_data_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required UserDataRepository userDataRepository,
  }) : _userDataRepository = userDataRepository;

  final UserDataRepository _userDataRepository;

  final List<CartItemModel> _items = <CartItemModel>[];
  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  List<CartItemModel> get items => List<CartItemModel>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalItems =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (total, item) => total + item.totalPrice);

  Future<void> syncForUser(String? userId) async {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _items.clear();
    notifyListeners();

    if (userId == null || userId.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storedItems = await _userDataRepository.getCartItems(userId);
      _items
        ..clear()
        ..addAll(storedItems);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(ProductModel product, {int quantity = 1}) async {
    if (_userId == null || _userId!.isEmpty) {
      _errorMessage = 'Please log in to save cart items to Firestore.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex == -1) {
      _items.add(CartItemModel(product: product, quantity: quantity));
    } else {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    }

    notifyListeners();
    try {
      await _persistProduct(product.id);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _items
        ..clear()
        ..addAll(previousItems);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return false;

    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }

    notifyListeners();
    try {
      await _persistByProductId(productId);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _items
        ..clear()
        ..addAll(previousItems);
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromCart(String productId) async {
    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    try {
      if (_userId != null && _userId!.isNotEmpty) {
        await _userDataRepository.removeCartItem(
          userId: _userId!,
          productId: productId,
        );
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _items
        ..clear()
        ..addAll(previousItems);
      notifyListeners();
      return false;
    }
  }

  Future<bool> clear() async {
    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    _items.clear();
    notifyListeners();
    try {
      if (_userId != null && _userId!.isNotEmpty) {
        await _userDataRepository.clearCart(_userId!);
      }
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      _items
        ..clear()
        ..addAll(previousItems);
      notifyListeners();
      return false;
    }
  }

  Future<void> _persistProduct(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      return;
    }

    if (_userId != null && _userId!.isNotEmpty) {
      await _userDataRepository.upsertCartItem(
        userId: _userId!,
        item: _items[index],
      );
    }
  }

  Future<void> _persistByProductId(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) {
      if (_userId != null && _userId!.isNotEmpty) {
        await _userDataRepository.removeCartItem(
          userId: _userId!,
          productId: productId,
        );
      }
      return;
    }

    if (_userId != null && _userId!.isNotEmpty) {
      await _userDataRepository.upsertCartItem(
        userId: _userId!,
        item: _items[index],
      );
    }
  }
}
