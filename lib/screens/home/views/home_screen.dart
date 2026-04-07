import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

import 'components/offer_carousel_and_categories.dart';
import 'components/popular_products.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: OffersCarouselAndCategories()),
            const SliverToBoxAdapter(child: PopularProducts()),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}
