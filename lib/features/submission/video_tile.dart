import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:video_player/video_player.dart';

class VideoTile extends StatefulWidget {
  const VideoTile({
    super.key,
    required this.video,
  });

  final VideoSubmission video;

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
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
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.image),
      title: const Text('video'),
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
          ),
          child: Chewie(
            controller: _chewieController,
          ),
        ),
      ],
    );
  }
}
