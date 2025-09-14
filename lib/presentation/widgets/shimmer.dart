import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final base = widget.baseColor ?? onSurface.withOpacity(.08);
    final highlight = widget.highlightColor ?? onSurface.withOpacity(.22);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final dx = Tween<double>(begin: -1, end: 2).transform(_c.value);
        return ShaderMask(
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1 + dx, 0),
            end: Alignment(dx, 0),
            colors: [base, highlight, base],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(rect),
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
