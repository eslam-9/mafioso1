import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mafioso/core/ai_provider/ai_provider.dart';
import 'package:mafioso/core/ai_provider/ai_provider_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AiProviderCubit', () {
    late AiProviderCubit cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cubit = AiProviderCubit();
    });

    test('initial state should be gemini', () {
      expect(cubit.state.provider, AiProvider.gemini);
    });

    blocTest<AiProviderCubit, AiProviderState>(
      'emits grok when setProvider(grok) is called',
      build: () => AiProviderCubit(),
      act: (cubit) => cubit.setProvider(AiProvider.grok),
      expect: () => [const AiProviderState(provider: AiProvider.grok)],
    );

    blocTest<AiProviderCubit, AiProviderState>(
      'emits gemini when setProvider(gemini) is called',
      build: () => AiProviderCubit(),
      act: (cubit) {
        cubit.setProvider(AiProvider.grok);
        cubit.setProvider(AiProvider.gemini);
      },
      expect: () => [
        const AiProviderState(provider: AiProvider.grok),
        const AiProviderState(provider: AiProvider.gemini),
      ],
    );

    blocTest<AiProviderCubit, AiProviderState>(
      'toggles from gemini to grok',
      build: () => AiProviderCubit(),
      act: (cubit) => cubit.toggle(),
      expect: () => [const AiProviderState(provider: AiProvider.grok)],
    );

    blocTest<AiProviderCubit, AiProviderState>(
      'toggles from grok to gemini',
      build: () => AiProviderCubit(),
      act: (cubit) {
        cubit.setProvider(AiProvider.grok);
        cubit.toggle();
      },
      expect: () => [
        const AiProviderState(provider: AiProvider.grok),
        const AiProviderState(provider: AiProvider.gemini),
      ],
    );
  });
}
