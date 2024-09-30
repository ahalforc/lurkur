import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lurkur/app/widgets/shells.dart';
import 'package:lurkur/features/browse_page.dart';
import 'package:lurkur/features/settings_popup.dart';
import 'package:lurkur/features/sign_in_page.dart';
import 'package:lurkur/features/subreddit_page.dart';

extension BuildContextXRouter on BuildContext {
  RouterCubit get routerCubit => read<RouterCubit>();

  RouterCubit get watchRouter => watch<RouterCubit>();
}

/// Manages the routes available in the app.
class RouterCubit extends Cubit<RouteState> {
  static const signIn = '/';
  static const home = '/home';
  static const popular = '/popular';
  static const browse = '/browse';
  static const subreddit = '/subreddit';

  static const subredditQueryParameter = 'subreddit';

  RouterCubit() : super(UnauthorizedRoutes());

  bool get canPop => (state.routerConfig as GoRouter).canPop();

  void showUnauthorizedRoutes() {
    emit(UnauthorizedRoutes());
  }

  void showAuthorizedRoutes() {
    emit(AuthorizedRoutes());
  }

  void pushSubreddit(
    BuildContext context, {
    String? subredditName,
  }) =>
      (state.routerConfig as GoRouter).pushNamed(
        subreddit,
        queryParameters: {
          if (subredditName != null) subredditQueryParameter: subredditName,
        },
      );

  void pushDismissibleFullScreenWidget(
    BuildContext context, {
    required Widget child,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return child;
        },
      ),
    );
  }

  void goBack(BuildContext context) => context.pop();
}

/// Represents the available routes.
///
/// This routing architecture follows the "sealed garden" approach where
/// specific routes are only available pending a certain authorization state.
sealed class RouteState {
  const RouteState();

  /// Implementations of this class should reuse the same [RouterConfig] object.
  ///
  /// Failing to do so will result in hard-to-trace navigation history issues.
  RouterConfig<Object> get routerConfig;
}

/// Provides routes available for those that haven't signed in yet.
class UnauthorizedRoutes extends RouteState {
  @override
  final RouterConfig<Object> routerConfig = GoRouter(
    initialLocation: RouterCubit.signIn,
    routes: [
      GoRoute(
        path: RouterCubit.signIn,
        builder: (context, state) => const SignInPage(),
      ),
    ],
  );
}

/// Provides routes available for those that have signed in.
class AuthorizedRoutes extends RouteState {
  @override
  final RouterConfig<Object> routerConfig = GoRouter(
    initialLocation: RouterCubit.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, child) {
          return NavigationShell(
            selectedIndex: child.currentIndex,
            onSelectIndex: (index) {
              if (index == 3) {
                showSettingsPopup(context);
              } else {
                child.goBranch(index);
              }
            },
            child: child,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterCubit.home,
                name: RouterCubit.home,
                builder: (context, state) => const SubredditPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterCubit.popular,
                name: RouterCubit.popular,
                builder: (context, state) => const SubredditPage(
                  subreddit: 'popular',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouterCubit.browse,
                name: RouterCubit.browse,
                builder: (context, state) => const BrowsePage(),
              ),
              GoRoute(
                path: RouterCubit.subreddit,
                name: RouterCubit.subreddit,
                builder: (context, state) => SubredditPage(
                  subreddit: state
                      .uri.queryParameters[RouterCubit.subredditQueryParameter],
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
