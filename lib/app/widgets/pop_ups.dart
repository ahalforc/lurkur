import 'package:flutter/material.dart';

/// Shows whatever the current "full screen popup" UI is.
void showPrimaryPopup({
  required BuildContext context,
  required ScrollableWidgetBuilder builder,
  bool expand = false,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: expand ? 0.9 : 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: builder,
      );
    },
  );
}

/// Shows whatever the current "basic notification popup" UI is.
void showNotificationPopup({
  required BuildContext context,
  required Widget content,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: content),
  );
}
