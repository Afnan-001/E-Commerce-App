import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';
import 'package:shop/core/widgets/info_bottom_sheet.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/product/views/product_returns_screen.dart';

import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import 'product_buy_now_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const FeaturePlaceholderScreen(
        title: "Product unavailable",
        description:
            "This product could not be loaded. Refresh the catalog after Firebase data is connected.",
      );
    }

    final currentProduct = product!;
    final isProductAvailable =
        currentProduct.isActive && currentProduct.stockQuantity > 0;
    final relatedProducts = context
        .watch<ProductProvider>()
        .popularProducts
        .where((item) => item.id != currentProduct.id)
        .take(4)
        .toList();
    final productImages = currentProduct.imageUrl.isEmpty
        ? const <String>['']
        : <String>[currentProduct.imageUrl];
    final displayPrice = currentProduct.salePrice ?? currentProduct.price;
    final isBookmarked =
        context.watch<ProductProvider>().isBookmarked(currentProduct.id);

    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: displayPrice,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: ProductBuyNowScreen(product: currentProduct),
                );
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {
                    context.read<ProductProvider>().toggleBookmark(currentProduct);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/Bookmark.svg",
                    colorFilter: ColorFilter.mode(
                      isBookmarked
                          ? primaryColor
                          : Theme.of(context).textTheme.bodyLarge!.color!,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            ProductImages(images: productImages),
            ProductInfo(
              brand: currentProduct.brandName.isEmpty
                  ? currentProduct.categoryName
                  : currentProduct.brandName,
              title: currentProduct.title,
              isAvailable: isProductAvailable,
              description: currentProduct.description.isEmpty
                  ? "Product details will appear here once the item description is added in Firebase."
                  : currentProduct.description,
            ),
            ProductListTile(
              svgSrc: "assets/icons/Product.svg",
              title: "Care details",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.78,
                  child: InfoBottomSheet(
                    title: "Care details",
                    sections: [
                      InfoSection(
                        heading: "Best for",
                        body:
                            currentProduct.categoryName.isEmpty
                                ? "Ideal for your pet care catalog."
                                : "Built for the ${currentProduct.categoryName.toLowerCase()} section of your store.",
                      ),
                      InfoSection(
                        heading: "Product notes",
                        body: currentProduct.description.isEmpty
                            ? "Add a richer description in Firestore to show grooming directions, ingredients, or usage details."
                            : currentProduct.description,
                      ),
                      const InfoSection(
                        heading: "Need expert help?",
                        body:
                            "Use this section for pet-safe usage guidance, grooming suitability, and breed-specific recommendations.",
                      ),
                    ],
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Delivery information",
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.72,
                  child: const InfoBottomSheet(
                    title: "Delivery information",
                    sections: [
                      InfoSection(
                        heading: "Standard delivery",
                        body:
                            "Orders are usually packed within 24 hours and delivered in 2 to 5 business days depending on your location.",
                      ),
                      InfoSection(
                        heading: "Store pickup",
                        body:
                            "Pickup can be offered for stocked pet products or bundled with nearby grooming service slots.",
                      ),
                      InfoSection(
                        heading: "Before checkout",
                        body:
                            "Use this area later for shipping eligibility, grooming appointment notes, and delivery cut-off details.",
                      ),
                    ],
                  ),
                );
              },
            ),
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Care policy",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),
            if (relatedProducts.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.all(defaultPadding),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "You may also need",
                    style: Theme.of(context).textTheme.titleSmall!,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: relatedProducts.length,
                    itemBuilder: (context, index) => Padding(
                      padding: EdgeInsets.only(
                        left: defaultPadding,
                        right:
                            index == relatedProducts.length - 1 ? defaultPadding : 0,
                      ),
                      child: ProductCard(
                        image: relatedProducts[index].image,
                        title: relatedProducts[index].title,
                        brandName: relatedProducts[index].brandName,
                        price: relatedProducts[index].price,
                        priceAfetDiscount:
                            relatedProducts[index].priceAfetDiscount,
                        dicountpercent: relatedProducts[index].dicountpercent,
                        press: () {
                          Navigator.pushReplacementNamed(
                            context,
                            productDetailsScreenRoute,
                            arguments: relatedProducts[index],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            ),
          ],
        ),
      ),
    );
  }
}
