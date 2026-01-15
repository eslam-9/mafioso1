import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/services/sound_service.dart';
import '../../../../core/di/injection_container.dart' as di;

class RoleRevealActionButton extends StatelessWidget {
  final bool isRevealed;
  final bool hasNextPlayer;
  final VoidCallback onReveal;
  final VoidCallback onNext;
  final VoidCallback onStartGame;

  const RoleRevealActionButton({
    super.key,
    required this.isRevealed,
    required this.hasNextPlayer,
    required this.onReveal,
    required this.onNext,
    required this.onStartGame,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (!isRevealed) {
            try {
              di.getIt<SoundService>().playSound(SoundEffect.roleReveal);
            } catch (e) {
              // Sound service might not be available
            }
            onReveal();
          } else if (hasNextPlayer) {
            onNext();
          } else {
            onStartGame();
          }
        },
        child: Text(_getButtonText()),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  String _getButtonText() {
    if (!isRevealed) {
      return 'اكشف الدور';
    } else if (hasNextPlayer) {
      return 'اللاعب الجاي';
    } else {
      return 'ابدأ اللعبة';
    }
  }
}
