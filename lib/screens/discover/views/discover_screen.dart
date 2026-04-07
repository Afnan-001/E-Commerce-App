import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

import 'components/expansion_category.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().discoverCategories;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(defaultPadding),
              child: SearchForm(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // While loading use 👇
            // const Expanded(
            //   child: DiscoverCategoriesSkelton(),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) => ExpansionCategory(
                  svgSrc: categories[index].svgSrc!,
                  title: categories[index].title,
                  subCategory: categories[index].subCategories,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
