import 'package:flutter/material.dart';

/// It's like a [Column], but you can separate its entries.
class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    super.key,
    this.mainAxisSize,
    this.crossAxisAlignment,
    required this.space,
    required this.children,
  });

  final MainAxisSize? mainAxisSize;
  final CrossAxisAlignment? crossAxisAlignment;
  final double space;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(top: i != 0 ? space : 0),
            child: children[i],
          ),
      ],
    );
  }
}

/// Like [SliverFillRemaining], but is just the size of the screen.
class SliverFullScreen extends StatelessWidget {
  const SliverFullScreen({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  }
}
