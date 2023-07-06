import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/auth_cubit.dart';
import 'package:lurkur/app/blocs/reddit/submission_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_api.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:video_player/video_player.dart';

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
    final self = submission.self;
    final gallery = submission.gallery;
    final video = submission.video;
    return Scaffold(
      body: BlocBuilder<SubmissionCubit, SubmissionState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(submission.title),
                centerTitle: false,
              ),
              if (self != null)
                SliverToBoxAdapter(
                  child: _SelfTextCard(self: self),
                ),
              if (gallery != null)
                SliverToBoxAdapter(
                  child: _GalleryCard(gallery: gallery),
                ),
              if (video != null)
                SliverToBoxAdapter(
                  child: _VideoCard(video: video),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SelfTextCard extends StatelessWidget {
  const _SelfTextCard({required this.self});

  final SelfSubmission self;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeCubit.mediumPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeCubit.mediumPadding),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SelectableText(self.text),
          ),
        ),
      ),
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({required this.gallery});

  final GallerySubmission gallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 800,
      ),
      child: PageView(
        children: [
          for (final url in gallery.urls)
            Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    url,
                    fit: BoxFit.fitHeight,
                    gaplessPlayback: true,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    '${gallery.urls.indexOf(url) + 1} / ${gallery.urls.length}',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  const _VideoCard({required this.video});

  final VideoSubmission video;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late final _videoController = VideoPlayerController.networkUrl(
    Uri.parse(widget.video.url),
  );

  late final _chewieController = ChewieController(
    videoPlayerController: _videoController,
    autoPlay: true,
    looping: false,
  );

  @override
  void dispose() {
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(ThemeCubit.mediumPadding),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(ThemeCubit.mediumPadding),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 800),
            child: Chewie(
              controller: _chewieController,
            ),
          ),
        ),
      ),
    );
  }
}
