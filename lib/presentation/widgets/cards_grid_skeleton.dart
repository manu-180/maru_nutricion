import 'package:flutter/material.dart';
import 'shimmer.dart';

class CardsGridSkeleton extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int? forcedCount; // opcional, por si querés forzar cantidad

  const CardsGridSkeleton({super.key, this.padding = EdgeInsets.zero, this.forcedCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, c) {
          int cross = 1;
          if (c.maxWidth >= 1000) cross = 4;
          else if (c.maxWidth >= 760) cross = 3;
          else if (c.maxWidth >= 520) cross = 2;
          final count = forcedCount ?? (cross * 2); // 2 filas aprox

          final cs = Theme.of(context).colorScheme;
          Widget block(double h, {double? w, double r = 10}) => Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(.08),
                  borderRadius: BorderRadius.circular(r),
                ),
              );

          return Shimmer(
            child: GridView.builder(
              itemCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 4 / 5,
              ),
              itemBuilder: (_, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // imagen
                    AspectRatio(aspectRatio: 16 / 9, child: block(double.infinity, r: 12)),
                    const SizedBox(height: 10),
                    // título
                    block(16, r: 6),
                    const SizedBox(height: 8),
                    // subtítulo
                    block(14, w: c.maxWidth * .25, r: 6),
                    const Spacer(),
                    // botón
                    Align(
                      alignment: Alignment.centerLeft,
                      child: block(34, w: 120, r: 24),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
