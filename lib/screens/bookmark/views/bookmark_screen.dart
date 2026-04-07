import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/core/widgets/section_empty_state.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

import '../../../constants.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().bookmarkedProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved products"),
      ),
      body: products.isEmpty
          ? const SectionEmptyState(
              title: "No saved products yet",
              message:
                  "Products you bookmark from the pet shop will appear here once wishlist syncing is added.",
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200.0,
                      mainAxisSpacing: defaultPadding,
                      crossAxisSpacing: defaultPadding,
                      childAspectRatio: 0.66,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return ProductCard(
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
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
