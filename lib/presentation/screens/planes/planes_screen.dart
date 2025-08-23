import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/widgets/wpp_floating_button.dart';
import 'widgets/planes_grid.dart';

class PlanesScreen extends StatelessWidget {
  const PlanesScreen({super.key});
  static const double _maxWidth = 900;

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

                child: Text('Planes de nutrición',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Text('Elegí el plan que mejor se adapte a tus objetivos.',
                    style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(height: 24),
              const PlanesGrid(),
              const SizedBox(height: 48),
              const MaruFooter(),
            ],
          ),
        ),
      ),
      floatingActionButton: const WhatsappFloatingButton(),
    );
  }
}
