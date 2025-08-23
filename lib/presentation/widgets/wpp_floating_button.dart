import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsappFloatingButton extends StatefulWidget {
  const WhatsappFloatingButton({super.key});
  @override
  State<WhatsappFloatingButton> createState() => _WhatsappFloatingButtonState();
}

class _WhatsappFloatingButtonState extends State<WhatsappFloatingButton> {
  static const _phone = '5491166383102';
  static const _msg = 'Hola! Quiero más info sobre los cursos de nutrición.';

  bool _isHovered = false;

  Future<void> _openWhatsapp() async {
    final encoded = Uri.encodeComponent(_msg);

    // 1) App nativa (Android/iOS)
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
         defaultTargetPlatform == TargetPlatform.iOS)) {
      final native = Uri.parse('whatsapp://send?phone=$_phone&text=$encoded');
      if (await canLaunchUrl(native)) {
        final ok = await launchUrl(native, mode: LaunchMode.externalApplication);
        if (ok) return;
      }
    }

    // 2) Fallback universal (Web / desktop / sin app)
    final wa = Uri.parse('https://wa.me/$_phone?text=$encoded');
    try {
      // intento pestaña nueva
      final ok = await launchUrl(
        wa,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (ok) return;
    } catch (_) {}
    // si el navegador bloquea popups, abrimos en la misma pestaña
    await launchUrl(
      wa,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_self',
    );
  }

  bool get _esWebDesktop =>
      kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.macOS ||
       defaultTargetPlatform == TargetPlatform.windows ||
       defaultTargetPlatform == TargetPlatform.linux);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final icono = Padding(
      padding: const EdgeInsets.all(10),
      child: AnimatedScale(
        scale: _esWebDesktop && _isHovered ? 1.6 : 1.4,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.primary, shape: BoxShape.circle),
          child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 40),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(25),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: _esWebDesktop ? (_) => setState(() => _isHovered = true) : null,
        onExit : _esWebDesktop ? (_) => setState(() => _isHovered = false) : null,
        child: GestureDetector(onTap: _openWhatsapp, child: icono),
      ),
    );
  }
}
