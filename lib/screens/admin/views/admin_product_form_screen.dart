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
  const AdminProductFormScreen({super.key, this.product});

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
  late List<String> _galleryImageUrls;
  String? _selectedMajorCategoryId;
  String? _selectedSubCategoryId;
  bool _isFeatured = false;
  bool _isPopular = false;
  bool _isNewArrival = false;
  bool _isActive = true;
  bool _useCustomCategory = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _brandController = TextEditingController(text: product?.brandName ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryNameController = TextEditingController(
      text: product?.categoryName ?? '',
    );
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
    _galleryImageUrls = product?.galleryImages.toList() ?? <String>[];
    _isFeatured = product?.isFeatured ?? false;
    _isPopular = product?.isPopular ?? false;
    _isNewArrival = product?.isNewArrival ?? false;
    _isActive = product?.isActive ?? true;
    _useCustomCategory = false;
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
    if (_galleryImageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can upload up to 5 product images only.'),
        ),
      );
      return;
    }

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file == null || !mounted) return;

    final imageUrl = await context.read<AdminProvider>().uploadImage(file);
    if (!mounted || imageUrl == null || imageUrl.isEmpty) return;

    setState(() {
      _galleryImageUrls = <String>[
        ..._galleryImageUrls,
        imageUrl,
      ];
      _imageUrl = _galleryImageUrls.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final categories = adminProvider.categories;
    final majorCategories = categories
        .where((item) => item.parentId == null)
        .toList();
    final categoryById = <String, CategoryModel>{
      for (final category in categories) category.id: category,
    };
    if (!_useCustomCategory &&
        majorCategories.isNotEmpty &&
        _selectedMajorCategoryId == null) {
      _initializeCategorySelection(
        majorCategories: majorCategories,
        categories: categories,
      );
      _applyCategorySelectionToController(
        categoryById,
        _selectedMajorCategoryId,
        _selectedSubCategoryId,
      );
    }

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
                'Product images',
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
              if (_galleryImageUrls.isNotEmpty) ...[
                const SizedBox(height: defaultPadding / 2),
                SizedBox(
                  height: 78,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _galleryImageUrls.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: defaultPadding / 2),
                    itemBuilder: (context, index) {
                      final image = _galleryImageUrls[index];
                      final isPrimary = index == 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _galleryImageUrls = <String>[
                                  image,
                                  ..._galleryImageUrls.where(
                                    (item) => item != image,
                                  ),
                                ];
                                _imageUrl = _galleryImageUrls.first;
                              });
                            },
                            child: Container(
                              width: 78,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: isPrimary
                                      ? primaryColor
                                      : Theme.of(context).dividerColor,
                                  width: isPrimary ? 2 : 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                child: NetworkImageWithLoader(image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _galleryImageUrls = _galleryImageUrls
                                      .where((item) => item != image)
                                      .toList();
                                  _imageUrl = _galleryImageUrls.isEmpty
                                      ? null
                                      : _galleryImageUrls.first;
                                });
                              },
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: errorColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(999),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: defaultPadding / 2),
              OutlinedButton(
                onPressed: adminProvider.isSaving ? null : _pickAndUploadImage,
                child: Text(
                  adminProvider.isSaving
                      ? 'Uploading...'
                      : 'Upload from gallery (${_galleryImageUrls.length}/5)',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'The first image is used as the main product photo.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _useCustomCategory = !_useCustomCategory;
                        if (!_useCustomCategory && majorCategories.isNotEmpty) {
                          _selectedMajorCategoryId ??= majorCategories.first.id;
                          final subOptions = categories
                              .where(
                                (item) =>
                                    item.parentId == _selectedMajorCategoryId,
                              )
                              .toList();
                          _selectedSubCategoryId = subOptions.isEmpty
                              ? null
                              : (_selectedSubCategoryId != null &&
                                    subOptions.any(
                                      (item) =>
                                          item.id == _selectedSubCategoryId,
                                    ))
                              ? _selectedSubCategoryId
                              : subOptions.first.id;
                          _applyCategorySelectionToController(
                            categoryById,
                            _selectedMajorCategoryId,
                            _selectedSubCategoryId,
                          );
                        }
                      });
                    },
                    child: Text(
                      _useCustomCategory ? 'Use dropdown' : 'Use custom text',
                    ),
                  ),
                ],
              ),
              if (!_useCustomCategory && majorCategories.isNotEmpty)
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue:
                          majorCategories.any(
                            (item) => item.id == _selectedMajorCategoryId,
                          )
                          ? _selectedMajorCategoryId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Major category',
                      ),
                      items: majorCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        final subOptions = categories
                            .where((item) => item.parentId == value)
                            .toList();
                        setState(() {
                          _selectedMajorCategoryId = value;
                          _selectedSubCategoryId = subOptions.isEmpty
                              ? null
                              : subOptions.first.id;
                          _applyCategorySelectionToController(
                            categoryById,
                            _selectedMajorCategoryId,
                            _selectedSubCategoryId,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    DropdownButtonFormField<String>(
                      initialValue:
                          _subCategoryOptions(
                            categories,
                            _selectedMajorCategoryId,
                          ).any((item) => item.id == _selectedSubCategoryId)
                          ? _selectedSubCategoryId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Sub category',
                      ),
                      items:
                          _subCategoryOptions(
                                categories,
                                _selectedMajorCategoryId,
                              )
                              .map(
                                (category) => DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.title),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubCategoryId = value;
                          _applyCategorySelectionToController(
                            categoryById,
                            _selectedMajorCategoryId,
                            _selectedSubCategoryId,
                          );
                        });
                      },
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    labelText: categories.isEmpty
                        ? 'Category name (manual)'
                        : 'Category name (custom)',
                    hintText: 'Example: Dog Food (All)',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Category is required'
                      : null,
                ),
              if (categories.isEmpty) ...[
                const SizedBox(height: defaultPadding / 2),
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
                        'No categories available in Firestore',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      const Text(
                        'You can still type a category manually, or sync/add categories from the admin panel.',
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
              ],
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
                      decoration: const InputDecoration(
                        labelText: 'Sale price (optional)',
                      ),
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
                value: _isPopular,
                title: const Text('Mark as Best Seller'),
                onChanged: (value) {
                  setState(() {
                    _isPopular = value;
                  });
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isNewArrival,
                title: const Text('Show in New Arrivals'),
                subtitle: const Text(
                  'Turn this on only for products you want in the home section.',
                ),
                onChanged: (value) {
                  setState(() {
                    _isNewArrival = value;
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
                              content: Text('Upload at least one product image first.'),
                            ),
                          );
                          return;
                        }
                        if (_categoryNameController.text.trim().isEmpty) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Provide a category before saving the product.',
                              ),
                            ),
                          );
                          return;
                        }

                        final categoryName = _resolvedCategoryName(
                          categoryById: categoryById,
                          selectedMajorCategoryId: _selectedMajorCategoryId,
                          selectedSubCategoryId: _selectedSubCategoryId,
                          fallback: _categoryNameController.text.trim(),
                        );
                        final price = double.parse(
                          _priceController.text.trim(),
                        );
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
                          imageUrls: _galleryImageUrls,
                          stockQuantity: int.parse(
                            _stockController.text.trim(),
                          ),
                          isActive: _isActive,
                          isFeatured: _isFeatured,
                          isPopular: _isPopular,
                          isNewArrival: _isNewArrival,
                          createdAt: widget.product?.createdAt,
                          updatedAt: widget.product?.updatedAt,
                        );

                        final success = await admin.saveProduct(product);
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

  List<CategoryModel> _subCategoryOptions(
    List<CategoryModel> categories,
    String? majorId,
  ) {
    if (majorId == null || majorId.isEmpty) return const <CategoryModel>[];
    return categories.where((item) => item.parentId == majorId).toList();
  }

  void _initializeCategorySelection({
    required List<CategoryModel> majorCategories,
    required List<CategoryModel> categories,
  }) {
    final existing = _categoryNameController.text.trim();
    final parts = existing
        .split('>')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (parts.isNotEmpty) {
      CategoryModel? major;
      for (final item in majorCategories) {
        if (item.title.toLowerCase() == parts.first.toLowerCase()) {
          major = item;
          break;
        }
      }
      if (major != null) {
        _selectedMajorCategoryId = major.id;
      }
    }

    _selectedMajorCategoryId ??= majorCategories.first.id;
    final subOptions = _subCategoryOptions(
      categories,
      _selectedMajorCategoryId,
    );
    if (parts.length >= 2) {
      CategoryModel? sub;
      for (final item in subOptions) {
        if (item.title.toLowerCase() == parts[1].toLowerCase()) {
          sub = item;
          break;
        }
      }
      if (sub != null) {
        _selectedSubCategoryId = sub.id;
        return;
      }
    }
    _selectedSubCategoryId = subOptions.isEmpty ? null : subOptions.first.id;
  }

  void _applyCategorySelectionToController(
    Map<String, CategoryModel> byId,
    String? majorId,
    String? subId,
  ) {
    final major = majorId == null ? null : byId[majorId];
    final sub = subId == null ? null : byId[subId];
    if (major == null) return;
    _categoryNameController.text = sub == null
        ? major.title
        : '${major.title} > ${sub.title}';
  }

  String _resolvedCategoryName({
    required Map<String, CategoryModel> categoryById,
    required String? selectedMajorCategoryId,
    required String? selectedSubCategoryId,
    required String fallback,
  }) {
    if (_useCustomCategory) {
      return fallback;
    }
    final major = selectedMajorCategoryId == null
        ? null
        : categoryById[selectedMajorCategoryId];
    final sub = selectedSubCategoryId == null
        ? null
        : categoryById[selectedSubCategoryId];
    if (major == null) {
      return fallback;
    }
    return sub == null ? major.title : '${major.title} > ${sub.title}';
  }
}
