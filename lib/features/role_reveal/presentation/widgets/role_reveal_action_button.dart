import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';

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
      return 'reveal_role'.tr();
    } else if (hasNextPlayer) {
      return 'next_player'.tr();
    } else {
      return 'start_game'.tr();
    }
  }
}
