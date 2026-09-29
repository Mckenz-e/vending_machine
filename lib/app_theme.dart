import 'package:flutter/material.dart';

const Color darkBrown = Color(0xFF3E2410);
const Color brown = Color(0xFF6B4423);
const Color gold = Color(0xFFD4AF37);
const Color parchment = Color(0xFFF3E2A9);

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: gold,
    primary: darkBrown,
    onPrimary: parchment,
    secondary: gold,
    surface: parchment,
    onSurface: darkBrown,
  );

  return ThemeData(
    colorScheme: scheme,
    fontFamily: 'serif',
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBrown,
      foregroundColor: gold,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: gold,
        fontFamily: 'serif',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: parchment,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: brown),
      ),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: parchment),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkBrown,
        backgroundColor: parchment.withValues(alpha: 0.60),
        side: const BorderSide(color: brown),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkBrown,
        foregroundColor: gold,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: darkBrown,
      contentTextStyle: TextStyle(color: gold),
    ),
  );
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: parchment,
        image: DecorationImage(
          image: AssetImage('assets/theme.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
