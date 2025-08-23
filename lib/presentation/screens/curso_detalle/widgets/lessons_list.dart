import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonsList extends StatelessWidget {
  final bool hasAccess;
  /// id, title, section, position, free_preview, thumbnail_url, duration_sec
  final List<Map<String, dynamic>> lessons;

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

    final sections = groups.keys.toList()..sort();

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
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                for (int i = 0; i < groups[s]!.length; i++) ...[
                  _LessonRow(
                    data: groups[s]![i],
                    isUnlocked: hasAccess || (groups[s]![i]['free_preview'] == true),
                    onTap: (id) {
                      if (!(hasAccess || (groups[s]![i]['free_preview'] == true))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comprá el curso para acceder a esta lección'),
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                        return;
                      }
                      context.go('/leccion/$id');
                    },
                  ),
                  if (i != groups[s]!.length - 1)
                    const Divider(height: 1, thickness: 1),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Row segura para móviles:
/// - leading acotado (72–88 px)
/// - trailing acotado (máx 96 px)
/// - nada se expande a todo el ancho del ListTile
class _LessonRow extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isUnlocked;
  final void Function(String id) onTap;

  const _LessonRow({
    required this.data,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final id = (data['id'] ?? '').toString();
    final title = (data['title'] ?? '') as String;
    final thumb = (data['thumbnail_url'] ?? '') as String?;
    final durationSec = (data['duration_sec'] ?? 0) as int;
    final isPreview = (data['free_preview'] ?? false) as bool;

    final mins = (durationSec / 60).ceil();
    final subtitleText = mins > 0 ? '$mins min${isPreview ? ' · Vista previa' : ''}' : (isPreview ? 'Vista previa' : null);

    return ListTile(
      // 👇 límites para que no crashee en pantallas angostas
      minLeadingWidth: 72,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      leading: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 72, maxWidth: 88,
          minHeight: 56, maxHeight: 72,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: (thumb != null && thumb.isNotEmpty)
                ? Image.network(thumb, fit: BoxFit.cover)
                : Container(color: Colors.black12),
          ),
        ),
      ),

      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: subtitleText == null
          ? null
          : Text(subtitleText, style: theme.textTheme.bodySmall),

      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 96),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock_outline, size: 20)
            else
              IconButton(
                tooltip: 'Reproducir',
                onPressed: () => onTap(id),
                icon: const Icon(Icons.play_circle_fill),
              ),
          ],
        ),
      ),

      onTap: isUnlocked ? () => onTap(id) : null,
    );
  }
}
