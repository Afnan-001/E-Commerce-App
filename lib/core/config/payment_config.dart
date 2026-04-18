const String razorpayKeyId = String.fromEnvironment(
  'RAZORPAY_KEY_ID',
  defaultValue: '',
);

const String razorpayKeySecret = String.fromEnvironment(
  'RAZORPAY_KEY_SECRET',
  defaultValue: '',
);

/// Replace this placeholder with a secure backend endpoint that creates
/// Razorpay orders using the secret key server-side.
const String razorpayOrderCreationUrl = String.fromEnvironment(
  'RAZORPAY_ORDER_CREATION_URL',
  defaultValue: '',
);

const String razorpayCurrency = 'INR';

bool get isRazorpayConfigured =>
    razorpayKeyId.trim().isNotEmpty && razorpayOrderCreationUrl.trim().isNotEmpty;
