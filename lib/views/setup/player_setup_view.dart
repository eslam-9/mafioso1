import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../models/game_config.dart';
import '../../viewmodels/game_setup_viewmodel.dart';
import '../../widgets/background_widget.dart';

class PlayerSetupView extends ConsumerWidget {
  const PlayerSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(gameSetupViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('تجهيز اللاعبين'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.gameMode),
        ),
      ),
      body: BackgroundWidget(
        child: SafeArea(
          child: Builder(
            builder: (context) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              viewModel.selectedMode == GameMode.withDetective
                                  ? Icons.search
                                  : Icons.groups,
                              color: AppTheme.bloodRed,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              viewModel.selectedMode == GameMode.withDetective
                                  ? 'بمحقق'
                                  : 'من غير محقق',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(),
                    
                    const SizedBox(height: 24),
                    
                    // Suspect Count Selector
                    Text(
                      'عدد المشتبه فيهم',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.bloodRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int count in [4, 5, 6])
                          _buildCountButton(context, ref, viewModel, count),
                      ],
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 24),
                    
                    // Player Names
                    Text(
                      'أسامي اللاعبين',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.bloodRed,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 300.ms),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'إجمالي اللاعبين: ${viewModel.totalPlayers}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.lightGray,
                          ),
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 16),
                    
                    // Player Name Inputs
                    ...List.generate(
                      viewModel.totalPlayers,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'لاعب ${index + 1}',
                            prefixIcon: Icon(
                              Icons.person,
                              color: AppTheme.bloodRed,
                            ),
                          ),
                          onChanged: (value) {
                            ref.read(gameSetupViewModelProvider.notifier).setPlayerName(index, value);
                          },
                        ).animate().fadeIn(delay: (500 + index * 50).ms),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Continue Button
                    ElevatedButton(
                      onPressed: viewModel.validateNames()
                          ? () => context.go(AppRouter.storyGeneration)
                          : null,
                      child: const Text('استمر'),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCountButton(
    BuildContext context,
    WidgetRef ref,
    GameSetupViewModel viewModel,
    int count,
  ) {
    final isSelected = viewModel.suspectCount == count;
    
    return InkWell(
      onTap: () => ref.read(gameSetupViewModelProvider).setSuspectCount(count),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRed : AppTheme.smokeGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.bloodRed : AppTheme.darkRed.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
