import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/config/cloudinary_config.dart';

class CloudinaryService {
  const CloudinaryService();

  bool get isConfigured => CloudinaryConfig.isConfigured;

  Future<String> uploadProductImage(XFile file) async {
    if (!isConfigured) {
      throw StateError(
        'Cloudinary is not configured. Add your cloud name and unsigned '
        'upload preset in lib/core/config/cloudinary_config.dart.',
      );
    }

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = CloudinaryConfig.unsignedUploadPreset
      ..fields['folder'] = CloudinaryConfig.uploadFolder
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.name,
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        data['error'] is Map<String, dynamic>
            ? (data['error']['message'] as String? ?? 'Cloudinary upload failed.')
            : 'Cloudinary upload failed.',
      );
    }

    return data['secure_url'] as String? ?? '';
  }
}
