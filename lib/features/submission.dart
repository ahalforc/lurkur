import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/submission_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/features/submission/comments_tree.dart';
import 'package:lurkur/features/submission/gallery_tile.dart';
import 'package:lurkur/features/submission/link_tile.dart';
import 'package:lurkur/features/submission/self_tile.dart';
import 'package:lurkur/features/submission/title_tile.dart';
import 'package:lurkur/features/submission/video_tile.dart';

class SubmissionPage extends StatelessWidget {
  const SubmissionPage({
    super.key,
    required this.serializedSubmission,
  });

  final String serializedSubmission;

  @override
  Widget build(BuildContext context) {
    final submission = RedditSubmission(
      data: jsonDecode(serializedSubmission),
    );
    return BlocProvider(
      create: (_) => SubmissionCubit(
        authCubit: context.read<AuthCubit>(),
        redditApi: context.read<RedditApi>(),
      )..load(submission),
      child: SubmissionView(
        submission: submission,
      ),
    );
  }
}

class SubmissionView extends StatelessWidget {
  const SubmissionView({
    super.key,
    required this.submission,
  });

  final RedditSubmission submission;

  @override
  Widget build(BuildContext context) {
    final link = submission.link;
    final self = submission.self;
    final video = submission.video;
    final gallery = submission.gallery;

    final content = CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(submission.subreddit),
          centerTitle: false,
        ),
        SliverToBoxAdapter(
          child: TitleTile(
            title: submission.title,
            author: submission.author,
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
        if (gallery != null)
          SliverToBoxAdapter(
            child: GalleryTile(gallery: gallery),
          ),
      ],
    );

    return Scaffold(
      body: context.isDeviceWide
          ? Row(
              children: [
                Expanded(
                  child: content,
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                ),
                const Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        title: Text('comments'),
                        centerTitle: false,
                      ),
                      CommentsTree(),
                    ],
                  ),
                ),
              ],
            )
          : content,
    );
  }
}
