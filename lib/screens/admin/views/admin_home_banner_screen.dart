import 'package:flutter/material.dart';
import 'package:shop/components/home_banner_card.dart';
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
  final _startColorController = TextEditingController();
  final _endColorController = TextEditingController();
  bool _isActive = true;
  bool _didInit = false;

  static const List<_BannerColorPreset> _presets = <_BannerColorPreset>[
    _BannerColorPreset(name: 'Ocean', startHex: '#1FA48E', endHex: '#128B7B'),
    _BannerColorPreset(
      name: 'Twilight',
      startHex: '#2A334A',
      endHex: '#1A2238',
    ),
    _BannerColorPreset(name: 'Sunset', startHex: '#FF9F7A', endHex: '#FF5E62'),
    _BannerColorPreset(name: 'Berry', startHex: '#7B61FF', endHex: '#5140C4'),
    _BannerColorPreset(name: 'Mint', startHex: '#D9FFF0', endHex: '#B4F2D2'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _highlightController.dispose();
    _dateController.dispose();
    _buttonController.dispose();
    _leftImageController.dispose();
    _rightImageController.dispose();
    _startColorController.dispose();
    _endColorController.dispose();
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
      _startColorController.text = banner.startColorHex ?? '';
      _endColorController.text = banner.endColorHex ?? '';
      _isActive = banner.isActive;
      _didInit = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home banner')),
      body: ListView(
        padding: const EdgeInsets.all(defaultPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(28)),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF18392F), Color(0xFFF1A208)],
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Banner preview',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This is how the hero banner appears on the home page.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                HomeBannerCard(banner: _previewBanner, onTapShopNow: null),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(28)),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Banner content',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use sharper copy, one strong offer line, and optional pet imagery for the best visual balance.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: defaultPadding + 4),
                  _AdminField(
                    controller: _titleController,
                    label: 'Banner title',
                    hint: 'PetsWorld',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding),
                  _AdminField(
                    controller: _highlightController,
                    label: 'Highlight text',
                    hint: 'Premium pet essentials',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding),
                  _AdminField(
                    controller: _dateController,
                    label: 'Date text',
                    hint: 'Fresh arrivals for every routine',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding),
                  _AdminField(
                    controller: _buttonController,
                    label: 'Button text',
                    hint: 'Shop now',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding),
                  _AdminField(
                    controller: _leftImageController,
                    label: 'Left image path or URL (optional)',
                    hint: 'assets/images/home/banner_cat.png or https://...',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding),
                  _AdminField(
                    controller: _rightImageController,
                    label: 'Right image path or URL (optional)',
                    hint: 'assets/images/home/banner_dog.png or https://...',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: defaultPadding + 4),
                  Text(
                    'Banner palette',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a preset or fine-tune both gradient stops with custom hex values.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: defaultPadding / 1.2),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _presets
                        .map(
                          (preset) => _ColorPresetChip(
                            preset: preset,
                            isSelected:
                                _normalizeHex(_startColorController.text) ==
                                    preset.startHex &&
                                _normalizeHex(_endColorController.text) ==
                                    preset.endHex,
                            onTap: () {
                              setState(() {
                                _startColorController.text = preset.startHex;
                                _endColorController.text = preset.endHex;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Expanded(
                        child: _AdminField(
                          controller: _startColorController,
                          label: 'Start color hex (optional)',
                          hint: '#1FA48E',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: _AdminField(
                          controller: _endColorController,
                          label: 'End color hex (optional)',
                          hint: '#128B7B',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
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
        startColorHex: _normalizeHex(_startColorController.text),
        endColorHex: _normalizeHex(_endColorController.text),
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

  HomeBannerModel get _previewBanner {
    return HomeBannerModel(
      id: 'home_main',
      title: _titleController.text.trim(),
      highlightText: _highlightController.text.trim(),
      dateText: _dateController.text.trim(),
      buttonText: _buttonController.text.trim(),
      leftImageUrl: _leftImageController.text.trim(),
      rightImageUrl: _rightImageController.text.trim(),
      startColorHex: _normalizeHex(_startColorController.text),
      endColorHex: _normalizeHex(_endColorController.text),
      isActive: _isActive,
    );
  }

  String? _normalizeHex(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalized = trimmed.startsWith('#') ? trimmed : '#$trimmed';
    final hex = normalized.replaceAll('#', '');
    if (hex.length != 6 && hex.length != 8) {
      return null;
    }
    return '#${hex.toUpperCase()}';
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
        if (label.contains('color hex')) {
          final trimmed = (value ?? '').trim();
          if (trimmed.isEmpty) return null;
          final normalized = trimmed.startsWith('#')
              ? trimmed.substring(1)
              : trimmed;
          if (normalized.length != 6 && normalized.length != 8) {
            return 'Use 6 or 8 hex digits';
          }
          if (int.tryParse(normalized, radix: 16) == null) {
            return 'Invalid hex color';
          }
        }
        return null;
      },
    );
  }
}

class _ColorPresetChip extends StatelessWidget {
  const _ColorPresetChip({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final _BannerColorPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? primaryColor
        : Theme.of(context).dividerColor;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [
                    Color(_hexToColor(preset.startHex)),
                    Color(_hexToColor(preset.endHex)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              preset.name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  int _hexToColor(String value) {
    final cleaned = value.replaceAll('#', '');
    return int.parse('FF$cleaned', radix: 16);
  }
}

class _BannerColorPreset {
  const _BannerColorPreset({
    required this.name,
    required this.startHex,
    required this.endHex,
  });

  final String name;
  final String startHex;
  final String endHex;
}
