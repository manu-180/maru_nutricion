import 'package:flutter/material.dart';

class BiosSelector extends StatefulWidget {
  const BiosSelector({super.key});

  @override
  State<BiosSelector> createState() => _BiosSelectorState();
}

class _BiosSelectorState extends State<BiosSelector> {
  int _index = 0;

  static const _images = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
  ];

  static const _descriptions = [
    // Mariela
    'Soy Mariela, Licenciada en Nutrición, especializada en Nutrición Deportiva y Antropometrista ISAK II. '
        'A lo largo de los años, practiqué diferentes deportes como: maratones, natación, trail running, powerlifting, '
        'y en la actualidad evolucionando como triatleta. Me dedico a la planificación nutricional y a la programación '
        'de entrenamientos para la consecución de objetivos basados en la composición corporal (pérdida de grasa y '
        'ganancia de masa muscular), mejora del rendimiento deportivo, preparación de competición, mejora de la salud, etc. '
        'El deporte y la alimentación son dos de mis grandes pasiones; debemos poder fusionarlos para una combinación '
        'perfecta que mejore el bienestar y el rendimiento.',
    // Tali
    'Soy Tali Ferraro, licenciada en Nutrición, especializada en Nutrición Deportiva, Antropometrista ISAK II y runner. '
        'Disfruto del movimiento y los buenos hábitos como estilo de vida, entendiendo la alimentación como una forma de '
        'nutrir cuerpo, mente y emociones, buscando siempre el equilibrio entre rendimiento, salud y disfrute para que sea '
        'sostenible en el tiempo.',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatares
            Wrap(
              spacing: 20,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(_images.length, (i) {
                final selected = i == _index;
                return _AvatarChoice(
                  imagePath: _images[i],
                  selected: selected,
                  onTap: () => setState(() => _index = i),
                  primary: cs.primary,
                );
              }),
            ),

            const SizedBox(height: 20),

            // Descripción animada (fade + size)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SizeTransition(sizeFactor: anim, axisAlignment: -1.0, child: child),
              ),
              child: Padding(
                key: ValueKey(_index),
                padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 12),
                child: Text(
                  _descriptions[_index],
                  textAlign: TextAlign.justify,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AvatarChoice extends StatefulWidget {
  final String imagePath;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;

  const _AvatarChoice({
    required this.imagePath,
    required this.selected,
    required this.onTap,
    required this.primary,
  });

  @override
  State<_AvatarChoice> createState() => _AvatarChoiceState();
}

class _AvatarChoiceState extends State<_AvatarChoice> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final size = 120.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar con borde animado y leve escala al hover/selección
            AnimatedScale(
              scale: widget.selected || _hover ? 1.03 : 1.0,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: size,
                height: size,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.selected
                        ? widget.primary
                        : widget.primary.withOpacity(_hover ? 0.5 : 0.25),
                    width: widget.selected ? 3 : 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Indicador sutil bajo el avatar (aparece/desaparece)
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: widget.selected || _hover ? 36 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: widget.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
