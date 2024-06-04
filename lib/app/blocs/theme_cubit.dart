import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

extension BuildContextXTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  EdgeInsets get responsiveHorizontalPadding {
    final screenSize = MediaQuery.of(this).size;
    return EdgeInsets.symmetric(
      horizontal: max(
        (screenSize.width - ThemeCubit.maxBodyWidth) / 2,
        16,
      ),
    );
  }
}

/// Manages the app's theme.
class ThemeCubit extends Cubit<ThemeState> {
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

  static const ivoryA = Color(0xFFF6EBD4); // 246 235 212
  static const ivoryB = Color(0xFFEAE1CA); // 234 225 202
  static const blueA = Color(0xFF5F739A); // 95 115 154
  static const blueB = Color(0xFF43618B); // 67 97 139

  const ThemeState({
    required this.color,
  });

  final Color color;

  ThemeData get lightTheme => _makeThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: blueA,
          brightness: Brightness.light,
        ),
      );

  ThemeData get darkTheme => _makeThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: blueA,
          brightness: Brightness.dark,
        ),
      );

  ThemeData _makeThemeData({
    required ColorScheme colorScheme,
  }) =>
      ThemeData(
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
    final titleFont = GoogleFonts.heebo(
      fontWeight: FontWeight.w500,
    );
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
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: colorScheme.surface,
    );
  }

  BottomNavigationBarThemeData _makeBottomNavigationBarTheme(
    ColorScheme colorScheme,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      unselectedItemColor: colorScheme.onSurface,
      selectedItemColor: colorScheme.onSurface,
    );
  }

  BottomSheetThemeData _makeBottomSheetTheme(ColorScheme colorScheme) {
    return BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surface,
      dragHandleColor: colorScheme.onSurface,
      dragHandleSize: const Size(48, 4),
      shape: RoundedRectangleBorder(
        borderRadius: LurkurRadius.radius16.topCircularBorderRadius,
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
        borderRadius: LurkurRadius.radius16.circularBorderRadius,
      ),
    );
  }

  InputDecorationTheme _makeInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: LurkurRadius.radius16.circularBorderRadius,
      ),
    );
  }

  FilledButtonThemeData _makeFilledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: LurkurRadius.radius8.circularBorderRadius,
          ),
        ),
      ),
    );
  }

  OutlinedButtonThemeData _makeOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: LurkurRadius.radius8.circularBorderRadius,
          ),
        ),
      ),
    );
  }

  TextButtonThemeData _makeTextButtonTheme() {
    return TextButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: LurkurRadius.radius8.circularBorderRadius,
          ),
        ),
      ),
    );
  }
}

extension ColorSchemeX on ColorScheme {
  Color get nsfwPrimaryColor => Colors.red;

  Color get pinnedPrimaryColor => Colors.brown;

  Color get stickiedPrimaryColor => Colors.green;
}

enum LurkurSpacing {
  spacing2(2),
  spacing4(4),
  spacing8(8),
  spacing12(12),
  spacing16(16),
  spacing24(24),
  spacing32(32);

  const LurkurSpacing(this.value);

  final double value;

  EdgeInsets get leftInset => EdgeInsets.only(left: value);

  EdgeInsets get rightInset => EdgeInsets.only(right: value);

  EdgeInsets get topInset => EdgeInsets.only(top: value);

  EdgeInsets get bottomInset => EdgeInsets.only(bottom: value);

  EdgeInsets get horizontalInsets => EdgeInsets.symmetric(horizontal: value);

  EdgeInsets get verticalInsets => EdgeInsets.symmetric(vertical: value);

  EdgeInsets get allInsets => EdgeInsets.all(value);

  Widget get horizontalGap => SizedBox(width: value);

  Widget get verticalGap => SizedBox(height: value);

  Widget get horizontalSliverGap => SliverToBoxAdapter(child: horizontalGap);

  Widget get verticalSliverGap => SliverToBoxAdapter(child: verticalGap);
}

enum LurkurRadius {
  radius8(8),
  radius16(16);

  const LurkurRadius(this.value);

  final double value;

  BorderRadius get topCircularBorderRadius => BorderRadius.vertical(
        top: Radius.circular(value),
      );

  BorderRadius get circularBorderRadius => BorderRadius.circular(value);
}
