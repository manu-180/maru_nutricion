import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/shimmer.dart';
import 'package:maru_nutricion/presentation/widgets/min_viewport_space.dart';

class CourseDetailSkeleton extends StatelessWidget {
  const CourseDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final block = (double h, {double? w, double r = 10}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: cs.onSurface.withOpacity(.08),
            borderRadius: BorderRadius.circular(r),
          ),
        );

    return MinViewportSpace(
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover/banner
            AspectRatio(
              aspectRatio: 16 / 9,
              child: block(double.infinity, r: 12),
            ),
            const SizedBox(height: 20),

            // Título + precio/botón
            Row(
              children: [
                Expanded(child: block(24, r: 6)),
                const SizedBox(width: 16),
                block(36, w: 140, r: 24),
              ],
            ),
            const SizedBox(height: 14),

            // Descripción (3 líneas)
            block(14, w: double.infinity, r: 6),
            const SizedBox(height: 10),
            block(14, w: double.infinity, r: 6),
            const SizedBox(height: 10),
            block(14, w: MediaQuery.of(context).size.width * .55, r: 6),

            const SizedBox(height: 24),

            // Lista de lecciones (5 ítems)
            ...List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    block(60, w: 100, r: 8), // thumbnail
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          block(16, w: double.infinity, r: 6),
                          const SizedBox(height: 8),
                          block(14, w: MediaQuery.of(context).size.width * .35, r: 6),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    block(14, w: 48, r: 6), // duración
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
