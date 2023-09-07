import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

/// Allows loading a subreddit.
///
/// See [SubredditState] for the various meta states.
class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit({
    required AuthCubit authCubit,
    required RedditApi redditApi,
  })  : _authCubit = authCubit,
        _redditApi = redditApi,
        super(const Loading());

  final AuthCubit _authCubit;
  final RedditApi _redditApi;

  void load({
    required String subreddit,
    required String submissionId,
  }) async {
    final accessToken = _authCubit.state.accessToken;
    if (accessToken == null) {
      emit(const LoadingFailed());
      return;
    }

    emit(const Loading());

    try {
      final comments = await _redditApi.getComments(
        accessToken: accessToken,
        subreddit: subreddit,
        submissionId: submissionId,
      );
      if (isClosed) return;
      emit(
        Loaded(
          comments: comments,
        ),
      );
    } catch (e, st) {
      emit(const LoadingFailed());
    }
  }
}

/// Represents the meta state of a comments request.
sealed class CommentsState {
  const CommentsState();
}

class Loading extends CommentsState {
  const Loading();
}

class LoadingFailed extends CommentsState {
  const LoadingFailed();
}

class Loaded extends CommentsState {
  const Loaded({
    required this.comments,
  });

  final List<RedditComment> comments;
}
