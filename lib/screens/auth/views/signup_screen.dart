import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/auth/views/components/sign_up_form.dart';
import 'package:shop/screens/auth/views/components/auth_feedback.dart';

import '../../../constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/signUp_dark.png",
              height: MediaQuery.of(context).size.height * 0.35,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create your PetsWorld account",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Create an account to book grooming services, shop pet products, and track your orders.",
                  ),
                  const SizedBox(height: defaultPadding),
                  SignUpForm(
                    formKey: _formKey,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),
                  const SizedBox(height: defaultPadding),
                  OutlinedButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            final auth = context.read<AuthProvider>();
                            final cartProvider = context.read<CartProvider>();
                            final productProvider = context
                                .read<ProductProvider>();
                            final orderProvider = context.read<OrderProvider>();
                            final navigator = Navigator.of(context);
                            final success = await auth.signInWithGoogle();
                            if (!context.mounted) return;
                            if (!success) {
                              final message =
                                  auth.errorMessage ??
                                  'Unable to sign up with Google.';
                              await showAuthErrorDialog(
                                context,
                                message: message,
                              );
                              auth.clearError();
                              return;
                            }

                            final userId = auth.currentUser?.uid;
                            await cartProvider.syncForUser(userId);
                            await productProvider.syncUserData(userId);
                            await orderProvider.syncForUser(userId);

                            if (!context.mounted) return;
                            navigator.pushNamedAndRemoveUntil(
                              entryPointScreenRoute,
                              (route) => false,
                            );
                          },
                    icon: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'G',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDB4437),
                        ),
                      ),
                    ),
                    label: const Text('Sign up with Google'),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  OutlinedButton.icon(
                    onPressed: authProvider.isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(
                              context,
                              phoneAuthScreenRoute,
                              arguments: <String, dynamic>{
                                'isSignUp': true,
                                'prefilledName': _nameController.text.trim(),
                              },
                            );
                          },
                    icon: const Icon(Icons.phone_android_outlined),
                    label: const Text('Sign up with phone OTP'),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(onChanged: (value) {}, value: true),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "I agree with the",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                                text: " Terms of service ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(text: "& privacy policy."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding * 2),
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final auth = context.read<AuthProvider>();
                            final cartProvider = context.read<CartProvider>();
                            final productProvider = context
                                .read<ProductProvider>();
                            final orderProvider = context.read<OrderProvider>();
                            final navigator = Navigator.of(context);
                            final success = await auth.signUp(
                              name: _nameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            if (!context.mounted) return;
                            if (!success) {
                              final message =
                                  auth.errorMessage ??
                                  'Unable to create account.';
                              await showAuthErrorDialog(
                                context,
                                message: message,
                              );
                              auth.clearError();
                              return;
                            }

                            final userId = auth.currentUser?.uid;
                            await cartProvider.syncForUser(userId);
                            await productProvider.syncUserData(userId);
                            await orderProvider.syncForUser(userId);

                            if (!context.mounted) return;

                            navigator.pushNamedAndRemoveUntil(
                              entryPointScreenRoute,
                              (route) => false,
                            );
                          },
                    child: Text(
                      authProvider.isLoading ? "Please wait..." : "Continue",
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Do you have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Log in"),
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
