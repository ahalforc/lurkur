import 'package:lurkur/app/blocs/reddit/core/reddit_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';

/// Allows loading a subreddit's comments.
///
/// See [CommentsState] for the various meta states.
class CommentsCubit extends RedditCubit<CommentsState> {
  CommentsCubit({
    required super.authCubit,
    required super.redditApi,
  }) : super(const Loading());

  /// Loads the subreddit's comments.
  void load({
    required String subreddit,
    required String submissionId,
  }) async {
    emit(const Loading());
    try {
      final comments = await redditApi.getComments(
        accessToken: accessToken,
        subreddit: subreddit,
        submissionId: submissionId,
      );
      if (isClosed) return;
      emit(Loaded(comments: comments));
    } catch (_) {
      emit(const LoadingFailed());
    }
  }
}

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
