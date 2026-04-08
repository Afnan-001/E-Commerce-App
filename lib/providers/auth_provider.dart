import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shop/models/app_user_model.dart';
import 'package:shop/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  AppUserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneVerificationId;
  int? _phoneResendToken;
  String? _pendingPhoneNumber;

  AppUserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  String? get errorMessage => _errorMessage;
  bool get isPhoneOtpRequested => _phoneVerificationId != null;
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  Future<void> restoreSession() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (error) {
      _errorMessage = _mapAuthError(error);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signIn(
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.signInWithGoogle();
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestPhoneOtp({
    required String phoneNumber,
    bool isResend = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authRepository.requestPhoneOtp(
        phoneNumber: phoneNumber,
        forceResendingToken: isResend ? _phoneResendToken : null,
      );

      _pendingPhoneNumber = phoneNumber.trim();

      if (result.codeSent) {
        _phoneVerificationId = result.verificationId;
        _phoneResendToken = result.resendToken;
      } else {
        _currentUser = result.user;
        _phoneVerificationId = null;
        _phoneResendToken = null;
      }
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyPhoneOtp({
    required String smsCode,
    String? preferredName,
  }) async {
    if (_phoneVerificationId == null) {
      _errorMessage = 'Please request OTP first.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.verifyPhoneOtp(
        verificationId: _phoneVerificationId!,
        smsCode: smsCode,
        preferredName: preferredName,
      );
      _phoneVerificationId = null;
      _phoneResendToken = null;
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearPhoneAuthState() {
    _phoneVerificationId = null;
    _phoneResendToken = null;
    _pendingPhoneNumber = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordResetEmail(email);
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.updateProfile(
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );
      return true;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _currentUser = null;
      _phoneVerificationId = null;
      _phoneResendToken = null;
      _pendingPhoneNumber = null;
    } catch (error) {
      _errorMessage = _mapAuthError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapAuthError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email or password is incorrect.';
        case 'email-already-in-use':
          return 'This email is already registered. Please log in.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again in a few minutes.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled in Firebase Auth.';
        case 'network-request-failed':
          return 'Network issue. Please check your internet connection.';
        case 'account-exists-with-different-credential':
          return 'This account exists with a different sign-in method.';
        case 'invalid-phone-number':
          return 'Please enter a valid phone number with country code.';
        case 'session-expired':
          return 'OTP expired. Please request a new OTP.';
        case 'invalid-verification-code':
          return 'Invalid OTP. Please enter the correct 6-digit code.';
        case 'invalid-verification-id':
          return 'Verification expired. Please request OTP again.';
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    if (error is PlatformException) {
      if (error.code == 'network_error') {
        return 'Network issue. Please check your internet connection.';
      }
      if (error.code == 'channel-error') {
        return 'Sign-in service is temporarily unavailable. Please try again.';
      }
      return error.message ?? 'Something went wrong. Please try again.';
    }

    if (error is StateError) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
