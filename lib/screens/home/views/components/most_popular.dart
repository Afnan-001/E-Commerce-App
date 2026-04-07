import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/secondary_product_card.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/providers/product_provider.dart';

import '../../../../constants.dart';
import '../../../../route/route_constants.dart';

class MostPopular extends StatelessWidget {
  const MostPopular({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().mostPopularProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Most popular",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        if (products.isEmpty)
          const SectionEmptyState(
            title: "No trending products yet",
            message:
                "Popular pet essentials and grooming picks will show up here after catalog sync.",
          )
        else
          SizedBox(
            height: 114,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: defaultPadding,
                  right: index == products.length - 1 ? defaultPadding : 0,
                ),
                child: SecondaryProductCard(
                  image: products[index].image,
                  brandName: products[index].brandName,
                  title: products[index].title,
                  price: products[index].price,
                  priceAfetDiscount: products[index].priceAfetDiscount,
                  dicountpercent: products[index].dicountpercent,
                  press: () {
                    Navigator.pushNamed(
                      context,
                      productDetailsScreenRoute,
                      arguments: products[index],
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
