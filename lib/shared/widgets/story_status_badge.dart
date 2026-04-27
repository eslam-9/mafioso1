import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

enum StoryStatus {
  /// Saved on device only — not yet uploaded to Supabase
  localOnly,

  /// Saved locally and successfully synced to Supabase community
  uploaded,

  /// Loaded from the Supabase community library
  community,
}

/// A colored pill badge that clearly communicates a story's origin and sync status.
class StoryStatusBadge extends StatelessWidget {
  final StoryStatus status;

  const StoryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _backgroundColor.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: _backgroundColor, size: 13),
          const SizedBox(width: 5),
          Text(
            _label.tr(),
            style: TextStyle(
              color: _backgroundColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Color get _backgroundColor => switch (status) {
    StoryStatus.localOnly => const Color(0xFF5B8DEF), // blue
    StoryStatus.uploaded => const Color(0xFF34C77B), // green
    StoryStatus.community => const Color(0xFFFF9F43), // orange
  };

  IconData get _icon => switch (status) {
    StoryStatus.localOnly => Icons.phone_android_rounded,
    StoryStatus.uploaded => Icons.cloud_done_rounded,
    StoryStatus.community => Icons.public_rounded,
  };

  String get _label => switch (status) {
    StoryStatus.localOnly => 'badge_local',
    StoryStatus.uploaded => 'badge_uploaded',
    StoryStatus.community => 'badge_community',
  };
}
