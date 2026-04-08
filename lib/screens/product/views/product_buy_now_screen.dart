import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/screens/product/views/added_to_cart_message_screen.dart';
import 'package:shop/screens/product/views/components/product_list_tile.dart';
import 'package:shop/screens/product/views/location_permission_store_availability_screen.dart';

import '../../../constants.dart';
import 'components/product_quantity.dart';
import 'components/unit_price.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  State<ProductBuyNowScreen> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  int _quantity = 1;

  double get _unitPrice => widget.product.salePrice ?? widget.product.price;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final totalPrice = _unitPrice * _quantity;
    final isBookmarked = context.watch<ProductProvider>().isBookmarked(product.id);

    return Scaffold(
      bottomNavigationBar: CartButton(
        price: totalPrice,
        title: "Add to cart",
        subTitle: "Total price",
        press: () async {
          final messenger = ScaffoldMessenger.of(context);
          final cartProvider = context.read<CartProvider>();
          final success =
              await cartProvider.addToCart(product, quantity: _quantity);
          if (!context.mounted) return;
          if (!success) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  cartProvider.errorMessage ??
                      'Unable to save this cart item to Firestore.',
                ),
              ),
            );
            return;
          }
          if (!context.mounted) return;
          customModalBottomSheet(
            context,
            isDismissible: false,
            child: const AddedToCartMessageScreen(),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding / 2,
              vertical: defaultPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Expanded(
                  child: Text(
                    product.title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final productProvider = context.read<ProductProvider>();
                    final success =
                        await productProvider.toggleBookmark(product);
                    if (!context.mounted || success) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          productProvider.errorMessage ??
                              'Unable to save this product right now.',
                        ),
                      ),
                    );
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
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: defaultPadding),
                    child: AspectRatio(
                      aspectRatio: 1.05,
                      child: NetworkImageWithLoader(product.imageUrl),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: UnitPrice(
                            price: product.price,
                            priceAfterDiscount: product.salePrice,
                          ),
                        ),
                        ProductQuantity(
                          numOfItem: _quantity,
                          onIncrement: () {
                            setState(() {
                              _quantity += 1;
                            });
                          },
                          onDecrement: () {
                            if (_quantity == 1) return;
                            setState(() {
                              _quantity -= 1;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider()),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.categoryName.isEmpty
                              ? "Product summary"
                              : product.categoryName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          product.description.isEmpty
                              ? "Add a detailed product description in Firebase to explain ingredients, pet suitability, or grooming usage."
                              : product.description,
                        ),
                        const SizedBox(height: defaultPadding),
                        Text(
                          "Store pickup availability",
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        const Text(
                          "Use this flow later for local pickup, same-day grooming add-ons, or branch-wise stock availability.",
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTile(
                    title: "Check stores",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorder: true,
                    press: () {
                      customModalBottomSheet(
                        context,
                        height: MediaQuery.of(context).size.height * 0.92,
                        child:
                            const LocationPermissonStoreAvailabilityScreen(),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: defaultPadding),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
