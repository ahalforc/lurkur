import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';

/// Shows a popup that lets the user change app settings.
///
/// For more information, please see [SettingsBody].
void showSettingsPopup(BuildContext context) {
  showPrimaryPopup(
    context: context,
    builder: (context, _) {
      return const SettingsBody();
    },
  );
}

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _HeaderTile(text: 'Theme'),
        const _ThemeBrightness(),
        const _ThemeColor(),
        const _HeaderTile(text: 'Session'),
        const ListTile(
          leading: Icon(Icons.logout),
          title: Text('Log out'),
        ),
        SizedBox(
          height: MediaQuery.of(context).padding.bottom,
        ),
      ],
    );
  }
}

class _HeaderTile extends StatelessWidget {
  const _HeaderTile({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: context.textTheme.titleMedium,
      ),
    );
  }
}

class _ThemeBrightness extends StatelessWidget {
  const _ThemeBrightness();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: switch (context.watch<PreferenceCubit>().state.themeBrightness) {
        ThemeBrightness.light => const Icon(Icons.light_mode),
        ThemeBrightness.dark => const Icon(Icons.dark_mode),
        ThemeBrightness.auto => const Icon(Icons.brightness_auto),
      },
      title: const Text('Brightness mode'),
      onTap: () => context.read<PreferenceCubit>().nextThemeBrightness(),
    );
  }
}

class _ThemeColor extends StatelessWidget {
  const _ThemeColor();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.color_lens,
        color: context.colorScheme.primary,
      ),
      title: const Text('App color'),
      onTap: () => context.read<PreferenceCubit>().nextThemeColor(),
    );
  }
}
