const String fallbackRazorpayKeyId = 'rzp_test_SbNb9Ak1AfEHen';

const String razorpayKeyId = String.fromEnvironment(
  'RAZORPAY_KEY_ID',
  defaultValue: fallbackRazorpayKeyId,
);

String get razorpayBackendBaseUrl {
  final configuredUrl = String.fromEnvironment(
    'RAZORPAY_BACKEND_BASE_URL',
    defaultValue: '',
  ).trim();
  if (configuredUrl.isNotEmpty) {
    return configuredUrl;
  }

  return 'https://petstore-razorpay-backend.onrender.com';
}

const String razorpayCurrency = String.fromEnvironment(
  'RAZORPAY_CURRENCY',
  defaultValue: 'INR',
);

const String checkoutMerchantName = String.fromEnvironment(
  'CHECKOUT_MERCHANT_NAME',
  defaultValue: 'Store Checkout',
);

const String checkoutDescription = String.fromEnvironment(
  'CHECKOUT_DESCRIPTION',
  defaultValue: 'Order payment',
);

bool get isRazorpayConfigured => razorpayBackendBaseUrl.trim().isNotEmpty;

String get razorpayOrderCreationUrl => _resolveBackendPath('/create-order');

String get razorpayPaymentVerificationUrl =>
    _resolveBackendPath('/verify-payment');

String get codOrderCreationUrl => _resolveBackendPath('/orders');

String _resolveBackendPath(String path) {
  final baseUrl = razorpayBackendBaseUrl.trim();
  if (baseUrl.isEmpty) {
    return '';
  }

  final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  return '$normalizedBaseUrl$path';
}
