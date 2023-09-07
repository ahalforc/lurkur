import 'package:flutter/material.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:lurkur/app/widgets/videos.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({
    super.key,
    required this.video,
  });

  final VideoSubmission video;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.image),
      title: const Text('video'),
      children: [
        VideoPlayer(
          video: UrlVideo(
            url: video.url,
            width: video.width,
            height: video.height,
          ),
        ),
      ],
    );
  }
}
