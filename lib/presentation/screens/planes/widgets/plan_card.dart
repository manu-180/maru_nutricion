import 'package:flutter/material.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String description;
  final int priceCents;
  final bool includesWhatsapp;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.description,
    required this.priceCents,
    required this.includesWhatsapp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            _Bullet(text: 'Plan personalizado (menú + explicación)'),
            _Bullet(text: 'Ajustes continuos'),
            _Bullet(text: 'Control mensual'),
            _Bullet(
              text: includesWhatsapp
                  ? 'Seguimiento por WhatsApp (L–V 9–20)'
                  : 'Soporte por email (L–V 9–20)',
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  _formatPrice(priceCents),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                FilledButton(onPressed: onTap, child: const Text('Elegir')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int cents) => '\$${(cents / 100.0).toStringAsFixed(2)}';
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
