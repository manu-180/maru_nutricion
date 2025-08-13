import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/widgets/course_header.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/widgets/lessons_list.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Servicio de MP (como te pasé antes):
import 'package:maru_nutricion/features/payments/services/mp_checkout_service.dart';

class CursoDetalleScreen extends StatelessWidget {
  final String productId;
  const CursoDetalleScreen({super.key, required this.productId});

  static const double _maxWidth = 1100;

  Future<_CourseBundle> _fetchAll() async {
    final sb = Supabase.instance.client;

    // --- curso ---
    final course = await sb
        .from('maru_products')
        .select('id, title, description, cover_url, price_cents')
        .eq('id', productId)
        .eq('kind', 'course')
        .single(); // ya es Map<String, dynamic>

    // --- lecciones ---
    final rawLessons = await sb
        .from('maru_lessons')
        .select(
          'id, title, section, position, free_preview, thumbnail_url, duration_sec',
        )
        .eq('product_id', productId)
        .order('section', ascending: true)
        .order('position', ascending: true);

    // --- acceso del usuario (si logueado) ---
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

  @override
  Widget build(BuildContext context) {
    final checkout = MpCheckoutService(Supabase.instance.client);

    return Scaffold(
      appBar: const MaruAppBar(),
      body: Center(
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
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                children: [
                  CourseHeader(
                    title: bundle.course['title'] ?? '',
                    description: bundle.course['description'] ?? '',
                    coverUrl: bundle.course['cover_url'] ?? '',
                    priceCents: bundle.course['price_cents'] ?? 0,
                    hasAccess: bundle.hasAccess,
                    onBuy: () => checkout.startCheckout(context, productId),
                    onContinue: () {
                      final first =
                          bundle.lessons.isNotEmpty ? bundle.lessons.first : null;
                      if (first != null) {
                        context.go('/leccion/${first["id"]}');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  LessonsList(
                    hasAccess: bundle.hasAccess,
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
