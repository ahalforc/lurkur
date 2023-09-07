import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
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
      width: 44,
      height: 44,
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
  const Gallery({super.key, required this.images});

  final List<UrlImage> images;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Use the smallest aspect ratio in the gallery.
      // (The smaller the aspect ratio, the taller it is.)
      aspectRatio: images.fold(
        images.first.width / images.first.height,
        (aspectRatio, image) => min(
          aspectRatio,
          image.width / image.height,
        ),
      ),
      child: PageView(
        children: [
          for (final image in images)
            Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      context
                          .read<RouterCubit>()
                          .pushDismissibleFullScreenWidget(
                            context,
                            child: FullScreenImage(url: image.url),
                          );
                    },
                    child: Image.network(
                      image.url,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(ThemeCubit.medium1Padding),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: context.colorScheme.background,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeCubit.medium1Padding,
                        vertical: ThemeCubit.small1Padding,
                      ),
                      child: Text(
                        '${images.indexOf(image) + 1} / ${images.length}',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
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
      backgroundColor: context.colorScheme.background,
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
