import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/comments_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/layout.dart';
import 'package:lurkur/app/widgets/popups.dart';
import 'package:lurkur/features/submission/comments_tree.dart';
import 'package:lurkur/features/submission/link_tile.dart';
import 'package:lurkur/features/subreddit/submission_card.dart';
import 'package:provider/provider.dart';

void showSubmissionPopup(
  BuildContext context, {
  required RedditSubmission submission,
}) {
  showPrimaryPopup(
    context: context,
    expand: true,
    builder: (context, scrollController) {
      return MultiProvider(
        providers: [
          BlocProvider(
            create: (_) => CommentsCubit(
              authCubit: context.read<AuthCubit>(),
              redditApi: context.read<RedditApi>(),
            )..load(
                subreddit: submission.subreddit,
                submissionId: submission.id,
              ),
          ),
          Provider.value(
            value: submission,
          ),
        ],
        child: SubmissionBody(
          scrollController: scrollController,
        ),
      );
    },
  );
}

class SubmissionBody extends StatelessWidget {
  const SubmissionBody({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final submission = context.watch<RedditSubmission>();
    final comments = context.watch<CommentsCubit>().state;
    final link = submission.link;
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeCubit.medium2Padding,
            ),
            child: SubmissionCard(
              submission: submission,
              compact: false,
            ),
          ),
        ),
        if (link != null)
          SliverToBoxAdapter(
            child: LinkTile(link: link),
          ),
        switch (comments) {
          (Loading _) => const SliverFullScreen(
              child: LoadingIndicator(),
            ),
          (LoadingFailed _) => const SliverFullScreen(
              child: LoadingFailedIndicator(),
            ),
          (Loaded loaded) => CommentsTree(
              comments: loaded.comments,
            ),
        },
      ],
    );
  }
}
