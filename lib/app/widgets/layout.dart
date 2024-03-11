import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

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

class SeparatedRow extends StatelessWidget {
  const SeparatedRow({
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
    return Row(
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < children.length; i++)
          Padding(
            padding: EdgeInsets.only(left: i != 0 ? space : 0),
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

class HorizontalFancyScrollView extends StatelessWidget {
  const HorizontalFancyScrollView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final Widget Function(BuildContext, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverList.separated(
            itemCount: itemCount,
            itemBuilder: itemBuilder,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
          )
        ],
      ),
    );
  }
}

class FancyPageView extends StatefulWidget {
  const FancyPageView({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  State<FancyPageView> createState() => _FancyPageViewState();
}

class _FancyPageViewState extends State<FancyPageView> {
  late final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _controller,
          children: widget.children,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _FancyPageViewIndicator(
              controller: _controller,
              pageCount: widget.children.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _FancyPageViewIndicator extends StatefulWidget {
  const _FancyPageViewIndicator({
    required this.controller,
    required this.pageCount,
  });

  final PageController controller;
  final int pageCount;

  @override
  State<_FancyPageViewIndicator> createState() =>
      _FancyPageViewIndicatorState();
}

class _FancyPageViewIndicatorState extends State<_FancyPageViewIndicator> {
  var _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_setCurrentPage);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_setCurrentPage);
    super.dispose();
  }

  void _setCurrentPage() {
    final page = widget.controller.page;
    if (page != null) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.pageCount; i++) ...[
          if (i != 0) const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.primary,
            ),
            width: 4,
            height: 4,
          )
              .animate(
                target: (i - _currentPage).abs().clamp(0, 1),
              )
              .scale(
                begin: const Offset(2, 2),
                end: const Offset(1, 1),
              ),
        ],
      ],
    );
  }
}
