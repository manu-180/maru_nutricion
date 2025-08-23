import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MaruCompraProgresoController {
  final ValueNotifier<String> _mensaje;
  MaruCompraProgresoController._(String inicial)
    : _mensaje = ValueNotifier(inicial);

  void update(String nuevoMensaje) => _mensaje.value = nuevoMensaje;

  void close(BuildContext context) {
    Navigator.of(context, rootNavigator: true).maybePop();
  }
}

class MaruCompraProgresoDialog extends StatelessWidget {
  final ValueListenable<String> mensajeListenable;
  const MaruCompraProgresoDialog({super.key, required this.mensajeListenable});

  static MaruCompraProgresoController show(
    BuildContext context, {
    String mensajeInicial = 'Generando ticket de compra…',
  }) {
    final controller = MaruCompraProgresoController._(mensajeInicial);

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _DialogBody(mensajeListenable: controller._mensaje),
        ),
      ),
    );

    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(child: _DialogBody(mensajeListenable: mensajeListenable));
  }
}

class _DialogBody extends StatelessWidget {
  final ValueListenable<String> mensajeListenable;
  const _DialogBody({required this.mensajeListenable});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: mensajeListenable,
          builder: (_, __) => Text(
            mensajeListenable.value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No cierres esta ventana',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
        ),
      ],
    );
  }
}
