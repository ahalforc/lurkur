import 'package:flutter/material.dart';

/// Shows whatever the current "full screen popup" UI is.
///
/// For now, this is a modal bottom sheet.
///
/// [context] is required to push on the modal route.
/// [isScrollable] tells the popup to configure itself for an infinitely sized child.
/// [builder] is what you want to show the user.
void showPrimaryPopup({
  required BuildContext context,
  required ScrollableWidgetBuilder builder,
}) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return DraggableScrollableSheet(
        maxChildSize: 0.8,
        expand: false,
        builder: builder,
      );
    },
  );
}
