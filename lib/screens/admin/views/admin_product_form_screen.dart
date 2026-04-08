import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/auth_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/route/route_constants.dart';

class AdminProductFormScreen extends StatefulWidget {
  const AdminProductFormScreen({
    super.key,
    this.product,
  });

  final ProductModel? product;

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryNameController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;

  String? _imageUrl;
  String? _selectedCategoryId;
  bool _isFeatured = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _brandController = TextEditingController(text: product?.brandName ?? '');
    _descriptionController =
        TextEditingController(text: product?.description ?? '');
    _categoryNameController =
        TextEditingController(text: product?.categoryName ?? '');
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _salePriceController = TextEditingController(
      text: product?.salePrice?.toStringAsFixed(0) ?? '',
    );
    _stockController = TextEditingController(
      text: product != null ? product.stockQuantity.toString() : '0',
    );
    _imageUrl = product?.imageUrl;
    _selectedCategoryId = product?.categoryId.isNotEmpty == true
        ? product!.categoryId
        : null;
    _isFeatured = product?.isFeatured ?? false;
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    final imageUrl = await context.read<AdminProvider>().uploadImage(file);
    if (!mounted || imageUrl == null || imageUrl.isEmpty) return;

    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final categories = adminProvider.categories;

    if (authProvider.isAdmin &&
        categories.isEmpty &&
        !adminProvider.isLoading) {
      Future.microtask(adminProvider.loadAdminData);
    }

    if (!authProvider.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product form')),
        body: const Center(
          child: Text('Admin access is required to edit products.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add product' : 'Edit product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product image',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: defaultPadding / 2),
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(defaultBorderRadious),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(defaultBorderRadious),
                  ),
                  child: NetworkImageWithLoader(_imageUrl ?? ''),
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              OutlinedButton(
                onPressed: adminProvider.isSaving ? null : _pickAndUploadImage,
                child: Text(
                  adminProvider.isSaving ? 'Uploading...' : 'Upload from gallery',
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Brand is required'
                    : null,
              ),
              const SizedBox(height: defaultPadding),
              if (categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  initialValue:
                      categories.any((item) => item.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.title),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    final category = categories.firstWhere(
                      (item) => item.id == value,
                      orElse: () => const CategoryModel(id: '', title: ''),
                    );
                    setState(() {
                      _selectedCategoryId = value;
                      _categoryNameController.text = category.title;
                    });
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Choose a category' : null,
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(defaultBorderRadious),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No categories available',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        'Add categories from the admin panel first, then return here to choose one from the dropdown.',
                      ),
                      const SizedBox(height: defaultPadding),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            adminCategoriesScreenRoute,
                          );
                        },
                        child: const Text('Manage categories'),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: defaultPadding),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration:
                          const InputDecoration(labelText: 'Sale price (optional)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        if (double.tryParse(value.trim()) == null) {
                          return 'Enter a valid sale price';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock quantity'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stock is required';
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
                value: _isFeatured,
                title: const Text('Feature on home page'),
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                title: const Text('Show product in catalog'),
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
                        final messenger = ScaffoldMessenger.of(context);
                        final admin = context.read<AdminProvider>();
                        final productProvider = context.read<ProductProvider>();
                        final navigator = Navigator.of(context);
                        if (!_formKey.currentState!.validate()) return;
                        if ((_imageUrl ?? '').trim().isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Upload a product image first.'),
                            ),
                          );
                          return;
                        }
                        if (_selectedCategoryId == null ||
                            _categoryNameController.text.trim().isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Add and select a category before saving the product.',
                              ),
                            ),
                          );
                          return;
                        }

                        final categoryName = _categoryNameController.text.trim();
                        final price = double.parse(_priceController.text.trim());
                        final salePriceText = _salePriceController.text.trim();
                        final salePrice = salePriceText.isEmpty
                            ? null
                            : double.parse(salePriceText);
                        final discountPercent =
                            salePrice != null && price > salePrice
                                ? (((price - salePrice) / price) * 100).round()
                                : null;

                        final product = ProductModel(
                          id: widget.product?.id ?? '',
                          name: _nameController.text.trim(),
                          category: categoryName,
                          brandName: _brandController.text.trim(),
                          description: _descriptionController.text.trim(),
                          price: price,
                          salePrice: salePrice,
                          discountPercent: discountPercent,
                          imageUrl: _imageUrl!.trim(),
                          stockQuantity: int.parse(_stockController.text.trim()),
                          isActive: _isActive,
                          isFeatured: _isFeatured,
                          createdAt: widget.product?.createdAt,
                          updatedAt: DateTime.now(),
                        );

                        final success =
                            await admin.saveProduct(product);
                        if (!mounted || !success) return;
                        await productProvider.loadInitialData();
                        if (!mounted) return;
                        navigator.pop();
                      },
                child: Text(
                  adminProvider.isSaving ? 'Saving...' : 'Save product',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
