import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../models/game_config.dart';
import '../../widgets/background_widget.dart';

class GameModeView extends StatefulWidget {
  const GameModeView({super.key});

  @override
  State<GameModeView> createState() => _GameModeViewState();
}

class _GameModeViewState extends State<GameModeView> {
  bool _showFirstCard = false;
  bool _showSecondCard = false;

  @override
  void initState() {
    super.initState();
    // Trigger animations with delays
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _showFirstCard = true);
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showSecondCard = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختار نوع اللعبة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Builder(
            builder: (builderContext) {
              // Builder ensures fresh context with provider access
              return SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'اختار النوع',
                          style: Theme.of(builderContext).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.bloodRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ).animate().fadeIn(),
                        
                        const SizedBox(height: 60),
                        
                        // With Detective Card
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: _showFirstCard ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (animContext, opacity, child) {
                            return Transform.translate(
                              offset: Offset(-30.0 * (1 - opacity), 0),
                              child: Opacity(
                                opacity: opacity,
                                child: _buildModeCard(
                                  builderContext, // Use Builder's context
                                  title: 'بمحقق',
                                  description: 'فيه دور محقق يساعد في حل اللغز',
                                  icon: Icons.search,
                                  mode: GameMode.withDetective,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Without Detective Card
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: _showSecondCard ? 1.0 : 0.0),
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          builder: (animContext, opacity, child) {
                            return Transform.translate(
                              offset: Offset(30.0 * (1 - opacity), 0),
                              child: Opacity(
                                opacity: opacity,
                                child: _buildModeCard(
                                  builderContext, // Use Builder's context
                                  title: 'من غير محقق',
                                  description: 'استنتاج بحت - مفيش محقق يساعدك',
                                  icon: Icons.groups,
                                  mode: GameMode.withoutDetective,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24), // Extra space at bottom
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required GameMode mode,
  }) {
    return Card(
      child: InkWell(
        onTap: () {
          // Use container to access provider from StatefulWidget
          final container = ProviderScope.containerOf(context);
          container.read(gameSetupViewModelProvider.notifier).setMode(mode);
          context.go(AppRouter.playerSetup);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: AppTheme.bloodRed.withOpacity(0.1),
        highlightColor: AppTheme.bloodRed.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.darkRed.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 64,
                color: AppTheme.bloodRed,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightGray,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
