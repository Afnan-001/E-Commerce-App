import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shop/models/home_banner_model.dart';

class HomeBannerCard extends StatelessWidget {
  const HomeBannerCard({super.key, required this.banner, this.onTapShopNow});

  final HomeBannerModel banner;
  final VoidCallback? onTapShopNow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final startColor = _resolveColor(
      banner.startColorHex,
      fallback: isDark ? const Color(0xFF0D2137) : const Color(0xFF0A6E5E),
    );
    final endColor = _resolveColor(
      banner.endColorHex,
      fallback: isDark ? const Color(0xFF091828) : const Color(0xFF0D9E82),
    );

    final mixedColor = Color.lerp(startColor, endColor, 0.5) ?? startColor;
    final useLightText =
        ThemeData.estimateBrightnessForColor(mixedColor) == Brightness.dark;

    final titleColor = useLightText ? Colors.white : const Color(0xFF0A1F1A);
    final subtitleColor = useLightText
        ? Colors.white.withValues(alpha: 0.76)
        : const Color(0xFF2D4A42);
    final buttonBg =
        useLightText ? Colors.white : const Color(0xFF003D2E);
    final buttonFg =
        useLightText ? const Color(0xFF0A3D30) : Colors.white;

    final title = banner.title.trim().isEmpty ? 'PetsWorld' : banner.title;
    final highlight = banner.highlightText.trim().isEmpty
        ? 'Everything your pet needs'
        : banner.highlightText;
    final dateText = banner.dateText.trim().isEmpty
        ? 'Fresh arrivals for daily care'
        : banner.dateText;
    final buttonText =
        banner.buttonText.trim().isEmpty ? 'Shop Now' : banner.buttonText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final cardHeight = compact ? 184.0 : 212.0;
        final horizontalPadding = compact ? 18.0 : 22.0;
        final verticalPadding = compact ? 18.0 : 22.0;
        final dogWidth = compact ? 126.0 : 152.0;
        final dogHeight = compact ? 148.0 : 178.0;
        final contentMaxWidth = compact ? 170.0 : 210.0;

        return Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: mixedColor.withValues(alpha: 0.34),
                blurRadius: 34,
                spreadRadius: -4,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: mixedColor.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(32)),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: _MeshOverlay(
                    startColor: startColor,
                    endColor: endColor,
                  ),
                ),
                Positioned(
                  top: -36,
                  right: -24,
                  child: _SoftOrb(
                    size: compact ? 150 : 190,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                Positioned(
                  bottom: -26,
                  left: compact ? 72 : 94,
                  child: _SoftOrb(
                    size: compact ? 88 : 108,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.24),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: compact ? -6 : -2,
                  bottom: compact ? -2 : -4,
                  child: _PetImage(
                    width: dogWidth,
                    height: dogHeight,
                    source: banner.rightImageUrl,
                    fallback: 'assets/images/home/banner_dog.png',
                    alignment: Alignment.bottomRight,
                    scale: compact ? 0.95 : 1.0,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding + dogWidth - (compact ? 36 : 44),
                    verticalPadding,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _BannerContent(
                      title: title,
                      highlight: highlight,
                      dateText: dateText,
                      buttonText: buttonText,
                      titleColor: titleColor,
                      subtitleColor: subtitleColor,
                      buttonBg: buttonBg,
                      buttonFg: buttonFg,
                      onTap: onTapShopNow,
                      compact: compact,
                      maxWidth: contentMaxWidth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _resolveColor(String? hexValue, {required Color fallback}) {
    final value = (hexValue ?? '').trim();
    if (value.isEmpty) return fallback;
    var hex = value.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return fallback;
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) return fallback;
    return Color(parsed);
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({
    required this.title,
    required this.highlight,
    required this.dateText,
    required this.buttonText,
    required this.titleColor,
    required this.subtitleColor,
    required this.buttonBg,
    required this.buttonFg,
    required this.onTap,
    required this.compact,
    required this.maxWidth,
  });

  final String title;
  final String highlight;
  final String dateText;
  final String buttonText;
  final Color titleColor;
  final Color subtitleColor;
  final Color buttonBg;
  final Color buttonFg;
  final VoidCallback? onTap;
  final bool compact;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BrandPill(title: title, titleColor: titleColor),
          SizedBox(height: compact ? 10 : 12),
          Text(
            highlight,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 22 : 28,
              height: 0.96,
              letterSpacing: -0.9,
            ),
          ),
          SizedBox(height: compact ? 8 : 10),
          Text(
            dateText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtitleColor,
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.15,
              height: 1.12,
            ),
          ),
          SizedBox(height: compact ? 14 : 16),
          _CTAButton(
            text: buttonText,
            background: buttonBg,
            foreground: buttonFg,
            onTap: onTap,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.title, required this.titleColor});

  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title.toUpperCase(),
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CTAButton extends StatelessWidget {
  const _CTAButton({
    required this.text,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.compact,
  });

  final String text;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        splashColor: foreground.withValues(alpha: 0.12),
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            boxShadow: [
              BoxShadow(
                color: background.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 14 : 16,
              vertical: compact ? 10 : 11,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    color: foreground,
                    fontSize: compact ? 12.5 : 13.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: compact ? 16 : 18,
                  color: foreground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PetImage extends StatelessWidget {
  const _PetImage({
    required this.width,
    required this.height,
    required this.source,
    required this.fallback,
    required this.alignment,
    required this.scale,
  });

  final double width;
  final double height;
  final String source;
  final String fallback;
  final Alignment alignment;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final src = source.trim();
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: Transform.scale(
          scale: scale,
          alignment: alignment,
          child: _buildImage(src),
        ),
      ),
    );
  }

  Widget _buildImage(String src) {
    final fallbackWidget = Image.asset(
      fallback,
      fit: BoxFit.contain,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => const Center(
        child: Icon(Icons.pets_rounded, size: 32, color: Colors.white),
      ),
    );

    if (src.isEmpty) return fallbackWidget;

    if (src.startsWith('http')) {
      return Image.network(
        src,
        fit: BoxFit.contain,
        alignment: alignment,
        errorBuilder: (context, error, stackTrace) => fallbackWidget,
      );
    }

    return Image.asset(
      src,
      fit: BoxFit.contain,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => fallbackWidget,
    );
  }
}

class _MeshOverlay extends StatelessWidget {
  const _MeshOverlay({required this.startColor, required this.endColor});

  final Color startColor;
  final Color endColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _MeshPainter(startColor, endColor));
  }
}

class _MeshPainter extends CustomPainter {
  _MeshPainter(this.startColor, this.endColor);

  final Color startColor;
  final Color endColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.06),
        Colors.transparent,
        Colors.black.withValues(alpha: 0.08),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);
    canvas.drawRect(rect, paint);

    final glowCenter = Offset(size.width * 0.28, size.height * 0.42);
    const glowRadius = 90.0;
    paint.shader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.09),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromCircle(center: glowCenter, radius: glowRadius),
    );
    canvas.drawCircle(glowCenter, glowRadius, paint);

    paint.shader = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.12),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_MeshPainter oldDelegate) {
    return oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor;
  }
}

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
