// lib/presentation/screens/lesson/lesson_screen.dart
import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/widgets/maru_video_player.dart';
import 'package:maru_nutricion/presentation/widgets/wpp_floating_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LessonScreen extends StatelessWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  Future<Map<String, dynamic>?> _fetchLesson() async {
    final sb = Supabase.instance.client;
    final data = await sb
        .from('maru_lessons')
        .select('title, description, video_url, duration_sec')
        .eq('id', lessonId)
        .maybeSingle();
    return (data as Map?)?.cast<String, dynamic>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MaruAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _fetchLesson(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final lesson = snap.data;
              if (lesson == null) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Lección no encontrada.'),
                );
              }

              final title = (lesson['title'] ?? '') as String;
              final desc = (lesson['description'] ?? '') as String;
              final url = (lesson['video_url'] ?? '') as String;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  if (url.isNotEmpty)
                    MaruVideoPlayer(url: url)
                  else
                    Container(
                      height: 300,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Sin video_url configurada'),
                    ),
                  const SizedBox(height: 16),
                  if (desc.isNotEmpty)
                    Text(desc, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 48),
                  const MaruFooter(),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: WhatsappFloatingButton(),
    );
  }
}
