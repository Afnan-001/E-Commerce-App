import 'package:flutter/material.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Search',
      description:
          'Search will soon let customers quickly find grooming products, accessories, and pet care essentials.',
    );
  }
}
