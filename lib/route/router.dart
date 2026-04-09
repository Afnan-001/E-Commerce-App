import 'package:flutter/material.dart';
import 'package:shop/entry_point.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/screen_export.dart';

// Yuo will get 50+ screens and more once you have the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

// NotificationPermissionScreen()
// PreferredLanguageScreen()
// SelectLanguageScreen()
// SignUpVerificationScreen()
// ProfileSetupScreen()
// VerificationMethodScreen()
// OtpScreen()
// SetNewPasswordScreen()
// DoneResetPasswordScreen()
// TermsOfServicesScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFingerprintScreen()
// SetupFaceIdScreen()
// OnSaleScreen()
// BannerLStyle2()
// BannerLStyle3()
// BannerLStyle4()
// SearchScreen()
// SearchHistoryScreen()
// NotificationsScreen()
// EnableNotificationScreen()
// NoNotificationScreen()
// NotificationOptionsScreen()
// ProductInfoScreen()
// ShippingMethodsScreen()
// ProductReviewsScreen()
// SizeGuideScreen()
// BrandScreen()
// CartScreen()
// EmptyCartScreen()
// PaymentMethodScreen()
// ThanksForOrderScreen()
// CurrentPasswordScreen()
// EditUserInfoScreen()
// OrdersScreen()
// OrderProcessingScreen()
// OrderDetailsScreen()
// CancleOrderScreen()
// DelivereOrdersdScreen()
// AddressesScreen()
// NoAddressScreen()
// AddNewAddressScreen()
// ServerErrorScreen()
// NoInternetScreen()
// ChatScreen()
// DiscoverWithImageScreen()
// SubDiscoverScreen()
// AddNewCardScreen()
// EmptyPaymentScreen()
// GetHelpScreen()

// ℹ️ All the comments screen are included in the full template
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(builder: (context) => const OnBordingScreen());
    case logInScreenRoute:
      return MaterialPageRoute(builder: (context) => const LoginScreen());
    case signUpScreenRoute:
      return MaterialPageRoute(builder: (context) => const SignUpScreen());
    case phoneAuthScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final arguments = settings.arguments as Map<String, dynamic>?;
          return PhoneAuthScreen(
            isSignUp: arguments?['isSignUp'] == true,
            prefilledName: arguments?['prefilledName'] as String?,
          );
        },
      );
    case passwordRecoveryScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const PasswordRecoveryScreen(),
      );
    case productDetailsScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final product = settings.arguments as ProductModel?;
          return ProductDetailsScreen(product: product);
        },
      );
    case homeScreenRoute:
      return MaterialPageRoute(builder: (context) => const HomeScreen());
    case discoverScreenRoute:
      return MaterialPageRoute(builder: (context) => const DiscoverScreen());
    case searchScreenRoute:
      return MaterialPageRoute(builder: (context) => const SearchScreen());
    case bookmarkScreenRoute:
      return MaterialPageRoute(builder: (context) => const BookmarkScreen());
    case adminDashboardScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminDashboardScreen(),
      );
    case adminCategoriesScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminCategoriesScreen(),
      );
    case adminCategoryFormScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final category = settings.arguments as CategoryModel?;
          return AdminCategoryFormScreen(category: category);
        },
      );
    case adminProductsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminProductsScreen(),
      );
    case adminProductFormScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final product = settings.arguments as ProductModel?;
          return AdminProductFormScreen(product: product);
        },
      );
    case adminOrdersScreenRoute:
      return MaterialPageRoute(builder: (context) => const AdminOrdersScreen());
    case adminHomeBannerScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AdminHomeBannerScreen(),
      );
    case entryPointScreenRoute:
      return MaterialPageRoute(builder: (context) => const EntryPoint());
    case profileScreenRoute:
      return MaterialPageRoute(builder: (context) => const ProfileScreen());
    case userInfoScreenRoute:
      return MaterialPageRoute(builder: (context) => const UserInfoScreen());
    case addressesScreenRoute:
      return MaterialPageRoute(builder: (context) => const AddressesScreen());
    case ordersScreenRoute:
      return MaterialPageRoute(builder: (context) => const OrdersScreen());
    case preferencesScreenRoute:
      return MaterialPageRoute(builder: (context) => const PreferencesScreen());
    case emptyWalletScreenRoute:
      return MaterialPageRoute(builder: (context) => const EmptyWalletScreen());
    case walletScreenRoute:
      return MaterialPageRoute(builder: (context) => const WalletScreen());
    case cartScreenRoute:
      return MaterialPageRoute(builder: (context) => const CartScreen());
    case checkoutScreenRoute:
      return MaterialPageRoute(builder: (context) => const CheckoutScreen());
    case orderSuccessScreenRoute:
      return MaterialPageRoute(
        builder: (context) {
          final order = settings.arguments as OrderModel;
          return OrderSuccessScreen(order: order);
        },
      );
    default:
      return MaterialPageRoute(builder: (context) => const OnBordingScreen());
  }
}
