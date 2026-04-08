import 'package:flutter/foundation.dart';

import 'package:shop/models/address_model.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/repositories/address_repository.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({
    required AddressRepository addressRepository,
    required AuthProvider authProvider,
  })  : _addressRepository = addressRepository,
        _authProvider = authProvider {
    _activeUserId = _authProvider.currentUser?.uid;
    _authProvider.addListener(_onAuthChanged);
    if (_activeUserId != null) {
      loadAddresses();
    }
  }

  final AddressRepository _addressRepository;
  final AuthProvider _authProvider;

  final List<AddressModel> _addresses = <AddressModel>[];
  String? _activeUserId;
  String? _selectedAddressId;
  bool _isLoading = false;
  String? _errorMessage;

  List<AddressModel> get addresses => List<AddressModel>.unmodifiable(_addresses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AddressModel? get selectedAddress {
    if (_selectedAddressId != null) {
      final selected = _addresses.where((item) => item.id == _selectedAddressId);
      if (selected.isNotEmpty) {
        return selected.first;
      }
    }

    final defaults = _addresses.where((item) => item.isDefault);
    if (defaults.isNotEmpty) {
      return defaults.first;
    }

    return _addresses.isEmpty ? null : _addresses.first;
  }

  bool get hasAddress => _addresses.isNotEmpty;

  Future<void> loadAddresses() async {
    final userId = _activeUserId;
    if (userId == null) {
      _addresses.clear();
      _selectedAddressId = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _addressRepository.fetchAddresses(userId);
      _addresses
        ..clear()
        ..addAll(data);
      _sortAddresses();

      if (_selectedAddressId == null && _addresses.isNotEmpty) {
        _selectedAddressId = (_addresses.firstWhere(
          (item) => item.isDefault,
          orElse: () => _addresses.first,
        ))
            .id;
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(AddressModel address) async {
    final userId = _requireUserId();
    _errorMessage = null;
    notifyListeners();

    final shouldBeDefault = _addresses.isEmpty || address.isDefault;

    try {
      final savedAddress = await _addressRepository.addAddress(
        userId,
        address.copyWith(isDefault: shouldBeDefault),
      );

      if (shouldBeDefault) {
        await _addressRepository.setDefaultAddress(userId, savedAddress.id);
      }

      _selectedAddressId = savedAddress.id;
      await loadAddresses();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAddress(AddressModel address) async {
    final userId = _requireUserId();
    _errorMessage = null;
    notifyListeners();

    try {
      await _addressRepository.updateAddress(userId, address);
      if (address.isDefault) {
        await _addressRepository.setDefaultAddress(userId, address.id);
      }
      await loadAddresses();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final userId = _requireUserId();
    _errorMessage = null;
    notifyListeners();

    final addressToDelete = _addresses.where((item) => item.id == addressId);
    final wasDefault = addressToDelete.isNotEmpty && addressToDelete.first.isDefault;

    try {
      await _addressRepository.deleteAddress(userId, addressId);
      await loadAddresses();

      if (wasDefault && _addresses.isNotEmpty) {
        await setDefaultAddress(_addresses.first.id);
      }
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final userId = _requireUserId();
    _errorMessage = null;
    _selectedAddressId = addressId;
    notifyListeners();

    try {
      await _addressRepository.setDefaultAddress(userId, addressId);
      await loadAddresses();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  void selectAddressForCheckout(String addressId) {
    _selectedAddressId = addressId;
    notifyListeners();
  }

  void _onAuthChanged() {
    final nextUserId = _authProvider.currentUser?.uid;
    if (nextUserId == _activeUserId) return;

    _activeUserId = nextUserId;
    _addresses.clear();
    _selectedAddressId = null;
    _errorMessage = null;
    notifyListeners();

    if (nextUserId != null) {
      loadAddresses();
    }
  }

  void _sortAddresses() {
    _addresses.sort((a, b) {
      if (a.isDefault != b.isDefault) {
        return a.isDefault ? -1 : 1;
      }

      final aDate = a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
  }

  String _requireUserId() {
    final userId = _activeUserId;
    if (userId == null) {
      throw StateError('Please sign in to manage addresses.');
    }

    return userId;
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    super.dispose();
  }
}
