import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminCategoryFormScreen extends StatefulWidget {
  const AdminCategoryFormScreen({super.key, this.category});

  final CategoryModel? category;

  @override
  State<AdminCategoryFormScreen> createState() =>
      _AdminCategoryFormScreenState();
}

class _AdminCategoryFormScreenState extends State<AdminCategoryFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  late final TextEditingController _titleController;
  late final TextEditingController _imageController;
  late final TextEditingController _sortOrderController;
  bool _isActive = true;
  String? _selectedParentId;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final category = widget.category;
    _titleController = TextEditingController(text: category?.title ?? '');
    _imageController = TextEditingController(text: category?.image ?? '');
    _sortOrderController = TextEditingController(
      text: category?.sortOrder.toString() ?? '0',
    );
    _isActive = category?.isActive ?? true;
    _selectedParentId = category?.parentId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
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

  Future<void> _pickAndUploadImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null || !mounted) return;

    setState(() {
      _isUploadingImage = true;
    });

    final imageUrl = await context.read<AdminProvider>().uploadCategoryImage(
      file,
    );
    if (!mounted) return;

    setState(() {
      _isUploadingImage = false;
      if ((imageUrl ?? '').trim().isNotEmpty) {
        _imageController.text = imageUrl!.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final parentOptions =
        adminProvider.categories
            .where((c) => c.parentId == null && c.id != widget.category?.id)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

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
              DropdownButtonFormField<String?>(
                initialValue: _selectedParentId,
                decoration: const InputDecoration(
                  labelText: 'Major category',
                  hintText: 'No parent = major category (Dogs/Cats)',
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No parent (major category)'),
                  ),
                  ...parentOptions.map(
                    (parent) => DropdownMenuItem<String?>(
                      value: parent.id,
                      child: Text(parent.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                  });
                },
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Category image URL (Cloudinary or asset path)',
                  hintText: 'https://res.cloudinary.com/...',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: defaultPadding / 2),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: adminProvider.isSaving || _isUploadingImage
                      ? null
                      : _pickAndUploadImage,
                  icon: _isUploadingImage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_rounded),
                  label: Text(
                    _isUploadingImage
                        ? 'Uploading to Cloudinary...'
                        : 'Select image and upload to Cloudinary',
                  ),
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              Container(
                height: 96,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(defaultBorderRadious),
                  ),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: NetworkImageWithLoader(
                  _imageController.text.trim(),
                  fit: BoxFit.cover,
                  radius: defaultBorderRadious,
                ),
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
                          id:
                              widget.category?.id ??
                              _slugify(_titleController.text),
                          title: _titleController.text.trim(),
                          image: _imageController.text.trim().isEmpty
                              ? null
                              : _imageController.text.trim(),
                          svgSrc: _imageController.text.trim().isEmpty
                              ? null
                              : _imageController.text.trim(),
                          parentId: _selectedParentId,
                          isActive: _isActive,
                          sortOrder: int.parse(
                            _sortOrderController.text.trim(),
                          ),
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
