class StoryUploadPayload {
  final Map<String, dynamic> storyJson;
  final int suspectCount;

  const StoryUploadPayload({
    required this.storyJson,
    required this.suspectCount,
  });

  factory StoryUploadPayload.fromJson(Map<String, dynamic> storyJson) {
    final rawSuspects = storyJson['suspects'];
    if (rawSuspects is! List) {
      throw const FormatException(
        'Invalid story payload: suspects must be an array.',
      );
    }

    final suspectCount = rawSuspects.length;
    if (suspectCount < 4 || suspectCount > 6) {
      throw FormatException(
        'Invalid story payload: suspect count must be between 4 and 6, '
        'but was $suspectCount.',
      );
    }

    return StoryUploadPayload(storyJson: storyJson, suspectCount: suspectCount);
  }

  static int resolveSuspectCount(
    Object? storedCount,
    Map<String, dynamic> storyJson,
  ) {
    final stored = storedCount is num ? storedCount.toInt() : null;
    if (stored != null && stored >= 4 && stored <= 6) return stored;
    return StoryUploadPayload.fromJson(storyJson).suspectCount;
  }
}
