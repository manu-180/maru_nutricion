// lib/presentation/screens/curso_detalle/widgets/course_header.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maru_nutricion/animated/animated_button.dart';

String _fmtPrice(int cents) {
  final n = NumberFormat.currency(locale: 'es_AR', symbol: r'$');
  return n.format(cents / 100);
}

class CourseHeader extends StatefulWidget {
  final String title;
  final String description;
  final String coverUrl;
  final int priceCents;
  final bool hasAccess;

  // 👇 Hacemos los callbacks opcionales
  final VoidCallback? onBuy;
  final VoidCallback? onContinue;

  const CourseHeader({
    super.key,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.priceCents,
    required this.hasAccess,
    this.onBuy,
    this.onContinue,
  });

  @override
  State<CourseHeader> createState() => _CourseHeaderState();
}

class _CourseHeaderState extends State<CourseHeader> {
  bool _hover = false; // anima el botón también al pasar por el header

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si tiene acceso: tap al continuar; si no: tap al comprar; si no hay callback -> null
    final VoidCallback? onTapHeader =
        widget.hasAccess ? widget.onContinue : widget.onBuy;

    Widget _coverPlaceholder() => Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: const Text(
            'Curso',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: onTapHeader != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTapHeader, // puede ser null (no clickable)
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              Expanded(
                flex: 4,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.coverUrl.isNotEmpty)
                        ? Image.network(
                            widget.coverUrl,
                            fit: BoxFit.cover,
                            // Evita crashear si la URL falla
                            errorBuilder: (_, __, ___) => _coverPlaceholder(),
                          )
                        : _coverPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Info + botón
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(widget.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Text(
                      _fmtPrice(widget.priceCents),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Mostrar SOLO si corresponde
                        if (widget.hasAccess && widget.onContinue != null)
                          HoverOutlineFillButton(
                            text: 'Continuar',
                            onPressed: widget.onContinue!,
                            active: _hover,
                            width: 140,
                            height: 40,
                          )
                        else if (!widget.hasAccess && widget.onBuy != null)
                          HoverOutlineFillButton(
                            text: 'Comprar',
                            onPressed: widget.onBuy!,
                            active: _hover,
                            width: 140,
                            height: 40,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
