import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/auth/views/components/auth_feedback.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({
    super.key,
    this.isSignUp = false,
    this.prefilledName,
  });

  final bool isSignUp;
  final String? prefilledName;

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _otpFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.prefilledName?.trim() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    try {
      context.read<AuthProvider>().clearPhoneAuthState();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _syncAndOpenApp() async {
    final auth = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();

    final userId = auth.currentUser?.uid;
    await cartProvider.syncForUser(userId);
    await productProvider.syncUserData(userId);
    await orderProvider.syncForUser(userId);

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      entryPointScreenRoute,
      (route) => false,
    );
  }

  String _normalizePhoneNumber(String input) {
    final value = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (value.startsWith('+')) return value;

    final onlyDigits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.length == 10) {
      return '+91$onlyDigits';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final otpRequested = authProvider.isPhoneOtpRequested;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSignUp ? 'Sign up with phone' : 'Sign in with phone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: SizedBox(
          width: double.infinity,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Use your mobile number and OTP to continue.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: defaultPadding),
            if (widget.isSignUp) ...[
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(hintText: 'Full name (optional)'),
              ),
              const SizedBox(height: defaultPadding),
            ],
            Form(
              key: _phoneFormKey,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return 'Phone number is required';
                  if (trimmed.length < 10) {
                    return 'Enter a valid number (example: +919876543210)';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Phone number (example: +919876543210)',
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        final auth = context.read<AuthProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        if (!_phoneFormKey.currentState!.validate()) return;
                        final normalizedPhone = _normalizePhoneNumber(
                          _phoneController.text,
                        );
                        _phoneController.text = normalizedPhone;

                        final success = await auth.requestPhoneOtp(
                          phoneNumber: normalizedPhone,
                        );
                        if (!context.mounted) return;
                        if (!success) {
                          final message =
                              auth.errorMessage ??
                              'Unable to send OTP right now.';
                          await showAuthErrorDialog(context, message: message);
                          auth.clearError();
                          return;
                        }

                        if (!auth.isPhoneOtpRequested) {
                          await _syncAndOpenApp();
                          return;
                        }

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('OTP sent successfully.'),
                          ),
                        );
                      },
                child: Text(authProvider.isLoading ? 'Please wait...' : 'Send OTP'),
              ),
            ),
            if (otpRequested) ...[
              const SizedBox(height: defaultPadding * 1.2),
              Form(
                key: _otpFormKey,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    final code = value?.trim() ?? '';
                    if (code.isEmpty) return 'OTP is required';
                    if (code.length != 6) return 'Enter the 6-digit OTP';
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter 6-digit OTP',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              final auth = context.read<AuthProvider>();
                              if (!_otpFormKey.currentState!.validate()) return;
                              final success = await auth.verifyPhoneOtp(
                                smsCode: _otpController.text,
                                preferredName: _nameController.text,
                              );
                              if (!context.mounted) return;
                              if (!success) {
                                final message =
                                    auth.errorMessage ??
                                    'Unable to verify OTP right now.';
                                await showAuthErrorDialog(
                                  context,
                                  message: message,
                                );
                                auth.clearError();
                                return;
                              }
                              await _syncAndOpenApp();
                            },
                      child: Text(
                        authProvider.isLoading
                            ? 'Verifying...'
                            : 'Verify & continue',
                      ),
                    ),
                  ),
                  const SizedBox(width: defaultPadding / 2),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (!_phoneFormKey.currentState!.validate()) return;
                              final normalizedPhone = _normalizePhoneNumber(
                                _phoneController.text,
                              );
                              _phoneController.text = normalizedPhone;
                              await context.read<AuthProvider>().requestPhoneOtp(
                                phoneNumber: normalizedPhone,
                                isResend: true,
                              );
                            },
                      child: const Text('Resend OTP'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: defaultPadding),
            Text(
              'Note: Phone sign-in works best on a real device.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
