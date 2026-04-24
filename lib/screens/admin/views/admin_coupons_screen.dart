import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/coupon_model.dart';
import 'package:shop/providers/admin_provider.dart';

class AdminCouponsScreen extends StatelessWidget {
  const AdminCouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final coupons = adminProvider.coupons;

    return Scaffold(
      appBar: AppBar(title: const Text('Coupons')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.discount_outlined),
        label: const Text('Add coupon'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          if (coupons.isEmpty)
            const _EmptyAdminState(
              icon: Icons.local_offer_outlined,
              title: 'No coupons yet',
              message:
                  'Create discount codes for flat, percentage, category, or product-based offers.',
            )
          else
            ...coupons.map(
              (coupon) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: _CouponCard(
                  coupon: coupon,
                  onEdit: () => _openEditor(context, coupon: coupon),
                  onDelete: () => _deleteCoupon(context, coupon),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {CouponModel? coupon}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CouponEditorSheet(initialCoupon: coupon),
    );
  }

  Future<void> _deleteCoupon(BuildContext context, CouponModel coupon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete coupon?'),
        content: Text('Remove coupon code ${coupon.code}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final success = await context.read<AdminProvider>().deleteCoupon(coupon.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Coupon deleted.' : 'Could not delete coupon.'),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.coupon,
    required this.onEdit,
    required this.onDelete,
  });

  final CouponModel coupon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(
                label: coupon.isActive ? 'Active' : 'Inactive',
                color: coupon.isActive
                    ? const Color(0xFFE6F7EC)
                    : const Color(0xFFF3E8E8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            coupon.discountType == CouponDiscountType.flatAmount
                ? 'Flat Rs ${coupon.discountValue.toStringAsFixed(0)} off'
                : '${coupon.discountValue.toStringAsFixed(0)}% off',
          ),
          const SizedBox(height: 6),
          Text(
            'Min cart: Rs ${coupon.minCartValue.toStringAsFixed(0)}'
            '${coupon.expiryDate == null ? '' : ' • Expires ${_formatDate(coupon.expiryDate!)}'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Usage: ${coupon.usageCount}${coupon.usageLimit == null ? '' : ' / ${coupon.usageLimit}'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (coupon.applicableCategoryIds.isNotEmpty ||
              coupon.applicableProductIds.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Targets: ${[if (coupon.applicableCategoryIds.isNotEmpty) '${coupon.applicableCategoryIds.length} categories', if (coupon.applicableProductIds.isNotEmpty) '${coupon.applicableProductIds.length} products'].join(' • ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onDelete,
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CouponEditorSheet extends StatefulWidget {
  const _CouponEditorSheet({this.initialCoupon});

  final CouponModel? initialCoupon;

  @override
  State<_CouponEditorSheet> createState() => _CouponEditorSheetState();
}

class _CouponEditorSheetState extends State<_CouponEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _discountValueController;
  late final TextEditingController _minCartValueController;
  late final TextEditingController _usageLimitController;
  late CouponDiscountType _discountType;
  late bool _isActive;
  DateTime? _expiryDate;
  final Set<String> _selectedCategoryIds = <String>{};
  final Set<String> _selectedProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    final coupon = widget.initialCoupon;
    _codeController = TextEditingController(text: coupon?.code ?? '');
    _discountValueController = TextEditingController(
      text: coupon == null ? '' : coupon.discountValue.toStringAsFixed(0),
    );
    _minCartValueController = TextEditingController(
      text: coupon == null ? '0' : coupon.minCartValue.toStringAsFixed(0),
    );
    _usageLimitController = TextEditingController(
      text: coupon?.usageLimit?.toString() ?? '',
    );
    _discountType = coupon?.discountType ?? CouponDiscountType.flatAmount;
    _isActive = coupon?.isActive ?? true;
    _expiryDate = coupon?.expiryDate;
    _selectedCategoryIds.addAll(coupon?.applicableCategoryIds ?? const []);
    _selectedProductIds.addAll(coupon?.applicableProductIds ?? const []);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _discountValueController.dispose();
    _minCartValueController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final categories = adminProvider.categories;
    final products = adminProvider.products;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.initialCoupon == null
                        ? 'Create coupon'
                        : 'Edit coupon',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Code is required'
                        : null,
                    decoration: const InputDecoration(labelText: 'Coupon code'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<CouponDiscountType>(
                    value: _discountType,
                    decoration: const InputDecoration(
                      labelText: 'Discount type',
                    ),
                    items: CouponDiscountType.values
                        .map(
                          (item) => DropdownMenuItem<CouponDiscountType>(
                            value: item,
                            child: Text(
                              item == CouponDiscountType.flatAmount
                                  ? 'Flat amount off'
                                  : 'Percentage off',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _discountType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _discountValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (double.tryParse((value ?? '').trim()) == null) {
                        return 'Enter a valid discount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: _discountType == CouponDiscountType.flatAmount
                          ? 'Discount value (Rs)'
                          : 'Discount value (%)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _minCartValueController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Minimum cart value',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usageLimitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Usage limit (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _expiryDate == null
                          ? 'Pick expiry date'
                          : 'Expires on ${_formatDate(_expiryDate!)}',
                    ),
                    trailing: TextButton(
                      onPressed: _pickExpiryDate,
                      child: const Text('Select'),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Coupon active'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Applicable categories',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories
                        .map(
                          (category) => FilterChip(
                            label: Text(category.title),
                            selected: _selectedCategoryIds.contains(
                              category.title,
                            ),
                            onSelected: (_) {
                              setState(() {
                                if (_selectedCategoryIds.contains(
                                  category.title,
                                )) {
                                  _selectedCategoryIds.remove(category.title);
                                } else {
                                  _selectedCategoryIds.add(category.title);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Applicable products',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...products
                      .take(20)
                      .map(
                        (product) => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _selectedProductIds.contains(product.id),
                          onChanged: (_) {
                            setState(() {
                              if (_selectedProductIds.contains(product.id)) {
                                _selectedProductIds.remove(product.id);
                              } else {
                                _selectedProductIds.add(product.id);
                              }
                            });
                          },
                          title: Text(product.title),
                          subtitle: Text(product.categoryName),
                        ),
                      ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: adminProvider.isSaving ? null : _save,
                      child: Text(
                        adminProvider.isSaving ? 'Saving...' : 'Save coupon',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _expiryDate ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AdminProvider>().saveCoupon(
      CouponModel(
        id: widget.initialCoupon?.id ?? '',
        code: _codeController.text.trim().toUpperCase(),
        discountType: _discountType,
        discountValue:
            double.tryParse(_discountValueController.text.trim()) ?? 0,
        applicableCategoryIds: _selectedCategoryIds.toList(),
        applicableProductIds: _selectedProductIds.toList(),
        minCartValue: double.tryParse(_minCartValueController.text.trim()) ?? 0,
        expiryDate: _expiryDate,
        usageLimit: int.tryParse(_usageLimitController.text.trim()),
        usageCount: widget.initialCoupon?.usageCount ?? 0,
        isActive: _isActive,
        createdAt: widget.initialCoupon?.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AdminProvider>().errorMessage ??
                'Could not save coupon.',
          ),
        ),
      );
      return;
    }
    Navigator.pop(context);
  }
}

class _EmptyAdminState extends StatelessWidget {
  const _EmptyAdminState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 52),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
