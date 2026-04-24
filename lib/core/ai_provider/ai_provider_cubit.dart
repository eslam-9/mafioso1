import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_provider.dart';

class AiProviderState extends Equatable {
  final AiProvider provider;

  const AiProviderState({required this.provider});

  AiProviderState copyWith({AiProvider? provider}) {
    return AiProviderState(provider: provider ?? this.provider);
  }

  @override
  List<Object> get props => [provider];
}

class AiProviderCubit extends Cubit<AiProviderState> {
  static const String _key = 'ai_provider';

  AiProviderCubit() : super(const AiProviderState(provider: AiProvider.gemini));

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProvider = prefs.getString(_key);
    if (savedProvider != null) {
      final provider = AiProvider.values.byName(savedProvider);
      emit(AiProviderState(provider: provider));
    }
  }

  void setProvider(AiProvider provider) {
    emit(AiProviderState(provider: provider));
    _save(provider);
  }

  Future<void> toggle() async {
    final newProvider = state.provider == AiProvider.gemini
        ? AiProvider.grok
        : AiProvider.gemini;
    setProvider(newProvider);
  }

  Future<void> _save(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, provider.name);
  }
}
