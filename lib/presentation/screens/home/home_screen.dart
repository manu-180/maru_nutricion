import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/home_hero.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/home_plans_teaser.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/home_section.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/home_courses_grid.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/no_glow_scroll.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const double _maxWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MaruAppBar(),
      body: ScrollConfiguration(
        behavior: const NoGlowScroll(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HERO
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 48,
                  horizontal: 16,
                ),
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: const HomeHero(),
                ),
              ),

              // SOBRE MÍ
              HomeSection(
                title: 'Sobre mí',
                child: Text(
                  'Soy Licenciada en Nutrición especializada en Nutrición Deportiva. '
                  'Trabajo con deportistas y personas activas para mejorar rendimiento, salud y composición corporal. '
                  'Más de 15 años entrenando; 21k Buenos Aires (2015), Patagonia Run 25k (2016) y desde 2023 triatlón.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),

              // POR QUÉ ELEGIRNOS
              const HomeSection(
                title: '¿Por qué elegir esta plataforma?',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bullet(
                      text: 'Cursos prácticos y específicos por disciplina.',
                    ),
                    _Bullet(text: 'Contenido aplicable con base científica.'),
                    _Bullet(text: 'Acompañamiento y actualizaciones.'),
                  ],
                ),
              ),

              // CURSOS DESTACADOS
              HomeSection(
                title: 'Cursos destacados',
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/cursos'),
                  child: const Text('Ver todos'),
                ),
                child: const HomeCoursesGrid(limit: 4),
              ),

              // PLANES
              HomeSection(
                title: 'Planes de nutrición',
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/planes'),
                  child: const Text('Ver planes'),
                ),
                child: const HomePlansTeaser(),
              ),

              const SizedBox(height: 48),

              // TESTIMONIOS (placeholder)
              HomeSection(
                title: 'Testimonios',
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surfaceVariant.withOpacity(.4),
                  ),
                  child: Text(
                    '“Tu progreso es nuestra mejor carta de presentación.” (Pronto, nuevas historias reales).',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),

              const SizedBox(height: 56),
              const MaruFooter(),
            ],
          ),
        ),
      ),
    );
  }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
