import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'product_card.dart';

class CursosGrid extends StatelessWidget {
  const CursosGrid({super.key});

  Future<List<Map<String, dynamic>>> _fetch() async {
    final sb = Supabase.instance.client;
    final res = await sb
        .from('maru_products')
        .select('id, title, description, cover_url, price_cents')
        .eq('kind', 'course')
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
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
      ratio = 1.05;
    } else if (cross == 3) {
      ratio = 1.00;
    } else if (cross == 2) {
      ratio = 0.95;
    } else {
      ratio = 0.90;
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetch(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aún no hay cursos publicados.'),
          );
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
            return ProductCard(
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
