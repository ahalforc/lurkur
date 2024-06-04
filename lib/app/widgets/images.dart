import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

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

class Thumbnail extends StatelessWidget {
  const Thumbnail({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.hardEdge,
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            )
          : null,
    );
  }
}

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
    return IgnorePointer(
      ignoring: images.length <= 1,
      child: CarouselSlider.builder(
        itemCount: images.length,
        itemBuilder: (context, itemIndex, pageViewIndex) {
          return ClipRRect(
            borderRadius: LurkurRadius.radius16.circularBorderRadius,
            child: Image.network(
              images[itemIndex].url,
              fit: BoxFit.contain,
              gaplessPlayback: true,
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
