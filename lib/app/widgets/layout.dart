import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeparatedColumn extends StatelessWidget {
  const SeparatedColumn({
    super.key,
    this.mainAxisSize,
    this.crossAxisAlignment,
    required this.separatorBuilder,
    required this.children,
  });

  final MainAxisSize? mainAxisSize;
  final CrossAxisAlignment? crossAxisAlignment;
  final WidgetBuilder separatorBuilder;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i != 0) separatorBuilder(context),
          children[i],
        ],
      ],
    );
  }
}

class SeparatedRow extends StatelessWidget {
  const SeparatedRow({
    super.key,
    this.mainAxisSize,
    this.crossAxisAlignment,
    required this.separatorBuilder,
    required this.children,
  });

  final MainAxisSize? mainAxisSize;
  final CrossAxisAlignment? crossAxisAlignment;
  final WidgetBuilder separatorBuilder;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i != 0) separatorBuilder(context),
          children[i],
        ],
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
