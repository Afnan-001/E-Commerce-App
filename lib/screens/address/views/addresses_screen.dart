import 'package:flutter/material.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Saved Addresses',
      description:
          'Address management will be connected to your customer profile so users can save delivery and pickup details.',
    );
  }
}
