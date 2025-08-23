import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HoverOutlineFillButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  final bool active;
  final double width;
  final double height;

  const HoverOutlineFillButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.active = false,
    this.width = 160,
    this.height = 40,
  });

  @override
  State<HoverOutlineFillButton> createState() => _HoverOutlineFillButtonState();
}

class _HoverOutlineFillButtonState extends State<HoverOutlineFillButton> {
  bool _hoverLocal = false;

  bool get _isFilling => _hoverLocal || widget.active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(10);
    const dur = Duration(milliseconds: 450);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: false,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoverLocal = true),
            onExit: (_) => setState(() => _hoverLocal = false),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: radius,
                color: Colors.transparent,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 👇 Relleno animado de izquierda a derecha
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: dur,
                      curve: Curves.easeOutCubic,
                      width: _isFilling ? widget.width : 0,
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: radius,
                      ),
                    ),
                  ),
                  // Botón encima
                  TextButton(
                    onPressed: widget.onPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: _isFilling
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: radius),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    child: Text(widget.text),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
