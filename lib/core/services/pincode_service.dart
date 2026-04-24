import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PincodeLookupResult {
  const PincodeLookupResult({
    required this.district,
    required this.state,
    required this.city,
  });

  final String district;
  final String state;
  final String city;
}

class PincodeLookupException implements Exception {
  const PincodeLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PincodeService {
  PincodeService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const Duration _requestTimeout = Duration(seconds: 8);

  Future<PincodeLookupResult> lookup(String pincode) async {
    final normalizedPincode = pincode.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedPincode)) {
      throw const PincodeLookupException('Enter a valid 6-digit pincode.');
    }

    final uri = Uri.parse(
      'https://api.postalpincode.in/pincode/$normalizedPincode',
    );

    try {
      final response = await _requestWithRetry(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const PincodeLookupException(
          'Unable to verify this pincode right now.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) {
        throw const PincodeLookupException('No data found for this pincode.');
      }

      final firstEntry = decoded.first;
      if (firstEntry is! Map<String, dynamic>) {
        throw const PincodeLookupException('Unexpected pincode response.');
      }

      final status = firstEntry['Status'] as String? ?? '';
      final postOffices = firstEntry['PostOffice'];
      if (status.toLowerCase() != 'success' ||
          postOffices is! List ||
          postOffices.isEmpty) {
        throw const PincodeLookupException(
          'No location found for the entered pincode.',
        );
      }

      final offices = postOffices.whereType<Map<String, dynamic>>().toList();
      if (offices.isEmpty) {
        throw const PincodeLookupException(
          'No location found for the entered pincode.',
        );
      }

      final office = offices.first;

      final district = (office['District'] as String? ?? '').trim();
      final state = (office['State'] as String? ?? '').trim();
      final city =
          (office['Block'] as String? ??
                  office['Taluk'] as String? ??
                  office['Division'] as String? ??
                  '')
              .trim();

      if (district.isEmpty || state.isEmpty) {
        throw const PincodeLookupException(
          'Incomplete location details returned.',
        );
      }

      return PincodeLookupResult(district: district, state: state, city: city);
    } on PincodeLookupException {
      rethrow;
    } on SocketException {
      throw const PincodeLookupException(
        'No internet connection. Please check your network and try again.',
      );
    } on HandshakeException {
      throw const PincodeLookupException(
        'Secure connection failed while verifying pincode. Please try again.',
      );
    } on http.ClientException {
      throw const PincodeLookupException(
        'Unable to connect to pincode service. Please try again.',
      );
    } on TimeoutException {
      throw const PincodeLookupException(
        'Pincode lookup timed out. Please try again.',
      );
    } catch (_) {
      throw const PincodeLookupException(
        'Unable to fetch location details. Check your network and try again.',
      );
    }
  }

  Future<http.Response> _requestWithRetry(Uri uri) async {
    try {
      return await _client.get(uri).timeout(_requestTimeout);
    } catch (_) {
      return await _client.get(uri).timeout(_requestTimeout);
    }
  }
}
