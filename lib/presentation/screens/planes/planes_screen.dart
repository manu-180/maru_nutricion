import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/widgets/wpp_floating_button.dart';
import 'package:maru_nutricion/presentation/widgets/min_viewport_space.dart';
import 'package:maru_nutricion/presentation/widgets/skeleton_until_ready.dart';
import 'package:maru_nutricion/presentation/widgets/cards_grid_skeleton.dart';
import 'widgets/planes_grid.dart';

class PlanesScreen extends StatelessWidget {
  const PlanesScreen({super.key});
  static const double _maxWidth = 900;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const MaruAppBar(),
      body: ListView(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: MinViewportSpace(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Planes de nutrición',
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text('Elegí el plan que mejor se adapte a tus objetivos.',
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 24),
                      SkeletonUntilReady(
                        minHeight: 220,
                        skeleton: const CardsGridSkeleton(),
                        child: const PlanesGrid(),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const MaruFooter(),
        ],
      ),
      floatingActionButton: const WhatsappFloatingButton(),
    );
  }
}
