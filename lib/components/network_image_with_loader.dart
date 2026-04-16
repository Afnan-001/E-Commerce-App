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
    if (src.isEmpty) {
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

    if (!src.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        child: Image.asset(
          src,
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
        imageUrl: src,
        filterQuality: FilterQuality.high,
        placeholder: (context, url) => const Skeleton(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
