import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaruAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MaruAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100, // altura del AppBar
      // background/foreground vienen del Theme (fondo crema + texto oscuro)
      titleSpacing: 16,
      title: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => context.go('/'),
          child: Image.asset(
            'assets/logo/maru_logo.png',
            height: 140,           // encaja cómodo en 100px de alto
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final sb = Supabase.instance.client;
            if (sb.auth.currentUser == null) {
              await sb.auth.signInWithPassword(
                email: 'manunv97@gmail.com',
                password: '654321',
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Sesión iniciada')));
            } else {
              await sb.auth.signOut();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
            }
          },
          child: Text(
            Supabase.instance.client.auth.currentUser == null
                ? 'Ingresar (dev)'
                : 'Salir',
          ),
        ),
        TextButton(
          onPressed: () => context.go('/cursos'),
          child: const Text('Cursos'),
        ),
        TextButton(
          onPressed: () => context.go('/planes'),
          child: const Text('Planes'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
