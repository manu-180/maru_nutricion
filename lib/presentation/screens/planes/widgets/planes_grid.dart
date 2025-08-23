// lib/presentation/screens/planes/widgets/planes_grid.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maru_nutricion/animated/animated_button.dart';
import 'package:maru_nutricion/features/payments/services/mp_checkout_service.dart';
import 'package:maru_nutricion/presentation/widgets/maru_compra_progreso_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String _fmtPrice(int cents) {
  final n = NumberFormat.currency(locale: 'es_AR', symbol: r'$');
  return n.format((cents) / 100);
}

class PlanesGrid extends StatelessWidget {
  const PlanesGrid({super.key});

  Future<List<Map<String, dynamic>>> _fetchPlans() async {
    final sb = Supabase.instance.client;
    final data = await sb
        .from('maru_products')
        .select(
          'id, title, description, cover_url, price_cents, includes_whatsapp',
        )
        .eq('kind', 'plan')
        .eq('is_published', true)
        .order('created_at');
    return (data as List).cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchPlans(),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Aún no hay planes publicados.',
              style: theme.textTheme.bodyLarge,
            ),
          );
        }

        return LayoutBuilder(
          builder: (_, c) {
            final w = c.maxWidth;
            final cross = w > 1000 ? 3 : (w > 640 ? 2 : 1);
            // Menor ratio = más alto el ítem (evita overflow)
            final ratio = cross == 1 ? 0.99 : 0.85;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: ratio,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _PlanCard(plan: items[i]),
            );
          },
        );
      },
    );
  }
}

// arriba ya tenés estos imports, sumá este si no está:

class _PlanCard extends StatefulWidget {
  final Map<String, dynamic> plan;
  const _PlanCard({required this.plan});

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _hover = false;
  bool _loading = false; // evita dobles toques

  Widget _planCover(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: (url != null && url.isNotEmpty)
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverPlaceholder(),
              )
            : _coverPlaceholder(),
      ),
    );
  }

  Widget _coverPlaceholder() => Container(
    alignment: Alignment.center,
    color: Colors.black12,
    child: const Text('Plan', style: TextStyle(fontWeight: FontWeight.w600)),
  );

  void showBottomSnack(BuildContext context, String msg) {
  final m = ScaffoldMessenger.of(context);
  m.clearSnackBars();
  m.showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.fixed, // 👈 pegado al borde inferior
      duration: const Duration(seconds: 3),
    ),
  );
}

 Future<void> _buyWithDialog() async {
  if (_loading) return;

  // ✅ 1) Chequeo de login primero
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Para comprar un plan, iniciá sesión.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
    // (opcional) redirigir a login si tenés ruta:
    // context.go('/login');
    return;
  }

  final productId = (widget.plan['id'] ?? '').toString();
  if (productId.isEmpty) return;

  // ✅ 2) Sólo si está logueado mostramos el diálogo y seguimos
  setState(() => _loading = true);
  final dialog = MaruCompraProgresoDialog.show(
    context,
    mensajeInicial: 'Generando ticket de compra…',
  );

  try {
    dialog.update('Redirigiendo a Mercado Pago…');
    await MpCheckoutService(sb).startCheckout(context, productId);
  } catch (e) {
   final messenger = ScaffoldMessenger.of(context);
messenger.clearSnackBars();
if (context.mounted) {
  showBottomSnack(context, 'Para comprar un plan, iniciá sesión.');
  return;
}


  } finally {
    dialog.close(context);
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = (widget.plan['title'] ?? '') as String;
    final desc = (widget.plan['description'] ?? '') as String;
    final price = (widget.plan['price_cents'] ?? 0) as int;
    final cover = (widget.plan['cover_url'] ?? '') as String?;
    final hasWpp = (widget.plan['includes_whatsapp'] ?? false) as bool;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _loading ? null : _buyWithDialog, // 👉 tap en la card compra
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _loading
                ? null
                : _buyWithDialog, // 👉 tap también por InkWell
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _planCover(cover),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        _fmtPrice(price),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasWpp)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Seguimiento por WhatsApp',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: HoverOutlineFillButton(
                      text: _loading ? 'Procesando…' : 'Contratar plan',
                      onPressed: _loading
                          ? () {}
                          : _buyWithDialog, // 👉 botón compra
                      active: _hover,
                      width: 160,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
