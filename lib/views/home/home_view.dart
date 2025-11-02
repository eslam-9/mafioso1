import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_router.dart';
import '../../app/app_theme.dart';
import '../../widgets/background_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'مافيوسو',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.bloodRed,
                      letterSpacing: 8,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryRed.withOpacity(0.8),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),

                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    'لعبة غموض وجريمة قتل',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.lightGray,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 80),

                  // Start Game Button
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () => context.go(AppRouter.gameMode),
                      child: const Text('ابدأ اللعب'),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 24),

                  // How to Play Button
                  SizedBox(
                    width: 250,
                    child: OutlinedButton(
                      onPressed: () => _showHowToPlay(context),
                      child: const Text('إزاي تلعب'),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 80),

                  // Footer
                  Text(
                    'تقدر تلاقي القاتل؟',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightGray.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fadeIn(delay: 1000.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.charcoal,
        title: Text('إزاي تلعب', style: TextStyle(color: AppTheme.bloodRed)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHowToPlayItem(
                '١. اختار نوع اللعبة',
                'اختار تلعب بمحقق ولا من غيره.',
              ),
              const SizedBox(height: 16),
              _buildHowToPlayItem(
                '٢. جهز اللاعبين',
                'اختار من ٤ لـ ٦ مشتبه فيهم وحط أسامي اللاعبين.',
              ),
              const SizedBox(height: 16),
              _buildHowToPlayItem(
                '٣. اصنع القصة',
                'هتتعمل قصة جريمة قتل مميزة خاصة باللعبة بتاعتك.',
              ),
              const SizedBox(height: 16),
              _buildHowToPlayItem(
                '٤. اكشف الأدوار',
                'كل لاعب هيعرف دوره في السر، قاتل ولا محقق ولا بريء.',
              ),
              const SizedBox(height: 16),
              _buildHowToPlayItem(
                '٥. حقق',
                'اقرا القصة، اكشف الأدلة، واتناقش مين ممكن يكون القاتل.',
              ),
              const SizedBox(height: 16),
              _buildHowToPlayItem(
                '٦. صوّت',
                'اللاعبين يصوتوا عشان يستبعدوا المشتبه فيهم. لاقي القاتل عشان تكسب!',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('فهمت', style: TextStyle(color: AppTheme.bloodRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlayItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppTheme.bloodRed,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(color: AppTheme.lightGray, fontSize: 14),
        ),
      ],
    );
  }
}
