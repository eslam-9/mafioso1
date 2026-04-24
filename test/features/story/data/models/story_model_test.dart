import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/features/story/data/models/story_model.dart';

void main() {
  group('StoryModel.fromJson', () {
    test('parses a valid story payload', () {
      final story = StoryModel.fromJson({
        'title': 'The Manor',
        'intro': 'A cold night at the manor.',
        'crimeDescription': 'The host was found dead in the library.',
        'suspects': [
          {
            'name': 'Alice',
            'suspiciousBehavior': 'She was seen leaving the library.',
          },
        ],
        'clues': [
          {'text': 'A muddy footprint.', 'difficulty': 'easy'},
        ],
        'twist': 'The murder weapon was hidden inside a cane.',
        'killerName': 'Alice',
      });

      expect(story.title, 'The Manor');
      expect(story.suspects.single.name, 'Alice');
      expect(story.clues.single.text, 'A muddy footprint.');
    });

    test('throws FormatException when required fields are missing', () {
      expect(
        () => StoryModel.fromJson({
          'title': 'The Manor',
          'intro': 'A cold night at the manor.',
          'crimeDescription': 'The host was found dead in the library.',
          'suspects': [],
          'clues': [],
          'twist': '',
          'killerName': '',
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
