import 'package:flutter/material.dart';

import '../../../../constants.dart';

class OffersCarousel extends StatelessWidget {
  const OffersCarousel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        defaultPadding,
        defaultPadding,
        defaultPadding,
        defaultPadding / 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop trusted pet care',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Daily essentials, grooming products, and accessories curated for dogs and cats.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: blackColor80,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: defaultPadding),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _TrustCard(
                  title: 'Fast delivery',
                  subtitle: '2-5 days in major cities',
                ),
                SizedBox(width: defaultPadding / 2),
                _TrustCard(
                  title: 'Salon support',
                  subtitle: 'Products selected for grooming care',
                ),
                SizedBox(width: defaultPadding / 2),
                _TrustCard(
                  title: 'Easy checkout',
                  subtitle: 'COD and online payment ready',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: const Icon(
              Icons.pets_rounded,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(height: defaultPadding),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: blackColor80,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}
