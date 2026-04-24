import 'package:flutter/foundation.dart';

@immutable
class DeliverySettingsModel {
  const DeliverySettingsModel({
    this.freeDeliveryThreshold = 999,
    this.deliveryFee = 49,
  });

  final double freeDeliveryThreshold;
  final double deliveryFee;

  DeliverySettingsModel copyWith({
    double? freeDeliveryThreshold,
    double? deliveryFee,
  }) {
    return DeliverySettingsModel(
      freeDeliveryThreshold:
          freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      deliveryFee: deliveryFee ?? this.deliveryFee,
    );
  }

  factory DeliverySettingsModel.fromMap(Map<String, dynamic> data) {
    return DeliverySettingsModel(
      freeDeliveryThreshold:
          (data['freeDeliveryThreshold'] as num?)?.toDouble() ?? 999,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 49,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'freeDeliveryThreshold': freeDeliveryThreshold,
      'deliveryFee': deliveryFee,
    };
  }
}
