import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lurkur/app/blocs/theme_cubit.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 50,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFoldingCube(
        color: context.colorScheme.onSurface,
        size: size,
      ),
    );
  }
}

class LoadingFailedIndicator extends StatelessWidget {
  const LoadingFailedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'failed to load',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.error,
        ),
      ),
    );
  }
}
