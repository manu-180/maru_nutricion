import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_compra_progreso_dialog.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/widgets/course_header.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/widgets/lessons_list.dart';
import 'package:maru_nutricion/presentation/widgets/wpp_floating_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maru_nutricion/features/payments/services/mp_checkout_service.dart';

class CursoDetalleScreen extends StatelessWidget {
  final String productId;
  CursoDetalleScreen({super.key, required this.productId});

  static const double _maxWidth = 1100;
  final checkout = MpCheckoutService(Supabase.instance.client);

  Future<_CourseBundle> _fetchAll() async {
    final sb = Supabase.instance.client;

    final course = await sb
        .from('maru_products')
        .select('id, title, description, cover_url, price_cents')
        .eq('id', productId)
        .eq('kind', 'course')
        .single();

    final rawLessons = await sb
        .from('maru_lessons')
        .select('id, title, section, position, free_preview, thumbnail_url, duration_sec')
        .eq('product_id', productId)
        .order('section', ascending: true)
        .order('position', ascending: true);

    final uid = sb.auth.currentUser?.id;
    bool hasAccess = false;
    if (uid != null) {
      final access = await sb
          .from('maru_access')
          .select('id')
          .eq('user_id', uid)
          .eq('product_id', productId)
          .maybeSingle();
      hasAccess = access != null;
    }

    return _CourseBundle(
      course: (course as Map).cast<String, dynamic>(),
      lessons: (rawLessons as List).cast<Map<String, dynamic>>(),
      hasAccess: hasAccess,
    );
  }

  Future<void> _comprar(BuildContext context) async {
    final sb = Supabase.instance.client;

    final uid = sb.auth.currentUser?.id;
    if (uid == null) {
      final m = ScaffoldMessenger.of(context);
      m.clearSnackBars();
      m.showSnackBar(const SnackBar(
        content: Text('Para comprar un curso, iniciá sesión.'),
        behavior: SnackBarBehavior.fixed,
        duration: Duration(seconds: 3),
      ));
      // context.go('/login');
      return;
    }

    final dialog = MaruCompraProgresoDialog.show(
      context,
      mensajeInicial: 'Generando ticket de compra…',
    );
    try {
      dialog.update('Redirigiendo a Mercado Pago…');
      await checkout.startCheckout(context, productId);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No se pudo iniciar la compra. Intenta otra vez.'),
        behavior: SnackBarBehavior.fixed,
      ));
    } finally {
      dialog.close(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const MaruAppBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: FutureBuilder<_CourseBundle>(
            future: _fetchAll(),
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (!snap.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No se encontró el curso.'),
                );
              }

              final bundle = snap.data!;
              final hasAccess = bundle.hasAccess;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  CourseHeader(
                    title: bundle.course['title'] ?? '',
                    description: bundle.course['description'] ?? '',
                    coverUrl: bundle.course['cover_url'] ?? '',
                    priceCents: bundle.course['price_cents'] ?? 0,
                    hasAccess: hasAccess,
                    // 👉 solo desktop/tablet muestra botón propio del header
                    onBuy: (!isMobile && !hasAccess) ? () { _comprar(context); } : null,
                    onContinue: hasAccess ? () {
                      // tu lógica para continuar (por ej. ir a la primera lección)
                    } : null,
                  ),

                  // 👉 solo mobile muestra "Comprar ahora"
                  if (isMobile && !hasAccess) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () { _comprar(context); },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Comprar ahora'),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  LessonsList(
                    hasAccess: hasAccess,
                    lessons: bundle.lessons,
                  ),
                  const SizedBox(height: 48),
                  const MaruFooter(),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: const WhatsappFloatingButton(),
    );
  }
}

class _CourseBundle {
  final Map<String, dynamic> course;
  final List<Map<String, dynamic>> lessons;
  final bool hasAccess;
  _CourseBundle({
    required this.course,
    required this.lessons,
    required this.hasAccess,
  });
}
