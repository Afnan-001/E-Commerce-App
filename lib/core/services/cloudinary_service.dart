import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shop/core/config/cloudinary_config.dart';

class CloudinaryService {
  const CloudinaryService();

  bool get isConfigured => CloudinaryConfig.isConfigured;

  Future<String> uploadProductImage(XFile file) async {
    return uploadImageFile(file, folder: CloudinaryConfig.uploadFolder);
  }

  Future<String> uploadCategoryImage(XFile file) async {
    return uploadImageFile(
      file,
      folder: '${CloudinaryConfig.uploadFolder}/categories',
    );
  }

  Future<String> uploadAssetCategoryImage(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final fileName = _fileNameFromPath(assetPath);
    return uploadImageBytes(
      bytes: bytes,
      fileName: fileName,
      folder: '${CloudinaryConfig.uploadFolder}/categories',
      publicId: _publicIdFromName(fileName),
    );
  }

  Future<String> uploadImageFile(
    XFile file, {
    required String folder,
    String? publicId,
  }) async {
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
      ..fields['folder'] = folder;

    if ((publicId ?? '').trim().isNotEmpty) {
      request.fields['public_id'] = publicId!.trim();
      request.fields['overwrite'] = 'true';
    }

    request.files.add(
      await http.MultipartFile.fromPath('file', file.path, filename: file.name),
    );

    return _sendRequest(request);
  }

  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String fileName,
    required String folder,
    String? publicId,
  }) async {
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
      ..fields['folder'] = folder;

    if ((publicId ?? '').trim().isNotEmpty) {
      request.fields['public_id'] = publicId!.trim();
      request.fields['overwrite'] = 'true';
    }

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    return _sendRequest(request);
  }

  Future<String> _sendRequest(http.MultipartRequest request) async {
    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        data['error'] is Map<String, dynamic>
            ? (data['error']['message'] as String? ??
                  'Cloudinary upload failed.')
            : 'Cloudinary upload failed.',
      );
    }

    return data['secure_url'] as String? ?? '';
  }

  String _fileNameFromPath(String path) {
    final segments = path.split('/');
    return segments.isEmpty ? path : segments.last;
  }

  String _publicIdFromName(String fileName) {
    final dotIndex = fileName.lastIndexOf('.');
    final noExt = dotIndex > 0 ? fileName.substring(0, dotIndex) : fileName;
    return noExt
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
}
