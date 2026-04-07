import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

import 'components/prederence_list_tile.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App preferences"),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Reset"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            PreferencesListTile(
              titleText: "Order updates",
              subtitleTxt:
                  "Control how often you receive order, delivery, and grooming appointment updates inside the app.",
              isActive: true,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Pet care reminders",
              subtitleTxt:
                  "Enable reminders for grooming schedules, repeat orders, and routine pet care follow-ups.",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Offers and promotions",
              subtitleTxt:
                  "Choose whether to receive offers on pet products, grooming bundles, and seasonal care campaigns.",
              isActive: false,
              press: () {},
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Community updates",
              subtitleTxt:
                  "Stay informed about store announcements, new services, and helpful pet care content from the brand.",
              isActive: false,
              press: () {},
            ),
          ],
        ),
      ),
    );
  }
}
