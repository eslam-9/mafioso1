import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/game_setup_bloc.dart';
import '../bloc/game_setup_event.dart';
import '../bloc/game_setup_state.dart';

class PlayerNameInput extends StatefulWidget {
  final int index;

  const PlayerNameInput({
    super.key,
    required this.index,
  });

  @override
  State<PlayerNameInput> createState() => _PlayerNameInputState();
}

class _PlayerNameInputState extends State<PlayerNameInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameSetupBloc, GameSetupState>(
      buildWhen: (previous, current) {
        return previous.playerNames.length != current.playerNames.length ||
            (widget.index < current.playerNames.length &&
                previous.playerNames[widget.index] !=
                    current.playerNames[widget.index]);
      },
      builder: (context, state) {
        final currentName = widget.index < state.playerNames.length
            ? state.playerNames[widget.index]
            : '';

        if (_controller.text != currentName) {
          _controller.text = currentName;
        }

        return TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'player'.tr(namedArgs: {'index': (widget.index + 1).toString()}),
            prefixIcon: Icon(
              Icons.person,
              color: AppColors.bloodRed,
            ),
          ),
          onChanged: (value) {
            context.read<GameSetupBloc>().add(SetPlayerName(widget.index, value));
          },
        );
      },
    );
  }
}
