import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class HomeBannerModel {
  const HomeBannerModel({
    required this.id,
    required this.imageUrl,
    this.title = '',
    this.subtitle = '',
    this.actionCategory,
    this.sortOrder = 0,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? actionCategory;
  final int sortOrder;
  final bool isActive;
  final DateTime? updatedAt;

  bool get hasImage => imageUrl.trim().isNotEmpty;

  HomeBannerModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? subtitle,
    String? actionCategory,
    int? sortOrder,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return HomeBannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      actionCategory: actionCategory ?? this.actionCategory,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HomeBannerModel.fromMap(String id, Map<String, dynamic> data) {
    return HomeBannerModel(
      id: id,
      imageUrl: data['imageUrl'] as String? ??
          data['bannerImageUrl'] as String? ??
          data['rightImageUrl'] as String? ??
          '',
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ??
          data['highlightText'] as String? ??
          data['dateText'] as String? ??
          '',
      actionCategory: data['actionCategory'] as String?,
      sortOrder: data['sortOrder'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'actionCategory': actionCategory,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'updatedAt': updatedAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _dateTimeFromValue(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
