import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:maru_nutricion/presentation/screens/home/home_screen.dart';
import 'package:maru_nutricion/presentation/screens/cursos/cursos_screen.dart';
import 'package:maru_nutricion/presentation/screens/planes/planes_screen.dart';
import 'package:maru_nutricion/presentation/screens/quienes_somos/quienes_somos_screen.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/curso_detalle_screen.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/lesson/lesson_screen.dart';
import 'package:maru_nutricion/presentation/screens/mis_cursos_screen/mis_cursos_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/cursos', builder: (_, __) => const CursosScreen()),
    GoRoute(path: '/planes', builder: (_, __) => const PlanesScreen()),
    GoRoute(
      path: '/quienes-somos',
      builder: (_, __) => const QuienesSomosScreen(),
    ),
    GoRoute(
      path: '/mis-cursos',
      builder: (_, __) => const MisCursosScreen(),
    ),
    GoRoute(
      path: '/curso/:id',
      builder: (_, s) => CursoDetalleScreen(productId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/leccion/:id',
      builder: (_, s) => LessonScreen(lessonId: s.pathParameters['id']!),
    ),
  ],
);
