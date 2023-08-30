import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/submission_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/indicators.dart';
import 'package:lurkur/app/widgets/pop_ups.dart';
import 'package:lurkur/app/widgets/tags.dart';
import 'package:lurkur/features/submission/gallery_tile.dart';
import 'package:lurkur/features/submission/link_tile.dart';
import 'package:lurkur/features/submission/self_tile.dart';
import 'package:lurkur/features/submission/title_tile.dart';
import 'package:lurkur/features/submission/video_tile.dart';

void showCommentsPopup(
  BuildContext context, {
  required RedditSubmission submission,
}) {
  showPrimaryPopup(
    context: context,
    builder: (context, scrollController) {
      return BlocProvider(
        create: (_) => SubmissionCubit(
          authCubit: context.read<AuthCubit>(),
          redditApi: context.read<RedditApi>(),
        )..load(submission),
        child: CommentsBody(
          scrollController: scrollController,
        ),
      );
    },
  );
}

class CommentsBody extends StatelessWidget {
  const CommentsBody({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return switch (context.watch<SubmissionCubit>().state) {
      (Loading _) => const LoadingIndicator(),
      (LoadingFailed _) => const LoadingFailedIndicator(),
      (Loaded loaded) => _Loaded(
          scrollController: scrollController,
          state: loaded,
        ),
    };
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({
    this.scrollController,
    required this.state,
  });

  final ScrollController? scrollController;
  final Loaded state;

  @override
  Widget build(BuildContext context) {
    final link = state.submission.link;
    final self = state.submission.self;
    final video = state.submission.video;
    final gallery = state.submission.gallery;
    return BlocProvider(
      create: (_) => _ExpansionStateCubit(),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: TitleTile(
                title: state.submission.title,
                author: state.submission.author,
                subreddit: state.submission.subreddit,
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
            SliverList.builder(
              itemBuilder: (context, index) {
                return CommentTile(
                  comment: state.comments[index],
                );
              },
              itemCount: state.comments.length,
            ),
          ],
        ),
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  const CommentTile({
    super.key,
    required this.comment,
  });

  final RedditComment comment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_ExpansionStateCubit, Set<RedditComment>>(
      builder: (context, collapsedComments) {
        final title = Text.rich(
          TextSpan(
            children: [
              if (comment.isSubmitter)
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ThemeCubit.small3Padding,
                    ),
                    child: SubmitterTag(),
                  ),
                ),
              if (comment.isEdited)
                const WidgetSpan(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ThemeCubit.small3Padding,
                    ),
                    child: EditedTag(),
                  ),
                ),
              TextSpan(
                text: '${comment.score > 0 ? '+' : ''}${comment.score} - ',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
              TextSpan(
                text: comment.author,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.secondary,
                ),
              ),
            ],
          ),
        );
        final subtitle = Text(comment.body);
        return comment.replies.isNotEmpty
            ? ExpansionTile(
                title: title,
                subtitle: subtitle,
                initiallyExpanded: !collapsedComments.contains(comment),
                childrenPadding: const EdgeInsets.only(left: 24),
                onExpansionChanged: (v) => v
                    ? context.read<_ExpansionStateCubit>().setExpanded(comment)
                    : context
                        .read<_ExpansionStateCubit>()
                        .setCollapsed(comment),
                children: [
                  for (final reply in comment.replies)
                    CommentTile(comment: reply),
                ],
              )
            : ListTile(
                title: title,
                subtitle: subtitle,
              );
      },
    );
  }
}

class _ExpansionStateCubit extends Cubit<Set<RedditComment>> {
  _ExpansionStateCubit() : super({});

  void setExpanded(RedditComment comment) {
    emit(state..remove(comment));
  }

  void setCollapsed(RedditComment comment) {
    emit(state..add(comment));
  }
}
