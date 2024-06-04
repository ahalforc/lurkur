import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
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

  @override
  Widget build(BuildContext context) {
    final tallestAspectRatio =
        images.map((image) => image.width / image.height).fold(0.0, max);
    return CarouselSlider.builder(
      itemCount: images.length,
      itemBuilder: (context, itemIndex, pageViewIndex) {
        return ClipRRect(
          borderRadius: LurkurRadius.radius16.circularBorderRadius,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _NetworkImage(
                url: images[itemIndex].url,
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
                        borderRadius: LurkurRadius.radius8.circularBorderRadius,
                      ),
                      child: Text(
                        '${itemIndex + 1} / ${images.length}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      options: CarouselOptions(
        height: null,
        enableInfiniteScroll: false,
        viewportFraction: 1,
        aspectRatio: tallestAspectRatio,
        enlargeCenterPage: true,
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
        if (frame != null) {
          return child.animate().fadeIn();
        }
        return const Center(
          child: LoadingIndicator(
            size: 12,
          ),
        );
      },
      errorBuilder: (context, _, __) {
        return const Center(
          child: LoadingFailedIndicator(),
        );
      },
    );
  }
}
