import 'package:flutter/foundation.dart';

@immutable
class CloudinaryImageRef {
  const CloudinaryImageRef({
    required this.secureUrl,
    this.publicId,
  });

  final String secureUrl;
  final String? publicId;
}
