import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/search/views/components/search_form.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.searchInCatalog(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: SearchForm(
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _query = (value ?? '').trim();
                  });
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                defaultPadding,
                0,
                defaultPadding,
                defaultPadding,
              ),
              child: Text(
                _query.isEmpty
                    ? 'Type to find products from your catalog.'
                    : '${products.length} item${products.length == 1 ? '' : 's'} found for "$_query".',
              ),
            ),
          ),
          if (_query.isNotEmpty && products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  'No products matched this search. Try another keyword.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                defaultPadding,
                0,
                defaultPadding,
                defaultPadding,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: defaultPadding,
                  crossAxisSpacing: defaultPadding,
                  childAspectRatio: 0.66,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = products[index];
                  return ProductCard(
                    image: product.image,
                    brandName: product.brandName,
                    title: product.title,
                    price: product.price,
                    priceAfetDiscount: product.priceAfetDiscount,
                    dicountpercent: product.dicountpercent,
                    isSaved: productProvider.isBookmarked(product.id),
                    onToggleSaved: () {
                      context.read<ProductProvider>().toggleBookmark(product);
                    },
                    press: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: product,
                      );
                    },
                  );
                }, childCount: products.length),
              ),
            ),
        ],
      ),
    );
  }
}
