import 'package:flutter/material.dart';
import 'package:lurkur/app/reddit/reddit.dart';
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
            for (final image in gallery.images)
              UrlImage(
                url: image.url,
                width: image.width,
                height: image.height,
              ),
          ],
        ),
      ],
    );
  }
}
