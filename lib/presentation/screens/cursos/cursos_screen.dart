import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/screens/cursos/widget/cursos_grid.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';

class CursosScreen extends StatelessWidget {
  const CursosScreen({super.key});

  static const double _maxWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const MaruAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: ListView(
          
            children: [
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'Todos los cursos',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text(
                  'Capacitaciones 100% online orientadas a rendimiento deportivo.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 24),
              const CursosGrid(), // consulta a Supabase
              const SizedBox(height: 48),
              const MaruFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
