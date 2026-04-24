import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: const [
          _PolicySection(title: 'Effective date', body: 'April 21, 2026'),
          _PolicySection(
            title: 'What PetsWorld does',
            body:
                'PetsWorld lets users browse pet products, manage saved items and addresses, place orders, download invoices, and lets admins manage products, banners, and orders.',
          ),
          _PolicySection(
            title: 'Information we collect',
            body:
                'We may collect your name, email address, phone number, account identifiers, addresses, saved products, cart items, orders, payment status details, and product review information.',
          ),
          _PolicySection(
            title: 'How we use it',
            body:
                'We use this information to create accounts, process orders, generate invoices, deliver products, support authentication, save your cart and bookmarks, and help admins operate the store.',
          ),
          _PolicySection(
            title: 'Payments',
            body:
                'Online payments may be processed by third-party services such as Razorpay. Full card details are not stored in the app database.',
          ),
          _PolicySection(
            title: 'Storage and sharing',
            body:
                'Data may be stored in Firebase services and other configured infrastructure used to operate the app. We do not sell personal information. Data is shared only with services needed for authentication, storage, payments, and store operations.',
          ),
          _PolicySection(
            title: 'Account deletion',
            body:
                'Users can delete their account from the Profile screen. This removes the user profile, saved items, cart items, addresses, and associated order records created by the app, subject to any legal retention requirements.',
          ),
          _PolicySection(
            title: 'Contact',
            body:
                'Replace the support contact in docs/privacy_policy.md with your real support email before publishing.',
          ),
          SizedBox(height: defaultPadding),
          Text(
            'Publishing note: host the privacy policy text from docs/privacy_policy.md on a public URL and submit that URL in Google Play Console.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
