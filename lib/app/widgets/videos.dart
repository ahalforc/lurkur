import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/preferences_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
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
      autoPlay: context.watchPreferences.state.autoPlayVideos,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder(
                valueListenable: _videoController,
                builder: (context, value, widget) {
                  return Padding(
                    padding: LurkurSpacing.spacing12.bottomInset,
                    child: _PlayButton(
                      isPlaying: value.isPlaying,
                      positionMs: value.position.inMilliseconds,
                      durationMs: value.duration.inMilliseconds,
                    ),
                  );
                },
              ),
            ),
            _Glass(
              onTap: _playOrPause,
              onSeek: _seekBy,
            ),
          ],
        ),
      ),
    );
  }

  void _playOrPause() {
    if (!_videoController.value.isInitialized) return;
    _videoController.value.isPlaying
        ? _videoController.pause()
        : _videoController.play();
  }

  void _seekBy(double percent) {
    final ms = _videoController.value.position.inMilliseconds;
    final totalMs = _videoController.value.duration.inMilliseconds;
    _videoController.seekTo(
      Duration(
        milliseconds: (ms + totalMs * percent).round().clamp(0, totalMs),
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

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.isPlaying,
    required this.positionMs,
    required this.durationMs,
  });

  final bool isPlaying;
  final int positionMs;
  final int durationMs;

  double get _progress => (positionMs / durationMs).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: _progress,
          color: context.colorScheme.onSurface,
          strokeWidth: 2,
        ),
        AnimatedSwitcher(
          duration: 0.25.seconds,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey('video_player_icon_$isPlaying'),
            color: context.colorScheme.onSurface,
          ),
        ),
      ],
    )
        .animate(
          target: isPlaying ? 0 : 1,
        )
        .fadeIn(
          duration: 0.5.seconds,
        );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({
    required this.onTap,
    required this.onSeek,
  });

  final void Function() onTap;
  final void Function(double percent) onSeek;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onHorizontalDragUpdate: (details) {
        onSeek(
          details.delta.dx > 0 ? 0.025 : -0.025,
        );
      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
