import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_event.dart';
import '../bloc/game_setup_state.dart';
import '../../domain/entities/game_config.dart';
import '../widgets/mode_display.dart';
import '../widgets/suspect_count_selector.dart';
import '../widgets/player_name_inputs.dart';
import '../widgets/continue_button.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/data/models/story_model.dart';

class PlayerSetupPage extends StatelessWidget {
  const PlayerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.playerSetup);

    final args = ModalRoute.of(context)?.settings.arguments;
    final initialConfig = args is GameConfig ? args : null;
    final existingStory = args is Map<String, dynamic>
        ? args['existingStory']
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('player_setup'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) {
            final bloc = GameSetupBloc();
            if (initialConfig != null) {
              bloc.add(SetGameMode(initialConfig.mode));
              bloc.add(SetSuspectCount(initialConfig.suspectCount));
              for (int i = 0; i < initialConfig.playerNames.length; i++) {
                bloc.add(SetPlayerName(i, initialConfig.playerNames[i]));
              }
            } else if (existingStory != null) {
              // Extract count from existing story
              try {
                Story? storyObj;
                if (existingStory is Story) {
                  storyObj = existingStory;
                } else if (existingStory is Map<String, dynamic>) {
                  storyObj = StoryModel.fromJson(existingStory);
                }
                if (storyObj != null) {
                  bloc.add(SetSuspectCount(storyObj.suspects.length));
                }
              } catch (e) {
                AppLogger.logError(
                  'PlayerSetupPage',
                  'Failed to pre-fill count: $e',
                );
              }
            }
            return bloc;
          },
          child: BlocBuilder<GameSetupBloc, GameSetupState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ModeDisplay(),
                    SizedBox(height: AppSpacing.large),
                    SuspectCountSelector(isLocked: existingStory != null),
                    SizedBox(height: AppSpacing.large),
                    const PlayerNameInputs(),
                    SizedBox(height: AppSpacing.xlarge),
                    ContinueButton(existingStory: existingStory),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
