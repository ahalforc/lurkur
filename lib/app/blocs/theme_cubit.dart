import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

extension BuildContextXTheme on BuildContext {
  bool get isDeviceWide =>
      MediaQuery.of(this).size.width > MediaQuery.of(this).size.height;

  bool get isDeviceNarrow => !isDeviceWide;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

/// Manages the app's theme.
class ThemeCubit extends Cubit<ThemeState> {
  static const xxsmallPadding = 2.0;
  static const xsmallPadding = 4.0;
  static const smallPadding = 8.0;
  static const mediumPadding = 16.0;
  static const bigPadding = 24.0;
  static const largePadding = 32.0;
  static const xlargePadding = 64.0;

  ThemeCubit() : super(const ThemeState(color: Colors.blue));

  void setColorSeed(Color color) {
    emit(
      ThemeState(
        color: color,
      ),
    );
  }
}

/// Provides access to theme objects using customizable inputs.
final class ThemeState {
  const ThemeState({
    required this.color,
  });

  final Color color;

  ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
        ),
        textTheme: _makeTextTheme(),
      );

  ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,
        ),
        textTheme: _makeTextTheme(),
      );

  TextTheme _makeTextTheme() {
    final displayFont = GoogleFonts.yantramanav();
    final headlineFont = displayFont;
    final titleFont = GoogleFonts.heebo();
    final bodyFont = GoogleFonts.oxygen();
    final labelFont = bodyFont;

    return TextTheme(
      displayLarge: displayFont,
      displayMedium: displayFont,
      displaySmall: displayFont,
      headlineLarge: headlineFont,
      headlineMedium: headlineFont,
      headlineSmall: headlineFont,
      titleLarge: titleFont,
      titleMedium: titleFont,
      titleSmall: titleFont,
      bodyLarge: bodyFont,
      bodyMedium: bodyFont,
      bodySmall: bodyFont,
      labelLarge: labelFont,
      labelMedium: labelFont,
      labelSmall: labelFont,
    );
  }
}
