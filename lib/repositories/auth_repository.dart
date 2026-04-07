import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:shop/models/app_user_model.dart';

abstract class AuthRepository {
  Future<AppUserModel?> getCurrentUser();
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  });
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<void> signOut();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  bool get _isReady => Firebase.apps.isNotEmpty;

  @override
  Future<AppUserModel?> getCurrentUser() async {
    if (!_isReady) return null;

    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return _loadUserProfile(user);
  }

  @override
  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) async {
    _ensureReady();

    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    return _loadUserProfile(credential.user!);
  }

  @override
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _ensureReady();

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user!;
    await user.updateDisplayName(name.trim());

    final appUser = AppUserModel(
      uid: user.uid,
      email: user.email ?? email.trim(),
      name: name.trim(),
      role: AppUserRole.user,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
    return appUser;
  }

  @override
  Future<void> signOut() async {
    if (!_isReady) return;
    await _firebaseAuth.signOut();
  }

  Future<AppUserModel> _loadUserProfile(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      return AppUserModel.fromMap(user.uid, doc.data()!);
    }

    final fallbackUser = AppUserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? _nameFromEmail(user.email),
      role: AppUserRole.user,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(
          fallbackUser.toMap(),
          SetOptions(merge: true),
        );

    return fallbackUser;
  }

  String _nameFromEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Pet Parent';
    return email.split('@').first;
  }

  void _ensureReady() {
    if (!_isReady) {
      throw StateError(
        'Firebase is not configured yet. Run flutterfire configure and add '
        'the platform config files before using authentication.',
      );
    }
  }
}
