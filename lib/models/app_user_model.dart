import 'package:flutter/foundation.dart';

enum AppUserRole { user, admin }

@immutable
class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phoneNumber,
    this.role = AppUserRole.user,
    this.photoUrl,
    this.createdAt,
  });

  final String uid;
  final String email;
  final String name;
  final String? phoneNumber;
  final AppUserRole role;
  final String? photoUrl;
  final DateTime? createdAt;

  bool get isAdmin => role == AppUserRole.admin;

  factory AppUserModel.fromMap(String uid, Map<String, dynamic> data) {
    final roleValue = data['role'] as String? ?? 'user';
    return AppUserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String?,
      role: roleValue == 'admin' ? AppUserRole.admin : AppUserRole.user,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role.name,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
