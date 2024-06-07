import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preferences_cubit.dart';
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
        _HideAutoModeratorComments(),
        _HeaderTile(text: 'Session'),
        _HiddenSubreddits(),
        _ClearAllSettings(),
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

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: AnimatedSwitcher(
        duration: 0.25.seconds,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          icon,
          key: ValueKey(icon),
        ),
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class _ThemeBrightness extends StatelessWidget {
  const _ThemeBrightness();

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: switch (context.watchPreferences.state.themeBrightness) {
        ThemeBrightness.light => Icons.light_mode_rounded,
        ThemeBrightness.dark => Icons.dark_mode_rounded,
        ThemeBrightness.auto => Icons.brightness_auto_rounded,
      },
      title: 'Brightness',
      onTap: () => context.preferences.nextThemeBrightness(),
    );
  }
}

class _ThemeColor extends StatelessWidget {
  const _ThemeColor();

  @override
  Widget build(BuildContext context) {
    // This is temporarily disabled while I figure out the app theme.
    return const _OptionTile(
      icon: Icons.color_lens_rounded,
      title: 'Color',
    ).animate().fade(begin: 1.0, end: 0.5);
  }
}

class _ThemeDensity extends StatelessWidget {
  const _ThemeDensity();

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: switch (context.watchPreferences.state.themeDensity) {
        ThemeDensity.small => Icons.density_small,
        ThemeDensity.medium => Icons.density_medium,
        ThemeDensity.large => Icons.density_large,
      },
      title: 'Density',
      onTap: () => context.preferences.nextThemeDensity(),
    );
  }
}

class _AutoPlayVideos extends StatelessWidget {
  const _AutoPlayVideos();

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: switch (context.watchPreferences.state.autoPlayVideos) {
        true => Icons.play_arrow,
        false => Icons.cancel,
      },
      title: 'Auto play videos',
      onTap: () => context.preferences.nextAutoPlayVideos(),
    );
  }
}

class _UseHtmlForText extends StatelessWidget {
  const _UseHtmlForText();

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: switch (context.watchPreferences.state.useHtmlForText) {
        true => Icons.check_rounded,
        false => Icons.cancel_rounded,
      },
      title: 'Use HTML for text',
      onTap: () => context.preferences.nextUseHtmlForText(),
    );
  }
}

class _HideAutoModeratorComments extends StatelessWidget {
  const _HideAutoModeratorComments();

  @override
  Widget build(BuildContext context) {
    return _OptionTile(
      icon: switch (context.watchPreferences.state.hideAutoModeratorComments) {
        true => Icons.comments_disabled_rounded,
        false => Icons.comment_rounded,
      },
      title: 'Hide Auto Moderator comments',
      onTap: () => context.preferences.nextHideAutoModeratorComments(),
    );
  }
}

class _HiddenSubreddits extends StatelessWidget {
  const _HiddenSubreddits();

  @override
  Widget build(BuildContext context) {
    final hiddenSubreddits = context.watchPreferences.state.hiddenSubreddits;
    return ExpansionTile(
      leading: const Icon(Icons.hide_source),
      title: const Text('Hidden subreddits'),
      children: [
        for (final subreddit in hiddenSubreddits)
          ListTile(
            key: ValueKey(subreddit),
            leading: Checkbox(
              value: true,
              onChanged: (_) => context.preferences.showSubreddit(
                subreddit,
              ),
            ),
            title: Text(subreddit),
            onTap: () => context.preferences.showSubreddit(
              subreddit,
            ),
          ),
      ],
    );
  }
}

class _ClearAllSettings extends StatelessWidget {
  const _ClearAllSettings();

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
          onConfirm: () => context.preferences.clearAllPreferences(),
        );
      },
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
