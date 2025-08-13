import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MaruFooter extends StatelessWidget {
  const MaruFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceVariant.withOpacity(.3),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            Text(
              '© ${DateTime.now().year} Nutricionista Online — Todos los derechos reservados',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                TextButton(onPressed: () {}, child: const Text('Términos')),
                TextButton(onPressed: () {}, child: const Text('Privacidad')),
                TextButton(
                  onPressed: () => GoRouter.of(context).go('/mis-cursos'),
                  child: const Text('Mis cursos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
