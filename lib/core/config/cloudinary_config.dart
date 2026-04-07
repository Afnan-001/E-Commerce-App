class CloudinaryConfig {
  static const String cloudName = 'dezot0sua';
  static const String unsignedUploadPreset = 'pet-name';
  static const String uploadFolder = 'pawcare/products';

  static bool get isConfigured =>
      cloudName.isNotEmpty && unsignedUploadPreset.isNotEmpty;
}
