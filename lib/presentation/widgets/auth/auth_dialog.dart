import 'package:flutter/material.dart';
import 'package:maru_nutricion/presentation/widgets/feedback/toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthMode { login, register }

Future<void> showAuthDialog(
  BuildContext context, {
  AuthMode initial = AuthMode.login,
  VoidCallback? onSuccess,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _AuthDialog(initial: initial, onSuccess: onSuccess),
  );
}

class _AuthDialog extends StatefulWidget {
  final AuthMode initial;
  final VoidCallback? onSuccess;
  const _AuthDialog({required this.initial, this.onSuccess});

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  late AuthMode _mode = widget.initial;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  final _pass2Focus = FocusNode();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    _pass2Focus.dispose();
    super.dispose();
  }

  String _friendlyAuthError(AuthException e) {
    final m = (e.message ?? '').toLowerCase();
    if (m.contains('already registered')) {
      return 'Ese email ya está registrado. Probá iniciar sesión.';
    }
    if (m.contains('invalid login credentials')) {
      return 'Email o contraseña incorrectos. Revisá los datos.';
    }
    if (m.contains('email not confirmed') || m.contains('not verified')) {
      return 'Tu email aún no está verificado. Revisá tu casilla.';
    }
    if (m.contains('too many requests') || m.contains('rate limit')) {
      return 'Demasiados intentos. Probá de nuevo en unos minutos.';
    }
    return 'No pudimos completar la operación. Intentá nuevamente.';
    // para debugging: // return e.message ?? 'Error';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final sb = Supabase.instance.client;

    try {
      if (_mode == AuthMode.login) {
        final res = await sb.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
        if (res.user == null) throw AuthException('login_failed');
      } else {
        final res = await sb.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          data: {'full_name': _nameCtrl.text.trim()},
        );
        if (res.user == null) throw AuthException('signup_failed');
      }

      if (!mounted) return;
      showSuccessToast(null, _mode == AuthMode.login
          ? '¡Sesión iniciada!'
          : 'Cuenta creada. Revisá tu correo si es necesario.');
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    } on AuthException catch (e) {
      setState(() => _error = _friendlyAuthError(e));
    } catch (_) {
      setState(() => _error = 'No pudimos completar la operación. Intentá nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _ModeChip(
                    label: 'Iniciar sesión',
                    selected: _mode == AuthMode.login,
                    onTap: () => setState(() => _mode = AuthMode.login),
                  ),
                  const SizedBox(width: 8),
                  _ModeChip(
                    label: 'Crear cuenta',
                    selected: _mode == AuthMode.register,
                    onTap: () => setState(() => _mode = AuthMode.register),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: cs.onSurface.withOpacity(.08)),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                      sizeFactor: anim,
                      axisAlignment: -1,
                      child: child,
                    ),
                  ),
                  child: _mode == AuthMode.login
                      ? _LoginFields(
                          key: const ValueKey('login'),
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          emailFocus: _emailFocus,
                          passFocus: _passFocus,
                          onSubmit: _submit, // ENTER
                          obscure: _obscure,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                        )
                      : _RegisterFields(
                          key: const ValueKey('register'),
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          pass2Ctrl: _pass2Ctrl,
                          emailFocus: _emailFocus,
                          passFocus: _passFocus,
                          pass2Focus: _pass2Focus,
                          onSubmit: _submit, // ENTER
                          obscure: _obscure,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Botón más chico (máx. 360 px)
              Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_mode == AuthMode.login
                              ? 'Iniciar sesión'
                              : 'Crear cuenta'),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading
                    ? null
                    : () => setState(() {
                          _mode = _mode == AuthMode.login
                              ? AuthMode.register
                              : AuthMode.login;
                        }),
                child: Text(_mode == AuthMode.login
                    ? '¿No tenés cuenta? Crear cuenta'
                    : '¿Ya tenés cuenta? Iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? cs.primary.withOpacity(.12) : Colors.transparent,
          border: Border.all(
            color: selected ? cs.primary : cs.onSurface.withOpacity(.24),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? cs.primary : null,
          ),
        ),
      ),
    );
  }
}

class _LoginFields extends StatelessWidget {
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final VoidCallback onSubmit;
  final bool obscure;
  final VoidCallback onToggleObscure;
  const _LoginFields({
    super.key,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.onSubmit,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: emailCtrl,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passFocus),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'tu@email.com',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingresá tu email';
            if (!v.contains('@')) return 'Email inválido';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passCtrl,
          focusNode: passFocus,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(), // ENTER
          decoration: InputDecoration(
            labelText: 'Contraseña',
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleObscure,
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresá tu contraseña';
            return null;
          },
        ),
      ],
    );
  }
}

class _RegisterFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final TextEditingController pass2Ctrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final FocusNode pass2Focus;
  final VoidCallback onSubmit;
  final bool obscure;
  final VoidCallback onToggleObscure;

  const _RegisterFields({
    super.key,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.pass2Ctrl,
    required this.emailFocus,
    required this.passFocus,
    required this.pass2Focus,
    required this.onSubmit,
    required this.obscure,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: nameCtrl,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Nombre y apellido'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingresá tu nombre';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailCtrl,
          focusNode: emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passFocus),
          decoration: const InputDecoration(labelText: 'Email'),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Ingresá tu email';
            if (!v.contains('@')) return 'Email inválido';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passCtrl,
          focusNode: passFocus,
          obscureText: obscure,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) =>
              FocusScope.of(context).requestFocus(pass2Focus),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            helperText: 'Mínimo 6 caracteres',
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleObscure,
            ),
          ),
          validator: (v) {
            if (v == null || v.length < 6) return 'Mínimo 6 caracteres';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: pass2Ctrl,
          focusNode: pass2Focus,
          obscureText: obscure,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onSubmit(), // ENTER
          decoration: const InputDecoration(labelText: 'Repetir contraseña'),
          validator: (v) {
            if (v != passCtrl.text) return 'Las contraseñas no coinciden';
            return null;
          },
        ),
      ],
    );
  }
}
