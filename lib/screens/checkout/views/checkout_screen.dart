import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:shop/constants.dart';
import 'package:shop/core/config/payment_config.dart';
import 'package:shop/core/services/razorpay_checkout_service.dart';
import 'package:shop/models/app_user_model.dart';
import 'package:shop/models/cart_item_model.dart';
import 'package:shop/models/address_model.dart';
import 'package:shop/models/order_delivery_address_model.dart';
import 'package:shop/models/order_enums.dart';
import 'package:shop/models/order_item_model.dart';
import 'package:shop/models/order_model.dart';
import 'package:shop/models/order_payment_model.dart';
import 'package:shop/models/order_pricing_model.dart';
import 'package:shop/providers/address_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/order_provider.dart';
import 'package:shop/repositories/order_repository.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/screens/address/views/address_form_screen.dart';
import 'package:shop/screens/order/views/order_success_screen.dart';

enum _CheckoutPaymentMethod { razorpay, cod }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final RazorpayCheckoutService _razorpayService = RazorpayCheckoutService();
  final Random _random = Random();

  bool _isProcessing = false;
  _CheckoutPaymentMethod _selectedPaymentMethod =
      _CheckoutPaymentMethod.razorpay;

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final AppUserModel? user = authProvider.currentUser;
    final items = cartProvider.items;
    final selectedAddress = addressProvider.selectedAddress;
    final pricing = _buildPricing(items);
    final deliveryCharge = pricing.deliveryCharge;
    final discount = pricing.discount;
    final totalAmount = pricing.totalAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stack(
        children: [
          if (!authProvider.isAuthenticated)
            _SignedOutState(
              onSignIn: () => Navigator.pushNamed(context, logInScreenRoute),
            )
          else if (items.isEmpty)
            _EmptyCheckoutState(
              onContinueShopping: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  entryPointScreenRoute,
                  (route) => false,
                );
              },
            )
          else
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(defaultPadding),
                children: [
                  _SectionCard(
                    title: 'Cart items',
                    child: Column(
                      children: [
                        for (final item in items) ...[
                          _CheckoutItemTile(item: item),
                          if (item != items.last)
                            const Divider(height: defaultPadding * 1.5),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Delivery address',
                    actionLabel: 'Manage',
                    onAction: () =>
                        Navigator.pushNamed(context, addressesScreenRoute),
                    child: addressProvider.isLoading
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : _AddressSection(
                            selectedAddress: selectedAddress,
                            addresses: addressProvider.addresses,
                            onSelect: (address) {
                              context
                                  .read<AddressProvider>()
                                  .selectAddressForCheckout(address.id);
                            },
                            onAddAddress: () async {
                              final result = await Navigator.of(context)
                                  .push<AddressModel>(
                                    MaterialPageRoute(
                                      builder: (_) => const AddressFormScreen(),
                                    ),
                                  );
                              if (!context.mounted || result == null) return;
                              try {
                                await context
                                    .read<AddressProvider>()
                                    .addAddress(result);
                              } catch (_) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Unable to save address.'),
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Payment method',
                    child: Column(
                      children: [
                        _PaymentMethodTile(
                          title: 'Razorpay',
                          subtitle:
                              'UPI, Google Pay, PhonePe, cards, and wallets',
                          isSelected:
                              _selectedPaymentMethod ==
                              _CheckoutPaymentMethod.razorpay,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod =
                                  _CheckoutPaymentMethod.razorpay;
                            });
                          },
                          leadingIcon: Icons.account_balance_wallet_outlined,
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        _PaymentMethodTile(
                          title: 'Cash on Delivery',
                          subtitle:
                              'Pay when the order arrives at your address',
                          isSelected:
                              _selectedPaymentMethod ==
                              _CheckoutPaymentMethod.cod,
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod =
                                  _CheckoutPaymentMethod.cod;
                            });
                          },
                          leadingIcon: Icons.local_shipping_outlined,
                        ),
                        if (razorpayOrderCreationUrl.isEmpty) ...[
                          const SizedBox(height: defaultPadding / 2),
                          Text(
                            'Razorpay needs a secure backend order endpoint before it can be used.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  _SectionCard(
                    title: 'Payment summary',
                    child: Column(
                      children: [
                        _PriceRow(
                          label: 'Subtotal',
                          value: _formatMoney(pricing.subtotal),
                        ),
                        const SizedBox(height: defaultPadding / 4),
                        _PriceRow(
                          label: 'Delivery charges',
                          value: _formatMoney(deliveryCharge),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(height: defaultPadding / 4),
                          _PriceRow(
                            label: 'Discount',
                            value: '-${_formatMoney(discount)}',
                            valueStyle: const TextStyle(color: successColor),
                          ),
                        ],
                        const Divider(height: defaultPadding * 1.5),
                        _PriceRow(
                          label: 'Total amount',
                          value: _formatMoney(totalAmount),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),
                  ElevatedButton(
                    onPressed: _isProcessing ? null : () => _placeOrder(user),
                    child: Text(
                      _selectedPaymentMethod == _CheckoutPaymentMethod.cod
                          ? 'Place Order'
                          : 'Pay Now',
                    ),
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text(
                    _selectedPaymentMethod == _CheckoutPaymentMethod.cod
                        ? 'Cash on delivery orders will be saved to Firestore with a pending payment status.'
                        : 'Secure Razorpay checkout opens after the backend creates the order id.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.18),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(AppUserModel? user) async {
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();
    final addressProvider = context.read<AddressProvider>();
    final selectedAddress = addressProvider.selectedAddress;
    final items = cartProvider.items;
    final isRazorpayFlow =
        _selectedPaymentMethod == _CheckoutPaymentMethod.razorpay;

    if (!authProvider.isAuthenticated || user == null) {
      _showSnackBar('Please sign in to continue checkout.');
      return;
    }

    if (items.isEmpty) {
      _showSnackBar('Your cart is empty.');
      return;
    }

    if (selectedAddress == null) {
      _showSnackBar('Select a delivery address first.');
      return;
    }

    if (isRazorpayFlow && razorpayOrderCreationUrl.isEmpty) {
      _showSnackBar(
        'Razorpay is not configured yet. Add a secure backend order-creation endpoint first, or choose Cash on Delivery.',
      );
      return;
    }

    final orderId = _generateOrderId();
    final pricing = _buildPricing(items);
    final deliveryAddress = OrderDeliveryAddressModel.fromAddress(
      selectedAddress,
    );
    final paymentMethod = isRazorpayFlow
        ? PaymentMethod.razorpay
        : PaymentMethod.cod;
    final pendingPayment = OrderPaymentModel(
      paymentMethod: paymentMethod,
      paymentStatus: PaymentStatus.pending,
    );
    final draftOrder = _buildOrder(
      orderId: orderId,
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      userPhone: user.phoneNumber ?? selectedAddress.phoneNumber,
      deliveryAddress: deliveryAddress,
      items: items,
      pricing: pricing,
      payment: pendingPayment,
    );

    setState(() {
      _isProcessing = true;
    });

    try {
      if (paymentMethod == PaymentMethod.cod) {
        final order = draftOrder.copyWith(
          payment: pendingPayment,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _saveOrder(order);
        return;
      }

      final razorpayOrderId = await _razorpayService.createOrderId(
        amountInPaise: (pricing.totalAmount * 100).round(),
        receiptId: orderId,
        notes: <String, dynamic>{'userId': user.uid, 'orderId': orderId},
      );

      final razorpayDraft = draftOrder.copyWith(
        payment: OrderPaymentModel(
          paymentMethod: PaymentMethod.razorpay,
          paymentStatus: PaymentStatus.pending,
          razorpayOrderId: razorpayOrderId,
        ),
      );

      _razorpayService.openCheckout(
        orderId: razorpayOrderId,
        amountInPaise: (pricing.totalAmount * 100).round(),
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phoneNumber ?? selectedAddress.phoneNumber,
        onSuccess: (response) {
          unawaited(_handleRazorpaySuccess(response, razorpayDraft));
        },
        onFailure: (response) {
          unawaited(_handleRazorpayFailure(response));
        },
        onExternalWallet: (response) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('External wallet selected: ${response.walletName}'),
            ),
          );
        },
      );

      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar(error.toString());
    }
  }

  Future<void> _handleRazorpaySuccess(
    PaymentSuccessResponse response,
    OrderModel draftOrder,
  ) async {
    final paidOrder = draftOrder.copyWith(
      payment: OrderPaymentModel(
        paymentMethod: PaymentMethod.razorpay,
        paymentStatus: PaymentStatus.paid,
        razorpayPaymentId: response.paymentId,
        razorpayOrderId: response.orderId ?? draftOrder.payment.razorpayOrderId,
        razorpaySignature: response.signature,
      ),
      updatedAt: DateTime.now(),
    );

    try {
      await _saveOrder(paidOrder);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      _showSnackBar('Payment succeeded, but order save failed: $error');
    }
  }

  Future<void> _handleRazorpayFailure(PaymentFailureResponse response) async {
    _razorpayService.dispose();
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });
    _showSnackBar(response.message ?? 'Payment failed. Please try again.');
  }

  Future<void> _saveOrder(OrderModel order) async {
    await context.read<OrderRepository>().saveOrder(order);
    context.read<OrderProvider>().addOrder(order);
    context.read<CartProvider>().clear();
    _razorpayService.dispose();

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: order)),
    );
  }

  OrderModel _buildOrder({
    required String orderId,
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    required OrderDeliveryAddressModel deliveryAddress,
    required List<CartItemModel> items,
    required OrderPricingModel pricing,
    required OrderPaymentModel payment,
  }) {
    final now = DateTime.now();
    return OrderModel(
      orderId: orderId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      deliveryAddress: deliveryAddress,
      items: items.map(OrderItemModel.fromCartItem).toList(),
      pricing: pricing,
      payment: payment,
      orderStatus: OrderStatus.placed,
      createdAt: now,
      updatedAt: now,
    );
  }

  OrderPricingModel _buildPricing(List<CartItemModel> items) {
    final subtotal = items.fold<double>(
      0,
      (total, item) => total + (item.product.price * item.quantity),
    );
    final saleTotal = items.fold<double>(
      0,
      (total, item) => total + item.totalPrice,
    );
    final discount = (subtotal - saleTotal)
        .clamp(0.0, double.infinity)
        .toDouble();
    final deliveryCharge = items.isEmpty ? 0.0 : 49.0;
    final totalAmount = subtotal - discount + deliveryCharge;

    return OrderPricingModel(
      subtotal: subtotal,
      deliveryCharge: deliveryCharge,
      discount: discount,
      totalAmount: totalAmount,
    );
  }

  String _generateOrderId() {
    final timeStamp = DateTime.now().microsecondsSinceEpoch;
    final suffix = 1000 + _random.nextInt(9000);
    return 'ORD-$timeStamp-$suffix';
  }

  String _formatMoney(double amount) => 'Rs ${amount.toStringAsFixed(0)}';

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: const BorderRadius.all(
          Radius.circular(defaultBorderRadious),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (actionLabel != null && onAction != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
          const SizedBox(height: defaultPadding / 2),
          child,
        ],
      ),
    );
  }
}

