import 'package:flutter/material.dart';

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

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.child,
  });

  final int selectedIndex;
  final void Function(int) onSelectIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: [
          for (final item in NavigationShell._items)
            BottomNavigationBarItem(
              icon: Icon(item.$2),
              label: item.$1,
            ),
        ],
        onTap: onSelectIndex,
      ),
    );
  }
}
