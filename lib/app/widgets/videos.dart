import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/preference_cubit.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:visibility_detector/visibility_detector.dart';

/// Represents a standard video.
///
/// Note that this only represents network url videos.
///
/// In the future, this should be made abstract and other
/// video types can be supported by switching on the type.
class UrlVideo {
  const UrlVideo({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;
}

/// Standard widget for rendering a [UrlVideo].
class VideoPlayer extends StatelessWidget {
  const VideoPlayer({
    super.key,
    required this.video,
  });

  final UrlVideo video;

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

  final UrlVideo video;
  final bool autoPlay;

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late final _videoController = vp.VideoPlayerController.networkUrl(
    Uri.parse(widget.video.url),
    videoPlayerOptions: vp.VideoPlayerOptions(
      allowBackgroundPlayback: false,
      mixWithOthers: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _videoController.initialize().then((_) {
      if (mounted) {
        setState(() {});
        if (widget.autoPlay) {
          _videoController.play();
        }
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.video.width / widget.video.height,
      child: VisibilityDetector(
        key: ValueKey(widget.video),
        onVisibilityChanged: _onVisibilityChanged,
        child: Stack(
          children: [
            Positioned.fill(
              child: vp.VideoPlayer(_videoController),
            ),
            GestureDetector(
              onTap: () {
                if (!_videoController.value.isInitialized) return;
                _videoController.value.isPlaying
                    ? _videoController.pause()
                    : _videoController.play();
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!widget.autoPlay) return;
    if (info.visibleFraction > 0.75) {
      _videoController.play();
    } else {
      _videoController.pause();
    }
  }
}
