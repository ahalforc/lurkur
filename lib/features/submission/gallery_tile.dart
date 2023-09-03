import 'package:flutter/material.dart';
import 'package:lurkur/app/utils/reddit_models.dart';
import 'package:lurkur/app/widgets/images.dart';

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
        Gallery(
          images: [
            for (final (url, width, height) in gallery.images)
              UrlImage(
                url: url,
                width: width,
                height: height,
              ),
          ],
        ),
      ],
    );
  }
}
