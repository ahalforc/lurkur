import 'package:flutter/material.dart';
import 'package:lurkur/app/utils/reddit_models.dart';

class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.link,
  });

  final LinkSubmission link;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: SelectableText(
        link.url,
        maxLines: 1,
      ),
      leading: const Icon(Icons.link),
    );
  }
}
