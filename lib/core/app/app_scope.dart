import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/address_provider.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/providers/theme_provider.dart';
import 'package:shop/repositories/address_repository.dart';
import 'package:shop/repositories/admin_repository.dart';
import 'package:shop/repositories/auth_repository.dart';
import 'package:shop/repositories/category_repository.dart';
import 'package:shop/repositories/coupon_repository.dart';
import 'package:shop/repositories/order_repository.dart';
import 'package:shop/repositories/product_repository.dart';
import 'package:shop/repositories/product_review_repository.dart';
import 'package:shop/repositories/storefront_repository.dart';
import 'package:shop/repositories/user_data_repository.dart';

class AppScope extends StatelessWidget {
  const AppScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => FirebaseAuthRepository()),
        Provider<ProductRepository>(create: (_) => FirebaseProductRepository()),
        Provider<CategoryRepository>(
          create: (_) => FirebaseCategoryRepository(),
        ),
        Provider<AdminRepository>(create: (_) => FirestoreAdminRepository()),
        Provider<CouponRepository>(create: (_) => FirestoreCouponRepository()),
        Provider<StorefrontRepository>(
          create: (_) => FirestoreStorefrontRepository(),
        ),
        Provider<AddressRepository>(
          create: (_) => FirestoreAddressRepository(),
        ),
        Provider<OrderRepository>(create: (_) => FirestoreOrderRepository()),
        Provider<ProductReviewRepository>(
          create: (_) => FirestoreProductReviewRepository(),
        ),
        Provider<UserDataRepository>(
          create: (_) => FirestoreUserDataRepository(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<AuthRepository>())..restoreSession(),
        ),
        ChangeNotifierProvider<AddressProvider>(
          create: (context) => AddressProvider(
            addressRepository: context.read<AddressRepository>(),
            authProvider: context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(
            productRepository: context.read<ProductRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
            userDataRepository: context.read<UserDataRepository>(),
          )..loadInitialData(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (context) => CartProvider(
            userDataRepository: context.read<UserDataRepository>(),
            couponRepository: context.read<CouponRepository>(),
            storefrontRepository: context.read<StorefrontRepository>(),
          )..initialize(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) =>
              OrderProvider(orderRepository: context.read<OrderRepository>()),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (context) =>
              AdminProvider(adminRepository: context.read<AdminRepository>()),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider()..loadPreference(),
        ),
      ],
      child: child,
    );
  }
}
