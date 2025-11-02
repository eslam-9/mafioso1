import 'package:flutter/material.dart';
import '../app/app_theme.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;

  const BackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: AppTheme.backgroundGradient,
          ),
        ),
        child,
      ],
    );
  }
}
