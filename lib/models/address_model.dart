import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine1,
    this.addressLine2,
    required this.district,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
    required this.label,
    this.isDefault = false,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final String addressLine1;
  final String? addressLine2;
  final String district;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;
  final String label;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get shortAddress => '$addressLine1, $city, $state - $pincode';

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2?.trim().isNotEmpty == true) addressLine2!.trim(),
      if (district.trim().isNotEmpty) district.trim(),
      city,
      state,
      pincode,
      if (landmark?.trim().isNotEmpty == true) 'Landmark: ${landmark!.trim()}',
    ];

    return parts.join(', ');
  }

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? district,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    String? label,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      district: district ?? this.district,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AddressModel.fromMap(String id, Map<String, dynamic> data) {
    final city = data['city'] as String? ?? '';
    final district = data['district'] as String? ?? city;

    return AddressModel(
      id: id,
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      addressLine1: data['addressLine1'] as String? ?? '',
      addressLine2: data['addressLine2'] as String?,
      district: district,
      city: city,
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      landmark: data['landmark'] as String?,
      label: data['label'] as String? ?? 'Home',
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'district': district,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'label': label,
      'isDefault': isDefault,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
