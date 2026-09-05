import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/features/story_library/data/models/story_upload_payload.dart';

void main() {
  group('StoryUploadPayload.fromJson', () {
    for (final count in [4, 5, 6]) {
      test('derives a valid count of $count from suspects', () {
        final payload = StoryUploadPayload.fromJson({
          'suspects': List.generate(count, (index) => {'name': 'S$index'}),
        });

        expect(payload.suspectCount, count);
      });
    }

    test('rejects a missing suspects array', () {
      expect(
        () => StoryUploadPayload.fromJson(const {}),
        throwsA(isA<FormatException>()),
      );
    });

    for (final count in [0, 3, 7]) {
      test('rejects an out-of-range count of $count', () {
        expect(
          () => StoryUploadPayload.fromJson({
            'suspects': List.generate(count, (index) => index),
          }),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('keeps a valid stored count', () {
      final count = StoryUploadPayload.resolveSuspectCount(5, {
        'suspects': List.generate(4, (index) => index),
      });

      expect(count, 5);
    });

    for (final storedCount in [null, 0, 7]) {
      test('derives from JSON when stored count is $storedCount', () {
        final count = StoryUploadPayload.resolveSuspectCount(storedCount, {
          'suspects': List.generate(6, (index) => index),
        });

        expect(count, 6);
      });
    }
  });
}
