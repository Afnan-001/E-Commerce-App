import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/category_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/product_option_model.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryNameController;
  late final TextEditingController _defaultPackLabelController;
  late final TextEditingController _priceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late final List<_PackOptionDraft> _extraPackDrafts;

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
    final defaultPack = product?.defaultPackOption;
    final extraPacks = (product?.packOptions ?? const <ProductOptionModel>[])
        .where((item) => defaultPack == null || item.id != defaultPack.id)
        .toList();
    _nameController = TextEditingController(text: product?.name ?? '');
    _brandController = TextEditingController(text: product?.brandName ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryNameController = TextEditingController(
      text: product?.categoryName ?? '',
    );
    _defaultPackLabelController = TextEditingController(
      text: defaultPack?.label ?? 'Standard',
    );
    _priceController = TextEditingController(
      text: (defaultPack?.price ?? product?.price)?.toStringAsFixed(0) ?? '',
    );
    _salePriceController = TextEditingController(
      text:
          (defaultPack?.salePrice ?? product?.salePrice)?.toStringAsFixed(0) ??
          '',
    );
    _stockController = TextEditingController(
      text: '${defaultPack?.stockQuantity ?? product?.stockQuantity ?? 0}',
    );
    _extraPackDrafts = extraPacks
        .map((item) => _PackOptionDraft.fromOption(item))
        .toList();
    _imageUrl = product?.imageUrl;
    _galleryImageUrls = product?.galleryImages.toList() ?? <String>[];
    _isFeatured = product?.isFeatured ?? false;
    _isPopular = product?.isPopular ?? false;
    _isNewArrival = product?.isNewArrival ?? false;
    _isActive = product?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    _defaultPackLabelController.dispose();
    _priceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    for (final draft in _extraPackDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    if (_galleryImageUrls.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can upload up to 5 product images only.')),
      );
      return;
    }

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    final imageUrl = await context.read<AdminProvider>().uploadImage(file);
    if (!mounted || (imageUrl ?? '').trim().isEmpty) return;
    setState(() {
      _galleryImageUrls = <String>[..._galleryImageUrls, imageUrl!.trim()];
      _imageUrl = _galleryImageUrls.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final categories = adminProvider.categories;
    final majorCategories = categories.where((item) => item.parentId == null).toList();
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
        body: const Center(child: Text('Admin access is required to edit products.')),
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
              _buildImageSection(adminProvider),
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
              _buildCategorySection(categories, majorCategories, categoryById),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 3,
                maxLines: 5,
              ),
              const SizedBox(height: defaultPadding),
              _buildPackSection(),
              const SizedBox(height: defaultPadding),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFeatured,
                title: const Text('Feature on home page'),
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPopular,
                title: const Text('Mark as Best Seller'),
                onChanged: (value) => setState(() => _isPopular = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isNewArrival,
                title: const Text('Show in New Arrivals'),
                onChanged: (value) => setState(() => _isNewArrival = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                title: const Text('Show product in catalog'),
                onChanged: (value) => setState(() => _isActive = value),
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
                onPressed: adminProvider.isSaving ? null : () => _saveProduct(categoryById),
                child: Text(adminProvider.isSaving ? 'Saving...' : 'Save product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(AdminProvider adminProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product images', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: defaultPadding / 2),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
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
              separatorBuilder: (_, _) => const SizedBox(width: defaultPadding / 2),
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
                            ..._galleryImageUrls.where((item) => item != image),
                          ];
                          _imageUrl = _galleryImageUrls.first;
                        });
                      },
                      child: Container(
                        width: 78,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          border: Border.all(
                            color: isPrimary ? primaryColor : Theme.of(context).dividerColor,
                            width: isPrimary ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
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
                            _galleryImageUrls =
                                _galleryImageUrls.where((item) => item != image).toList();
                            _imageUrl = _galleryImageUrls.isEmpty ? null : _galleryImageUrls.first;
                          });
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: errorColor,
                            borderRadius: BorderRadius.all(Radius.circular(999)),
                          ),
                          child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
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
      ],
    );
  }

  Widget _buildCategorySection(
    List<CategoryModel> categories,
    List<CategoryModel> majorCategories,
    Map<String, CategoryModel> categoryById,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Category', style: Theme.of(context).textTheme.titleSmall)),
            TextButton(
              onPressed: () {
                setState(() {
                  _useCustomCategory = !_useCustomCategory;
                  if (!_useCustomCategory && majorCategories.isNotEmpty) {
                    _selectedMajorCategoryId ??= majorCategories.first.id;
                    final subOptions =
                        categories.where((item) => item.parentId == _selectedMajorCategoryId).toList();
                    _selectedSubCategoryId = subOptions.isEmpty ? null : subOptions.first.id;
                    _applyCategorySelectionToController(
                      categoryById,
                      _selectedMajorCategoryId,
                      _selectedSubCategoryId,
                    );
                  }
                });
              },
              child: Text(_useCustomCategory ? 'Use dropdown' : 'Use custom text'),
            ),
          ],
        ),
        if (!_useCustomCategory && majorCategories.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            initialValue: majorCategories.any((item) => item.id == _selectedMajorCategoryId)
                ? _selectedMajorCategoryId
                : null,
            decoration: const InputDecoration(labelText: 'Major category'),
            items: majorCategories
                .map((category) => DropdownMenuItem(value: category.id, child: Text(category.title)))
                .toList(),
            onChanged: (value) {
              final subOptions = categories.where((item) => item.parentId == value).toList();
              setState(() {
                _selectedMajorCategoryId = value;
                _selectedSubCategoryId = subOptions.isEmpty ? null : subOptions.first.id;
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
            initialValue: _subCategoryOptions(categories, _selectedMajorCategoryId)
                    .any((item) => item.id == _selectedSubCategoryId)
                ? _selectedSubCategoryId
                : null,
            decoration: const InputDecoration(labelText: 'Sub category'),
            items: _subCategoryOptions(categories, _selectedMajorCategoryId)
                .map((category) => DropdownMenuItem(value: category.id, child: Text(category.title)))
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
        ] else
          TextFormField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category name',
              hintText: 'Example: Dog Food > Dry Food',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Category is required'
                : null,
          ),
        if (categories.isEmpty) ...[
          const SizedBox(height: defaultPadding / 2),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, adminCategoriesScreenRoute),
            child: const Text('Manage categories'),
          ),
        ],
      ],
    );
  }

  Widget _buildPackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pack options', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: defaultPadding / 2),
        TextFormField(
          controller: _defaultPackLabelController,
          decoration: const InputDecoration(labelText: 'Default pack label'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Pack label is required'
              : null,
        ),
        const SizedBox(height: defaultPadding / 2),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Default price'),
                keyboardType: TextInputType.number,
                validator: _validatePrice,
              ),
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: TextFormField(
                controller: _salePriceController,
                decoration: const InputDecoration(labelText: 'Default sale price'),
                keyboardType: TextInputType.number,
                validator: (value) => _validateSalePrice(value, priceController: _priceController),
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding / 2),
        TextFormField(
          controller: _stockController,
          decoration: const InputDecoration(labelText: 'Default stock quantity'),
          keyboardType: TextInputType.number,
          validator: _validateStock,
        ),
        const SizedBox(height: defaultPadding),
        ..._extraPackDrafts.asMap().entries.map((entry) {
          final index = entry.key;
          final draft = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: defaultPadding),
            child: Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: const BorderRadius.all(Radius.circular(defaultBorderRadious)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Extra pack ${index + 1}')),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            draft.dispose();
                            _extraPackDrafts.removeAt(index);
                          });
                        },
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: draft.labelController,
                    decoration: const InputDecoration(labelText: 'Pack label'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Pack label is required'
                        : null,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: draft.priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator: _validatePrice,
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: TextFormField(
                          controller: draft.salePriceController,
                          decoration: const InputDecoration(labelText: 'Sale price'),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              _validateSalePrice(value, priceController: draft.priceController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  TextFormField(
                    controller: draft.stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    validator: _validateStock,
                  ),
                ],
              ),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () => setState(() => _extraPackDrafts.add(_PackOptionDraft.empty())),
          icon: const Icon(Icons.add),
          label: const Text('Add another pack'),
        ),
      ],
    );
  }

  Future<void> _saveProduct(Map<String, CategoryModel> categoryById) async {
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) return;
    if ((_imageUrl ?? '').trim().isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Upload at least one product image first.')),
      );
      return;
    }

    final categoryName = _resolvedCategoryName(
      categoryById: categoryById,
      selectedMajorCategoryId: _selectedMajorCategoryId,
      selectedSubCategoryId: _selectedSubCategoryId,
      fallback: _categoryNameController.text.trim(),
    );
    final packOptions = _buildPackOptions();
    final defaultPack = packOptions.first;
    final product = ProductModel(
      id: widget.product?.id ?? '',
      name: _nameController.text.trim(),
      category: categoryName,
      brandName: _brandController.text.trim(),
      description: _descriptionController.text.trim(),
      price: defaultPack.price,
      salePrice: defaultPack.salePrice,
      discountPercent: defaultPack.discountPercent,
      imageUrl: _imageUrl!.trim(),
      imageUrls: _galleryImageUrls,
      stockQuantity: defaultPack.stockQuantity,
      packOptions: packOptions,
      isActive: _isActive,
      isFeatured: _isFeatured,
      isPopular: _isPopular,
      isNewArrival: _isNewArrival,
      createdAt: widget.product?.createdAt,
      updatedAt: widget.product?.updatedAt,
    );

    final admin = context.read<AdminProvider>();
    final products = context.read<ProductProvider>();
    final success = await admin.saveProduct(product);
    if (!mounted || !success) return;
    await products.loadInitialData();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  List<ProductOptionModel> _buildPackOptions() {
    final items = <ProductOptionModel>[
      ProductOptionModel(
        id: _slugify(_defaultPackLabelController.text),
        label: _defaultPackLabelController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        salePrice: _salePriceController.text.trim().isEmpty
            ? null
            : double.parse(_salePriceController.text.trim()),
        stockQuantity: int.parse(_stockController.text.trim()),
        isDefault: true,
      ),
    ];
    for (final draft in _extraPackDrafts) {
      items.add(
        ProductOptionModel(
          id: draft.id.isEmpty ? _slugify(draft.labelController.text) : draft.id,
          label: draft.labelController.text.trim(),
          price: double.parse(draft.priceController.text.trim()),
          salePrice: draft.salePriceController.text.trim().isEmpty
              ? null
              : double.parse(draft.salePriceController.text.trim()),
          stockQuantity: int.parse(draft.stockController.text.trim()),
        ),
      );
    }
    return items;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    if (double.tryParse(value.trim()) == null) return 'Enter a valid price';
    return null;
  }

  String? _validateSalePrice(
    String? value, {
    required TextEditingController priceController,
  }) {
    if (value == null || value.trim().isEmpty) return null;
    final salePrice = double.tryParse(value.trim());
    final price = double.tryParse(priceController.text.trim());
    if (salePrice == null) return 'Enter a valid sale price';
    if (price != null && salePrice >= price) {
      return 'Sale price must be lower than price';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) return 'Stock is required';
    if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  String _slugify(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }

  List<CategoryModel> _subCategoryOptions(List<CategoryModel> categories, String? majorId) {
    if (majorId == null || majorId.isEmpty) return const <CategoryModel>[];
    return categories.where((item) => item.parentId == majorId).toList();
  }

  void _initializeCategorySelection({
    required List<CategoryModel> majorCategories,
    required List<CategoryModel> categories,
  }) {
    final parts = _categoryNameController.text
        .split('>')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (parts.isNotEmpty) {
      for (final item in majorCategories) {
        if (item.title.toLowerCase() == parts.first.toLowerCase()) {
          _selectedMajorCategoryId = item.id;
          break;
        }
      }
    }
    _selectedMajorCategoryId ??= majorCategories.first.id;
    final subOptions = _subCategoryOptions(categories, _selectedMajorCategoryId);
    if (parts.length >= 2) {
      for (final item in subOptions) {
        if (item.title.toLowerCase() == parts[1].toLowerCase()) {
          _selectedSubCategoryId = item.id;
          return;
        }
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
    _categoryNameController.text = sub == null ? major.title : '${major.title} > ${sub.title}';
  }

  String _resolvedCategoryName({
    required Map<String, CategoryModel> categoryById,
    required String? selectedMajorCategoryId,
    required String? selectedSubCategoryId,
    required String fallback,
  }) {
    if (_useCustomCategory) return fallback;
    final major = selectedMajorCategoryId == null ? null : categoryById[selectedMajorCategoryId];
    final sub = selectedSubCategoryId == null ? null : categoryById[selectedSubCategoryId];
    if (major == null) return fallback;
    return sub == null ? major.title : '${major.title} > ${sub.title}';
  }
}

class _PackOptionDraft {
  _PackOptionDraft({
    required this.id,
    required this.labelController,
    required this.priceController,
    required this.salePriceController,
    required this.stockController,
  });

  factory _PackOptionDraft.empty() => _PackOptionDraft(
        id: '',
        labelController: TextEditingController(),
        priceController: TextEditingController(),
        salePriceController: TextEditingController(),
        stockController: TextEditingController(text: '0'),
      );

  factory _PackOptionDraft.fromOption(ProductOptionModel option) => _PackOptionDraft(
        id: option.id,
        labelController: TextEditingController(text: option.label),
        priceController: TextEditingController(text: option.price.toStringAsFixed(0)),
        salePriceController: TextEditingController(
          text: option.salePrice?.toStringAsFixed(0) ?? '',
        ),
        stockController: TextEditingController(text: '${option.stockQuantity}'),
      );

  final String id;
  final TextEditingController labelController;
  final TextEditingController priceController;
  final TextEditingController salePriceController;
  final TextEditingController stockController;

  void dispose() {
    labelController.dispose();
    priceController.dispose();
    salePriceController.dispose();
    stockController.dispose();
  }
}
