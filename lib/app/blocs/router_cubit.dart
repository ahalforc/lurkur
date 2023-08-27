import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lurkur/features/sign_in.dart';
import 'package:lurkur/features/submission.dart';
import 'package:lurkur/features/subreddit.dart';

/// Manages the routes available in the app.
class RouterCubit extends Cubit<RouteState> {
  static const signIn = '/';
  static const post = '/post';
  static const subreddit = '/subreddit';

  static const submissionQueryParameter = 'submission';
  static const subredditQueryParameter = 'subreddit';

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
          if (subredditName != null) subredditQueryParameter: subredditName,
        },
      );

  void pushSubmission(
    BuildContext context, {
    required String serializedSubmission,
  }) =>
      context.pushNamed(RouterCubit.post, queryParameters: {
        submissionQueryParameter: serializedSubmission,
      });

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
    initialLocation: RouterCubit.subreddit,
    routes: [
      GoRoute(
        // todo maybe using the same str for path and name is a bad idea
        path: RouterCubit.post,
        name: RouterCubit.post,
        builder: (context, state) => SubmissionPage(
          serializedSubmission:
              state.uri.queryParameters[RouterCubit.submissionQueryParameter] ??
                  '',
        ),
      ),
      GoRoute(
        // todo maybe using the same str for path and name is a bad idea
        path: RouterCubit.subreddit,
        name: RouterCubit.subreddit,
        builder: (context, state) => SubredditPage(
          subreddit:
              state.uri.queryParameters[RouterCubit.subredditQueryParameter],
        ),
      ),
    ],
  );
}
