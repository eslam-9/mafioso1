import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import 'how_to_play_item.dart';

class HowToPlayDialog extends StatelessWidget {
  const HowToPlayDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.charcoal,
      title: Text(
        'how_to_play_title'.tr(),
        style: TextStyle(color: Theme.of(context).colorScheme.primary),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            HowToPlayItem(title: 'step1'.tr(), description: 'step1_desc'.tr()),
            const SizedBox(height: 16),
            HowToPlayItem(title: 'step2'.tr(), description: 'step2_desc'.tr()),
            const SizedBox(height: 16),
            HowToPlayItem(title: 'step3'.tr(), description: 'step3_desc'.tr()),
            const SizedBox(height: 16),
            HowToPlayItem(title: 'step4'.tr(), description: 'step4_desc'.tr()),
            const SizedBox(height: 16),
            HowToPlayItem(title: 'step5'.tr(), description: 'step5_desc'.tr()),
            const SizedBox(height: 16),
            HowToPlayItem(title: 'step6'.tr(), description: 'step6_desc'.tr()),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'understood'.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
