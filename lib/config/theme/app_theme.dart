import 'package:flutter/material.dart';

/// Paleta (0 = color de marca del logo)
const List<Color> listColors = [
  Color.fromRGBO(219, 121, 61, 1), // Naranja marca
  Color(0xFF26D1D9),
  Color(0xFF55E6C1),
  Color(0xFFF7D794),
  Color(0xFFFFA552),
  Color(0xFFE74C3C),
  Color(0xFFAF52DE),
];

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;
  const AppTheme({this.selectedColor = 0, this.isDarkMode = false});

  // Brand
  static const _brand    = Color.fromRGBO(219, 121, 61, 1);
  static const _cream    = Color(0xFFF9F6E8);
  static const _textDark = Color(0xFF3B3A37);

  ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: listColors[selectedColor],
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: _brand,
        onPrimary: Colors.white,
        surface: _cream,
        onSurface: _textDark,
      ),
      scaffoldBackgroundColor: _cream,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _cream,
        foregroundColor: _textDark,
      ),
     filledButtonTheme: FilledButtonThemeData(
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) return _brand.withOpacity(.45);
      return _brand;
    }),
    foregroundColor: MaterialStateProperty.resolveWith((states) {
      return states.contains(MaterialState.disabled) ? Colors.white70 : Colors.white;
    }),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered)) return _brand.withOpacity(.08);
      if (states.contains(MaterialState.pressed)) return _brand.withOpacity(.16);
      if (states.contains(MaterialState.focused)) return _brand.withOpacity(.12);
      return null;
    }),
    elevation: MaterialStateProperty.resolveWith<double>((states) {
      if (states.contains(MaterialState.hovered)) return 1;
      return 0;
    }),
    shape: const MaterialStatePropertyAll(StadiumBorder()),
    padding: const MaterialStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
),

outlinedButtonTheme: OutlinedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.hovered) ||
                     states.contains(WidgetState.pressed) ||
                     states.contains(WidgetState.focused);
      return active ? _brand : Colors.transparent;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      final active = states.contains(WidgetState.hovered) ||
                     states.contains(WidgetState.pressed) ||
                     states.contains(WidgetState.focused);
      return active ? Colors.white : _textDark;
    }),
    side: WidgetStateProperty.resolveWith<BorderSide>((states) {
      final active = states.contains(WidgetState.hovered) ||
                     states.contains(WidgetState.pressed) ||
                     states.contains(WidgetState.focused);
      return BorderSide(color: active ? _brand : const Color(0x663B3A37), width: 1.4);
    }),
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),
),


textButtonTheme: TextButtonThemeData(
  style: ButtonStyle(
    foregroundColor: const MaterialStatePropertyAll(_textDark),
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.hovered)) return _brand.withOpacity(.06);
      if (states.contains(MaterialState.pressed)) return _brand.withOpacity(.10);
      return null;
    }),
  ),
),

    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: _textDark,
        displayColor: _textDark,
      ),
    );
  }

  AppTheme copyWith({bool? isDarkMode, int? selectedColor}) => AppTheme(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    selectedColor: selectedColor ?? this.selectedColor,
  );
}
