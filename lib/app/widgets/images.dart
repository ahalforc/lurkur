import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/indicators.dart';

/// Represents a standard image.
///
/// Note that this only represents network url images.
///
/// In the future, this should be made abstract and other
/// image types can be supported by switching on the type.
class UrlImage {
  const UrlImage({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  double get aspectRatio => height == 0 ? 0 : width / height;
}

/// Renders a small thumbnail version of an image.
class Thumbnail extends StatelessWidget {
  const Thumbnail({
    super.key,
    required this.url,
  });

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceBright,
        borderRadius: LurkurRadius.radius8.circularBorderRadius,
      ),
      clipBehavior: Clip.hardEdge,
      child: url != null
          ? _NetworkImage(
              url: url,
              fit: BoxFit.cover,
            )
          : null,
    );
  }
}

/// Renders a large gallery version of a collection of images.
///
/// Their sizes are used to determine the aspect ratio that this gallery confines itself to.
class Gallery extends StatelessWidget {
  const Gallery({
    super.key,
    required this.images,
  });

  final List<UrlImage> images;

  double get _tallestAspectRatio {
    if (images.isEmpty) return 0;
    var aspectRatio = images.first.aspectRatio;
    for (final image in images) {
      aspectRatio = min(aspectRatio, image.aspectRatio);
    }
    return aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _tallestAspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CarouselView(
            itemExtent: constraints.maxWidth,
            scrollDirection: Axis.horizontal,
            itemSnapping: true,
            shape: RoundedRectangleBorder(
              borderRadius: LurkurRadius.radius16.circularBorderRadius,
            ),
            children: [
              for (var i = 0; i < images.length; i++)
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _NetworkImage(
                      url: images[i].url,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                    if (images.length > 1)
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: LurkurSpacing.spacing8.bottomInset,
                            padding: LurkurSpacing.spacing8.allInsets.copyWith(
                              top: LurkurSpacing.spacing4.value,
                              bottom: LurkurSpacing.spacing4.value,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.surfaceBright,
                              borderRadius:
                                  LurkurRadius.radius8.circularBorderRadius,
                            ),
                            child: Text(
                              '${i + 1} / ${images.length}',
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({
    super.key,
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: InteractiveViewer(
        child: Image.network(
          url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  const _NetworkImage({
    required this.url,
    this.fit,
    this.gaplessPlayback = false,
  });

  final String url;
  final BoxFit? fit;
  final bool gaplessPlayback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: gaplessPlayback,
      frameBuilder: (context, child, frame, _) {
        return Container(
          alignment: Alignment.center,
          color: context.colorScheme.surfaceBright,
          child: AnimatedSwitcher(
            duration: 1.seconds,
            switchInCurve: Curves.fastLinearToSlowEaseIn,
            child: frame != null ? child : const LoadingIndicator(size: 12),
          ),
        );
      },
      errorBuilder: (context, _, __) {
        return Container(
          alignment: Alignment.center,
          color: context.colorScheme.surfaceBright,
          child: const LoadingFailedIndicator(),
        );
      },
    );
  }
}
