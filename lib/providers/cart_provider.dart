import 'package:flutter/foundation.dart';

import 'package:shop/models/cart_pricing_summary_model.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/coupon_model.dart';
import 'package:shop/models/delivery_settings_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/product_option_model.dart';
import 'package:shop/repositories/coupon_repository.dart';
import 'package:shop/repositories/storefront_repository.dart';
import 'package:shop/repositories/user_data_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required UserDataRepository userDataRepository,
    required CouponRepository couponRepository,
    required StorefrontRepository storefrontRepository,
  }) : _userDataRepository = userDataRepository,
       _couponRepository = couponRepository,
       _storefrontRepository = storefrontRepository;

  final UserDataRepository _userDataRepository;
  final CouponRepository _couponRepository;
  final StorefrontRepository _storefrontRepository;

  final List<CartItemModel> _items = <CartItemModel>[];
  String? _userId;
  bool _isLoading = false;
  bool _isApplyingCoupon = false;
  String? _errorMessage;
  String? _couponMessage;
  CouponModel? _appliedCoupon;
  DeliverySettingsModel _deliverySettings = const DeliverySettingsModel();

  List<CartItemModel> get items => List<CartItemModel>.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isApplyingCoupon => _isApplyingCoupon;
  String? get errorMessage => _errorMessage;
  String? get couponMessage => _couponMessage;
  CouponModel? get appliedCoupon => _appliedCoupon;
  DeliverySettingsModel get deliverySettings => _deliverySettings;

  int get totalItems =>
      _items.fold<int>(0, (total, item) => total + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (total, item) => total + item.totalPrice);

  double get originalSubtotal => _items.fold<double>(
    0,
    (total, item) =>
        total + ((item.originalUnitPrice ?? item.unitPrice) * item.quantity),
  );

  double get productDiscount =>
      (originalSubtotal - subtotal).clamp(0.0, double.infinity).toDouble();

  CartPricingSummaryModel get pricing {
    final couponDiscount = _calculateCouponDiscount(
      coupon: _appliedCoupon,
      subtotalValue: subtotal,
    );
    final deliveryCharge = _items.isEmpty
        ? 0.0
        : subtotal >= _deliverySettings.freeDeliveryThreshold
        ? 0.0
        : _deliverySettings.deliveryFee;
    final total = (subtotal - couponDiscount + deliveryCharge)
        .clamp(0.0, double.infinity)
        .toDouble();
    return CartPricingSummaryModel(
      subtotal: subtotal,
      originalSubtotal: originalSubtotal,
      productDiscount: productDiscount,
      couponDiscount: couponDiscount,
      deliveryCharge: deliveryCharge,
      total: total,
      freeDeliveryThreshold: _deliverySettings.freeDeliveryThreshold,
    );
  }

  Future<void> initialize() async {
    await loadPricingConfig();
  }

  Future<void> loadPricingConfig() async {
    try {
      _deliverySettings = await _storefrontRepository.getDeliverySettings();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> syncForUser(String? userId) async {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _items.clear();
    _appliedCoupon = null;
    _couponMessage = null;
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

  Future<bool> addToCart(
    ProductModel product, {
    required ProductOptionModel? selectedOption,
    int quantity = 1,
  }) async {
    if (_userId == null || _userId!.isEmpty) {
      _errorMessage = 'Please log in to save items to your cart.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    final resolvedOption = selectedOption ?? product.defaultPackOption;
    final optionId = resolvedOption?.id ?? '';
    final optionLabel = resolvedOption?.label ?? '';
    final unitPrice =
        resolvedOption?.effectivePrice ?? product.salePrice ?? product.price;
    final originalUnitPrice = resolvedOption?.price ?? product.price;
    final itemId =
        '${product.id}::${optionId.trim().isEmpty ? 'default' : optionId.trim()}';
    final existingIndex = _items.indexWhere((item) => item.id == itemId);

    if (existingIndex == -1) {
      _items.add(
        CartItemModel(
          product: product,
          selectedOptionId: optionId,
          selectedOptionLabel: optionLabel,
          unitPrice: unitPrice,
          originalUnitPrice: originalUnitPrice,
          quantity: quantity,
        ),
      );
    } else {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    }

    notifyListeners();
    try {
      await _persistCartItem(itemId);
      _refreshCouponState();
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

  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
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
      await _persistCartItem(cartItemId);
      _refreshCouponState();
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

  Future<bool> removeFromCart(String cartItemId) async {
    _errorMessage = null;
    final previousItems = List<CartItemModel>.from(_items);
    _items.removeWhere((item) => item.id == cartItemId);
    notifyListeners();
    try {
      if (_userId != null && _userId!.isNotEmpty) {
        await _userDataRepository.removeCartItem(
          userId: _userId!,
          cartItemId: cartItemId,
        );
      }
      _refreshCouponState();
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
      clearAppliedCoupon(notify: false);
      _refreshCouponState();
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

  Future<void> _persistCartItem(String cartItemId) async {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index == -1) {
      if (_userId != null && _userId!.isNotEmpty) {
        await _userDataRepository.removeCartItem(
          userId: _userId!,
          cartItemId: cartItemId,
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

  Future<bool> applyCoupon(String code) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      _couponMessage = 'Enter a coupon code.';
      notifyListeners();
      return false;
    }

    _isApplyingCoupon = true;
    _couponMessage = null;
    notifyListeners();

    try {
      final coupon = await _couponRepository.getCouponByCode(normalized);
      final validationMessage = _validateCoupon(coupon);
      if (validationMessage != null) {
        _appliedCoupon = null;
        _couponMessage = validationMessage;
        return false;
      }

      _appliedCoupon = coupon;
      _couponMessage = 'Coupon applied successfully.';
      return true;
    } catch (_) {
      _couponMessage = 'Unable to validate this coupon right now.';
      return false;
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  void clearAppliedCoupon({bool notify = true}) {
    _appliedCoupon = null;
    _couponMessage = null;
    if (notify) {
      notifyListeners();
    }
  }

  void markCouponUsed() {
    if (_appliedCoupon == null) return;
    _couponRepository.incrementCouponUsage(_appliedCoupon!.id);
  }

  void _refreshCouponState() {
    if (_appliedCoupon == null) {
      notifyListeners();
      return;
    }

    final validationMessage = _validateCoupon(_appliedCoupon);
    if (validationMessage != null) {
      _appliedCoupon = null;
      _couponMessage = validationMessage;
    }
    notifyListeners();
  }

  String? _validateCoupon(CouponModel? coupon) {
    if (coupon == null) {
      return 'Invalid coupon code.';
    }
    if (!coupon.isActive) {
      return 'This coupon is inactive.';
    }
    if (coupon.isExpired) {
      return 'This coupon has expired.';
    }
    if (coupon.hasReachedUsageLimit) {
      return 'This coupon has reached its usage limit.';
    }
    if (subtotal < coupon.minCartValue) {
      return 'Coupon is valid only on carts above Rs ${coupon.minCartValue.toStringAsFixed(0)}.';
    }

    final applicableAmount = _applicableSubtotalForCoupon(coupon);
    if (applicableAmount <= 0) {
      return 'This coupon is not applicable to the products in your cart.';
    }
    return null;
  }

  double _calculateCouponDiscount({
    required CouponModel? coupon,
    required double subtotalValue,
  }) {
    if (coupon == null) return 0;
    if (_validateCoupon(coupon) != null) return 0;

    final applicableSubtotal = _applicableSubtotalForCoupon(coupon);
    if (applicableSubtotal <= 0) return 0;

    if (coupon.discountType == CouponDiscountType.flatAmount) {
      return coupon.discountValue.clamp(0, applicableSubtotal).toDouble();
    }

    return (applicableSubtotal * (coupon.discountValue / 100))
        .clamp(0, subtotalValue)
        .toDouble();
  }

  double _applicableSubtotalForCoupon(CouponModel coupon) {
    if (coupon.appliesToAll) return subtotal;

    return _items.fold<double>(0, (total, item) {
      final inProductScope = coupon.applicableProductIds.contains(
        item.product.id,
      );
      final inCategoryScope = coupon.applicableCategoryIds.contains(
        item.product.category,
      );
      if (inProductScope || inCategoryScope) {
        return total + item.totalPrice;
      }
      return total;
    });
  }
}
