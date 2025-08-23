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
    // URL vacía → placeholder
    if (url.trim().isEmpty) {
      return _placeholder(context);
    }

    Widget img = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true, // 👈 evita parpadeo en relayout
      filterQuality: FilterQuality.medium, // 👈 mejor reescalado
      // Fade-in sólo en el primer frame cargado
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      // Loader discreto (sin fondo que “flashea”)
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );

    if (borderRadius != null) {
      img = ClipRRect(borderRadius: borderRadius!, child: img);
    }

    // Aísla repaints para mayor estabilidad al redimensionar
    return RepaintBoundary(child: img);
  }

  Widget _placeholder(BuildContext context) => Container(
    width: width,
    height: height,
    color: Theme.of(context).colorScheme.surfaceVariant,
    alignment: Alignment.center,
    child: const Icon(Icons.broken_image, size: 40),
  );
}
