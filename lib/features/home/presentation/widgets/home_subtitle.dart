import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeSubtitle extends StatelessWidget {
  const HomeSubtitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'app_subtitle'.tr(),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        letterSpacing: 2,
      ),
    );
  }
}
