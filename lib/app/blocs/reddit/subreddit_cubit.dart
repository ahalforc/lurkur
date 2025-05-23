import 'package:lurkur/app/blocs/reddit/core/reddit_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

/// Allows loading a subreddit and managing its ever-scrolling listing.
///
/// See [SubredditState] for the various meta states.
/// See [load] for kicking off an initial load.
/// See [loadMore] for kicking off subsequent loads.
/// See [setSortOption] re-loading using the new sort option.
class SubredditCubit extends RedditCubit<SubredditState> {
  SubredditCubit({
    required super.authCubit,
    required super.redditApi,
  }) : super(
          Loading(
            subreddit: null,
            sortOption: SortOption.values.first,
          ),
        );

  /// Loads the given [subreddit] (or "home" if null).
  void load(
    String? subreddit, {
    required SortOption sortOption,
  }) async {
    emit(Loading(subreddit: subreddit, sortOption: sortOption));
    try {
      final subredditInfo = await redditApi.getSubredditInfo(
        accessToken: accessToken,
        subreddit: subreddit,
      );
      final (after, submissions) = await redditApi.getSubmissions(
        accessToken: accessToken,
        subreddit: subreddit,
        sort: sortOption.toEndpointSortKey(),
        after: null,
        count: null,
        t: sortOption.toEndpointT(),
      );
      emit(
        Loaded(
          headerImageUrl: subredditInfo?.headerImageUrl,
          subreddit: subreddit,
          sortOption: sortOption,
          after: after,
          submissions: submissions,
          isLoadingMore: false,
          didLoadingMoreFail: false,
        ),
      );
    } catch (_) {
      emit(LoadingFailed(subreddit: subreddit, sortOption: sortOption));
    }
  }

  /// Just kicks off a [load] with its existing state.
  ///
  /// Does nothing if already loading.
  void reload() {
    if (state is Loading) return;
    load(state.subreddit, sortOption: state.sortOption);
  }

  /// Uses the cubit's current state to go get more submissions.
  ///
  /// Does nothing if the current state is not fully [Loaded].
  void loadMore() async {
    final state = this.state;
    if (state is! Loaded || state.isLoadingMore) return;

    // todo Don't load more if the current load count is less than the expected max.
    // todo This is the scenario where the subreddit doesn't have anymore more to load.
    // todo But first, I need to find a subreddit with only a few posts...

    emit(
      Loaded(
        headerImageUrl: state.headerImageUrl,
        subreddit: state.subreddit,
        sortOption: state.sortOption,
        after: state.after,
        submissions: state.submissions,
        isLoadingMore: true,
        didLoadingMoreFail: false,
      ),
    );

    try {
      final (after, submissions) = await redditApi.getSubmissions(
        accessToken: accessToken,
        subreddit: state.subreddit,
        sort: state.sortOption.toEndpointSortKey(),
        after: state.after,
        count: state.submissions.length,
        t: state.sortOption.toEndpointT(),
      );
      emit(
        Loaded(
          headerImageUrl: state.headerImageUrl,
          subreddit: state.subreddit,
          sortOption: state.sortOption,
          after: after,
          submissions: _joinSubmissions(
            existingSubmissions: state.submissions,
            incomingSubmissions: submissions,
          ),
          isLoadingMore: false,
          didLoadingMoreFail: false,
        ),
      );
    } catch (_) {
      emit(
        Loaded(
          headerImageUrl: state.headerImageUrl,
          subreddit: state.subreddit,
          sortOption: state.sortOption,
          after: state.after,
          submissions: state.submissions,
          isLoadingMore: false,
          didLoadingMoreFail: true,
        ),
      );
    }
  }

  List<RedditSubmission> _joinSubmissions({
    required List<RedditSubmission> existingSubmissions,
    required List<RedditSubmission> incomingSubmissions,
  }) {
    final existingKeys = {
      for (final submission in existingSubmissions) submission.id,
    };
    return [
      ...existingSubmissions,
      ...incomingSubmissions.where((s) => !existingKeys.contains(s.id)),
    ];
  }

  /// Performs a reload using the current subreddit but with the new sort option.
  ///
  /// Does nothing if the current state is [Loading].
  void setSortOption(
    SortOption option,
  ) {
    if (state is Loading) return;
    load(state.subreddit, sortOption: option);
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

extension on SortOption {
  String toEndpointSortKey() => switch (this) {
        SortOption.hot => 'hot',
        SortOption.topHour => 'top',
        SortOption.topDay => 'top',
        SortOption.topWeek => 'top',
        SortOption.topMonth => 'top',
        SortOption.topYear => 'top',
        SortOption.topAllTime => 'top',
      };

  String? toEndpointT() => switch (this) {
        SortOption.topHour => 'hour',
        SortOption.topDay => 'day',
        SortOption.topWeek => 'week',
        SortOption.topMonth => 'month',
        SortOption.topYear => 'year',
        SortOption.topAllTime => 'all',
        _ => null,
      };
}

/// Represents the meta state of a subreddit.
sealed class SubredditState {
  const SubredditState({
    required this.subreddit,
    required this.sortOption,
  });

  final String? subreddit;
  final SortOption sortOption;

  bool get isMultiSubreddit => {
        null,
        'popular',
      }.contains(subreddit);
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
    required this.headerImageUrl,
    required this.after,
    required this.submissions,
    required this.isLoadingMore,
    required this.didLoadingMoreFail,
  });

  final String? headerImageUrl;
  final String after;
  final List<RedditSubmission> submissions;
  final bool isLoadingMore;
  final bool didLoadingMoreFail;
}
