import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MpCheckoutService {
  MpCheckoutService(this._sb);
  final SupabaseClient _sb;

  Future<void> startCheckout(BuildContext context, String productId) async {
    await _sb.auth.refreshSession(); // evita tokens vencidos
    final session = _sb.auth.currentSession;

    if (session == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Iniciá sesión para comprar')));
      return;
    }

    try {
      final resp = await _sb.functions.invoke(
        'maru-mp-create-preference',
        body: {'product_id': productId},
        headers: {'Authorization': 'Bearer ${session.accessToken}'}, // <-- clave
      );

      final link = (resp.data as Map)['init_point'] as String?;
      if (link == null || link.isEmpty) throw 'init_point vacío';

      final ok = await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );
      if (!ok) throw 'No se pudo abrir el link';
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al iniciar pago: $e')));
    }
  }
}
