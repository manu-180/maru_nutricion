import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maru_nutricion/presentation/widgets/auth/auth_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:maru_nutricion/presentation/widgets/maru_app_bar.dart';
import 'package:maru_nutricion/presentation/widgets/maru_footer.dart';
import 'package:maru_nutricion/presentation/widgets/min_viewport_space.dart';
import 'package:maru_nutricion/presentation/widgets/cards_grid_skeleton.dart';

class MisCursosScreen extends StatelessWidget {
  const MisCursosScreen({super.key});

  static const double _maxWidth = 1100;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const MaruAppBar(),
      body: ListView(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: MinViewportSpace(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mis cursos',
                          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text(
                        'Accesos a tus cursos comprados.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      const _PurchasedCourses(),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const MaruFooter(),
        ],
      ),
    );
  }
}

/* ─────────────────────────  DATA  ───────────────────────── */

class _PurchasedCourses extends StatefulWidget {
  const _PurchasedCourses();

  @override
  State<_PurchasedCourses> createState() => _PurchasedCoursesState();
}

class _PurchasedCoursesState extends State<_PurchasedCourses> {
  late Future<List<_AccessCourse>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_AccessCourse>> _load() async {
    final sb = Supabase.instance.client;
    final uid = sb.auth.currentUser?.id;

    if (uid == null) return const [];

    // 1) Accesos del usuario
    final accesses = await sb
        .from('maru_access')
        .select('product_id, created_at, expires_at')
        .eq('user_id', uid)
        .order('created_at', ascending: false) as List;

    if (accesses.isEmpty) return const [];

    // ids de productos
    // ids de productos a partir de los accesos
final ids = (accesses as List)
    .map<String>((e) => e['product_id'] as String)
    .toList();

// 2) Productos
final products = await sb
    .from('maru_products')
    .select('id, title, cover_url, access_days, kind')
    .inFilter('id', ids) as List;   // 👈 inFilter

final byId = {for (final p in products) p['id'] as String: p};

// 3) Lecciones por curso (una query para todos)
final lessonsRaw = await sb
    .from('maru_lessons')
    .select('product_id')
    .inFilter('product_id', ids) as List;   // 👈 inFilter

    final lessonsCount = <String, int>{};
    for (final row in lessonsRaw) {
      final pid = row['product_id'] as String;
      lessonsCount[pid] = (lessonsCount[pid] ?? 0) + 1;
    }

    // 4) Compose
    final result = <_AccessCourse>[];
    for (final a in accesses) {
      final pid = a['product_id'] as String;
      final p = byId[pid];
      if (p == null) continue;

      final createdAt = DateTime.parse(a['created_at'] as String);
      final expiresAt = a['expires_at'] != null ? DateTime.parse(a['expires_at'] as String) : null;
      final accessDays = p['access_days'] as int?;
      final title = p['title'] as String? ?? 'Sin título';
      final cover = p['cover_url'] as String? ?? '';
      final kind = p['kind'] as String? ?? 'course';
      final nLessons = lessonsCount[pid] ?? 0;

      result.add(
        _AccessCourse(
          productId: pid,
          title: title,
          coverUrl: cover,
          createdAt: createdAt,
          expiresAt: expiresAt,
          accessDays: accessDays,
          kind: kind,
          lessons: nLessons,
        ),
      );
    }

    // Activos primero
    result.sort((a, b) => (b.daysLeft ?? 9999).compareTo(a.daysLeft ?? 9999));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_AccessCourse>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          // Skeleton de grilla (sin spinner)
          return const CardsGridSkeleton();
        }

        // No logueado
// No logueado
if (Supabase.instance.client.auth.currentUser == null) {
  return _EmptyState(
    icon: Icons.login,
    title: 'Iniciá sesión para ver tus cursos',
    buttonText: 'Iniciar sesión',
    onPressed: () async {
      await showAuthDialog(
        context,
        initial: AuthMode.login,
        onSuccess: () {
          if (!mounted) return;
          setState(() => _future = _load()); // recargar lista
        },
      );
    },
  );
}


        if (!snap.hasData || snap.data!.isEmpty) {
          return _EmptyState(
            icon: Icons.school_outlined,
            title: 'Todavía no tenés cursos',
            buttonText: 'Ver cursos disponibles',
            onPressed: () => context.go('/cursos'),
          );
        }

        final items = snap.data!;
        return LayoutBuilder(
          builder: (context, c) {
            int cross = 1;
            if (c.maxWidth >= 1050) cross = 4;
            else if (c.maxWidth >= 820) cross = 3;
            else if (c.maxWidth >= 560) cross = 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 4 / 5,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _CourseAccessCard(item: items[i]),
            );
          },
        );
      },
    );
  }
}

/* ─────────────────────────  UI  ───────────────────────── */

