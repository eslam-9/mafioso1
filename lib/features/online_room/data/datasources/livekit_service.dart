import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/utils/logger.dart';

class LiveKitService {
  Room? _room;
  EventsListener<RoomEvent>? _listener;

  bool get isConnected =>
      _room != null &&
      _room!.connectionState == ConnectionState.connected;

  /// Requests the microphone permission at runtime.
  /// Returns true if granted, false otherwise.
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;

    final result = await Permission.microphone.request();
    if (!result.isGranted) {
      AppLogger.logError('LiveKitService', 'Microphone permission denied (status: $result)');
      return false;
    }
    return true;
  }

  Future<void> connect(String url, String token) async {
    try {
      // 1. Request mic permission before attempting to connect
      final hasPermission = await requestMicPermission();
      if (!hasPermission) {
        // Connect to the room anyway (for listening), but don't publish audio
        AppLogger.logInfo('LiveKitService: connecting without mic — permission denied');
      }

      _room = Room();
      _listener = _room!.createListener();

      _listener!.on<RoomDisconnectedEvent>((event) {
        AppLogger.logInfo('LiveKitService: Disconnected from room');
      });

      _listener!.on<ParticipantConnectedEvent>((event) {
        AppLogger.logInfo('LiveKitService: Participant connected: ${event.participant.identity}');
      });

      await _room!.connect(
        url,
        token,
        roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
      );

      AppLogger.logInfo('LiveKitService: Connected to LiveKit room');
      // Note: mic is NOT enabled here. The Bloc dispatches ToggleMicRequested(true)
      // after a successful connect, which calls enableMic() exactly once.
    } catch (e, st) {
      AppLogger.logError('LiveKitService - connect', e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> enableMic(bool enable) async {
    if (_room == null) return;
    try {
      if (enable) {
        final hasPermission = await requestMicPermission();
        if (!hasPermission) {
          AppLogger.logInfo('LiveKitService: Cannot enable mic — permission denied');
          return;
        }
      }
      await _room!.localParticipant?.setMicrophoneEnabled(enable);
    } catch (e, st) {
      AppLogger.logError('LiveKitService - enableMic', e, stackTrace: st);
    }
  }

  Future<void> disconnect() async {
    try {
      if (_listener != null) {
        await _listener!.dispose();
        _listener = null;
      }
      if (_room != null) {
        await _room!.disconnect();
        _room = null;
      }
    } catch (e, st) {
      AppLogger.logError('LiveKitService - disconnect', e, stackTrace: st);
    }
  }
}
