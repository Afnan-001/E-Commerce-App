import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  const AdminCategoryFormScreen({
    super.key,
    this.category,
  });

  final CategoryModel? category;

  @override
  State<AdminCategoryFormScreen> createState() => _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _svgController;
  late final TextEditingController _sortOrderController;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _titleController = TextEditingController(text: category?.title ?? '');
    _svgController = TextEditingController(
      text: category?.svgSrc ?? 'assets/icons/Category.svg',
    );
    _sortOrderController = TextEditingController(
      text: category?.sortOrder.toString() ?? '0',
    );
    _isActive = category?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _svgController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category form')),
        body: const Center(
          child: Text('Admin access is required to edit categories.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add category' : 'Edit category'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Category title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Category title is required'
                    : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _svgController,
                decoration: const InputDecoration(
                  labelText: 'Icon asset path',
                  hintText: 'assets/icons/Category.svg',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Icon path is required'
                    : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _sortOrderController,
                decoration: const InputDecoration(labelText: 'Sort order'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Sort order is required';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: defaultPadding),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                title: const Text('Show category in app'),
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
              ),
              if (adminProvider.errorMessage != null) ...[
                const SizedBox(height: defaultPadding / 2),
                Text(
                  adminProvider.errorMessage!,
                  style: const TextStyle(color: errorColor),
                ),
              ],
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: adminProvider.isSaving
                    ? null
                    : () async {
                        final admin = context.read<AdminProvider>();
                        final product = context.read<ProductProvider>();
                        final navigator = Navigator.of(context);
                        if (!_formKey.currentState!.validate()) return;

                        final category = CategoryModel(
                          id: widget.category?.id ?? _slugify(_titleController.text),
                          title: _titleController.text.trim(),
                          svgSrc: _svgController.text.trim(),
                          isActive: _isActive,
                          sortOrder: int.parse(_sortOrderController.text.trim()),
                        );

                        final success = await admin.saveCategory(category);
                        if (!mounted || !success) return;
                        await product.loadInitialData();
                        if (!mounted) return;
                        navigator.pop();
                      },
                child: Text(
                  adminProvider.isSaving ? 'Saving...' : 'Save category',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
