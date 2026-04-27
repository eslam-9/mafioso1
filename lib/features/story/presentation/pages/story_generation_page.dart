import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../game_setup/domain/entities/game_config.dart';
import '../bloc/story_bloc.dart';
import '../bloc/story_event.dart';
import '../bloc/story_state.dart';
import '../widgets/story_loading_widget.dart';
import '../widgets/story_content_widget.dart';
import '../widgets/story_error_widget.dart';
import '../widgets/story_continue_button.dart';
import '../../domain/entities/story.dart';
import '../../data/models/story_model.dart';

class StoryGenerationPage extends StatefulWidget {
  const StoryGenerationPage({super.key});

  @override
  State<StoryGenerationPage> createState() => _StoryGenerationPageState();
}

class _StoryGenerationPageState extends State<StoryGenerationPage> {
  bool _storyGenerated = false;

  @override
  void initState() {
    super.initState();
  }

  void _generateStory(BuildContext context, GameConfig config) async {
    if (!mounted || _storyGenerated) return;
    _storyGenerated = true;

    final languageCode = context.locale.languageCode;

    context.read<StoryBloc>().add(
      GenerateStory(config, languageCode: languageCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.logNavigation(RouteNames.storyGeneration);

    final args = ModalRoute.of(context)?.settings.arguments;
    GameConfig? config;
    dynamic existingStory;

    if (args is GameConfig) {
      config = args;
    } else if (args is Map<String, dynamic>) {
      existingStory = args['existingStory'];
      config = args['config'] is GameConfig
          ? args['config'] as GameConfig
          : null;

      // If we have an existing story but no config yet, derive a pseudo-config
      if (existingStory != null && config == null) {
        Story? storyObj;
        if (existingStory is Story) {
          storyObj = existingStory;
        } else if (existingStory is Map<String, dynamic>) {
          try {
            storyObj = StoryModel.fromJson(existingStory);
          } catch (e) {
            AppLogger.logError(
              'StoryGenerationPage',
              'Failed to parse story JSON: $e',
            );
          }
        }

        if (storyObj != null) {
          config = GameConfig(
            mode: GameMode.withoutDetective,
            suspectCount: storyObj.suspects.length,
            playerNames: storyObj.suspects.map((s) => s.name).toList(),
          );
        }
      }
    }

    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: Text('story_generation'.tr())),
        body: Center(child: Text('error_no_game_config'.tr())),
      );
    }

    // Auto-generate or set existing story on view load
    if (!_storyGenerated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (existingStory != null) {
            _storyGenerated = true;
            context.read<StoryBloc>().add(SetExistingStory(existingStory));
          } else {
            _generateStory(context, config!);
          }
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('story_generation'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.pagePadding),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: BlocBuilder<StoryBloc, StoryState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const StoryLoadingWidget();
                      } else if (state.errorMessage != null) {
                        return StoryErrorWidget(
                          errorMessage: state.errorMessage!,
                          onRetry: () {
                            _storyGenerated = false;
                            _generateStory(context, config!);
                          },
                        );
                      } else if (state.story != null) {
                        return StoryContentWidget(story: state.story!);
                      } else {
                        return const StoryLoadingWidget();
                      }
                    },
                  ),
                ),
                BlocBuilder<StoryBloc, StoryState>(
                  builder: (context, state) {
                    if (state.story != null && !state.isLoading) {
                      return StoryContinueButton(
                        config: config!,
                        story: state.story!,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
