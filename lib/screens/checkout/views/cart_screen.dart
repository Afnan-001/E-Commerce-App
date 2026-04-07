import 'package:flutter/material.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Cart',
      description:
          'The cart flow will be connected to real products, quantities, checkout, COD, and Razorpay in the next build phase.',
    );
  }
}
