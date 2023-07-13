import 'package:flutter/material.dart';
import 'package:lurkur/features/subscriptions.dart';

class SubscriptionsFab extends StatelessWidget {
  const SubscriptionsFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showSubscriptionsPopup(context),
      child: const Icon(Icons.list),
    );
  }
}
