import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class VoteFormWidget extends StatelessWidget {
  final List<String> playerNames;
  final Function(String) onPlayerSelected;

  const VoteFormWidget({
    super.key,
    required this.playerNames,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...playerNames.map((name) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: OutlinedButton(
                  onPressed: () => onPlayerSelected(name),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(name),
                ),
              );
            }),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}
