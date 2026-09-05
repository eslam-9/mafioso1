import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

/// Single-select chips: all | 4 | 5 | 6 players (matches game suspect counts).
class PlayerCountStoryFilterBar extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onSelected;

  const PlayerCountStoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'filter_by_players'.tr(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            FilterChip(
              label: Text('player_filter_all'.tr()),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
            FilterChip(
              label: Text('story_player_count'.tr(namedArgs: {'count': '4'})),
              selected: selected == 4,
              onSelected: (_) => onSelected(4),
            ),
            FilterChip(
              label: Text('story_player_count'.tr(namedArgs: {'count': '5'})),
              selected: selected == 5,
              onSelected: (_) => onSelected(5),
            ),
            FilterChip(
              label: Text('story_player_count'.tr(namedArgs: {'count': '6'})),
              selected: selected == 6,
              onSelected: (_) => onSelected(6),
            ),
          ],
        ),
      ],
    );
  }
}
