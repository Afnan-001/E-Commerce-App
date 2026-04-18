import 'package:flutter/material.dart';

import '../../../../constants.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AutofillGroup(
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            _FieldLabel(title: 'Full name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: _buildDecoration(
                theme,
                hintText: 'Your full name',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel(title: 'Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.emailController,
              validator: emaildValidator.call,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [
                AutofillHints.username,
                AutofillHints.email,
              ],
              decoration: _buildDecoration(
                theme,
                hintText: 'name@example.com',
                icon: Icons.alternate_email_rounded,
              ),
            ),
            const SizedBox(height: 16),
            _FieldLabel(title: 'Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.passwordController,
              validator: passwordValidator.call,
              obscureText: _obscurePassword,
              autofillHints: const [AutofillHints.newPassword],
              decoration: _buildDecoration(
                theme,
                hintText: 'Create a secure password',
                icon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildDecoration(
    ThemeData theme, {
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF2B3445)
        : const Color(0xFFD9D0C2);

    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: isDark ? const Color(0xFF101722) : const Color(0xFFFFFCF7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFB88917)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFFF6C667) : const Color(0xFF18392F),
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
