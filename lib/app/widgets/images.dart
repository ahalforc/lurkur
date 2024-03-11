import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurkur/app/blocs/router_cubit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/widgets/layout.dart';

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
  const Gallery({super.key, required this.images});

  final List<UrlImage> images;

  @override
  Widget build(BuildContext context) {
    return FancyPageView(
      children: [
        for (final image in images)
          Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    context.read<RouterCubit>().pushDismissibleFullScreenWidget(
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
            ],
          ),
      ],
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
