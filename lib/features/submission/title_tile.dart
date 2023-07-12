import 'package:flutter/material.dart';

class TitleTile extends StatelessWidget {
  const TitleTile({
    super.key,
    required this.title,
    required this.author,
  });

  final String title;
  final String author;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.reddit),
      title: SelectableText(title),
      subtitle: SelectableText('- $author'),
    );
  }
}
