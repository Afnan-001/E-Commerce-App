class PaymentSettingsModel {
  const PaymentSettingsModel({
    this.isOnlinePaymentEnabled = true,
    this.keyId = '',
    this.backendBaseUrl = '',
    this.currency = 'INR',
    this.merchantName = 'Store Checkout',
    this.checkoutDescription = 'Order payment',
  });

  final bool isOnlinePaymentEnabled;
  final String keyId;
  final String backendBaseUrl;
  final String currency;
  final String merchantName;
  final String checkoutDescription;

  factory PaymentSettingsModel.fromMap(Map<String, dynamic> data) {
    return PaymentSettingsModel(
      isOnlinePaymentEnabled:
          data['isOnlinePaymentEnabled'] as bool? ??
          data['onlinePaymentEnabled'] as bool? ??
          true,
      keyId: (data['keyId'] as String? ?? data['razorpayKeyId'] as String? ?? '')
          .trim(),
      backendBaseUrl:
          (data['backendBaseUrl'] as String? ??
                  data['razorpayBackendBaseUrl'] as String? ??
                  '')
              .trim(),
      currency: (data['currency'] as String? ?? 'INR').trim(),
      merchantName:
          (data['merchantName'] as String? ?? 'Store Checkout').trim(),
      checkoutDescription:
          (data['checkoutDescription'] as String? ?? 'Order payment').trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'isOnlinePaymentEnabled': isOnlinePaymentEnabled,
      'keyId': keyId.trim(),
      'backendBaseUrl': backendBaseUrl.trim(),
      'currency': currency.trim(),
      'merchantName': merchantName.trim(),
      'checkoutDescription': checkoutDescription.trim(),
    };
  }

  PaymentSettingsModel copyWith({
    bool? isOnlinePaymentEnabled,
    String? keyId,
    String? backendBaseUrl,
    String? currency,
    String? merchantName,
    String? checkoutDescription,
  }) {
    return PaymentSettingsModel(
      isOnlinePaymentEnabled:
          isOnlinePaymentEnabled ?? this.isOnlinePaymentEnabled,
      keyId: keyId ?? this.keyId,
      backendBaseUrl: backendBaseUrl ?? this.backendBaseUrl,
      currency: currency ?? this.currency,
      merchantName: merchantName ?? this.merchantName,
      checkoutDescription: checkoutDescription ?? this.checkoutDescription,
    );
  }

  PaymentSettingsModel mergeWith(PaymentSettingsModel fallback) {
    return PaymentSettingsModel(
      isOnlinePaymentEnabled: isOnlinePaymentEnabled,
      keyId: keyId.trim().isNotEmpty ? keyId.trim() : fallback.keyId.trim(),
      backendBaseUrl: backendBaseUrl.trim().isNotEmpty
          ? backendBaseUrl.trim()
          : fallback.backendBaseUrl.trim(),
      currency: currency.trim().isNotEmpty
          ? currency.trim().toUpperCase()
          : fallback.currency.trim().toUpperCase(),
      merchantName: merchantName.trim().isNotEmpty
          ? merchantName.trim()
          : fallback.merchantName.trim(),
      checkoutDescription: checkoutDescription.trim().isNotEmpty
          ? checkoutDescription.trim()
          : fallback.checkoutDescription.trim(),
    );
  }

  bool get isOnlinePaymentAvailable =>
      isOnlinePaymentEnabled && hasBackendBaseUrl && hasPublicKey;
  bool get hasBackendBaseUrl => backendBaseUrl.trim().isNotEmpty;
  bool get hasPublicKey => keyId.trim().isNotEmpty;
}
