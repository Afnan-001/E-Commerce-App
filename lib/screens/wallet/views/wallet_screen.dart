import 'package:flutter/material.dart';

import 'package:shop/constants.dart';
import 'package:shop/core/widgets/section_empty_state.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Store credit"),
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: defaultPadding),
          child: SectionEmptyState(
            title: "Store credit will appear here",
            message:
                "Credit activity will be shown after refunds, promotional credit, or wallet support is connected to your pet store flows.",
          ),
        ),
      ),
    );
  }
}
