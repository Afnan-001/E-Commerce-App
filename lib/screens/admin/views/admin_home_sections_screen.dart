import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop/constants.dart';
import 'package:shop/models/coupon_model.dart';
import 'package:shop/models/home_section_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminHomeSectionsScreen extends StatelessWidget {
  const AdminHomeSectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final sections = adminProvider.homeSections;

    return Scaffold(
      appBar: AppBar(title: const Text('Home sections')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.view_stream_outlined),
        label: const Text('Add section'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          if (sections.isEmpty)
            const _SectionEmptyState()
          else
            ...sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: _HomeSectionCard(
                  section: section,
                  onEdit: () => _openEditor(context, section: section),
                  onDelete: () => _deleteSection(context, section),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    HomeSectionModel? section,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HomeSectionEditorSheet(initialSection: section),
    );
  }

  Future<void> _deleteSection(
    BuildContext context,
    HomeSectionModel section,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete section?'),
        content: Text('Remove "${section.title}" from the home page?'),
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
    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.deleteHomeSection(section.id);
    if (!context.mounted) return;
    if (success) {
      await context.read<ProductProvider>().loadInitialData();
    }
  }
}

class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({
    required this.section,
    required this.onEdit,
    required this.onDelete,
  });

  final HomeSectionModel section;
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
          Text(
            section.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '${section.productIds.length} curated products • Order ${section.sortOrder}',
          ),
          const SizedBox(height: 6),
          Text(
            section.isWithinDisplayRange ? 'Visible now' : 'Currently hidden',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (section.hasSectionDiscount) ...[
            const SizedBox(height: 6),
            Text(
              section.sectionDiscountType == CouponDiscountType.flatAmount
                  ? 'Section offer: Rs ${section.sectionDiscountValue?.toStringAsFixed(0) ?? '0'} off'
                  : 'Section offer: ${section.sectionDiscountValue?.toStringAsFixed(0) ?? '0'}% off',
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

class _HomeSectionEditorSheet extends StatefulWidget {
  const _HomeSectionEditorSheet({this.initialSection});

  final HomeSectionModel? initialSection;

  @override
  State<_HomeSectionEditorSheet> createState() =>
      _HomeSectionEditorSheetState();
}

class _HomeSectionEditorSheetState extends State<_HomeSectionEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _sortOrderController;
  late final TextEditingController _discountValueController;
  final Set<String> _selectedProductIds = <String>{};
  bool _isActive = true;
  bool _hasDiscount = false;
  CouponDiscountType _discountType = CouponDiscountType.percentage;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final section = widget.initialSection;
    _titleController = TextEditingController(text: section?.title ?? '');
    _sortOrderController = TextEditingController(
      text: (section?.sortOrder ?? 0).toString(),
    );
    _discountValueController = TextEditingController(
      text: section?.sectionDiscountValue?.toStringAsFixed(0) ?? '',
    );
    _selectedProductIds.addAll(section?.productIds ?? const []);
    _isActive = section?.isActive ?? true;
    _hasDiscount = section?.hasSectionDiscount ?? false;
    _discountType =
        section?.sectionDiscountType ?? CouponDiscountType.percentage;
    _startDate = section?.startDate;
    _endDate = section?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sortOrderController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
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
                    widget.initialSection == null
                        ? 'Create home section'
                        : 'Edit home section',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Title is required'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Section title',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sortOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Display order',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show this section'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _startDate == null
                          ? 'Start date (optional)'
                          : 'Starts ${_formatDate(_startDate!)}',
                    ),
                    trailing: TextButton(
                      onPressed: () => _pickDate(isStart: true),
                      child: const Text('Select'),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _endDate == null
                          ? 'End date (optional)'
                          : 'Ends ${_formatDate(_endDate!)}',
                    ),
                    trailing: TextButton(
                      onPressed: () => _pickDate(isStart: false),
                      child: const Text('Select'),
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Apply a section discount'),
                    value: _hasDiscount,
                    onChanged: (value) => setState(() => _hasDiscount = value),
                  ),
                  if (_hasDiscount) ...[
                    DropdownButtonFormField<CouponDiscountType>(
                      initialValue: _discountType,
                      decoration: const InputDecoration(
                        labelText: 'Section discount type',
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
                      decoration: const InputDecoration(
                        labelText: 'Section discount value',
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    'Curated products',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...products.map(
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: adminProvider.isSaving ? null : _save,
                      child: Text(
                        adminProvider.isSaving ? 'Saving...' : 'Save section',
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

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AdminProvider>().saveHomeSection(
      HomeSectionModel(
        id: widget.initialSection?.id ?? '',
        title: _titleController.text.trim(),
        productIds: _selectedProductIds.toList(),
        sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        sectionDiscountType: _hasDiscount ? _discountType : null,
        sectionDiscountValue: _hasDiscount
            ? double.tryParse(_discountValueController.text.trim()) ?? 0
            : null,
        createdAt: widget.initialSection?.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AdminProvider>().errorMessage ??
                'Could not save home section.',
          ),
        ),
      );
      return;
    }
    await context.read<ProductProvider>().loadInitialData();
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.view_stream_outlined, size: 52),
          SizedBox(height: 12),
          Text('No home sections yet'),
          SizedBox(height: 8),
          Text(
            'Create seasonal or promotional sections like Diwali Special and pin selected products there.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
