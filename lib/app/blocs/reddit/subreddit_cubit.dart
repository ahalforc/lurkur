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
        super(const Loading());

  final AuthCubit _authCubit;
  final RedditApi _redditApi;

  void load(String? subreddit) async {
    final accessToken = _authCubit.state.accessToken;
    if (accessToken == null) {
      emit(const LoadingFailed());
      return;
    }

    emit(const Loading());

    try {
      final submissions = await _redditApi.getSubmissions(
        accessToken: accessToken,
        subreddit: subreddit,
        sort: 'hot',
      );
      emit(
        Loaded(
          submissions: submissions,
        ),
      );
    } catch (e, st) {
      emit(const LoadingFailed());
    }
  }
}

/// Represents the meta state of a subreddit.
sealed class SubredditState {
  const SubredditState();
}

class Loading extends SubredditState {
  const Loading();
}

class LoadingFailed extends SubredditState {
  const LoadingFailed();
}

class Loaded extends SubredditState {
  const Loaded({
    required this.submissions,
  });

  final List<RedditSubmission> submissions;
}
