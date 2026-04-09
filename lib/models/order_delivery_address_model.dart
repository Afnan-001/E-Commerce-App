import 'package:flutter/foundation.dart';

import 'package:shop/models/address_model.dart';

@immutable
class OrderDeliveryAddressModel {
  const OrderDeliveryAddressModel({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    this.landmark,
  });

  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String? landmark;

  String get shortAddress => '$addressLine1, $city, $state - $pincode';

  String get fullAddress {
    final parts = <String>[
      addressLine1,
      if (addressLine2?.trim().isNotEmpty == true) addressLine2!.trim(),
      city,
      state,
      pincode,
      if (landmark?.trim().isNotEmpty == true) 'Landmark: ${landmark!.trim()}',
    ];

    return parts.join(', ');
  }

  factory OrderDeliveryAddressModel.fromAddress(AddressModel address) {
    return OrderDeliveryAddressModel(
      fullName: address.fullName,
      phone: address.phoneNumber,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      city: address.city,
      state: address.state,
      pincode: address.pincode,
      landmark: address.landmark,
    );
  }

  factory OrderDeliveryAddressModel.fromMap(Map<String, dynamic> data) {
    return OrderDeliveryAddressModel(
      fullName: data['fullName'] as String? ?? '',
      phone: data['phone'] as String? ?? data['phoneNumber'] as String? ?? '',
      addressLine1: data['addressLine1'] as String? ?? '',
      addressLine2: data['addressLine2'] as String?,
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      landmark: data['landmark'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
    };
  }
}
