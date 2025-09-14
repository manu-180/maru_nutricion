import 'package:flutter/material.dart';
import 'measure_size.dart';

class SkeletonUntilReady extends StatefulWidget {
  final Widget child;          // la grilla real (CursosGrid / PlanesGrid)
  final Widget skeleton;       // CardsGridSkeleton
  final double minHeight;      // altura mínima para considerar "listo"
  final Duration fadeDuration; // transición entre skeleton y child

  const SkeletonUntilReady({
    super.key,
    required this.child,
    required this.skeleton,
    this.minHeight = 240,
    this.fadeDuration = const Duration(milliseconds: 220),
  });

  @override
  State<SkeletonUntilReady> createState() => _SkeletonUntilReadyState();
}

class _SkeletonUntilReadyState extends State<SkeletonUntilReady> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // SKELETON visible hasta que el child alcance la altura mínima
        AnimatedOpacity(
          opacity: _ready ? 0 : 1,
          duration: widget.fadeDuration,
          child: IgnorePointer(ignoring: true, child: widget.skeleton),
        ),

        // CHILD ya montado (para que pueda cargar)
        // Lo medimos: cuando supere minHeight => _ready = true
        MeasureSize(
          onChange: (size) {
            if (!_ready && size.height >= widget.minHeight) {
              setState(() => _ready = true);
            }
          },
          child: AnimatedOpacity(
            opacity: _ready ? 1 : 0,
            duration: widget.fadeDuration,
            child: IgnorePointer(
              ignoring: !_ready, // evita clicks antes de estar listo
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
