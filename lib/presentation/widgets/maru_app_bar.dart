import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaruAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MaruAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: const Text('Nutricionista Online'),
      actions: [
        TextButton(
  onPressed: () async {
    final sb = Supabase.instance.client;
    if (sb.auth.currentUser == null) {
      await sb.auth.signInWithPassword(
        email: 'manunv97@gmail.com',  // el que crees en Dashboard
        password: '654321',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión iniciada')),
      );
    } else {
      await sb.auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada')),
      );
    }
  },
  child: Text(Supabase.instance.client.auth.currentUser == null
      ? 'Ingresar (dev)'
      : 'Salir'),
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
