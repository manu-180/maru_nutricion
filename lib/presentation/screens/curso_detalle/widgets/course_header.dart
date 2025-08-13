import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_network_image.dart';

class CourseHeader extends StatelessWidget {
  final String title;
  final String description;
  final String coverUrl;
  final int priceCents;
  final bool hasAccess;
  final VoidCallback onBuy;
  final VoidCallback onContinue;

  const CourseHeader({
    super.key,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.priceCents,
    required this.hasAccess,
    required this.onBuy,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final image = AspectRatio(
      aspectRatio: 16 / 9,
      child: MaruNetworkImage(
        url: coverUrl,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(description, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(_formatPrice(priceCents),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (hasAccess)
              FilledButton(onPressed: onContinue, child: const Text('Continuar curso'))
            else
              FilledButton(onPressed: onBuy, child: const Text('Comprar')),
          ],
        ),
      ],
    );

    // ✅ Wide: Row + Expanded   |   ✅ Mobile: Column (sin Expanded)
    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: image),
          const SizedBox(width: 24),
          Expanded(flex: 7, child: details),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          image,
          const SizedBox(height: 16),
          details,
        ],
      );
    }
  }

  String _formatPrice(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}
