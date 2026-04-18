import 'package:flutter/material.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.label,
    required this.imageUrl,
    required this.onTap,
    this.size = 80,
  });

  final String label;
  final String? imageUrl;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmedImageUrl = (imageUrl ?? '').trim();

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: SizedBox(
        width: size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: trimmedImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(14)),
                      child: NetworkImageWithLoader(
                        trimmedImageUrl,
                        radius: 14,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.pets_rounded,
                      color: warningColor,
                      size: 30,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
