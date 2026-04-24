import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shop/constants.dart';
import 'package:shop/core/services/pincode_service.dart';
import 'package:shop/models/address_model.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key, this.initialAddress});

  final AddressModel? initialAddress;

  bool get isEditMode => initialAddress != null;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pincodeService = PincodeService();

  final Map<String, PincodeLookupResult> _pincodeCache =
      <String, PincodeLookupResult>{};

  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _line1Controller;
  late final TextEditingController _line2Controller;
  late final TextEditingController _districtController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _pincodeController;
  late final TextEditingController _landmarkController;
  late final TextEditingController _customLabelController;

  static const List<String> _presetLabels = <String>['Home', 'Work', 'Other'];
  static const Duration _pincodeDebounceDuration = Duration(milliseconds: 500);
  static const Set<String> _supportedDistricts = <String>{
    'solapur',
    'solhapur',
  };
  static const Set<String> _supportedCityHints = <String>{
    'solapur',
    'solhapur',
  };

  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isLookingUpPincode = false;
  String? _pincodeLookupError;
  String? _pincodeLookupErrorPin;
  String? _lastResolvedPincode;
  bool _isServiceablePincode = true;
  int _pincodeLookupGeneration = 0;
  Timer? _pincodeDebounceTimer;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialAddress;

    _fullNameController = TextEditingController(text: initial?.fullName ?? '');
    _phoneController = TextEditingController(text: initial?.phoneNumber ?? '');
    _line1Controller = TextEditingController(text: initial?.addressLine1 ?? '');
    _line2Controller = TextEditingController(text: initial?.addressLine2 ?? '');
    _districtController = TextEditingController(text: initial?.district ?? '');
    _cityController = TextEditingController(text: initial?.city ?? '');
    _stateController = TextEditingController(text: initial?.state ?? '');
    _pincodeController = TextEditingController(text: initial?.pincode ?? '');
    _landmarkController = TextEditingController(text: initial?.landmark ?? '');

    final initialLabel = initial?.label.trim() ?? 'Home';
    if (_presetLabels.contains(initialLabel)) {
      _selectedLabel = initialLabel;
      _customLabelController = TextEditingController();
    } else {
      _selectedLabel = 'Other';
      _customLabelController = TextEditingController(text: initialLabel);
    }

    _isDefault = initial?.isDefault ?? false;
  }

  @override
  void dispose() {
    _pincodeDebounceTimer?.cancel();
    _fullNameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _landmarkController.dispose();
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedPincode = _normalizedPincode;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit address' : 'Add address'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(defaultPadding),
            children: [
              TextFormField(
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    _requiredValidator(value, field: 'Full name'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: _phoneValidator,
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _line1Controller,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Address Line 1'),
                validator: (value) =>
                    _requiredValidator(value, field: 'Address line 1'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _line2Controller,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Address Line 2 (optional)',
                ),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: _handlePincodeChanged,
                decoration: InputDecoration(
                  labelText: 'Pincode',
                  suffixIcon: _isLookingUpPincode
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                validator: _pincodeValidator,
              ),
              if (_pincodeLookupError != null &&
                  _pincodeLookupErrorPin == normalizedPincode) ...[
                const SizedBox(height: 8),
                Text(
                  _pincodeLookupError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              if (_isValidPincodeLength && !_isServiceablePincode) ...[
                const SizedBox(height: 8),
                Text(
                  'Delivery is currently available only for Solhapur city pincodes.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _districtController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'District'),
                validator: (value) =>
                    _requiredValidator(value, field: 'District'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _cityController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) => _requiredValidator(value, field: 'City'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _stateController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) => _requiredValidator(value, field: 'State'),
              ),
              const SizedBox(height: defaultPadding),
              TextFormField(
                controller: _landmarkController,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Landmark (optional)',
                ),
              ),
              const SizedBox(height: defaultPadding),
              Text('Address Label', style: theme.textTheme.titleSmall),
              const SizedBox(height: defaultPadding / 2),
              Wrap(
                spacing: defaultPadding / 2,
                runSpacing: defaultPadding / 2,
                children: _presetLabels
                    .map(
                      (label) => ChoiceChip(
                        label: Text(label),
                        selected: _selectedLabel == label,
                        onSelected: (_) {
                          setState(() {
                            _selectedLabel = label;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              if (_selectedLabel == 'Other') ...[
                const SizedBox(height: defaultPadding),
                TextFormField(
                  controller: _customLabelController,
                  decoration: const InputDecoration(labelText: 'Custom Label'),
                  validator: (value) {
                    if (_selectedLabel != 'Other') return null;
                    return _requiredValidator(value, field: 'Custom label');
                  },
                ),
              ],
              const SizedBox(height: defaultPadding),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
                title: const Text('Set as default address'),
              ),
              const SizedBox(height: defaultPadding),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text(
                  widget.isEditMode ? 'Update address' : 'Save address',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _normalizedPincode =>
      _pincodeController.text.replaceAll(RegExp(r'\D'), '');

  bool get _isValidPincodeLength => _normalizedPincode.length == 6;

  void _handlePincodeChanged(String value) {
    final normalizedPincode = value.replaceAll(RegExp(r'\D'), '');
    final currentGeneration = ++_pincodeLookupGeneration;

    setState(() {
      _pincodeLookupError = null;
      _pincodeLookupErrorPin = null;
      _isServiceablePincode = true;
      if (normalizedPincode.length != 6) {
        _isLookingUpPincode = false;
      }
    });

    _pincodeDebounceTimer?.cancel();

    if (normalizedPincode.length != 6) {
      return;
    }

    if (_lastResolvedPincode == normalizedPincode) {
      final cachedResult = _pincodeCache[normalizedPincode];
      if (cachedResult != null) {
        _applyLookupResult(
          normalizedPincode,
          cachedResult,
          generation: currentGeneration,
        );
        return;
      }
    }

    _pincodeDebounceTimer = Timer(
      _pincodeDebounceDuration,
      () => _lookupPincode(normalizedPincode, generation: currentGeneration),
    );
  }

  Future<void> _lookupPincode(String pincode, {required int generation}) async {
    if (!mounted) return;

    if (generation != _pincodeLookupGeneration) {
      return;
    }

    final cachedResult = _pincodeCache[pincode];
    if (cachedResult != null) {
      _applyLookupResult(pincode, cachedResult, generation: generation);
      return;
    }

    setState(() {
      _isLookingUpPincode = true;
      _pincodeLookupError = null;
      _pincodeLookupErrorPin = null;
      _isServiceablePincode = true;
    });

    try {
      final result = await _pincodeService.lookup(pincode);
      if (!mounted) return;

      if (generation != _pincodeLookupGeneration ||
          _normalizedPincode != pincode) {
        return;
      }

      _pincodeCache[pincode] = result;
      _lastResolvedPincode = pincode;
      final isServiceable = _isSolhapurServiceable(result);
      setState(() {
        _districtController.text = result.district;
        if (result.city.trim().isNotEmpty) {
          _cityController.text = result.city;
        }
        _stateController.text = result.state;
        _isLookingUpPincode = false;
        _pincodeLookupError = null;
        _pincodeLookupErrorPin = null;
        _isServiceablePincode = isServiceable;
      });
    } on PincodeLookupException catch (error) {
      if (!mounted) return;

      if (generation != _pincodeLookupGeneration ||
          _normalizedPincode != pincode) {
        return;
      }

      final message = error.message;
      setState(() {
        _isLookingUpPincode = false;
        _pincodeLookupError = message;
        _pincodeLookupErrorPin = pincode;
        _isServiceablePincode = false;
      });
    } catch (_) {
      if (!mounted) return;

      if (generation != _pincodeLookupGeneration ||
          _normalizedPincode != pincode) {
        return;
      }

      const message =
          'Unable to fetch location details. Check your network and try again.';
      setState(() {
        _isLookingUpPincode = false;
        _pincodeLookupError = message;
        _pincodeLookupErrorPin = pincode;
        _isServiceablePincode = false;
      });
    }
  }

  void _applyLookupResult(
    String pincode,
    PincodeLookupResult result, {
    required int generation,
  }) {
    if (!mounted) return;

    if (generation != _pincodeLookupGeneration ||
        _normalizedPincode != pincode) {
      return;
    }

    _lastResolvedPincode = pincode;
    final isServiceable = _isSolhapurServiceable(result);
    setState(() {
      _districtController.text = result.district;
      if (result.city.trim().isNotEmpty) {
        _cityController.text = result.city;
      }
      _stateController.text = result.state;
      _isLookingUpPincode = false;
      _pincodeLookupError = null;
      _pincodeLookupErrorPin = null;
      _isServiceablePincode = isServiceable;
    });
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isServiceablePincode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sorry, we currently deliver only within Solhapur city.',
          ),
        ),
      );
      return;
    }

    final label = _selectedLabel == 'Other'
        ? _customLabelController.text.trim()
        : _selectedLabel;

    final model = AddressModel(
      id: widget.initialAddress?.id ?? '',
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      addressLine1: _line1Controller.text.trim(),
      addressLine2: _line2Controller.text.trim().isEmpty
          ? null
          : _line2Controller.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      pincode: _pincodeController.text.trim(),
      landmark: _landmarkController.text.trim().isEmpty
          ? null
          : _landmarkController.text.trim(),
      label: label,
      isDefault: _isDefault,
      createdAt: widget.initialAddress?.createdAt,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(model);
  }

  bool _isSolhapurServiceable(PincodeLookupResult result) {
    final district = result.district.trim().toLowerCase();
    final city = result.city.trim().toLowerCase();

    return _supportedDistricts.contains(district) ||
        _supportedCityHints.contains(city);
  }

  String? _requiredValidator(String? value, {required String field}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _pincodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) {
      return 'Enter a valid pincode';
    }

    if (!_isServiceablePincode && _normalizedPincode == digits) {
      return 'We do not deliver to this pincode yet';
    }

    return null;
  }
}
