import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lurkur/features/post.dart';
import 'package:lurkur/features/sign_in.dart';
import 'package:lurkur/features/subreddit.dart';

/// Manages the routes available in the app.
class RouterCubit extends Cubit<RouteState> {
  static const signIn = '/';
  static const post = '/post';
  static const subreddit = '/subreddit';

  RouterCubit() : super(UnauthorizedRoutes());

  void showUnauthorizedRoutes() {
    emit(UnauthorizedRoutes());
  }

  void showAuthorizedRoutes() {
    emit(AuthorizedRoutes());
  }

  void goToSubreddit(
    BuildContext context, {
    String? subredditName,
  }) =>
      context.goNamed(
        subreddit,
        queryParameters: {
          if (subredditName != null) 'displayName': subredditName,
        },
      );

  void pushPost(
    BuildContext context, {
    required String post,
  }) =>
      context.pushNamed(RouterCubit.post, queryParameters: {
        'post': post,
      });

  void pop(BuildContext context) => context.pop();
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
    initialLocation: RouterCubit.subreddit,
    routes: [
      GoRoute(
        // todo maybe using the same str for path and name is a bad idea
        path: RouterCubit.post,
        name: RouterCubit.post,
        builder: (context, state) => PostPage(
          post: state.queryParameters['post'],
        ),
      ),
      GoRoute(
        // todo maybe using the same str for path and name is a bad idea
        path: RouterCubit.subreddit,
        name: RouterCubit.subreddit,
        builder: (context, state) => SubredditPage(
          // todo Use a const for the query param
          subreddit: state.queryParameters['displayName'],
        ),
      ),
    ],
  );
}
