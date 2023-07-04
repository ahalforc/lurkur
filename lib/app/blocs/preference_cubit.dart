import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores data on the user's device.
///
/// This data is only intended to be used for a user's preference and is subject
/// to deletion at the user's or device's discretion.
class PreferenceCubit extends Cubit<PreferenceState> {
  static const _themeBrightness = 'theme brightness';
  static const _themeColor = 'theme color';

  PreferenceCubit() : super(const PreferenceState.empty());

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<PreferenceState> get _nextState async {
    final prefs = await _prefs;
    return PreferenceState(
      themeBrightness: ThemeBrightness.values.firstWhere(
        (tb) => tb.value == prefs.getString(_themeBrightness),
        orElse: () => ThemeBrightness.auto,
      ),
      themeColor: ThemeColor.values.firstWhere(
        (tc) => tc.value == prefs.getString(_themeColor),
        orElse: () => ThemeColor.blue,
      ),
    );
  }

  void init() async {
    emit(await _nextState);
  }

  void nextThemeBrightness() async {
    (await _prefs).setString(
      _themeBrightness,
      ThemeBrightness.values.next(state.themeBrightness).value,
    );
    emit(await _nextState);
  }

  void nextThemeColor() async {
    (await _prefs).setString(
      _themeColor,
      ThemeColor.values.next(state.themeColor).value,
    );
    emit(await _nextState);
  }
}

extension _ListX<T> on List<T> {
  T next(T value) => this[(indexOf(value) + 1) % length];
}

/// A static type, synchronous representation of the user's stored preferences.
///
/// Note that defaults may be provided if the value isn't actually stored.
final class PreferenceState {
  const PreferenceState({
    required this.themeBrightness,
    required this.themeColor,
  });

  const PreferenceState.empty()
      : themeBrightness = ThemeBrightness.auto,
        themeColor = ThemeColor.blue;

  final ThemeBrightness themeBrightness;

  final ThemeColor themeColor;
}

enum ThemeBrightness {
  light('light'),
  dark('dark'),
  auto('auto');

  final String value;

  const ThemeBrightness(this.value);
}

enum ThemeColor {
  red('red'),
  orange('orange'),
  yellow('yellow'),
  green('green'),
  blue('blue'),
  indigo('indigo'),
  violet('violet');

  final String value;

  const ThemeColor(this.value);
}
