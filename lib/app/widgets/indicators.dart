import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 64,
        child: LinearProgressIndicator(),
      ),
    );
  }
}

class LoadingFailedIndicator extends StatelessWidget {
  const LoadingFailedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'failed to load',
      ),
    );
  }
}
