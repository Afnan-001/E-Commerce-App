import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/product_provider.dart';

class OffersCarousel extends StatelessWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final featuredCount = productProvider.popularProducts.length;
    final categoryCount = productProvider.discoverCategories.length;
    final catalogCount = productProvider.catalogProducts.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        defaultPadding,
        defaultPadding,
        defaultPadding,
        defaultPadding / 2,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(defaultPadding),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(defaultBorderRadious * 1.5),
          ),
          gradient: LinearGradient(
            colors: [
              Color(0xFFF2E1C8),
              Color(0xFFDCEFE3),
              Color(0xFFF9F5EE),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding / 2,
                vertical: defaultPadding / 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious),
                ),
              ),
              child: const Text(
                'Pet shop + grooming',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Daily care for pets, built around your live catalog',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'Everything on this screen now reflects what you add in Firebase admin, from categories to featured pet products.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
            ),
            const SizedBox(height: defaultPadding),
            Wrap(
              spacing: defaultPadding / 2,
              runSpacing: defaultPadding / 2,
              children: [
                _StatPill(label: 'Featured', value: '$featuredCount'),
                _StatPill(label: 'Categories', value: '$categoryCount'),
                _StatPill(label: 'Catalog', value: '$catalogCount'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 0.75,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: const BorderRadius.all(
          Radius.circular(999),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          children: [
            TextSpan(text: '$value '),
            TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
