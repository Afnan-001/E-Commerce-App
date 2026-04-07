import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/repositories/admin_repository.dart';
import 'package:shop/repositories/auth_repository.dart';
import 'package:shop/repositories/category_repository.dart';
import 'package:shop/repositories/product_repository.dart';

class AppScope extends StatelessWidget {
  const AppScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (_) => FirebaseAuthRepository(),
        ),
        Provider<ProductRepository>(
          create: (_) => FirebaseProductRepository(),
        ),
        Provider<CategoryRepository>(
          create: (_) => FirebaseCategoryRepository(),
        ),
        Provider<AdminRepository>(
          create: (_) => FirestoreAdminRepository(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<AuthRepository>())..restoreSession(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(
            productRepository: context.read<ProductRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          )..loadInitialData(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (_) => OrderProvider(),
        ),
        ChangeNotifierProvider<AdminProvider>(
          create: (context) => AdminProvider(
            adminRepository: context.read<AdminRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          )..loadAdminData(),
        ),
      ],
      child: child,
    );
  }
}
