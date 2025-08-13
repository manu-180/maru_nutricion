import 'package:flutter/material.dart';

class MaruNetworkImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const MaruNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    // Si la URL está vacía, devolvé placeholder directo
    if (url.trim().isEmpty) {
      return _placeholder(context);
    }

    final img = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (c, child, progress) => progress == null
          ? child
          : Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (c, err, st) => _placeholder(context),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _placeholder(BuildContext context) => Container(
    width: width,
    height: height,
    color: Theme.of(context).colorScheme.surfaceVariant,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image, size: 40),
  );
}
