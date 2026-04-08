import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class ProductReviewModel {
  const ProductReviewModel({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.userEmail,
    this.createdAt,
    this.updatedAt,
  });

  final String userId;
  final String userName;
  final String? userEmail;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ProductReviewModel.fromMap(Map<String, dynamic> data) {
    return ProductReviewModel(
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Customer',
      userEmail: data['userEmail'] as String?,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      comment: data['comment'] as String? ?? '',
      createdAt: _toDateTime(data['createdAt']),
      updatedAt: _toDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
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
