import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/providers/auth_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/auth/views/components/auth_feedback.dart';
import 'package:shop/screens/auth/views/components/auth_shell.dart';
import 'package:shop/screens/auth/views/components/login_form.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key, this.message});

  final String? message;

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return AuthShell(
      eyebrow: 'PETSWORLD ADMIN',
      title: 'Admin sign in',
      subtitle:
          'Use an email/password account whose Firestore user role is admin.',
      footer: Center(
        child: TextButton(
          onPressed: authProvider.isLoading
              ? null
              : () => Navigator.pushNamed(context, passwordRecoveryScreenRoute),
          child: const Text('Reset admin password'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((widget.message ?? '').trim().isNotEmpty) ...[
            _AdminNotice(message: widget.message!.trim()),
            const SizedBox(height: 18),
          ],
          _AdminNotice(
            message:
                'Only accounts with role "admin" in the users collection can continue.',
            icon: Icons.admin_panel_settings_outlined,
          ),
          const SizedBox(height: 20),
          LogInForm(
            formKey: _formKey,
            emailController: _emailController,
            passwordController: _passwordController,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1E242B),
                borderRadius: BorderRadius.circular(22),
              ),
              child: ElevatedButton.icon(
                onPressed: authProvider.isLoading ? null : _signIn,
                icon: authProvider.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded, color: Colors.white),
                label: Text(
                  authProvider.isLoading ? 'Checking...' : 'Log in as admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Admin access is enforced again by Firestore security rules on every protected read and write.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    final success = await auth.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      await showAuthErrorDialog(
        context,
        message: auth.errorMessage ?? 'Unable to log in.',
      );
      auth.clearError();
      return;
    }

    if (!auth.isAdmin) {
      await auth.signOut();
      if (!mounted) return;
      await showAuthErrorDialog(
        context,
        message: 'This account is not an admin account.',
      );
      return;
    }

    navigator.pushNamedAndRemoveUntil(
      adminDashboardScreenRoute,
      (route) => false,
    );
  }
}

class _AdminNotice extends StatelessWidget {
  const _AdminNotice({
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202733) : const Color(0xFFF6F6F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A333F) : const Color(0xFFE7E7E1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB88917)),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
