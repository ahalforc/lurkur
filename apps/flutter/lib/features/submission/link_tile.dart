import 'package:flutter/material.dart';
import 'package:lurkur/app/reddit/reddit.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkTile extends StatelessWidget {
  const LinkTile({
    super.key,
    required this.link,
  });

  final LinkSubmission link;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: _openWebView,
      title: Text(
        link.url,
        maxLines: 1,
      ),
      leading: const Icon(Icons.link),
    );
  }

  void _openWebView() {
    launchUrlString(
      link.url,
      mode: LaunchMode.inAppWebView,
    );
  }
}
