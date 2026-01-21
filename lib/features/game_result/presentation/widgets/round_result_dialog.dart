import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../voting/domain/entities/vote_result.dart';

class RoundResultDialog extends StatelessWidget {
  final VoteResult result;

  const RoundResultDialog({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: Text(
        result.eliminatedPlayerName != null
            ? 'player_eliminated'.tr()
            : 'no_elimination'.tr(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: Text(
        result.eliminatedPlayerName != null
            ? 'player_eliminated_msg'.tr(
                namedArgs: {'name': result.eliminatedPlayerName!},
              )
            : 'tie_vote'.tr(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'continue_game'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
