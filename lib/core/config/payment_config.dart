import 'package:shop/models/payment_settings_model.dart';

const String fallbackRazorpayKeyId = 'rzp_test_SbNb9Ak1AfEHen';
const String fallbackRazorpayBackendBaseUrl =
    'https://petstore-razorpay-backend.onrender.com';

final PaymentSettingsModel _defaultPaymentSettings = PaymentSettingsModel(
  keyId: const String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: fallbackRazorpayKeyId,
  ),
  backendBaseUrl: _configuredBackendBaseUrl,
  currency: const String.fromEnvironment(
    'RAZORPAY_CURRENCY',
    defaultValue: 'INR',
  ),
  merchantName: const String.fromEnvironment(
    'CHECKOUT_MERCHANT_NAME',
    defaultValue: 'Store Checkout',
  ),
  checkoutDescription: const String.fromEnvironment(
    'CHECKOUT_DESCRIPTION',
    defaultValue: 'Order payment',
  ),
);

PaymentSettingsModel _runtimePaymentSettings = _defaultPaymentSettings;

const String _configuredBackendBaseUrl = String.fromEnvironment(
  'RAZORPAY_BACKEND_BASE_URL',
  defaultValue: fallbackRazorpayBackendBaseUrl,
);

PaymentSettingsModel get currentPaymentSettings => _runtimePaymentSettings;

void setRuntimePaymentSettings(PaymentSettingsModel? settings) {
  _runtimePaymentSettings = (settings ?? const PaymentSettingsModel())
      .mergeWith(_defaultPaymentSettings);
}

String get razorpayKeyId => currentPaymentSettings.keyId.trim();

String get razorpayBackendBaseUrl => currentPaymentSettings.backendBaseUrl.trim();

String get razorpayCurrency => currentPaymentSettings.currency.trim().toUpperCase();

String get checkoutMerchantName => currentPaymentSettings.merchantName.trim();

String get checkoutDescription =>
    currentPaymentSettings.checkoutDescription.trim();

bool get isRazorpayConfigured => razorpayBackendBaseUrl.trim().isNotEmpty;
bool get isRazorpayPublicKeyConfigured => razorpayKeyId.trim().isNotEmpty;
bool get isOnlinePaymentEnabled =>
    currentPaymentSettings.isOnlinePaymentEnabled;
bool get isOnlinePaymentAvailable =>
    currentPaymentSettings.isOnlinePaymentAvailable;

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
