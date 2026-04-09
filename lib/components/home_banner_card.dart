import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
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
      fallback: isDark ? const Color(0xFF2A334A) : const Color(0xFFFFF1EB),
    );
    final endColor = _resolveColor(
      banner.endColorHex,
      fallback: isDark ? const Color(0xFF1A2238) : const Color(0xFFFFE4D6),
    );

    final mixedColor = Color.lerp(startColor, endColor, 0.5) ?? startColor;
    final textBrightness = ThemeData.estimateBrightnessForColor(mixedColor);
    final titleColor = textBrightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF24283A);
    final subtitleColor = textBrightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF596073);
    final buttonColor = textBrightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF1E2430);
    final imagePanelColor = textBrightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.72);
    final imagePanelBorderColor = textBrightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.9);

    final title = banner.title.trim().isEmpty ? 'NEW ARRIVALS' : banner.title;
    final highlight = banner.highlightText.trim().isEmpty
        ? 'Everything your pet loves'
        : banner.highlightText;
    final dateText = banner.dateText.trim().isEmpty
        ? 'Fresh picks for meals, playtime, grooming, and daily comfort.'
        : banner.dateText;
    final buttonText = banner.buttonText.trim().isEmpty
        ? 'Shop now'
        : banner.buttonText;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        gradient: LinearGradient(
          colors: <Color>[startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: <Widget>[
          _BannerSideImage(
            source: banner.leftImageUrl,
            fallbackAssetPath: 'assets/images/home/banner_cat.png',
            panelColor: imagePanelColor,
            panelBorderColor: imagePanelBorderColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    title.toUpperCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  highlight,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dateText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onTapShopNow,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '$buttonText ->',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: buttonColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _BannerSideImage(
            source: banner.rightImageUrl,
            fallbackAssetPath: 'assets/images/home/banner_dog.png',
            panelColor: imagePanelColor,
            panelBorderColor: imagePanelBorderColor,
          ),
        ],
      ),
    );
  }

  Color _resolveColor(String? hexValue, {required Color fallback}) {
    final value = (hexValue ?? '').trim();
    if (value.isEmpty) {
      return fallback;
    }

    var hex = value.toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) {
      return fallback;
    }

    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) {
      return fallback;
    }
    return Color(parsed);
  }
}

class _BannerSideImage extends StatelessWidget {
  const _BannerSideImage({
    required this.source,
    required this.fallbackAssetPath,
    required this.panelColor,
    required this.panelBorderColor,
  });

  final String source;
  final String fallbackAssetPath;
  final Color panelColor;
  final Color panelBorderColor;

  @override
  Widget build(BuildContext context) {
    final trimmed = source.trim();
    return Container(
      width: 82,
      height: 130,
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        border: Border.all(color: panelBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(trimmed),
    );
  }

  Widget _buildImage(String sourceValue) {
    if (sourceValue.isEmpty) {
      return Image.asset(
        fallbackAssetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(context),
      );
    }

    if (sourceValue.startsWith('http')) {
      return Image.network(
        sourceValue,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallbackIcon(context),
        ),
      );
    }

    return Image.asset(
      sourceValue,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        fallbackAssetPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(context),
      ),
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return const Center(
      child: Icon(Icons.pets_rounded, size: 34, color: primaryColor),
    );
  }
}
