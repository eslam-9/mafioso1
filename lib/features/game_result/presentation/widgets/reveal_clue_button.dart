import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';

class RevealClueButton extends StatelessWidget {
  const RevealClueButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<GameBloc>().add(const RevealNextClue());
      },
      icon: const Icon(Icons.lightbulb_outline),
      label: Text('reveal_next_clue'.tr()),
    ).animate().fadeIn(delay: 400.ms);
  }
}
