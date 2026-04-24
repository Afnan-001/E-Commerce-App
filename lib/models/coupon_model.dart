import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum CouponDiscountType { flatAmount, percentage }

@immutable
class CouponModel {
  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.applicableCategoryIds = const <String>[],
    this.applicableProductIds = const <String>[],
    this.minCartValue = 0,
    this.expiryDate,
    this.usageLimit,
    this.usageCount = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String code;
  final CouponDiscountType discountType;
  final double discountValue;
  final List<String> applicableCategoryIds;
  final List<String> applicableProductIds;
  final double minCartValue;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get appliesToAll =>
      applicableCategoryIds.isEmpty && applicableProductIds.isEmpty;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool get hasReachedUsageLimit =>
      usageLimit != null && usageCount >= usageLimit!;

  CouponModel copyWith({
    String? id,
    String? code,
    CouponDiscountType? discountType,
    double? discountValue,
    List<String>? applicableCategoryIds,
    List<String>? applicableProductIds,
    double? minCartValue,
    DateTime? expiryDate,
    int? usageLimit,
    int? usageCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      applicableCategoryIds:
          applicableCategoryIds ?? this.applicableCategoryIds,
      applicableProductIds: applicableProductIds ?? this.applicableProductIds,
      minCartValue: minCartValue ?? this.minCartValue,
      expiryDate: expiryDate ?? this.expiryDate,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CouponModel.fromMap(String id, Map<String, dynamic> data) {
    return CouponModel(
      id: id,
      code: (data['code'] as String? ?? '').trim().toUpperCase(),
      discountType: _discountTypeFromString(data['discountType'] as String?),
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0,
      applicableCategoryIds:
          ((data['applicableCategoryIds'] as List?) ?? const <dynamic>[])
              .whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
      applicableProductIds:
          ((data['applicableProductIds'] as List?) ?? const <dynamic>[])
              .whereType<String>()
              .map((item) => item.trim())
              .where((item) => item.isNotEmpty)
              .toList(),
      minCartValue: (data['minCartValue'] as num?)?.toDouble() ?? 0,
      expiryDate: _dateTimeFromValue(data['expiryDate']),
      usageLimit: data['usageLimit'] as int?,
      usageCount: data['usageCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: _dateTimeFromValue(data['createdAt']),
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code.trim().toUpperCase(),
      'discountType': discountType.name,
      'discountValue': discountValue,
      'applicableCategoryIds': applicableCategoryIds,
      'applicableProductIds': applicableProductIds,
      'minCartValue': minCartValue,
      'expiryDate': expiryDate == null ? null : Timestamp.fromDate(expiryDate!),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'isActive': isActive,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static CouponDiscountType _discountTypeFromString(String? value) {
    return CouponDiscountType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CouponDiscountType.flatAmount,
    );
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
