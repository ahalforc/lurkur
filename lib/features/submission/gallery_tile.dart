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
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
          ),
          child: Gallery(
            urls: gallery.urls,
          ),
        ),
      ],
    );
  }
}
