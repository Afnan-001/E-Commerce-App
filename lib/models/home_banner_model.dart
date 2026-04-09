import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class HomeBannerModel {
  const HomeBannerModel({
    required this.id,
    required this.title,
    required this.highlightText,
    required this.dateText,
    required this.buttonText,
    required this.leftImageUrl,
    required this.rightImageUrl,
    this.startColorHex,
    this.endColorHex,
    this.isActive = true,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String highlightText;
  final String dateText;
  final String buttonText;
  final String leftImageUrl;
  final String rightImageUrl;
  final String? startColorHex;
  final String? endColorHex;
  final bool isActive;
  final DateTime? updatedAt;

  HomeBannerModel copyWith({
    String? id,
    String? title,
    String? highlightText,
    String? dateText,
    String? buttonText,
    String? leftImageUrl,
    String? rightImageUrl,
    String? startColorHex,
    String? endColorHex,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return HomeBannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      highlightText: highlightText ?? this.highlightText,
      dateText: dateText ?? this.dateText,
      buttonText: buttonText ?? this.buttonText,
      leftImageUrl: leftImageUrl ?? this.leftImageUrl,
      rightImageUrl: rightImageUrl ?? this.rightImageUrl,
      startColorHex: startColorHex ?? this.startColorHex,
      endColorHex: endColorHex ?? this.endColorHex,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory HomeBannerModel.fromMap(String id, Map<String, dynamic> data) {
    return HomeBannerModel(
      id: id,
      title: data['title'] as String? ?? 'Pet Winter Offer',
      highlightText: data['highlightText'] as String? ?? '25% OFF',
      dateText: data['dateText'] as String? ?? 'Nov 16 - Dec 22',
      buttonText: data['buttonText'] as String? ?? 'Shop Now',
      leftImageUrl: data['leftImageUrl'] as String? ?? '',
      rightImageUrl: data['rightImageUrl'] as String? ?? '',
      startColorHex: data['startColorHex'] as String?,
      endColorHex: data['endColorHex'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      updatedAt: _dateTimeFromValue(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'highlightText': highlightText,
      'dateText': dateText,
      'buttonText': buttonText,
      'leftImageUrl': leftImageUrl,
      'rightImageUrl': rightImageUrl,
      'startColorHex': startColorHex,
      'endColorHex': endColorHex,
      'isActive': isActive,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static HomeBannerModel defaultBanner() {
    return const HomeBannerModel(
      id: 'home_main',
      title: 'Pet Winter Offer',
      highlightText: '25% OFF',
      dateText: 'Nov 16 - Dec 22',
      buttonText: 'Shop Now',
      leftImageUrl: '',
      rightImageUrl: '',
      startColorHex: null,
      endColorHex: null,
      isActive: true,
    );
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
