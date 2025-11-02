import 'package:flutter/foundation.dart';
import '../models/game_config.dart';

class GameSetupViewModel extends ChangeNotifier {
  GameMode _selectedMode = GameMode.withoutDetective;
  int _suspectCount = 4;
  List<String> _playerNames = [];
  
  GameMode get selectedMode => _selectedMode;
  int get suspectCount => _suspectCount;
  List<String> get playerNames => _playerNames;
  int get totalPlayers => _selectedMode == GameMode.withDetective ? _suspectCount + 1 : _suspectCount;
  
  void setMode(GameMode mode) {
    _selectedMode = mode;
    _updatePlayerNames();
    notifyListeners();
  }
  
  void setSuspectCount(int count) {
    if (count >= 4 && count <= 6) {
      _suspectCount = count;
      _updatePlayerNames();
      notifyListeners();
    }
  }
  
  void _updatePlayerNames() {
    final requiredCount = totalPlayers;
    if (_playerNames.length > requiredCount) {
      _playerNames = _playerNames.sublist(0, requiredCount);
    } else {
      while (_playerNames.length < requiredCount) {
        _playerNames.add('');
      }
    }
  }
  
  void setPlayerName(int index, String name) {
    if (index >= 0 && index < _playerNames.length) {
      _playerNames[index] = name;
      notifyListeners();
    }
  }
  
  bool validateNames() {
    if (_playerNames.any((name) => name.trim().isEmpty)) {
      return false;
    }
    
    // Check for duplicate names
    final uniqueNames = _playerNames.map((n) => n.trim().toLowerCase()).toSet();
    return uniqueNames.length == _playerNames.length;
  }
  
  GameConfig createGameConfig() {
    if (!validateNames()) {
      throw Exception('Invalid player names');
    }
    
    return GameConfig(
      mode: _selectedMode,
      suspectCount: _suspectCount,
      playerNames: _playerNames.map((n) => n.trim()).toList(),
    );
  }
  
  void reset() {
    _selectedMode = GameMode.withoutDetective;
    _suspectCount = 4;
    _playerNames = [];
    notifyListeners();
  }
}
