import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/providers/theme_provider.dart';
import 'package:shop/route/screen_export.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label will be connected soon.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final productProvider = context.watch<ProductProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.currentUser;

    final displayName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'Pet Parent';
    final displayContact = (user?.email.trim().isNotEmpty == true)
        ? user!.email.trim()
        : ((user?.phoneNumber?.trim().isNotEmpty ?? false)
              ? user!.phoneNumber!.trim()
              : 'No email linked');
    final initials = _initialsFor(displayName);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding / 2,
          defaultPadding,
          defaultPadding * 2,
        ),
        children: [
          _ProfileHeader(
            initials: initials,
            name: displayName,
            contact: displayContact,
            isAdmin: authProvider.isAdmin,
            onTap: () => Navigator.pushNamed(context, userInfoScreenRoute),
          ),
          const SizedBox(height: defaultPadding),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved',
                  value: productProvider.bookmarkedCount.toString(),
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              Expanded(
                child: _StatCard(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Cart',
                  value: cartProvider.totalItems.toString(),
                ),
              ),
              const SizedBox(width: defaultPadding / 2),
              Expanded(
                child: _StatCard(
                  icon: Icons.access_time_rounded,
                  label: 'Pending',
                  value: orderProvider.pendingOrders.length.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          _ThemeQuickCard(preference: themeProvider.preference),
          const SizedBox(height: defaultPadding),
          _GroupCard(
            title: 'Shopping',
            children: [
              _ActionTile(
                title: 'Orders',
                iconPath: 'assets/icons/Order.svg',
                onTap: () => Navigator.pushNamed(context, ordersScreenRoute),
              ),
              _ActionTile(
                title: 'Saved products',
                iconPath: 'assets/icons/Wishlist.svg',
                onTap: () => Navigator.pushNamed(context, bookmarkScreenRoute),
              ),
              _ActionTile(
                title: 'Addresses',
                iconPath: 'assets/icons/Address.svg',
                onTap: () => Navigator.pushNamed(context, addressesScreenRoute),
              ),
              _ActionTile(
                title: 'Cart',
                iconPath: 'assets/icons/Bag.svg',
                onTap: () => Navigator.pushNamed(context, cartScreenRoute),
              ),
              _ActionTile(
                title: 'Change password',
                iconPath: 'assets/icons/Lock.svg',
                onTap: () => Navigator.pushNamed(
                  context,
                  passwordRecoveryScreenRoute,
                ),
                isLast: true,
              ),
            ],
          ),
          if (authProvider.isAdmin) ...[
            const SizedBox(height: defaultPadding),
            _GroupCard(
              title: 'Admin',
              children: [
                _ActionTile(
                  title: 'Admin panel',
                  iconPath: 'assets/icons/Setting.svg',
                  onTap: () =>
                      Navigator.pushNamed(context, adminDashboardScreenRoute),
                ),
                _ActionTile(
                  title: 'Manage categories',
                  iconPath: 'assets/icons/Category.svg',
                  onTap: () =>
                      Navigator.pushNamed(context, adminCategoriesScreenRoute),
                  isLast: true,
                ),
              ],
            ),
          ],
          const SizedBox(height: defaultPadding),
          _GroupCard(
            title: 'Support',
            children: [
              _ActionTile(
                title: 'Customer support',
                iconPath: 'assets/icons/Help.svg',
                onTap: () => _showComingSoon(context, 'Customer support'),
              ),
              _ActionTile(
                title: 'Grooming assistance',
                iconPath: 'assets/icons/Return.svg',
                onTap: () => _showComingSoon(context, 'Grooming assistance'),
                isLast: true,
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          _LogoutButton(
            isLoading: authProvider.isLoading,
            onTap: () async {
              final auth = context.read<AuthProvider>();
              final cart = context.read<CartProvider>();
              final products = context.read<ProductProvider>();
              final orders = context.read<OrderProvider>();

              await auth.signOut();
              if (!context.mounted) return;

              if (auth.isAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      auth.errorMessage ??
                          'Unable to log out right now. Please try again.',
                    ),
                  ),
                );
                return;
              }

              await cart.syncForUser(null);
              await products.syncUserData(null);
              await orders.syncForUser(null);
              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                logInScreenRoute,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  String _initialsFor(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'PP';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.initials,
    required this.name,
    required this.contact,
    required this.isAdmin,
    required this.onTap,
  });

  final String initials;
  final String name;
  final String contact;
  final bool isAdmin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final cardColor = Theme.of(context).cardColor;
    final secondaryText = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.82);
    final chevronColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(defaultPadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFEDEFFF),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFF4B57D9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding * 0.8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (isAdmin)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8EBFF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'ADMIN',
                                style: TextStyle(
                                  color: Color(0xFF4651D2),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        contact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: secondaryText, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: chevronColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final cardColor = Theme.of(context).cardColor;
    final secondaryText = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.84);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding * 0.75,
        vertical: defaultPadding * 0.8,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF545C7A)),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: secondaryText)),
        ],
      ),
    );
  }
}

class _ThemeQuickCard extends StatelessWidget {
  const _ThemeQuickCard({required this.preference});

  final AppThemePreference preference;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Theme',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Switch app appearance instantly.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: defaultPadding / 2),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ThemeChip(
                  label: 'Device',
                  selected: preference == AppThemePreference.device,
                  onTap: () => context.read<ThemeProvider>().setPreference(
                    AppThemePreference.device,
                  ),
                ),
                _ThemeChip(
                  label: 'Light',
                  selected: preference == AppThemePreference.light,
                  onTap: () => context.read<ThemeProvider>().setPreference(
                    AppThemePreference.light,
                  ),
                ),
                _ThemeChip(
                  label: 'Dark',
                  selected: preference == AppThemePreference.dark,
                  onTap: () => context.read<ThemeProvider>().setPreference(
                    AppThemePreference.dark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor;
    final cardColor = Theme.of(context).cardColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              defaultPadding,
              defaultPadding,
              defaultPadding,
              defaultPadding / 2,
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.isLast = false,
  });

  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(
      context,
    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.9);
    final chipColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF242A38)
        : const Color(0xFFF3F4FA);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(isLast ? 20 : 0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding * 0.8,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 18,
                width: 18,
                colorFilter: ColorFilter.mode(
                  iconColor ?? const Color(0xFF5A6280),
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: defaultPadding * 0.7),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFC73D4C),
        side: const BorderSide(color: Color(0xFFF0B7BE)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      icon: const Icon(Icons.logout_rounded),
      label: Text(isLoading ? 'Please wait...' : 'Log out'),
    );
  }
}
