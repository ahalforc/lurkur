import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NavigationShell extends StatelessWidget {
  static const _items = [
    ('home', Icons.home_rounded),
    ('popular', Icons.local_fire_department_rounded),
    ('browse', Icons.grid_view_rounded),
    ('settings', Icons.settings_rounded),
  ];

  const NavigationShell({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.child,
  }) : assert(0 <= selectedIndex && selectedIndex < _items.length, '');

  final int selectedIndex;
  final void Function(int) onSelectIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _NavigationBar(
      selectedIndex: selectedIndex,
      onSelectIndex: onSelectIndex,
      child: child,
    );
  }
}

class _NavigationBar extends StatefulWidget {
  const _NavigationBar({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.child,
  });

  final int selectedIndex;
  final void Function(int) onSelectIndex;
  final Widget child;

  @override
  State<_NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<_NavigationBar>
    with TickerProviderStateMixin {
  final _animationControllers = <int, AnimationController>{};

  @override
  void dispose() {
    for (final controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getAnimationController(int index) {
    return _animationControllers.putIfAbsent(
      index,
      () => AnimationController(vsync: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        items: [
          for (var i = 0; i < NavigationShell._items.length; i++)
            BottomNavigationBarItem(
              icon: Icon(NavigationShell._items[i].$2)
                  .animate(
                    autoPlay: false,
                    controller: _getAnimationController(i),
                    onComplete: (c) => c.reverse(),
                  )
                  .scale(
                    duration: 0.2.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                  )
                  .shake(
                    hz: 4,
                  ),
              label: NavigationShell._items[i].$1,
            ),
        ],
        onTap: (index) {
          _getAnimationController(index).loop(count: 1);
          widget.onSelectIndex(index);
        },
      ),
    );
  }
}
