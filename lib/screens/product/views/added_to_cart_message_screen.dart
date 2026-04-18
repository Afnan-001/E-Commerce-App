import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';

class AddedToCartMessageScreen extends StatefulWidget {
  const AddedToCartMessageScreen({super.key});

  @override
  State<AddedToCartMessageScreen> createState() =>
      _AddedToCartMessageScreenState();
}

class _AddedToCartMessageScreenState extends State<AddedToCartMessageScreen> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted || !Navigator.of(context).canPop()) return;
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding,
          defaultPadding,
          defaultPadding * 1.25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
              ),
            ),
            const SizedBox(height: defaultPadding),
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: primaryColor,
                size: 42,
              ),
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Added to cart',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              'Your item is ready in the cart. This message will close automatically.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: defaultPadding,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious),
                ),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You can keep browsing or open the cart now.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: defaultPadding),
            OutlinedButton(
              onPressed: () {
                _dismissTimer?.cancel();
                Navigator.of(context).pop();
              },
              child: const Text('Continue shopping'),
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: () {
                _dismissTimer?.cancel();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, cartScreenRoute);
              },
              child: const Text('Open cart'),
            ),
          ],
        ),
      ),
    );
  }
}
