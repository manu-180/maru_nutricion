
import 'package:flutter/material.dart';

/// Empuja el footer fuera de la vista reservando alto mínimo para el contenido.
/// Calcula: viewport - statusBar - AppBar(100) - reservaFooter(≈240).
class MinViewportSpace extends StatelessWidget {
  final Widget child;
  final double footerReserve; // podés ajustar fino si querés

  const MinViewportSpace({
    super.key,
    required this.child,
    this.footerReserve = 240,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final topPad = MediaQuery.of(context).padding.top;
    const appBarH = 100.0;

    final minH = (size.height - topPad - appBarH - footerReserve)
        .clamp(0.0, double.infinity);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minH),
      child: child,
    );
  }
}
