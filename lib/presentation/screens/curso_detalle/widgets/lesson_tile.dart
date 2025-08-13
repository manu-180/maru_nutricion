import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_network_image.dart';

class LessonTile extends StatelessWidget {
  final String title;
  final int? durationSec;
  final String? thumbnailUrl;
  final bool isLocked;
  final bool isPreview;
  final VoidCallback onTap;

  const LessonTile({
    super.key,
    required this.title,
    required this.durationSec,
    required this.thumbnailUrl,
    required this.isLocked,
    required this.isPreview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: MaruNetworkImage(
        url: thumbnailUrl ?? '',
        width: 72,
        height: 48,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(8),
      ),

      title: Row(
        children: [
          Expanded(
            child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (isPreview)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Chip(
                label: const Text('Preview'),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (isLocked && !isPreview)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.lock,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(.6),
              ),
            ),
        ],
      ),
      subtitle: durationSec != null
          ? Text(_formatDuration(durationSec!))
          : null,
      onTap: onTap,
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}
