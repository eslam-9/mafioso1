import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/mode_selector.dart';

class GameModePage extends StatelessWidget {
  const GameModePage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.gameMode);

    return Scaffold(
      appBar: AppBar(
        title: Text('choose_game_mode'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: const ModeSelector()),
    );
  }
}
