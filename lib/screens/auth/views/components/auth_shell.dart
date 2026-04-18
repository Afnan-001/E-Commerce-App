import 'package:flutter/material.dart';

import '../../../../constants.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark
          ? const Color(0xFF11151C)
          : const Color(0xFFF7F7F5),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 380;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 16 : 22,
                  20,
                  isCompact ? 16 : 22,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: EdgeInsets.all(isCompact ? 20 : 24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181D25) : Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(24),
                        ),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF28303B)
                              : const Color(0xFFE6E6E0),
                        ),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Header(
                            eyebrow: eyebrow,
                            title: title,
                            subtitle: subtitle,
                          ),
                          const SizedBox(height: 28),
                          child,
                          if (footer != null) ...[
                            const SizedBox(height: 20),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF202733)
                    : const Color(0xFFF5F5F1),
                borderRadius: const BorderRadius.all(Radius.circular(14)),
              ),
              child: Image.asset(
                'assets/logo/petsworld_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'PetsWorld',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: grandisExtendedFont,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          eyebrow,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? Colors.white60 : const Color(0xFF6B6F76),
            letterSpacing: 1.1,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}
