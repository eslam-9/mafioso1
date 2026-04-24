import 'package:flutter_test/flutter_test.dart';
import 'package:mafioso/core/ai_provider/ai_provider.dart';

void main() {
  group('AiProvider', () {
    test('should have gemini and grok values', () {
      expect(AiProvider.values.length, 2);
      expect(AiProvider.values.contains(AiProvider.gemini), true);
      expect(AiProvider.values.contains(AiProvider.grok), true);
    });

    test('gemini should have correct name', () {
      expect(AiProvider.gemini.name, 'gemini');
    });

    test('grok should have correct name', () {
      expect(AiProvider.grok.name, 'grok');
    });

    test('should be able to find by name', () {
      expect(AiProvider.values.byName('gemini'), AiProvider.gemini);
      expect(AiProvider.values.byName('grok'), AiProvider.grok);
    });
  });
}
