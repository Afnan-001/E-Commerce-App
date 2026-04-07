import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/providers/product_provider.dart';

import '../../../../constants.dart';
import 'categories.dart';
import 'offers_carousel.dart';

class OffersCarouselAndCategories extends StatelessWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().discoverCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OffersCarousel(),
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            defaultPadding,
            defaultPadding / 2,
            defaultPadding,
            defaultPadding / 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop by category',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Explore the catalog the way customers actually browse it.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        if (categories.isEmpty)
          const SectionEmptyState(
            title: 'No categories added yet',
            message:
                'Admin categories will automatically appear here and in the discover screen.',
          )
        else
          const Categories(),
      ],
    );
  }
}
