import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'how_to_play_dialog.dart';

class HomeHowToPlayButton extends StatelessWidget {
  const HomeHowToPlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250.w,
      child: OutlinedButton(
        onPressed: () => _showHowToPlay(context),
        child: Text('how_to_play'.tr()),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(context: context, builder: (context) => const HowToPlayDialog());
  }
}
