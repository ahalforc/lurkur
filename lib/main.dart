import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const Lurkur());
}

/// Behold!
///
/// My app.
class Lurkur extends StatelessWidget {
  const Lurkur({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Providers(
      child: _Connectors(
        child: _App(),
      ),
    );
  }
}

/// Builds the root app widget and is dependent on [_Providers].
class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final preferenceState = context.watch<PreferenceCubit>().state;
    final routerState = context.watch<RouterCubit>().state;
    return MaterialApp.router(
      key: const ValueKey('app'),
      title: 'lurkur',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: switch (preferenceState.themeBrightness) {
        ThemeBrightness.light => ThemeMode.light,
        ThemeBrightness.dark => ThemeMode.dark,
        ThemeBrightness.auto => ThemeMode.system,
      },
      routerConfig: routerState.routerConfig,
    );
  }
}

/// Builds services used throughout the app.
///
/// To see how services interface with one another, see [_Connectors].
class _Providers extends StatelessWidget {
  const _Providers({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider(
          create: (_) => RouterCubit(),
        ),
        BlocProvider(
          create: (_) => AuthCubit(),
        ),
        BlocProvider(
          create: (_) => PreferenceCubit()..init(),
        ),
        Provider(
          create: (_) => RedditApi(),
        ),
      ],
      child: child,
    );
  }
}

/// Stitches together services to limit inter-service dependencies.
///
/// To see the total list of services, see [_Providers].
class _Connectors extends StatefulWidget {
  const _Connectors({
    required this.child,
  });

  final Widget child;

  @override
  State<_Connectors> createState() => _ConnectorsState();
}

class _ConnectorsState extends State<_Connectors> {
  final _subs = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _subs.addAll(
      [
        _connectAuthToRoutes(),
        _connectPreferencesToTheme(),
      ],
    );
  }

  @override
  void dispose() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  StreamSubscription<void> _connectAuthToRoutes() {
    return context.read<AuthCubit>().stream.listen((authState) {
      if (authState is Authorized) {
        context.read<RouterCubit>().showAuthorizedRoutes();
      } else if (authState is Unauthorized) {
        context.read<RouterCubit>().showUnauthorizedRoutes();
      }
    });
  }

  StreamSubscription<void> _connectPreferencesToTheme() {
    return context.read<PreferenceCubit>().stream.listen((preferenceState) {
      context
          .read<ThemeCubit>()
          .setColorSeed(switch (preferenceState.themeColor) {
            ThemeColor.red => Colors.red,
            ThemeColor.orange => Colors.orange,
            ThemeColor.yellow => Colors.yellow,
            ThemeColor.green => Colors.green,
            ThemeColor.blue => Colors.blue,
            ThemeColor.indigo => Colors.indigo,
            ThemeColor.violet => Colors.purple,
          });
    });
  }
}
