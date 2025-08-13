import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';

class LessonScreen extends StatelessWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    // Próximo paso: pedir URL firmada a Edge Function maru-sign-playback y reproducir HLS
    return Scaffold(
      appBar: const MaruAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Lección', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Container(
            height: 300,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: const Center(child: Text('Player aquí')),
          ),
          const SizedBox(height: 48),
          const MaruFooter(),
        ],
      ),
    );
  }
}
