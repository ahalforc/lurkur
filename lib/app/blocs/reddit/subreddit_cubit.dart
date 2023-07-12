import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';

/// Allows loading a subreddit.
///
/// See [SubredditState] for the various meta states.
class SubredditCubit extends Cubit<SubredditState> {
  SubredditCubit({
    required AuthCubit authCubit,
    required RedditApi redditApi,
  })  : _authCubit = authCubit,
        _redditApi = redditApi,
        super(
          Loading(
            subreddit: null,
            sortOption: SortOption.values.first,
          ),
        );

  final AuthCubit _authCubit;
  final RedditApi _redditApi;

  /// Loads the given [subreddit].
  ///
  /// [subreddit]  - the subreddit to load (null is interpreted as "home")
  /// [sortOption] - how to sort the listing
  void load(
    String? subreddit, {
    required SortOption sortOption,
  }) async {
    await _fetchSubmissions(
      subreddit: subreddit,
      sortOption: sortOption,
    );
  }

  /// Uses the cubit's current state to go get more submissions.
  ///
  /// todo Make sure this does nothing if we're updating
  void loadMore() {
    // todo
  }

  /// Performs a reload using the current subreddit but with the new sort option.
  void setSortOption(
    SortOption option,
  ) {
    // todo
  }

  Future<void> _fetchSubmissions({
    required String? subreddit,
    required SortOption sortOption,
  }) async {
    final accessToken = _authCubit.state.accessToken;
    if (accessToken == null) {
      emit(
        LoadingFailed(
          subreddit: subreddit,
          sortOption: sortOption,
        ),
      );
      return;
    }

    emit(
      Loading(
        subreddit: subreddit,
        sortOption: sortOption,
      ),
    );

    try {
      final submissions = await _redditApi.getSubmissions(
        accessToken: accessToken,
        subreddit: subreddit,
        sort: switch (sortOption) {
          SortOption.hot => 'hot',
          // todo this aint right, you need to set the 't' parameter
          SortOption.topHour => 'hour',
          SortOption.topDay => 'day',
          SortOption.topWeek => 'week',
          SortOption.topMonth => 'month',
          SortOption.topYear => 'year',
          SortOption.topAllTime => 'all',
        },
      );
      emit(
        Loaded(
          subreddit: subreddit,
          sortOption: sortOption,
          submissions: submissions,
        ),
      );
    } catch (e, st) {
      emit(
        LoadingFailed(
          subreddit: subreddit,
          sortOption: sortOption,
        ),
      );
    }
  }
}

/// Represents the different sort options available
enum SortOption {
  hot,
  topHour,
  topDay,
  topWeek,
  topMonth,
  topYear,
  topAllTime,
}

/// Represents the meta state of a subreddit.
sealed class SubredditState {
  const SubredditState({
    required this.subreddit,
    required this.sortOption,
  });

  final String? subreddit;
  final SortOption sortOption;
}

class Loading extends SubredditState {
  const Loading({
    required super.subreddit,
    required super.sortOption,
  });
}

class LoadingFailed extends SubredditState {
  const LoadingFailed({
    required super.subreddit,
    required super.sortOption,
  });
}

class Loaded extends SubredditState {
  const Loaded({
    required super.subreddit,
    required super.sortOption,
    required this.submissions,
  });

  final List<RedditSubmission> submissions;
}
