import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StoryRatingWidget extends StatefulWidget {
  final int? initialRating;
  final Function(int) onRatingSelected;

  const StoryRatingWidget({
    super.key,
    this.initialRating,
    required this.onRatingSelected,
  });

  @override
  State<StoryRatingWidget> createState() => _StoryRatingWidgetState();
}

class _StoryRatingWidgetState extends State<StoryRatingWidget> {
  int _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _currentRating > 0
              ? "thanks_for_rating".tr()
              : "rate_this_story".tr(),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final ratingValue = index + 1;
            final isSelected = _currentRating >= ratingValue;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentRating = ratingValue;
                });
                widget.onRatingSelected(ratingValue);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child:
                    Icon(
                          isSelected
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isSelected
                              ? Colors.amber
                              : Colors.grey.shade400,
                          size: 36.w,
                        )
                        .animate(target: isSelected ? 1 : 0)
                        .scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.2, 1.2),
                          curve: Curves.elasticOut,
                        ),
              ),
            );
          }),
        ),
        if (_currentRating > 0)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              "$_currentRating / 5",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(),
          ),
      ],
    );
  }
}
