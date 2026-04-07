import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
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
          create: (_) => const DemoAuthRepository(),
        ),
        Provider<ProductRepository>(
          create: (_) => const DemoProductRepository(),
        ),
        Provider<CategoryRepository>(
          create: (_) => const DemoCategoryRepository(),
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
      ],
      child: child,
    );
  }
}
