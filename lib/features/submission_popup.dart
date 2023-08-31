import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/comments_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/features/submission/comments_tree.dart';
import 'package:lurkur/features/submission/gallery_tile.dart';
import 'package:lurkur/features/submission/link_tile.dart';
import 'package:lurkur/features/submission/self_tile.dart';
import 'package:lurkur/features/submission/title_tile.dart';
import 'package:lurkur/features/submission/video_tile.dart';
import 'package:provider/provider.dart';

void showSubmissionPopup(
  BuildContext context, {
  required RedditSubmission submission,
}) {
  showPrimaryPopup(
    context: context,
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
    final self = submission.self;
    final video = submission.video;
    final gallery = submission.gallery;
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: TitleTile(
            title: submission.title,
            author: submission.author,
            subreddit: submission.subreddit,
          ),
        ),
        if (link != null)
          SliverToBoxAdapter(
            child: LinkTile(link: link),
          ),
        if (self != null)
          SliverToBoxAdapter(
            child: SelfTile(self: self),
          ),
        if (video != null)
          SliverToBoxAdapter(
            child: VideoTile(video: video),
          ),
        if (video == null && gallery != null)
          SliverToBoxAdapter(
            child: GalleryTile(gallery: gallery),
          ),
        switch (comments) {
          (Loading _) => const SliverFillRemaining(
              child: LoadingIndicator(),
            ),
          (LoadingFailed _) => const SliverFillRemaining(
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
