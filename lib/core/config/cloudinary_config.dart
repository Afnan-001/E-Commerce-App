class CloudinaryConfig {
  static const String cloudName = 'dezot0sua';
  static const String unsignedUploadPreset = 'pet-shop';
  static const String uploadFolder = 'petsworld/products';

  static bool get isConfigured =>
      cloudName.isNotEmpty && unsignedUploadPreset.isNotEmpty;
}
