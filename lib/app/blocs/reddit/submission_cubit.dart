import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';

/// Allows loading a subreddit.
///
/// See [SubredditState] for the various meta states.
class SubmissionCubit extends Cubit<SubmissionState> {
  SubmissionCubit({
    required AuthCubit authCubit,
    required RedditApi redditApi,
  })  : _authCubit = authCubit,
        _redditApi = redditApi,
        super(const Loading());

  final AuthCubit _authCubit;
  final RedditApi _redditApi;

  void load(RedditSubmission submission) async {
    final accessToken = _authCubit.state.accessToken;
    if (accessToken == null) {
      emit(const LoadingFailed());
      return;
    }

    emit(const Loading());

    try {
      final comments = await _redditApi.getComments(
        accessToken: accessToken,
        subreddit: submission.subreddit,
        submissionId: submission.id,
      );
      if (isClosed) return;
      emit(
        Loaded(
          submission: submission,
          comments: comments,
        ),
      );
    } catch (e, st) {
      emit(const LoadingFailed());
    }
  }
}

/// Represents the meta state of a subreddit.
sealed class SubmissionState {
  const SubmissionState();
}

class Loading extends SubmissionState {
  const Loading();
}

class LoadingFailed extends SubmissionState {
  const LoadingFailed();
}

class Loaded extends SubmissionState {
  const Loaded({
    required this.submission,
    required this.comments,
  });

  final RedditSubmission submission;
  final List<RedditComment> comments;
}
