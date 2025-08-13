import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'lesson_tile.dart';

class LessonsList extends StatelessWidget {
  final bool hasAccess;
  final List<Map<String, dynamic>>
  lessons; // id, title, section, position, free_preview, thumbnail_url, duration_sec

  const LessonsList({
    super.key,
    required this.hasAccess,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    // Agrupar por sección
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final l in lessons) {
      final key = (l['section'] as String?)?.trim().isNotEmpty == true
          ? l['section'] as String
          : 'Contenido';
      groups.putIfAbsent(key, () => []).add(l);
    }

    final sections = groups.keys.toList();
    sections.sort();

    if (sections.isEmpty) {
      return const Text('Este curso todavía no tiene lecciones cargadas.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in sections) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              s,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: groups[s]!.map((l) {
                final locked = !(hasAccess || (l['free_preview'] == true));
                return LessonTile(
                  title: l['title'] ?? '',
                  durationSec: l['duration_sec'] as int?,
                  thumbnailUrl: l['thumbnail_url'] as String?,
                  isLocked: locked,
                  isPreview: l['free_preview'] == true,
                  onTap: () {
                    if (locked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Comprá el curso para acceder a esta lección',
                          ),
                        ),
                      );
                      return;
                    }
                    context.go('/leccion/${l["id"]}');
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
