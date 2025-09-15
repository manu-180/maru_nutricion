import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maru_nutricion/presentation/widgets/feedback/toast.dart';
import 'package:maru_nutricion/presentation/widgets/auth/auth_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MaruAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MaruAppBar({super.key});

  @override
  State<MaruAppBar> createState() => _MaruAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _MaruAppBarState extends State<MaruAppBar>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _menuEntry;
  late final AnimationController _menuCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
  late final Animation<double> _fade =
      CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide =
      Tween(begin: const Offset(0, -0.06), end: Offset.zero)
          .animate(CurvedAnimation(parent: _menuCtrl, curve: Curves.easeOutCubic));

  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _removeMenu(immediate: true);
    _menuCtrl.dispose();
    _authSub?.cancel();
    super.dispose();
  }

  int _indexForLocation(String loc) {
    if (loc == '/' || loc.startsWith('/inicio')) return 0;
    if (loc.startsWith('/cursos')) return 1;
    if (loc.startsWith('/planes')) return 2;
    if (loc.startsWith('/quienes-somos')) return 3;
    if (loc.startsWith('/mis-cursos')) return 4;
    return 0;
  }

  void _goByIndex(int i) {
    switch (i) {
      case 0: context.go('/'); break;
      case 1: context.go('/cursos'); break;
      case 2: context.go('/planes'); break;
      case 3: context.go('/quienes-somos'); break;
      case 4: context.go('/mis-cursos'); break;
    }
  }

  void _openAuth(AuthMode mode) {
    _menuCtrl.reverse();
    _removeMenu(immediate: true);
    showAuthDialog(context, initial: mode, onSuccess: () {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _logout() async {
    // cerrar menú si está abierto
    if (_menuEntry != null) {
      try {
        await _menuCtrl.reverse().orCancel;
      } catch (_) {}
      _removeMenu(immediate: true);
    }

    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}

    if (!mounted) return;

    // navegar a Home y luego toast (en root overlay)
    context.go('/');
    Future.microtask(() {
      showSuccessToast(null, 'Sesión cerrada');
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 960;
    final cs = Theme.of(context).colorScheme;

    final loc = GoRouterState.of(context).uri.toString();
    final selected = _indexForLocation(loc);
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

    final navTextStyle =
        (Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16))
            .copyWith(fontSize: 16, fontWeight: FontWeight.w600);

    return AppBar(
      centerTitle: false,
      toolbarHeight: 100,
      titleSpacing: 16,
      title: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Image.asset(
                'assets/logo/maru_logo.png',
                height: 170,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 24),
          if (!isMobile)
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: _DesktopNavBar(
                      labels: const [
                        'Inicio', 'Cursos', 'Planes', 'Quiénes Somos', 'Mis cursos'
                      ],
                      selectedIndex: selected,
                      onTapIndex: _goByIndex,
                      primary: cs.primary,
                      textStyle: navTextStyle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      actions: [
        if (!isMobile) ...[
          if (isLoggedIn)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _NavItem(
                label: 'Cerrar sesión',
                selected: false,
                onTap: _logout,
                primary: cs.primary,
                textStyle: navTextStyle,
              ),
            )
          else ...[
            _NavItem(
              label: 'Iniciar sesión',
              selected: false,
              onTap: () => _openAuth(AuthMode.login),
              primary: cs.primary,
              textStyle: navTextStyle,
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _NavItem(
                label: 'Crear cuenta',
                selected: false,
                onTap: () => _openAuth(AuthMode.register),
                primary: cs.primary,
                textStyle: navTextStyle,
              ),
            ),
          ],
        ] else ...[
          IconButton(
            onPressed: _toggleMenu,
            icon: RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_menuCtrl),
              child: const Icon(Icons.keyboard_arrow_down),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  void _toggleMenu() {
    if (_menuEntry == null) {
      final overlay = Overlay.of(context);
      if (overlay == null) return;
      final top = MediaQuery.of(context).padding.top + 100;
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

      _menuEntry = OverlayEntry(
        builder: (ctx) {
          final cs = Theme.of(ctx).colorScheme;
          return Stack(
            children: [
              Positioned.fill(
                child: FadeTransition(
                  opacity: _fade,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleMenu,
                    child: const SizedBox.shrink(),
                  ),
                ),
              ),
              Positioned(
                left: 0, right: 0, top: top,
                child: SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Material(
                      color: cs.surface,
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _menuTile('Inicio', '/', Icons.home),
                          _menuTile('Cursos', '/cursos', Icons.school),
                          _menuTile('Planes', '/planes', Icons.subscriptions),
                          _menuTile('Quiénes Somos', '/quienes-somos', Icons.info),
                          _menuTile('Mis cursos', '/mis-cursos', Icons.library_books),
                          const Divider(height: 1),
                          if (isLoggedIn)
                            _menuTile('Cerrar sesión', null, Icons.logout, onTap: _logout)
                          else ...[
                            _menuTile('Iniciar sesión', null, Icons.login,
                                onTap: () => _openAuth(AuthMode.login)),
                            _menuTile('Crear cuenta', null, Icons.person_add,
                                onTap: () => _openAuth(AuthMode.register)),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      overlay.insert(_menuEntry!);
      _menuCtrl.forward(from: 0);
    } else {
      _menuCtrl.reverse().whenComplete(() => _removeMenu());
    }
  }

  void _removeMenu({bool immediate = false}) {
    if (_menuEntry == null) return;
    if (immediate) {
      _menuEntry?.remove();
      _menuEntry = null;
      return;
    }
    _menuEntry?.remove();
    _menuEntry = null;
  }

  Widget _menuTile(String label, String? route, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        _menuCtrl.reverse();
        _removeMenu();
        if (onTap != null) {
          onTap();
        } else if (route != null) {
          context.go(route);
        }
      },
    );
  }
}

class _DesktopNavBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final void Function(int) onTapIndex;
  final Color primary;
  final TextStyle textStyle;

  const _DesktopNavBar({
    required this.labels,
    required this.selectedIndex,
    required this.onTapIndex,
    required this.primary,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(labels.length, (i) {
        return _NavItem(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onTapIndex(i),
          primary: primary,
          textStyle: textStyle,
        );
      }),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;
  final TextStyle textStyle;

  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primary,
    required this.textStyle,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  double _textWidth(BuildContext context, String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp.width;
  }

  @override
  Widget build(BuildContext context) {
    final selectedStyle = widget.textStyle;
    final unselectedStyle =
        widget.textStyle.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.72));

    final style = widget.selected ? selectedStyle : unselectedStyle;
    final w = _textWidth(context, widget.label, style) + 2;
    final target = (widget.selected || _hover) ? 1.0 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.label, style: style),
              const SizedBox(height: 8),
              SizedBox(
                width: w,
                height: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    tween: Tween<double>(begin: 0, end: target),
                    builder: (_, value, __) {
                      final bw = w * value;
                      final draw = bw >= 1.0;
                      return draw
                          ? Container(
                              width: bw,
                              height: 3,
                              decoration: BoxDecoration(
                                color: widget.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
