// lib/presentation/home/widgets/home_hero.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> _fetchHeroImageUrl() async {
  final sb = Supabase.instance.client;
  final row = await sb
      .from('maru_settings')
      .select('value')
      .eq('key', 'home_hero_url')
      .maybeSingle();
  return (row != null) ? (row['value'] as String?) : null;
}

class HomeHero extends StatefulWidget {
  const HomeHero({super.key});
  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  late final Future<String?> _heroUrlFuture; // 👈 cacheamos el Future

  @override
  void initState() {
    super.initState();
    _heroUrlFuture = _fetchHeroImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width > 900;

    final left = Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          'Capacitaciones nutricionales para deportistas',
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
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
            FilledButton(
              onPressed: () => context.go('/cursos'),
              child: const Text('Ver cursos'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/planes'),
              child: const Text('Planes de nutrición'),
            ),
          ],
        ),
      ],
    );

    final right = AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FutureBuilder<String?>(
          future: _heroUrlFuture, // 👈 usa el mismo Future siempre
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Container(
                color: theme.colorScheme.secondaryContainer.withOpacity(.4),
              ); // sin spinner para evitar “flash”
            }
            final url = snap.data;
            if (url == null || url.isEmpty) {
              return Container(
                color: theme.colorScheme.secondaryContainer.withOpacity(.4),
                child: const Center(child: Text('Configura “home_hero_url”')),
              );
            }
            return Image.network(
              url,
              fit: BoxFit.cover,
              gaplessPlayback:
                  true, // 👈 mantiene el frame anterior en cambios de layout
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) => Container(
                color: theme.colorScheme.secondaryContainer.withOpacity(.4),
                child: const Center(child: Text('No se pudo cargar la imagen')),
              ),
            );
          },
        ),
      ),
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(right: 32),
              child: left,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 5, child: right),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [left, const SizedBox(height: 16), right],
      );
    }
  }
}
