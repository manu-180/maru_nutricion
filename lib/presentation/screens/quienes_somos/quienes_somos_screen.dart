import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/screens/home/widgets/home_section.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import '../../widgets/maru_app_bar.dart';
import '../../widgets/bios_selector.dart';

class QuienesSomosScreen extends StatelessWidget {
  const QuienesSomosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const MaruAppBar(),
      body: ListView(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quiénes Somos',
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Conocé a las profesionales detrás de Nutris Deportivas.',
                      style: textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(.72),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const BiosSelector(),
                    const SizedBox(height: 56),
                     HomeSection(
                title: 'Testimonios',
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color:  Theme.of(context).colorScheme.surfaceVariant.withOpacity(.4),
                  ),
                  child: Text(
                    '“Tu progreso es nuestra mejor carta de presentación.” (Pronto, nuevas historias reales).',
                    style:  Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
                  ],
                ),
              ),
            ),
          ),
          const MaruFooter(), // ← full width
        ],
      ),
    );
  }
}
