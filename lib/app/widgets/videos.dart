import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:video_player/video_player.dart';

class Video extends StatefulWidget {
  const Video({
    super.key,
    required this.video,
  });

  final VideoSubmission video;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  late final _videoController = VideoPlayerController.networkUrl(
    Uri.parse(widget.video.url),
    videoPlayerOptions: VideoPlayerOptions(
      allowBackgroundPlayback: false,
      mixWithOthers: true,
    ),
  );

  late final _chewieController = ChewieController(
    videoPlayerController: _videoController,
    autoPlay: true,
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
