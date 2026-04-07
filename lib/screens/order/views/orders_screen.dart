import 'package:flutter/material.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Orders',
      description:
          'Order history and status tracking will be connected to Firestore after checkout is implemented.',
    );
  }
}
