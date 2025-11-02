import 'package:audioplayers/audioplayers.dart';

enum SoundEffect {
  roleReveal,
  vote,
  win,
  lose,
  buttonClick,
}

class SoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSound(SoundEffect effect) async {
    if (_isMuted) return;

    try {
      final soundPath = _getSoundPath(effect);
      await _player.play(AssetSource(soundPath));
    } catch (e) {
      // Silently fail if sound file doesn't exist
      // In production, you would add actual sound files
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  String _getSoundPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.roleReveal:
        return 'audio/role_reveal.mp3';
      case SoundEffect.vote:
        return 'audio/vote.mp3';
      case SoundEffect.win:
        return 'audio/win.mp3';
      case SoundEffect.lose:
        return 'audio/lose.mp3';
      case SoundEffect.buttonClick:
        return 'audio/button_click.mp3';
    }
  }

  void dispose() {
    _player.dispose();
  }
}
