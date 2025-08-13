import 'package:go_router/go_router.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/curso_detalle_screen.dart';
import 'package:maru_nutricion/presentation/screens/curso_detalle/lesson/lesson_screen.dart';
import 'package:maru_nutricion/presentation/screens/home/home_screen.dart';
import 'package:maru_nutricion/presentation/screens/cursos/cursos_screen.dart';
import 'package:maru_nutricion/presentation/screens/planes/planes_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/cursos', builder: (_, __) => const CursosScreen()),
    GoRoute(path: '/planes', builder: (_, __) => const PlanesScreen()),
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
