import 'package:flutter/material.dart';

/// Paleta (0 = celeste del logo)
const List<Color> listColors = [
  Color(0xFF2FA9B1), // ajustá si tu hex exacto es otro
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;
  const AppTheme({this.selectedColor = 0, this.isDarkMode = true}); // oscuro por defecto

  // Colores base
  static const _brandTeal   = Color(0xFF2FA9B1); // celeste marca
  static const _bgDark      = Color(0xFF2B2B2B); // gris oscuro del fondo del logo
  static const _textOnDark  = Colors.white;
  static const _textOnDark2 = Colors.white70;

  ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: listColors[selectedColor],
        brightness: Brightness.dark,
        primary: _brandTeal,
        onPrimary: Colors.white,
        surface: _bgDark,
        onSurface: _textOnDark,
        background: _bgDark,
        onBackground: _textOnDark,
      ),
      scaffoldBackgroundColor: _bgDark,

      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _bgDark,
        foregroundColor: _textOnDark,
      ),

      iconTheme: const IconThemeData(color: _textOnDark),

      // OJO: en tu SDK esto debe ser TabBarThemeData
      tabBarTheme: const TabBarThemeData(
        dividerColor: Colors.transparent, // sin línea fina
        labelColor: _textOnDark,
        unselectedLabelColor: _textOnDark2,
        indicatorColor: _brandTeal, // usa el celeste de marca
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) return _brandTeal.withOpacity(.45);
            return _brandTeal;
          }),
          foregroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.disabled) ? Colors.white70 : Colors.white,
          ),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) return _brandTeal.withOpacity(.08);
            if (states.contains(MaterialState.pressed)) return _brandTeal.withOpacity(.16);
            if (states.contains(MaterialState.focused)) return _brandTeal.withOpacity(.12);
            return null;
          }),
          elevation: MaterialStateProperty.resolveWith<double>(
            (states) => states.contains(MaterialState.hovered) ? 1 : 0,
          ),
          shape: const MaterialStatePropertyAll(StadiumBorder()),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            final active = states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.focused);
            return active ? _brandTeal : Colors.transparent;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            final active = states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.focused);
            return active ? Colors.white : _textOnDark;
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>((states) {
            final active = states.contains(MaterialState.hovered) ||
                states.contains(MaterialState.pressed) ||
                states.contains(MaterialState.focused);
            return BorderSide(color: active ? _brandTeal : Colors.white38, width: 1.4);
          }),
          overlayColor: const MaterialStatePropertyAll(Colors.transparent),
          shape: const MaterialStatePropertyAll(StadiumBorder()),
          padding: const MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(_textOnDark),
          overlayColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) return _brandTeal.withOpacity(.10);
            if (states.contains(MaterialState.pressed)) return _brandTeal.withOpacity(.16);
            return null;
          }),
        ),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: _textOnDark,
        displayColor: _textOnDark,
      ),
    );
  }

  AppTheme copyWith({bool? isDarkMode, int? selectedColor}) => AppTheme(
        isDarkMode: isDarkMode ?? this.isDarkMode,
        selectedColor: selectedColor ?? this.selectedColor,
      );
}
