import 'package:flutter/material.dart';

class LargeSliverAppBar extends StatelessWidget {
  const LargeSliverAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
    this.background,
    this.actions,
  });

  final String title;
  final bool automaticallyImplyLeading;
  final Widget? background;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      expandedHeight: 100,
      stretch: true,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        titlePadding: automaticallyImplyLeading
            ? null
            : const EdgeInsets.only(
                left: 16,
                bottom: 16,
              ),
        centerTitle: false,
        background: background,
      ),
      actions: actions,
    );
  }
}
