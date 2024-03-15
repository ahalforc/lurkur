import 'package:flutter/material.dart';

class LargeSliverAppBar extends StatelessWidget {
  const LargeSliverAppBar({
    super.key,
    required this.title,
    this.background,
    this.actions,
  });

  final String title;
  final Widget? background;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      expandedHeight: 100,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        centerTitle: false,
        background: background,
      ),
      actions: actions,
    );
  }
}
