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
  static const small1Padding = 1.0;
  static const small2Padding = 2.0;
  static const small3Padding = 4.0;
  static const medium1Padding = 8.0;
  static const medium2Padding = 16.0;
  static const medium3Padding = 24.0;
  static const large1Padding = 32.0;
  static const large2Padding = 64.0;
  static const large3Padding = 128.0;

  static const maxBodyWidth = 560.0;

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
  static const black = Color(0xFF000000);
  static const night = Color(0xFF141414);
  static const white = Color(0xFFFFFFFF);
  static const linen = Color(0xFFFFEDE1);
  static const jasper = Color(0xFFBF4E30);
  static const cerulean = Color(0xFF37718E);
  static const resedaGreen = Color(0xFF646F4B);

  const ThemeState({
    required this.color,
  });

  final Color color;

  ThemeData get lightTheme => _makeThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: cerulean,
          brightness: Brightness.light,
          primary: cerulean,
          onPrimary: Colors.white,
          secondary: jasper,
          onSecondary: Colors.white,
          tertiary: resedaGreen,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      );

  ThemeData get darkTheme => _makeThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: cerulean,
          brightness: Brightness.dark,
          primary: cerulean,
          onPrimary: Colors.white,
          secondary: jasper,
          onSecondary: Colors.white,
          tertiary: resedaGreen,
          onTertiary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: Colors.black,
          onBackground: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
        ),
      );

  ThemeData _makeThemeData({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: _makeTextTheme(),
        applyElevationOverlayColor: false,
        appBarTheme: _makeAppBarTheme(colorScheme),
        bottomNavigationBarTheme: _makeBottomNavigationBarTheme(colorScheme),
        bottomSheetTheme: _makeBottomSheetTheme(colorScheme),
        cardTheme: _makeCardTheme(colorScheme),
        inputDecorationTheme: _makeInputDecorationTheme(),
        filledButtonTheme: _makeFilledButtonTheme(),
        outlinedButtonTheme: _makeOutlinedButtonTheme(),
        textButtonTheme: _makeTextButtonTheme(),
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

  AppBarTheme _makeAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.background,
      foregroundColor: colorScheme.onBackground,
      surfaceTintColor: colorScheme.background,
    );
  }

  BottomNavigationBarThemeData _makeBottomNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.background,
      unselectedItemColor: colorScheme.onBackground,
      selectedItemColor: colorScheme.onBackground,
    );
  }

  BottomSheetThemeData _makeBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.background,
      surfaceTintColor: colorScheme.background,
      dragHandleColor: colorScheme.onBackground,
      dragHandleSize: const Size(48, 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
    );
  }

  CardTheme _makeCardTheme(ColorScheme colorScheme) {
    return CardTheme(
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      color: colorScheme.primaryContainer,
      surfaceTintColor: null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  InputDecorationTheme _makeInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  FilledButtonThemeData _makeFilledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  OutlinedButtonThemeData _makeOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  TextButtonThemeData _makeTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
