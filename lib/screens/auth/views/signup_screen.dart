import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/auth/views/components/auth_feedback.dart';
import 'package:shop/screens/auth/views/components/auth_shell.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return AuthShell(
      eyebrow: 'CREATE ACCOUNT',
      title: 'Build a premium home for every pet profile.',
      subtitle:
          'Create your account to save favorites, manage care routines, and unlock seamless checkout across the app.',
      footer: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, logInScreenRoute);
              },
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoStrip(
            icon: Icons.mark_email_read_outlined,
            text:
                'We will send a verification email after sign up before email/password login is enabled.',
          ),
          const SizedBox(height: 20),
          SignUpForm(
            formKey: _formKey,
            nameController: _nameController,
            emailController: _emailController,
            passwordController: _passwordController,
          ),
          const SizedBox(height: 18),
          _buildPrimaryButton(context, authProvider),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or sign up with',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor)),
            ],
          ),
          const SizedBox(height: 14),
          _AuthActionButton(
            label: 'Sign up with Google',
            icon: Icons.language_rounded,
            onPressed: authProvider.isLoading
                ? null
                : () => _signUpWithGoogle(context),
          ),
          const SizedBox(height: 12),
          _AuthActionButton(
            label: 'Sign up with phone OTP',
            icon: Icons.sms_outlined,
            onPressed: authProvider.isLoading
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      phoneAuthScreenRoute,
                      arguments: <String, dynamic>{
                        'isSignUp': true,
                        'prefilledName': _nameController.text.trim(),
                      },
                    );
                  },
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Theme(
                data: theme.copyWith(
                  checkboxTheme: theme.checkboxTheme.copyWith(
                    side: WidgetStateBorderSide.resolveWith(
                      (states) => BorderSide(
                        color: states.contains(WidgetState.selected)
                            ? const Color(0xFF18392F)
                            : theme.dividerColor,
                      ),
                    ),
                  ),
                ),
                child: Checkbox(
                  value: true,
                  onChanged: (_) {},
                  activeColor: const Color(0xFF18392F),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our',
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          text: ' Terms of Service',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFFF6C667)
                                : const Color(0xFF18392F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' and'),
                        TextSpan(
                          recognizer: TapGestureRecognizer()..onTap = () {},
                          text: ' Privacy Policy.',
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFFF6C667)
                                : const Color(0xFF18392F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF18392F), Color(0xFF2A6050), Color(0xFFF1A208)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18392F).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: authProvider.isLoading ? null : () => _signUp(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          child: Text(
            authProvider.isLoading ? 'Please wait...' : 'Create account',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Plus Jakarta',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signUpWithGoogle(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final productProvider = context.read<ProductProvider>();
    final orderProvider = context.read<OrderProvider>();
    final navigator = Navigator.of(context);
    final success = await auth.signInWithGoogle();
    if (!context.mounted) return;
    if (!success) {
      final message = auth.errorMessage ?? 'Unable to sign up with Google.';
      await showAuthErrorDialog(context, message: message);
      auth.clearError();
      return;
    }

    final userId = auth.currentUser?.uid;
    await cartProvider.syncForUser(userId);
    await productProvider.syncUserData(userId);
    await orderProvider.syncForUser(userId);

    if (!context.mounted) return;
    navigator.pushNamedAndRemoveUntil(entryPointScreenRoute, (route) => false);
  }

  Future<void> _signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final success = await auth.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!context.mounted) return;
    if (!success) {
      final message = auth.errorMessage ?? 'Unable to create account.';
      await showAuthErrorDialog(context, message: message);
      auth.clearError();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification email sent to ${_emailController.text.trim()}. Please verify your email, then log in.',
        ),
      ),
    );
    navigator.pushNamedAndRemoveUntil(logInScreenRoute, (route) => false);
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8F2E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE5D8BF),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB88917)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AuthActionButton extends StatelessWidget {
  const _AuthActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final foregroundColor = isDark ? Colors.white : const Color(0xFF18392F);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          side: BorderSide(
            color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFD9D0C2),
          ),
          backgroundColor: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : const Color(0xFFFFFCF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        icon: Icon(icon, color: foregroundColor),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta',
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
      ),
    );
  }
}
