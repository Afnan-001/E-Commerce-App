import 'dart:ui';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0B1220),
                    Color(0xFF111827),
                    Color(0xFF18212F),
                  ]
                : const [
                    Color(0xFFF8F3E8),
                    Color(0xFFF4EDE4),
                    Color(0xFFE8EEF0),
                  ],
          ),
        ),
        child: Stack(
          children: [
            const _AuthBackdrop(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(defaultPadding),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF141B26).withValues(alpha: 0.92)
                                : Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : const Color(0xFFD6CBB8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 40,
                                offset: const Offset(0, 24),
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
                  ),
                ),
              ),
            ),
          ],
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFFF1A208).withValues(alpha: 0.14)
                : const Color(0xFF16302B),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            eyebrow,
            style: TextStyle(
              fontFamily: 'Plus Jakarta',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.6,
              color: isDark ? const Color(0xFFF6C667) : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE6DACA),
                ),
              ),
              child: Image.asset(
                'assets/logo/petsworld_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'PetsWorld',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Plus Jakarta',
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Plus Jakarta',
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withValues(
              alpha: isDark ? 0.94 : 0.9,
            ),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -10,
          child: _GlowOrb(
            size: 180,
            colors: isDark
                ? const [Color(0xFFF1A208), Color(0x00F1A208)]
                : const [Color(0xFFF2D6AE), Color(0x00F2D6AE)],
          ),
        ),
        Positioned(
          top: 120,
          left: -60,
          child: _GlowOrb(
            size: 220,
            colors: isDark
                ? const [Color(0xFF2E6A57), Color(0x002E6A57)]
                : const [Color(0xFFBFD9CE), Color(0x00BFD9CE)],
          ),
        ),
        Positioned(
          bottom: -90,
          right: -40,
          child: _GlowOrb(
            size: 240,
            colors: isDark
                ? const [Color(0xFF6A8DAE), Color(0x006A8DAE)]
                : const [Color(0xFFC7D8E5), Color(0x00C7D8E5)],
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
