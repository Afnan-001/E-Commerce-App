import 'package:flutter/material.dart';

import '../../constants.dart';
import '../network_image_with_loader.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.isSaved = false,
    this.onToggleSaved,
    required this.press,
  });
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final bool isSaved;
  final VoidCallback? onToggleSaved;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.8);
    final iconColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.9);

    return OutlinedButton(
      onPressed: press,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        side: BorderSide(color: Theme.of(context).dividerColor),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(defaultBorderRadious),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NetworkImageWithLoader(
                      image,
                      radius: defaultBorderRadious,
                    ),
                  ),
                  if (onToggleSaved != null)
                    Positioned(
                      left: defaultPadding / 2,
                      top: defaultPadding / 2,
                      child: InkWell(
                        onTap: onToggleSaved,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF262B36).withValues(alpha: 0.96)
                                : Colors.white.withValues(alpha: 0.95),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                          child: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border,
                            size: 17,
                            color: isSaved
                                ? primaryColor
                                : (iconColor ?? blackColor80),
                          ),
                        ),
                      ),
                    ),
                  if (dicountpercent != null)
                    Positioned(
                      right: defaultPadding / 2,
                      top: defaultPadding / 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: defaultPadding / 2,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          color: errorColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(999),
                          ),
                        ),
                        child: Text(
                          "$dicountpercent% off",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName.toUpperCase(),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(
                          fontSize: 10,
                          color: secondaryText,
                          letterSpacing: 0.2,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(fontSize: 13, height: 1.25),
                  ),
                  const Spacer(),
                  priceAfetDiscount != null
                      ? Row(
                          children: [
                            Text(
                              "Rs ${priceAfetDiscount!.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Color(0xFF31B0D8),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: defaultPadding / 4),
                            Text(
                              "Rs ${price.toStringAsFixed(0)}",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Rs ${price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Color(0xFF31B0D8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
