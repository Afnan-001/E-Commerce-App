import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/screen_export.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label will be connected in the next implementation step.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final user = authProvider.currentUser;
    final displayName =
        user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'Pet Parent';
    final email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : 'Connect Firebase Auth to load the customer profile.';
    final subtitle = authProvider.isAuthenticated
        ? 'Manage your pet products, saved items, addresses, and grooming support.'
        : 'Sign in with Firebase to unlock orders, saved products, and checkout details.';

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: defaultPadding),
        children: [
          ProfileCard(
            name: displayName,
            email: email,
            isPro: authProvider.isAdmin,
            proLableText: 'ADMIN',
            press: () {
              Navigator.pushNamed(context, userInfoScreenRoute);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
            child: Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.isAdmin ? 'Admin access enabled' : 'Customer account',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(subtitle),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              children: [
                Expanded(
                  child: _ProfileMetricCard(
                    label: 'Saved',
                    value: productProvider.bookmarkedCount.toString(),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _ProfileMetricCard(
                    label: 'Cart items',
                    value: cartProvider.totalItems.toString(),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: _ProfileMetricCard(
                    label: 'Catalog',
                    value: productProvider.catalogProducts.length.toString(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Shopping',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: 'Orders',
            svgSrc: 'assets/icons/Order.svg',
            press: () {
              Navigator.pushNamed(context, ordersScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: 'Saved products',
            svgSrc: 'assets/icons/Wishlist.svg',
            press: () {
              Navigator.pushNamed(context, bookmarkScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: 'Addresses',
            svgSrc: 'assets/icons/Address.svg',
            press: () {
              Navigator.pushNamed(context, addressesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: 'Cart',
            svgSrc: 'assets/icons/Bag.svg',
            press: () {
              Navigator.pushNamed(context, cartScreenRoute);
            },
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Services',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          DividerListTileWithTrilingText(
            svgSrc: 'assets/icons/Notification.svg',
            title: 'Grooming alerts',
            trilingText: 'Soon',
            press: () => _showComingSoon(context, 'Grooming alerts'),
          ),
          ProfileMenuListTile(
            text: 'Pet care preferences',
            svgSrc: 'assets/icons/Preferences.svg',
            press: () {
              Navigator.pushNamed(context, preferencesScreenRoute);
            },
          ),
          ProfileMenuListTile(
            text: 'Store credit',
            svgSrc: 'assets/icons/Discount.svg',
            press: () {
              Navigator.pushNamed(context, walletScreenRoute);
            },
            isShowDivider: false,
          ),
          if (authProvider.isAdmin) ...[
            const SizedBox(height: defaultPadding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(
                'Admin',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            ProfileMenuListTile(
              text: 'Admin panel',
              svgSrc: 'assets/icons/Setting.svg',
              press: () {
                Navigator.pushNamed(context, adminDashboardScreenRoute);
              },
            ),
            ProfileMenuListTile(
              text: 'Manage categories',
              svgSrc: 'assets/icons/Category.svg',
              press: () {
                Navigator.pushNamed(context, adminCategoriesScreenRoute);
              },
              isShowDivider: false,
            ),
          ],
          const SizedBox(height: defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Text(
              'Support',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: defaultPadding / 2),
          ProfileMenuListTile(
            text: 'Customer support',
            svgSrc: 'assets/icons/Help.svg',
            press: () => _showComingSoon(context, 'Customer support'),
          ),
          ProfileMenuListTile(
            text: 'Grooming assistance',
            svgSrc: 'assets/icons/Return.svg',
            press: () => _showComingSoon(context, 'Grooming assistance'),
            isShowDivider: false,
          ),
          const SizedBox(height: defaultPadding),
          ListTile(
            onTap: authProvider.isLoading
                ? null
                : () async {
                    await context.read<AuthProvider>().signOut();
                    if (!context.mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      logInScreenRoute,
                      (route) => false,
                    );
                  },
            minLeadingWidth: 24,
            leading: SvgPicture.asset(
              'assets/icons/Logout.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                errorColor,
                BlendMode.srcIn,
              ),
            ),
            title: Text(
              authProvider.isLoading ? 'Please wait...' : 'Log out',
              style: const TextStyle(color: errorColor, fontSize: 14, height: 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: defaultPadding / 4),
          Text(
            label,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
