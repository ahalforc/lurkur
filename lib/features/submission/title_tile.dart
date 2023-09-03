import 'package:flutter/material.dart';

class TitleTile extends StatelessWidget {
  const TitleTile({
    super.key,
    required this.title,
    required this.author,
    required this.subreddit,
    required this.scoreStr,
  });

  final String title;
  final String author;
  final String subreddit;
  final String scoreStr;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.reddit),
      title: SelectableText(title),
      subtitle: Text('$scoreStr - $author in $subreddit'),
    );
  }
}
