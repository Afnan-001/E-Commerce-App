class CloudinaryConfig {
  static const String cloudName = 'dezot0sua';
  static const String unsignedUploadPreset = 'pet-shop';
  static const String uploadFolder = 'petsworld/products';
  static const String apiKey = '243551958266343';
  static const String apiSecret = 'm2U3YPkTAii17aauXSwayTtp5lM';

  static bool get isConfigured =>
      cloudName.isNotEmpty && unsignedUploadPreset.isNotEmpty;

  static bool get canDeleteRemotely =>
      cloudName.isNotEmpty && apiKey.isNotEmpty && apiSecret.isNotEmpty;
}
