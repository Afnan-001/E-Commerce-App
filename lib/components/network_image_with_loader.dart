import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'skleton/skelton.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final BoxFit fit;

  const NetworkImageWithLoader(
    this.src, {
    super.key,
    this.fit = BoxFit.cover,
    this.radius = defaultPadding,
  });

  final String src;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final normalizedSrc = _normalizeSource(src);

    if (normalizedSrc.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
        child: Icon(
          Icons.pets_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    if (!_isRemoteUrl(normalizedSrc)) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Image.asset(
          normalizedSrc,
          fit: fit,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
            ),
            child: Icon(
              Icons.pets_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: normalizedSrc,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.all(Radius.circular(radius)),
          ),
          child: Icon(
            Icons.image_not_supported_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        httpHeaders: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
        },
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  bool _isRemoteUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String _normalizeSource(String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) return normalized;

    normalized = normalized.replaceAll('\\', '/');

    if (normalized.startsWith('//')) {
      normalized = 'https:$normalized';
    } else if (normalized.startsWith('http://')) {
      normalized = 'https://${normalized.substring('http://'.length)}';
    } else if (!normalized.startsWith('http') &&
        (normalized.startsWith('res.cloudinary.com/') ||
            normalized.startsWith('firebasestorage.googleapis.com/'))) {
      normalized = 'https://$normalized';
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.scheme.isEmpty || uri.host.isEmpty) {
      return normalized;
    }

    return uri
        .replace(scheme: uri.scheme == 'http' ? 'https' : uri.scheme)
        .toString();
  }
}
