import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/home_banner_model.dart';
import 'package:shop/providers/admin_provider.dart';
import 'package:shop/providers/product_provider.dart';

class AdminHomeBannerScreen extends StatefulWidget {
  const AdminHomeBannerScreen({super.key});

  @override
  State<AdminHomeBannerScreen> createState() => _AdminHomeBannerScreenState();
}

class _AdminHomeBannerScreenState extends State<AdminHomeBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _highlightController = TextEditingController();
  final _dateController = TextEditingController();
  final _buttonController = TextEditingController();
  final _leftImageController = TextEditingController();
  final _rightImageController = TextEditingController();
  bool _isActive = true;
  bool _didInit = false;

  @override
  void dispose() {
    _titleController.dispose();
    _highlightController.dispose();
    _dateController.dispose();
    _buttonController.dispose();
    _leftImageController.dispose();
    _rightImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    if (!_didInit) {
      final banner = adminProvider.homeBanner;
      _titleController.text = banner.title;
      _highlightController.text = banner.highlightText;
      _dateController.text = banner.dateText;
      _buttonController.text = banner.buttonText;
      _leftImageController.text = banner.leftImageUrl;
      _rightImageController.text = banner.rightImageUrl;
      _isActive = banner.isActive;
      _didInit = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home banner')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          _PreviewCard(
            title: _titleController.text.trim().isEmpty
                ? 'Pet Winter Offer'
                : _titleController.text.trim(),
            highlightText: _highlightController.text.trim().isEmpty
                ? '25% OFF'
                : _highlightController.text.trim(),
            dateText: _dateController.text.trim().isEmpty
                ? 'Nov 16 - Dec 22'
                : _dateController.text.trim(),
            buttonText: _buttonController.text.trim().isEmpty
                ? 'Shop Now'
                : _buttonController.text.trim(),
            isActive: _isActive,
          ),
          const SizedBox(height: defaultPadding),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _AdminField(
                  controller: _titleController,
                  label: 'Banner title',
                  hint: 'Pet Winter Offer',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: defaultPadding),
                _AdminField(
                  controller: _highlightController,
                  label: 'Highlight text',
                  hint: '25% OFF',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: defaultPadding),
                _AdminField(
                  controller: _dateController,
                  label: 'Date text',
                  hint: 'Nov 16 - Dec 22',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: defaultPadding),
                _AdminField(
                  controller: _buttonController,
                  label: 'Button text',
                  hint: 'Shop Now',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: defaultPadding),
                _AdminField(
                  controller: _leftImageController,
                  label: 'Left image URL (optional)',
                  hint: 'https://...',
                ),
                const SizedBox(height: defaultPadding),
                _AdminField(
                  controller: _rightImageController,
                  label: 'Right image URL (optional)',
                  hint: 'https://...',
                ),
                const SizedBox(height: defaultPadding / 2),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Banner active'),
                  subtitle: const Text(
                    'Turn off to show fallback default banner',
                  ),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                const SizedBox(height: defaultPadding),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: adminProvider.isSaving ? null : _onSave,
                    child: Text(
                      adminProvider.isSaving ? 'Saving...' : 'Save banner',
                    ),
                  ),
                ),
                if (adminProvider.errorMessage != null) ...[
                  const SizedBox(height: defaultPadding),
                  Text(
                    adminProvider.errorMessage!,
                    style: const TextStyle(color: errorColor),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    final adminProvider = context.read<AdminProvider>();
    final success = await adminProvider.saveHomeBanner(
      HomeBannerModel(
        id: 'home_main',
        title: _titleController.text.trim(),
        highlightText: _highlightController.text.trim(),
        dateText: _dateController.text.trim(),
        buttonText: _buttonController.text.trim(),
        leftImageUrl: _leftImageController.text.trim(),
        rightImageUrl: _rightImageController.text.trim(),
        isActive: _isActive,
      ),
    );

    if (!mounted) return;
    if (success) {
      await context.read<ProductProvider>().loadInitialData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Home banner saved.')));
    }
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: (value) {
        if ((value ?? '').trim().isEmpty &&
            (label == 'Banner title' ||
                label == 'Highlight text' ||
                label == 'Date text' ||
                label == 'Button text')) {
          return 'Required';
        }
        return null;
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.highlightText,
    required this.dateText,
    required this.buttonText,
    required this.isActive,
  });

  final String title;
  final String highlightText;
  final String dateText;
  final String buttonText;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        gradient: LinearGradient(
          colors: isActive
              ? const [Color(0xFF1FA48E), Color(0xFF128B7B)]
              : const [Color(0xFF9E9E9E), Color(0xFF757575)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            highlightText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(dateText, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F36A),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
