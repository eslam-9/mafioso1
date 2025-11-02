import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_providers.dart';
import '../../app/app_theme.dart';
import '../../models/story.dart';
import '../../models/vote_result.dart';
import '../../services/sound_service.dart';
import '../../viewmodels/game_viewmodel.dart';
import '../../widgets/background_widget.dart';

class GameView extends ConsumerStatefulWidget {
  const GameView({super.key});

  @override
  ConsumerState<GameView> createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, String?> _votes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقيق'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.bloodRed,
          labelColor: AppTheme.bloodRed,
          unselectedLabelColor: AppTheme.lightGray,
          tabs: const [
            Tab(text: 'القصة والأدلة'),
            Tab(text: 'التصويت'),
          ],
        ),
      ),
      body: BackgroundWidget(
        child: Builder(
          builder: (context) {
            final viewModel = ref.watch(gameViewModelProvider);
            
            if (viewModel.isGameOver) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(AppRouter.summary);
                }
              });
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildStoryTab(context, viewModel),
                _buildVoteTab(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStoryTab(BuildContext context, GameViewModel viewModel) {
    final story = viewModel.story;
    
    if (story == null) {
      return const Center(child: Text('مفيش قصة متاحة'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Story Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, color: AppTheme.bloodRed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          story.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppTheme.bloodRed,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    story.crimeDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightGray,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 24),
          
          // Round Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    'الجولة',
                    viewModel.currentRound.toString(),
                    Icons.refresh,
                  ),
                  _buildStatItem(
                    context,
                    'على قيد الحياة',
                    viewModel.alivePlayers.length.toString(),
                    Icons.people,
                  ),
                  _buildStatItem(
                    context,
                    'الأدلة',
                    '${viewModel.revealedClues.length}/${viewModel.availableClues.length}',
                    Icons.lightbulb,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 24),
          
          // Suspects Section
          Text(
            'المشتبه فيهم',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.bloodRed,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          ...story.suspects.asMap().entries.map((entry) {
            final index = entry.key;
            final suspect = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: AppTheme.bloodRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            suspect.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        suspect.suspiciousBehavior,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.lightGray,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (250 + index * 80).ms).slideX(begin: 0.2, end: 0),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Clues Section
          Text(
            'الأدلة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.bloodRed,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 16),
          
          if (viewModel.revealedClues.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'لسه مفيش أدلة اتكشفت. اكشف أدلة عشان تساعد في حل اللغز.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightGray,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          
          ...viewModel.revealedClues.asMap().entries.map((entry) {
            final index = entry.key;
            final clue = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getClueDifficultyColor(clue.difficulty),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getClueDifficultyLabel(clue.difficulty),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getClueDifficultyColor(clue.difficulty),
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              clue.text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.lightGray,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (300 + index * 100).ms).slideX(begin: -0.2, end: 0),
            );
          }),
          
          const SizedBox(height: 16),
          
          if (viewModel.canRevealMoreClues)
            ElevatedButton.icon(
              onPressed: () => viewModel.revealNextClue(),
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('اكشف الدليل الجاي'),
            ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildVoteTab(BuildContext context, GameViewModel viewModel) {
    final alivePlayers = viewModel.alivePlayers;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.how_to_vote, size: 48, color: AppTheme.bloodRed),
                  const SizedBox(height: 12),
                  Text(
                    'صوّت عشان تستبعد',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.bloodRed,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'كل لاعب يصوت على اللي يفتكر إنه القاتل',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightGray,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(),
          
          const SizedBox(height: 24),
          
          Text(
            'صوّتوا دلوقتي',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.bloodRed,
                  fontWeight: FontWeight.bold,
                ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 16),
          
          ...alivePlayers.map((voter) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voter.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _votes[voter.id],
                        decoration: const InputDecoration(
                          labelText: 'اتهم',
                          prefixIcon: Icon(Icons.gavel),
                        ),
                        items: alivePlayers
                            .where((p) => p.id != voter.id)
                            .map((player) => DropdownMenuItem(
                                  value: player.id,
                                  child: Text(player.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _votes[voter.id] = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (200 + alivePlayers.indexOf(voter) * 50).ms),
            );
          }),
          
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _canSubmitVotes(alivePlayers) ? () => _submitVotes(context, viewModel) : null,
            child: const Text('ابعت الأصوات'),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.bloodRed, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.lightGray,
              ),
        ),
      ],
    );
  }

  Color _getClueDifficultyColor(ClueDifficulty difficulty) {
    switch (difficulty) {
      case ClueDifficulty.veryEasy:
        return Colors.green;
      case ClueDifficulty.easy:
        return Colors.lightGreen;
      case ClueDifficulty.medium:
        return Colors.orange;
      case ClueDifficulty.hard:
        return Colors.deepOrange;
      case ClueDifficulty.veryHard:
        return Colors.red;
    }
  }

  String _getClueDifficultyLabel(ClueDifficulty difficulty) {
    switch (difficulty) {
      case ClueDifficulty.veryEasy:
        return 'سهل جداً';
      case ClueDifficulty.easy:
        return 'سهل';
      case ClueDifficulty.medium:
        return 'متوسط';
      case ClueDifficulty.hard:
        return 'صعب';
      case ClueDifficulty.veryHard:
        return 'صعب جداً';
    }
  }

  bool _canSubmitVotes(List alivePlayers) {
    return _votes.length == alivePlayers.length && 
           _votes.values.every((vote) => vote != null);
  }

  Future<void> _submitVotes(BuildContext context, GameViewModel viewModel) async {
    try {
      ref.read(soundServiceProvider).playSound(SoundEffect.vote);
    } catch (e) {
      // Sound service might not be available
    }

    final votes = _votes.entries.map((entry) {
      final voter = viewModel.players.firstWhere((p) => p.id == entry.key);
      final accused = viewModel.players.firstWhere((p) => p.id == entry.value);
      
      return Vote(
        voterId: voter.id,
        voterName: voter.name,
        accusedId: accused.id,
        accusedName: accused.name,
      );
    }).toList();

    await viewModel.submitVotes(votes);
    
    setState(() {
      _votes.clear();
    });

    if (!viewModel.isGameOver) {
      _showRoundResult(context, viewModel.voteHistory.last);
    }
  }

  void _showRoundResult(BuildContext context, VoteResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.charcoal,
        title: Text(
          result.eliminatedPlayerName != null ? 'لاعب اتشال' : 'مفيش إقصاء',
          style: TextStyle(color: AppTheme.bloodRed),
        ),
        content: Text(
          result.eliminatedPlayerName != null
              ? '${result.eliminatedPlayerName} اتشال من اللعبة.'
              : 'التصويت خلص بتعادل. محدش اتشال.',
          style: TextStyle(color: AppTheme.lightGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('استمر', style: TextStyle(color: AppTheme.bloodRed)),
          ),
        ],
      ),
    );
  }
}
