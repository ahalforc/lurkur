import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/popups.dart';

/// Shows a popup that lets the user change app settings.
///
/// For more information, please see [SettingsBody].
void showSettingsPopup(BuildContext context) {
  showPrimaryPopup(
    context: context,
    builder: (context, scrollController) {
      return SettingsBody(
        scrollController: scrollController,
      );
    },
  );
}

class SettingsBody extends StatelessWidget {
  const SettingsBody({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: const [
        _HeaderTile(text: 'Theme'),
        _ThemeBrightness(),
        _ThemeColor(),
        _ThemeDensity(),
        _HeaderTile(text: 'Media'),
        _AutoPlayVideos(),
        _UseHtmlForText(),
        _HeaderTile(text: 'Session'),
        _HiddenSubreddits(),
        _ClearPreferences(),
        _LogOut(),
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
      title: const Text('Brightness'),
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
      title: const Text('Color'),
      onTap: () => context.read<PreferenceCubit>().nextThemeColor(),
    );
  }
}

class _ThemeDensity extends StatelessWidget {
  const _ThemeDensity();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: switch (context.watch<PreferenceCubit>().state.themeDensity) {
        ThemeDensity.small => const Icon(Icons.density_small),
        ThemeDensity.medium => const Icon(Icons.density_medium),
        ThemeDensity.large => const Icon(Icons.density_large),
      },
      title: const Text('Density'),
      onTap: () => context.read<PreferenceCubit>().nextThemeDensity(),
    );
  }
}

class _AutoPlayVideos extends StatelessWidget {
  const _AutoPlayVideos();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: switch (context.watch<PreferenceCubit>().state.autoPlayVideos) {
        true => const Icon(Icons.play_arrow),
        false => const Icon(Icons.cancel),
      },
      title: const Text('Auto play videos'),
      onTap: () => context.read<PreferenceCubit>().nextAutoPlayVideos(),
    );
  }
}

class _UseHtmlForText extends StatelessWidget {
  const _UseHtmlForText();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: switch (context.watch<PreferenceCubit>().state.useHtmlForText) {
        true => const Icon(Icons.check).animate().shake(),
        false => const Icon(Icons.cancel).animate().shake(),
      },
      title: const Text('Use HTML for text'),
      onTap: () => context.read<PreferenceCubit>().nextUseHtmlForText(),
    );
  }
}

class _LogOut extends StatelessWidget {
  const _LogOut();
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Log Out'),
      onTap: () => context.read<AuthCubit>().logout(),
    );
  }
}

class _HiddenSubreddits extends StatelessWidget {
  const _HiddenSubreddits();

  @override
  Widget build(BuildContext context) {
    final hiddenSubreddits =
        context.watch<PreferenceCubit>().state.hiddenSubreddits;
    return ExpansionTile(
      leading: const Icon(Icons.hide_source),
      title: const Text('Hidden subreddits'),
      children: [
        for (final subreddit in hiddenSubreddits)
          ListTile(
            key: ValueKey(subreddit),
            leading: Checkbox(
              value: true,
              onChanged: (_) => context.read<PreferenceCubit>().showSubreddit(
                    subreddit,
                  ),
            ),
            title: Text(subreddit),
            onTap: () => context.read<PreferenceCubit>().showSubreddit(
                  subreddit,
                ),
          ),
      ],
    );
  }
}

class _ClearPreferences extends StatelessWidget {
  const _ClearPreferences();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.warning),
      title: const Text('Clear all settings'),
      onTap: () {
        showConfirmationPopup(
          context: context,
          title: const Text('Clear all settings'),
          body: const Text('This action cannot be undone.'),
          onConfirm: () =>
              context.read<PreferenceCubit>().clearAllPreferences(),
        );
      },
    );
  }
}
