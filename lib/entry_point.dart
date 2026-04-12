import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/route/screen_export.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  int _currentIndex = 0;
  String? _discoverCategoryTitle;
  int _discoverFilterSeed = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();

    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        height: 24,
        colorFilter: ColorFilter.mode(
          color ??
              Theme.of(context).iconTheme.color!.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 1,
              ),
          BlendMode.srcIn,
        ),
      );
    }

    final pages = <Widget>[
      HomeScreen(
        onOpenDiscover: () => _openDiscover(),
        onOpenCategory: (categoryTitle) =>
            _openDiscover(categoryTitle: categoryTitle),
      ),
      DiscoverScreen(
        initialCategoryTitle: _discoverCategoryTitle,
        filterSeed: _discoverFilterSeed,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: const SizedBox(),
        leadingWidth: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.9),
                ),
              ),
              child: Image.asset(
                'assets/logo/petsworld_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "PetsWorld",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (authProvider.isAdmin)
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, adminDashboardScreenRoute);
              },
              icon: SvgPicture.asset(
                "assets/icons/Setting.svg",
                height: 24,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn,
                ),
              ),
            ),
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, cartScreenRoute);
                },
                icon: SvgPicture.asset(
                  "assets/icons/Bag.svg",
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).textTheme.bodyLarge!.color!,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: errorColor,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, animation, secondAnimation) {
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            child: child,
          );
        },
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          defaultPadding,
          defaultPadding / 2,
          defaultPadding,
          defaultPadding / 2,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xCC0F1116),
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(28)),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                indicatorColor: const Color(0xFFF1A208),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? Colors.white : Colors.white70,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  if (index != _currentIndex) {
                    setState(() {
                      _currentIndex = index;
                      if (index == 1) {
                        _discoverCategoryTitle = null;
                        _discoverFilterSeed++;
                      }
                    });
                  }
                },
                height: 66,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: svgIcon(
                      "assets/icons/Shop.svg",
                      color: Colors.white70,
                    ),
                    selectedIcon: svgIcon(
                      "assets/icons/Shop.svg",
                      color: Colors.white,
                    ),
                    label: "Shop",
                  ),
                  NavigationDestination(
                    icon: svgIcon(
                      "assets/icons/Category.svg",
                      color: Colors.white70,
                    ),
                    selectedIcon: svgIcon(
                      "assets/icons/Category.svg",
                      color: Colors.white,
                    ),
                    label: "Discover",
                  ),
                  NavigationDestination(
                    icon: svgIcon(
                      "assets/icons/Bookmark.svg",
                      color: Colors.white70,
                    ),
                    selectedIcon: svgIcon(
                      "assets/icons/Bookmark.svg",
                      color: Colors.white,
                    ),
                    label: "Saved",
                  ),
                  NavigationDestination(
                    icon: svgIcon(
                      "assets/icons/Profile.svg",
                      color: Colors.white70,
                    ),
                    selectedIcon: svgIcon(
                      "assets/icons/Profile.svg",
                      color: Colors.white,
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDiscover({String? categoryTitle}) {
    setState(() {
      _currentIndex = 1;
      _discoverCategoryTitle = categoryTitle;
      _discoverFilterSeed++;
    });
  }
}
