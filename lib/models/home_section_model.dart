import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:shop/models/coupon_model.dart';

@immutable
class HomeSectionModel {
  const HomeSectionModel({
    required this.id,
    required this.title,
    this.productIds = const <String>[],
    this.sortOrder = 0,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sectionDiscountType,
    this.sectionDiscountValue,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final List<String> productIds;
  final int sortOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final CouponDiscountType? sectionDiscountType;
  final double? sectionDiscountValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasSectionDiscount =>
      sectionDiscountType != null && (sectionDiscountValue ?? 0) > 0;

  bool get isWithinDisplayRange {
    final now = DateTime.now();
    final afterStart = startDate == null || !now.isBefore(startDate!);
    final beforeEnd = endDate == null || !now.isAfter(endDate!);
    return isActive && afterStart && beforeEnd;
  }

  HomeSectionModel copyWith({
    String? id,
    String? title,
    List<String>? productIds,
    int? sortOrder,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    CouponDiscountType? sectionDiscountType,
    double? sectionDiscountValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      productIds: productIds ?? this.productIds,
      sortOrder: sortOrder ?? this.sortOrder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      sectionDiscountType: sectionDiscountType ?? this.sectionDiscountType,
      sectionDiscountValue: sectionDiscountValue ?? this.sectionDiscountValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HomeSectionModel.fromMap(String id, Map<String, dynamic> data) {
    return HomeSectionModel(
      id: id,
      title: (data['title'] as String? ?? '').trim(),
      productIds: ((data['productIds'] as List?) ?? const <dynamic>[])
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      sortOrder: data['sortOrder'] as int? ?? 0,
      startDate: _dateTimeFromValue(data['startDate']),
      endDate: _dateTimeFromValue(data['endDate']),
      isActive: data['isActive'] as bool? ?? true,
      sectionDiscountType: _sectionDiscountTypeFromString(
        data['sectionDiscountType'] as String?,
      ),
      sectionDiscountValue: (data['sectionDiscountValue'] as num?)?.toDouble(),
      createdAt: _dateTimeFromValue(data['createdAt']),
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'productIds': productIds,
      'sortOrder': sortOrder,
      'startDate': startDate == null ? null : Timestamp.fromDate(startDate!),
      'endDate': endDate == null ? null : Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'sectionDiscountType': sectionDiscountType?.name,
      'sectionDiscountValue': sectionDiscountValue,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  static CouponDiscountType? _sectionDiscountTypeFromString(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    return CouponDiscountType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CouponDiscountType.percentage,
    );
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}
