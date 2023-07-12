import 'package:flutter/material.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';
import 'package:lurkur/app/utils/reddit_models.dart';

class GalleryTile extends StatelessWidget {
  const GalleryTile({
    super.key,
    required this.gallery,
  });

  final GallerySubmission gallery;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: const Icon(Icons.image),
      title: const Text('gallery'),
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
          ),
          child: PageView(
            children: [
              for (final url in gallery.urls)
                Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(ThemeCubit.smallPadding),
                        child: Text(
                          '${gallery.urls.indexOf(url) + 1} / ${gallery.urls.length}',
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
