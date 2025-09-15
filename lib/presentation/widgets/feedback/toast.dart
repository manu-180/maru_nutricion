import 'package:flutter/material.dart';
import 'package:maru_nutricion/config/router/app_router.dart';

/// Puedes llamarlo con o sin context; siempre usa el root overlay.
void showSuccessToast(BuildContext? _, String message, {Duration? duration}) {
  showToastRoot(
    message: message,
    duration: duration ?? const Duration(milliseconds: 2200),
    success: true,
  );
}

void showErrorToast(BuildContext? _, String message, {Duration? duration}) {
  showToastRoot(
    message: message,
    duration: duration ?? const Duration(milliseconds: 2500),
    success: false,
  );
}

void showToastRoot({
  required String message,
  required Duration duration,
  required bool success,
}) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;

  final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
  if (overlay == null) return;

  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _CenterToast(
      message: message,
      duration: duration,
      success: success,
      onFinish: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}

class _CenterToast extends StatefulWidget {
  final String message;
  final Duration duration;
  final bool success;
  final VoidCallback onFinish;
  const _CenterToast({
    required this.message,
    required this.duration,
    required this.success,
    required this.onFinish,
  });

  @override
  State<_CenterToast> createState() => _CenterToastState();
}

class _CenterToastState extends State<_CenterToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 160),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  late final Animation<double> _scale =
      Tween(begin: .98, end: 1.0).animate(_fade);

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      try {
        await _ctrl.reverse();
      } finally {
        if (mounted) widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = widget.success ? const Color(0xFF22C55E) : cs.error;

    return IgnorePointer(
      child: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Card(
                elevation: 10,
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.success
                            ? Icons.check_circle_rounded
                            : Icons.error_rounded,
                        color: iconColor,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.message,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
