import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../game_setup/domain/entities/game_config.dart';
import '../../domain/entities/story.dart';

class StoryContinueButton extends StatelessWidget {
  final GameConfig config;
  final Story story;

  const StoryContinueButton({
    super.key,
    required this.config,
    required this.story,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        AppLogger.logNavigation(RouteNames.roleReveal);
        Navigator.pushNamed(
          context,
          RouteNames.roleReveal,
          arguments: {'config': config, 'story': story},
        );
      },
      child: Text('reveal_roles'.tr()),
    ).animate().fadeIn(delay: 500.ms);
  }
}
