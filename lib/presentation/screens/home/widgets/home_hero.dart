import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final left = Column(
      crossAxisAlignment: isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Capacitaciones nutricionales para deportistas',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, height: 1.1),
        ),
        const SizedBox(height: 12),
        Text(
          '100% online · científicas · aplicables a tu entrenamiento',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(.8),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            FilledButton(onPressed: () => context.go('/cursos'), child: const Text('Ver cursos')),
            OutlinedButton(onPressed: () => context.go('/planes'), child: const Text('Planes de nutrición')),
          ],
        ),
      ],
    );

    final right = AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.secondaryContainer.withOpacity(.4),
        ),
        child: const Center(child: Text('Imagen/ilustración aquí')),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 6, child: Padding(padding: const EdgeInsets.only(right: 32), child: left)),
          const SizedBox(width: 16),
          Expanded(flex: 5, child: right),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }
  }
}
