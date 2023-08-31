import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

/// Represents a standard video.
///
/// Note that this only represents network url videos.
///
/// In the future, this should be made abstract and other
/// video types can be supported by switching on the type.
class Video {
  const Video({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;
}

/// Standard widget for rendering a [Video].
class VideoPlayer extends StatelessWidget {
  const VideoPlayer({
    super.key,
    required this.video,
  });

  final Video video;

  @override
  Widget build(BuildContext context) {
    return _VideoPlayer(
      video: video,
      autoPlay: context.watch<PreferenceCubit>().state.autoPlayVideos,
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  const _VideoPlayer({
    required this.video,
    required this.autoPlay,
  });

  final Video video;
  final bool autoPlay;

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late final _videoController = VideoPlayerController.networkUrl(
    Uri.parse(widget.video.url),
    videoPlayerOptions: VideoPlayerOptions(
      allowBackgroundPlayback: false,
      mixWithOthers: true,
    ),
  );

  late final _chewieController = ChewieController(
    videoPlayerController: _videoController,
    autoPlay: widget.autoPlay,
    looping: false,
    aspectRatio: widget.video.width / widget.video.height,
  );

  @override
  void dispose() {
    _chewieController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.video.width / widget.video.height,
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }
}
