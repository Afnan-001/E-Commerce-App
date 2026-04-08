import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/login_dark.png",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back to PawCare!",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Sign in to manage grooming bookings, pet orders, and your saved pet care essentials.",
                  ),
                  const SizedBox(height: defaultPadding),
                  LogInForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  if (authProvider.errorMessage != null) ...[
                    const SizedBox(height: defaultPadding / 2),
                    Text(
                      authProvider.errorMessage!,
                      style: const TextStyle(color: errorColor),
                    ),
                  ],
                  Align(
                    child: TextButton(
                      child: const Text("Forgot password"),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          passwordRecoveryScreenRoute,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: size.height > 700
                        ? size.height * 0.1
                        : defaultPadding,
                  ),
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final auth = context.read<AuthProvider>();
                            final cartProvider = context.read<CartProvider>();
                            final productProvider =
                                context.read<ProductProvider>();
                            final orderProvider = context.read<OrderProvider>();
                            final navigator = Navigator.of(context);
                            final success = await auth.signIn(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            if (!mounted || !success) return;

                            final userId = auth.currentUser?.uid;
                            await cartProvider.syncForUser(userId);
                            await productProvider.syncUserData(userId);
                            await orderProvider.syncForUser(userId);

                            if (!mounted) return;

                            navigator.pushNamedAndRemoveUntil(
                              entryPointScreenRoute,
                              (route) => false,
                            );
                          },
                    child: Text(authProvider.isLoading ? "Please wait..." : "Log in"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, signUpScreenRoute);
                        },
                        child: const Text("Sign up"),
                      ),
                    ],
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
