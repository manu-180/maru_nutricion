import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_course_card.dart';

class HomeCoursesGrid extends StatefulWidget {
  final int limit;
  const HomeCoursesGrid({super.key, this.limit = 4});

  @override
  State<HomeCoursesGrid> createState() => _HomeCoursesGridState();
}

class _HomeCoursesGridState extends State<HomeCoursesGrid> {
  late final Future<List<Map<String, dynamic>>> _future;

  Future<List<Map<String, dynamic>>> _fetch() async {
    final sb = Supabase.instance.client;
    final res = await sb
        .from('maru_products')
        .select('id, title, description, cover_url, price_cents')
        .eq('kind', 'course')
        .eq('is_published', true)
        .order('created_at', ascending: false)
        .limit(widget.limit);
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  void initState() {
    super.initState();
    _future = _fetch(); // 👈 cache
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cross = width >= 1100
        ? 4
        : width >= 800
        ? 3
        : width >= 560
        ? 2
        : 1;

    double ratio;
    if (cross == 4) {
      ratio = 1.00;
    } else if (cross == 3) {
      ratio = 0.95;
    } else if (cross == 2) {
      ratio = 0.85; // más alto
    } else {
      ratio = 0.75; // 👈 mobile/una columna: bastante más alto
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future, // 👈 usa el mismo Future
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          // loader sin “flash”
          return const SizedBox(height: 140);
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Text('Pronto cargaremos los primeros cursos.');
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: ratio,
          ),
          itemBuilder: (_, i) {
            final c = items[i];
            return HomeCourseCard(
              id: c['id'],
              title: c['title'] ?? '',
              description: c['description'] ?? '',
              coverUrl: c['cover_url'] ?? '',
              priceCents: c['price_cents'] ?? 0,
              onTap: () => context.go('/curso/${c['id']}'),
            );
          },
        );
      },
    );
  }
}
