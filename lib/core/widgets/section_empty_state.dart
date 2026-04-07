import 'package:flutter/material.dart';

import 'package:shop/constants.dart';

class SectionEmptyState extends StatelessWidget {
  const SectionEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.pets_rounded,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.06),
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 28,
              ),
              const SizedBox(height: defaultPadding / 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: defaultPadding / 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