class _CourseAccessCard extends StatelessWidget {
  final _AccessCourse item;
  const _CourseAccessCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final status = _ExpiryStatus.from(item);
    final barColor = status.color(cs);
    final chipBg = barColor.withOpacity(.14);
    final icon = status.icon;
    final label = status.label;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.go('/curso/${item.productId}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: item.coverUrl.isEmpty
                      ? Container(color: cs.onSurface.withOpacity(.08))
                      : Image.network(item.coverUrl, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),

              // Título
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),

              // Lecciones
              if (item.lessons > 0)
                Text('${item.lessons} lecciones',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(.7),
                        )),
              const Spacer(),

              // Chip de días restantes
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: barColor.withOpacity(.5), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: barColor),
                        const SizedBox(width: 6),
                        Text(label, style: TextStyle(color: barColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Barra de tiempo restante (si aplica)
              if (status.showProgress)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: status.progress,
                    minHeight: 6,
                    backgroundColor: cs.onSurface.withOpacity(.08),
                    color: barColor,
                  ),
                ),
              const SizedBox(height: 10),

              // CTA
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: () => context.go('/curso/${item.productId}'),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 46, color: cs.primary.withOpacity(.9)),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

/* ─────────────────────────  MODELO  ───────────────────────── */

class _AccessCourse {
  final String productId;
  final String title;
  final String coverUrl;
  final DateTime createdAt;
  final DateTime? expiresAt; // si está seteado en maru_access
  final int? accessDays;     // si se define en maru_products
  final String kind;         // 'course' | 'plan'
  final int lessons;

  _AccessCourse({
    required this.productId,
    required this.title,
    required this.coverUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.accessDays,
    required this.kind,
    required this.lessons,
  });

  /// Fecha de expiración efectiva (maru_access.expires_at || created_at + access_days)
  DateTime? get effectiveExpiry {
    if (expiresAt != null) return expiresAt;
    if (accessDays != null) {
      return createdAt.add(Duration(days: accessDays!));
    }
    return null; // ilimitado
  }

  /// Días restantes (null = ilimitado)
  int? get daysLeft {
    final exp = effectiveExpiry;
    if (exp == null) return null;
    final left = exp.difference(DateTime.now()).inDays;
    return left;
  }

  /// Duración total en días (si se puede calcular)
  int? get totalDays {
    final exp = effectiveExpiry;
    if (exp == null) return null;
    final total = exp.difference(createdAt).inDays;
    return total <= 0 ? 1 : total;
  }
}

enum _ExpiryKind { unlimited, active, lastDay, expired }

class _ExpiryStatus {
  final _ExpiryKind kind;
  final int? daysLeft;
  final double progress; // 0..1 del tiempo consumido
  final bool showProgress;

  _ExpiryStatus(this.kind, this.daysLeft, this.progress, this.showProgress);

  static _ExpiryStatus from(_AccessCourse c) {
  final dl = c.daysLeft;

  if (dl == null) {
    return _ExpiryStatus(_ExpiryKind.unlimited, null, 1.0, false);
  }
  if (dl < 0) {
    return _ExpiryStatus(_ExpiryKind.expired, 0, 1.0, true);
  }
  if (dl == 0) {
    final double t = (c.totalDays ?? 1).toDouble();
    final double used = (t - 0).clamp(0.0, t).toDouble();
    final double p = (used / t).clamp(0.0, 1.0).toDouble();
    return _ExpiryStatus(_ExpiryKind.lastDay, 0, p, true);
  }

  final double t = (c.totalDays ?? dl).toDouble();
  final double used = (t - dl).clamp(0.0, t).toDouble();
  final double p = (used / t).clamp(0.0, 1.0).toDouble();
  return _ExpiryStatus(_ExpiryKind.active, dl, p, true);
}


  String get label {
    switch (kind) {
      case _ExpiryKind.unlimited:
        return 'Acceso ilimitado';
      case _ExpiryKind.expired:
        return 'Acceso expirado';
      case _ExpiryKind.lastDay:
        return '¡Último día!';
      case _ExpiryKind.active:
        return '$daysLeft días restantes';
    }
  }

  IconData get icon {
    switch (kind) {
      case _ExpiryKind.unlimited:
        return Icons.all_inclusive;
      case _ExpiryKind.expired:
        return Icons.cancel_outlined;
      case _ExpiryKind.lastDay:
        return Icons.hourglass_top_rounded;
      case _ExpiryKind.active:
        return Icons.hourglass_bottom_rounded;
    }
  }

  Color color(ColorScheme cs) {
    switch (kind) {
      case _ExpiryKind.unlimited:
        return cs.primary;
      case _ExpiryKind.active:
        return cs.primary;
      case _ExpiryKind.lastDay:
        return cs.tertiary; // tono de aviso
      case _ExpiryKind.expired:
        return cs.error;
    }
  }
}
