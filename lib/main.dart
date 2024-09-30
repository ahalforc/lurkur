import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/preferences_cubit.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
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
    final preferencesState = context.watch<PreferencesCubit>().state;
    final routerState = context.watch<RouterCubit>().state;
    return MaterialApp.router(
      key: const ValueKey('app'),
      title: 'lurkur',
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      themeMode: switch (preferencesState.themeBrightness) {
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
          create: (_) => AuthCubit()..initialize(),
        ),
        BlocProvider(
          create: (_) => PreferencesCubit()..init(),
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
    final authCubit = context.authCubit;
    final routerCubit = context.routerCubit;
    return authCubit.stream.listen((authState) {
      if (authState is Authorized) {
        routerCubit.showAuthorizedRoutes();
      } else if (authState is Unauthorized) {
        routerCubit.showUnauthorizedRoutes();
      }
    });
  }

  StreamSubscription<void> _connectPreferencesToTheme() {
    final preferencesCubit = context.preferences;
    final themeCubit = context.themeCubit;
    return preferencesCubit.stream.listen((preferencesState) {
      themeCubit.setColorSeed(switch (preferencesState.themeColor) {
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
