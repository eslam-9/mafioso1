import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';
import '../bloc/online_room_state.dart';

class MicToggleButton extends StatelessWidget {
  const MicToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineRoomBloc, OnlineRoomState>(
      builder: (context, state) {
        final isMicEnabled = state.isMicEnabled;
        return IconButton(
          icon: Icon(isMicEnabled ? Icons.mic : Icons.mic_off),
          color: isMicEnabled ? Colors.green : Colors.red,
          onPressed: () {
            context.read<OnlineRoomBloc>().add(ToggleMicRequested(!isMicEnabled));
          },
        );
      },
    );
  }
}
