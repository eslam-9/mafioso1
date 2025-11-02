import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../viewmodels/story_viewmodel.dart';
import '../../widgets/background_widget.dart';

class StoryGenerationView extends ConsumerStatefulWidget {
  const StoryGenerationView({super.key});

  @override
  ConsumerState<StoryGenerationView> createState() =>
      _StoryGenerationViewState();
}

class _StoryGenerationViewState extends ConsumerState<StoryGenerationView> {
  bool _storyGenerated = false;

  @override
  void initState() {
    super.initState();
  }

  void _generateStory() {
    if (!mounted || _storyGenerated) return;
    _storyGenerated = true;

    try {
      final setupViewModel = ref.read(gameSetupViewModelProvider);
      final storyViewModel = ref.read(storyViewModelProvider);

      final config = setupViewModel.createGameConfig();
      storyViewModel.generateStory(config);
    } catch (e) {
      // Error handling is done in StoryViewModel
      _storyGenerated = false; // Allow retry
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-generate story on view load after build completes
    if (!_storyGenerated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _generateStory();
        }
      });
    }

    final viewModel = ref.watch(storyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('توليد القصة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.playerSetup),
        ),
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Center(child: _buildContent(context, viewModel)),
                ),
                if (viewModel.state == StoryState.loaded)
                  ElevatedButton(
                    onPressed: () => _proceedToRoleReveal(context),
                    child: const Text('اكشف الأدوار'),
                  ).animate().fadeIn(delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, StoryViewModel viewModel) {
    switch (viewModel.state) {
      case StoryState.initial:
      case StoryState.loading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: AppTheme.bloodRed,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms, color: AppTheme.primaryRed),
            const SizedBox(height: 32),
            Text(
                  'بنصنع اللغز بتاعك...',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.bloodRed),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 1000.ms)
                .then()
                .fadeOut(duration: 1000.ms),
            const SizedBox(height: 16),
            Text(
              'ممكن ياخد شوية',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightGray),
            ),
          ],
        );

      case StoryState.loaded:
        final story = viewModel.story!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                story.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.bloodRed,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Story Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'القصة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.bloodRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        story.intro,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.lightGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        story.crimeDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightGray.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(delay: 200.ms),

              const SizedBox(height: 16),

              // Suspects Info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.people, color: AppTheme.bloodRed),
                          const SizedBox(width: 8),
                          Text(
                            'المشتبه فيهم: ${story.suspects.length}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'كل لاعب هياخد دوره السري',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightGray.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),
            ],
          ),
        );

      case StoryState.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.bloodRed,
            ).animate().shake(),
            const SizedBox(height: 24),
            Text(
              'فشل توليد القصة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: AppTheme.bloodRed),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'حصل خطأ مجهول',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.lightGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _generateStory,
              child: const Text('حاول تاني'),
            ),
          ],
        );
    }
  }

  void _proceedToRoleReveal(BuildContext context) {
    final setupViewModel = ref.read(gameSetupViewModelProvider);
    final storyViewModel = ref.read(storyViewModelProvider);
    final roleViewModel = ref.read(roleRevealViewModelProvider);

    final config = setupViewModel.createGameConfig();
    final story = storyViewModel.story!;

    roleViewModel.assignRoles(config, story);
    context.go(AppRouter.roleReveal);
  }
}
