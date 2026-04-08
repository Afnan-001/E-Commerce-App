import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/theme_provider.dart';

import 'components/prederence_list_tile.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _orderUpdates = true;
  bool _petReminders = false;
  bool _offers = false;
  bool _community = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("App preferences"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _orderUpdates = true;
                _petReminders = false;
                _offers = false;
                _community = false;
              });
              context.read<ThemeProvider>().setPreference(
                AppThemePreference.device,
              );
            },
            child: const Text("Reset"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: defaultPadding,
          horizontal: defaultPadding,
        ),
        child: Column(
          children: [
            _ThemeModeCard(preference: themeProvider.preference),
            const SizedBox(height: defaultPadding),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  PreferencesListTile(
                    titleText: "Order updates",
                    subtitleTxt:
                        "Control how often you receive order, delivery, and grooming appointment updates inside the app.",
                    isActive: _orderUpdates,
                    press: () => setState(() => _orderUpdates = !_orderUpdates),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  PreferencesListTile(
                    titleText: "Pet care reminders",
                    subtitleTxt:
                        "Enable reminders for grooming schedules, repeat orders, and routine pet care follow-ups.",
                    isActive: _petReminders,
                    press: () => setState(() => _petReminders = !_petReminders),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  PreferencesListTile(
                    titleText: "Offers and promotions",
                    subtitleTxt:
                        "Choose whether to receive offers on pet products, grooming bundles, and seasonal care campaigns.",
                    isActive: _offers,
                    press: () => setState(() => _offers = !_offers),
                  ),
                  Divider(height: 1, color: Theme.of(context).dividerColor),
                  PreferencesListTile(
                    titleText: "Community updates",
                    subtitleTxt:
                        "Stay informed about store announcements, new services, and helpful pet care content from the brand.",
                    isActive: _community,
                    press: () => setState(() => _community = !_community),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({required this.preference});

  final AppThemePreference preference;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Choose how PetsWorld looks across the entire app.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ThemeChoiceChip(
                  label: 'Use device',
                  selected: preference == AppThemePreference.device,
                  onSelected: () {
                    context.read<ThemeProvider>().setPreference(
                      AppThemePreference.device,
                    );
                  },
                ),
                _ThemeChoiceChip(
                  label: 'Light',
                  selected: preference == AppThemePreference.light,
                  onSelected: () {
                    context.read<ThemeProvider>().setPreference(
                      AppThemePreference.light,
                    );
                  },
                ),
                _ThemeChoiceChip(
                  label: 'Dark',
                  selected: preference == AppThemePreference.dark,
                  onSelected: () {
                    context.read<ThemeProvider>().setPreference(
                      AppThemePreference.dark,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChoiceChip extends StatelessWidget {
  const _ThemeChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
