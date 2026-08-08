import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Computes the canonical SHA-256 content hash used to identify a story's
/// core content regardless of suspect ordering or clue details.
///
/// The same algorithm is used by the community library uploader and by
/// played-story tracking so the two can be compared.
class StoryContentHasher {
  static String hash({
    required String title,
    required String intro,
    required String crimeDescription,
    required String killerName,
    required String twist,
    required String languageCode,
  }) {
    final canonical = jsonEncode({
      'title': title,
      'intro': intro,
      'crimeDescription': crimeDescription,
      'killerName': killerName,
      'twist': twist,
      'languageCode': languageCode,
    });
    return sha256.convert(utf8.encode(canonical)).toString();
  }
}
