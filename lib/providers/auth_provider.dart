import 'package:flutter/foundation.dart';

import 'package:shop/models/app_user_model.dart';
import 'package:shop/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AppUserModel? _currentUser;
  bool _isLoading = false;

  AppUserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authRepository.getCurrentUser();

    _isLoading = false;
    notifyListeners();
  }

  void setPreviewUser(AppUserModel? user) {
    _currentUser = user;
    notifyListeners();
  }
}
