import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePlansTeaser extends StatelessWidget {
  const HomePlansTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;

    Widget planCard(String title, List<String> bullets) {
      final theme = Theme.of(context);
      return InkWell(
        onTap: () => context.go('/planes'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (final b in bullets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b, style: theme.textTheme.bodyLarge)),
                  ]),
                ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: OutlinedButton(onPressed: () => context.go('/planes'), child: const Text('Ver detalles'))),
            ],
          ),
        ),
      );
    }

    final a = planCard('Trimestral Estándar', const [
      'Plan personalizado (menú + explicación)',
      'Ajustes continuos',
      'Soporte por email (L–V 9–20)',
      'Control mensual',
    ]);
    final b = planCard('Trimestral Premium', const [
      'Todo lo del Estándar',
      'Seguimiento por WhatsApp (L–V 9–20)',
    ]);

    if (isWide) {
      return Row(children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ]);
    } else {
      return Column(children: [
        a,
        const SizedBox(height: 16),
        b,
      ]);
    }
  }
}
