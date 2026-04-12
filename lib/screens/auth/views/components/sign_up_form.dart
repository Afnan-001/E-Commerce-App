import 'package:flutter/material.dart';

import '../../../../constants.dart';

class SignUpForm extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
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
              hintText: "Full name",
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: emailController,
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            decoration: _buildDecoration(
              theme,
              hintText: "Email address",
              icon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: defaultPadding),
          TextFormField(
            controller: passwordController,
            validator: passwordValidator.call,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: _buildDecoration(
              theme,
              hintText: "Password",
              icon: Icons.lock_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildDecoration(
    ThemeData theme, {
    required String hintText,
    required IconData icon,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFD9D0C2);

    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFFFFFCF7),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      hintStyle: TextStyle(
        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB88917),
      ),
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
        borderSide: const BorderSide(color: Color(0xFF18392F), width: 1.5),
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
