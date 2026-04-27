import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/core/ai_provider/ai_provider.dart';

void main() {
  group('AiProvider', () {
    test('should have gemini and groq values', () {
      expect(AiProvider.values.length, 2);
      expect(AiProvider.values.contains(AiProvider.gemini), true);
      expect(AiProvider.values.contains(AiProvider.groq), true);
    });

    test('gemini should have correct name', () {
      expect(AiProvider.gemini.name, 'gemini');
    });

    test('groq should have correct name', () {
      expect(AiProvider.groq.name, 'groq');
    });

    test('should be able to find by name', () {
      expect(AiProvider.values.byName('gemini'), AiProvider.gemini);
      expect(AiProvider.values.byName('groq'), AiProvider.groq);
    });
  });
}