class _CheckoutItemTile extends StatelessWidget {
  const _CheckoutItemTile({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(defaultBorderRadious),
          ),
          child: Image.network(
            item.product.imageUrl,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(item.product.brandName),
              const SizedBox(height: 4),
              Text('Qty ${item.quantity}'),
            ],
          ),
        ),
        Text(
          'Rs ${(item.unitPrice * item.quantity).toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _AddressSection extends StatelessWidget {
  const _AddressSection({
    required this.selectedAddress,
    required this.addresses,
    required this.onSelect,
    required this.onAddAddress,
  });

  final AddressModel? selectedAddress;
  final List<AddressModel> addresses;
  final ValueChanged<AddressModel> onSelect;
  final VoidCallback onAddAddress;

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No saved addresses yet.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: defaultPadding / 2),
          ElevatedButton(
            onPressed: onAddAddress,
            child: const Text('Add address'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          selectedAddress == null
              ? 'Select a delivery address'
              : '${selectedAddress!.fullName} • ${selectedAddress!.phoneNumber}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 2),
        Text(
          selectedAddress?.fullAddress ?? 'Tap an address below to continue.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: defaultPadding),
        for (final address in addresses) ...[
          InkWell(
            onTap: () => onSelect(address),
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: defaultPadding / 2),
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(
                  color: address.id == selectedAddress?.id
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(defaultBorderRadious),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        address.id == selectedAddress?.id
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: address.id == selectedAddress?.id
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.label,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (address.isDefault) const Text('Default'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${address.fullName} • ${address.phoneNumber}'),
                  const SizedBox(height: 4),
                  Text(address.fullAddress),
                ],
              ),
            ),
          ),
        ],
        OutlinedButton(
          onPressed: onAddAddress,
          child: const Text('Add new address'),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.leadingIcon,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData leadingIcon;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(
        Radius.circular(defaultBorderRadious),
      ),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          borderRadius: const BorderRadius.all(
            Radius.circular(defaultBorderRadious),
          ),
        ),
        child: Row(
          children: [
            Icon(leadingIcon),
            const SizedBox(width: defaultPadding / 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueStyle,
  });

  final String label;
  final String value;
  final bool isBold;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final baseStyle = isBold
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      children: [
        Text(label, style: baseStyle),
        const Spacer(),
        Text(value, style: valueStyle ?? baseStyle),
      ],
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 64),
            const SizedBox(height: defaultPadding),
            Text(
              'Sign in to checkout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              'We need your account details to create and save the order.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: onSignIn,
              child: const Text('Go to login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCheckoutState extends StatelessWidget {
  const _EmptyCheckoutState({required this.onContinueShopping});

  final VoidCallback onContinueShopping;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
            const Text(
              'Add items to your cart before starting checkout.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
              onPressed: onContinueShopping,
              child: const Text('Continue shopping'),
            ),
          ],
        ),
      ),
    );
  }
}
