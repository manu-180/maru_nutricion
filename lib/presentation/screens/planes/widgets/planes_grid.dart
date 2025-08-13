import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'plan_card.dart';

class PlanesGrid extends StatelessWidget {
  const PlanesGrid({super.key});

  Future<List<Map<String, dynamic>>> _fetch() async {
    final sb = Supabase.instance.client;
    final res = await sb
        .from('maru_products')
        .select('id, title, description, price_cents, includes_whatsapp')
        .eq('kind', 'plan')
        .eq('is_published', true)
        .order('created_at', ascending: false);
    return (res as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cross = width >= 900 ? 2 : 1;

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
            child: Text('Aún no hay planes publicados.'),
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
            childAspectRatio: 4 / 3,
          ),
          itemBuilder: (_, i) {
            final p = items[i];
            return PlanCard(
              title: p['title'] ?? '',
              description: p['description'] ?? '',
              priceCents: p['price_cents'] ?? 0,
              includesWhatsapp: (p['includes_whatsapp'] ?? false) as bool,
              onTap: () {
                // acá más adelante: iniciar flujo de compra con MercadoPago
                // por ahora solo mostramos un snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pronto podrás comprar este plan'),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
