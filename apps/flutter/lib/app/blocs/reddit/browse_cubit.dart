import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/reddit/core/reddit_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

extension BuildContextXBrowseCubit on BuildContext {
  BrowseCubit get browseCubit => read<BrowseCubit>();

  BrowseCubit get watchBrowseCubit => watch<BrowseCubit>();
}

/// Allows loading a user's subscribed subreddits.
///
/// See [BrowseState] for the various meta states.
class BrowseCubit extends RedditCubit<BrowseState> {
  BrowseCubit({
    required super.authCubit,
    required super.redditApi,
  }) : super(const Loading());

  /// Loads the user's subscribed subreddits.
  void load() async {
    emit(const Loading());
    try {
      final subscriptions = await redditApi.getSubscriptions(
        accessToken: accessToken,
      );
      emit(
        Loaded(
          subscriptions: subscriptions
            ..sort(
              (a, b) => a.displayName
                  .toLowerCase()
                  .compareTo(b.displayName.toLowerCase()),
            ),
        ),
      );
    } catch (_) {
      emit(const LoadingFailed());
    }
  }

  /// Reloads the user's subscribed subreddits.
  ///
  /// Does nothing if this cubit is already loading.
  void reload() {
    if (state is Loading) return;
    load();
  }
}

sealed class BrowseState {
  const BrowseState();
}

class Loading extends BrowseState {
  const Loading();
}

class LoadingFailed extends BrowseState {
  const LoadingFailed();
}

class Loaded extends BrowseState {
  const Loaded({
    required this.subscriptions,
  });

  final List<RedditSubscription> subscriptions;
}
