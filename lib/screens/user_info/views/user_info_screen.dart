import 'package:flutter/material.dart';
import 'package:shop/core/widgets/feature_placeholder_screen.dart';

class UserInfoScreen extends StatelessWidget {
  const UserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderScreen(
      title: 'Profile Details',
      description:
          'Customer profile editing will be connected to Firebase user data and saved account information.',
    );
  }
}
