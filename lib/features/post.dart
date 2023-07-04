import 'package:flutter/material.dart';

class PostPage extends StatelessWidget {
  const PostPage({
    super.key,
    required this.post,
  });

  final String? post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(post ?? 'temp'),
            centerTitle: false,
          ),
        ],
      ),
    );
  }
}
