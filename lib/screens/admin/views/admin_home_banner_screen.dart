import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shop/components/home_banner_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminHomeBannerScreen extends StatelessWidget {
  const AdminHomeBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final banners = <HomeBannerModel>[
      ...adminProvider.homeBanners,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      appBar: AppBar(title: const Text('Home banners')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBannerEditor(context),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('Add banner'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(30)),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carousel manager',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload full banner artwork, choose display order, and the home screen will rotate these banners automatically.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          if (banners.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 52,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No banners yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add your first home banner and it will show in the carousel automatically.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ...banners.map(
              (banner) => Padding(
                padding: const EdgeInsets.only(bottom: defaultPadding),
                child: _BannerAdminCard(
                  banner: banner,
                  onEdit: () => _openBannerEditor(context, banner: banner),
                  onDelete: () => _confirmDelete(context, banner),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openBannerEditor(
    BuildContext context, {
    HomeBannerModel? banner,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BannerEditorSheet(initialBanner: banner);
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, HomeBannerModel banner) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete banner?'),
          content: const Text(
            'This removes the banner from the home carousel.',
          ),
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
        );
      },
    );

    if (ok != true || !context.mounted) return;
    final adminProvider = context.read<AdminProvider>();
    final productProvider = context.read<ProductProvider>();
    final success = await adminProvider.deleteHomeBanner(banner.id);
    if (!context.mounted) return;
    if (success) {
      await productProvider.loadInitialData();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner deleted.')),
      );
    }
  }
}

class _BannerAdminCard extends StatelessWidget {
  const _BannerAdminCard({
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  final HomeBannerModel banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.all(Radius.circular(28)),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeBannerCard(banner: banner),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaPill(
                label: 'Order ${banner.sortOrder}',
                color: const Color(0xFFF1E8C7),
                textColor: const Color(0xFF6C5313),
              ),
              const SizedBox(width: 8),
              _MetaPill(
                label: banner.isActive ? 'Active' : 'Hidden',
                color: banner.isActive
                    ? const Color(0xFFE2F4EA)
                    : const Color(0xFFF5E4E4),
                textColor: banner.isActive
                    ? const Color(0xFF246947)
                    : const Color(0xFF9C4D4D),
              ),
            ],
          ),
          if ((banner.actionCategory ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Opens: ${banner.actionCategory}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BannerEditorSheet extends StatefulWidget {
  const _BannerEditorSheet({this.initialBanner});

  final HomeBannerModel? initialBanner;

  @override
  State<_BannerEditorSheet> createState() => _BannerEditorSheetState();
}

class _BannerEditorSheetState extends State<_BannerEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _actionCategoryController;
  late final TextEditingController _sortOrderController;
  late bool _isActive;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    final banner = widget.initialBanner;
    _actionCategoryController = TextEditingController(
      text: banner?.actionCategory ?? '',
    );
    _sortOrderController = TextEditingController(
      text: (banner?.sortOrder ?? 0).toString(),
    );
    _isActive = banner?.isActive ?? true;
    _imageUrl = banner?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _actionCategoryController.dispose();
    _sortOrderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 54,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.initialBanner == null ? 'Add banner' : 'Edit banner',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Upload one banner image and choose which category opens when shoppers tap it.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (_imageUrl.trim().isNotEmpty)
                    HomeBannerCard(
                      banner: HomeBannerModel(
                        id: widget.initialBanner?.id ?? 'preview',
                        imageUrl: _imageUrl,
                        actionCategory: _actionCategoryController.text.trim(),
                        sortOrder: int.tryParse(_sortOrderController.text) ?? 0,
                        isActive: _isActive,
                      ),
                    )
                  else
                    _UploadPlaceholder(onTap: _pickAndUploadImage),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: adminProvider.isSaving
                              ? null
                              : _pickAndUploadImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(
                            _imageUrl.trim().isEmpty ? 'Upload image' : 'Replace image',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _BannerTextField(
                    controller: _actionCategoryController,
                    label: 'Open category on tap',
                    hint: 'Dogs, Cats, Cages & Houses',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _BannerTextField(
                    controller: _sortOrderController,
                    label: 'Sort order',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) return 'Required';
                      if (int.tryParse((value ?? '').trim()) == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Show banner on home'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: adminProvider.isSaving ? null : _save,
                      icon: adminProvider.isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        adminProvider.isSaving ? 'Saving...' : 'Save banner',
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

  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
    );
    if (picked == null || !mounted) return;

    final adminProvider = context.read<AdminProvider>();
    final uploaded = await adminProvider.uploadBannerImage(picked);
    if (!mounted) return;
    if ((uploaded ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            adminProvider.errorMessage ?? 'Could not upload banner image.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _imageUrl = uploaded!;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a banner image first.')),
      );
      return;
    }

    final adminProvider = context.read<AdminProvider>();
    final productProvider = context.read<ProductProvider>();
    final success = await adminProvider.saveHomeBanner(
      HomeBannerModel(
        id: widget.initialBanner?.id ?? '',
        imageUrl: _imageUrl.trim(),
        actionCategory: _actionCategoryController.text.trim().isEmpty
            ? null
            : _actionCategoryController.text.trim(),
        sortOrder: int.tryParse(_sortOrderController.text.trim()) ?? 0,
        isActive: _isActive,
      ),
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.errorMessage ?? 'Could not save banner.'),
        ),
      );
      return;
    }

    await productProvider.loadInitialData();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banner saved.')),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Ink(
        height: 190,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          border: Border.all(
            color: Theme.of(context).dividerColor,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 46,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload banner image',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Landscape artwork looks best for the home carousel.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerTextField extends StatelessWidget {
  const _BannerTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
