import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/errors/app_error_localizer.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';
import '../bloc/online_room_state.dart';
import '../widgets/game_selection_sheet.dart';
import '../widgets/mic_toggle_button.dart';

class OnlineLobbyPage extends StatelessWidget {
  const OnlineLobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('lobby'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<OnlineRoomBloc>().add(LeaveRoomRequested());
            Navigator.pop(context);
          },
        ),
        actions: const [
          MicToggleButton(),
        ],
      ),
      body: BlocConsumer<OnlineRoomBloc, OnlineRoomState>(
        listener: (context, state) {
          if (state.status == OnlineRoomStatus.error) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppErrorLocalizer.localize(state.error!))),
              );
            }
            // If room is null (kicked or critical error), navigate back to home
            if (state.room == null) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          } else if (state.status == OnlineRoomStatus.inGame) {
            Navigator.pushReplacementNamed(context, RouteNames.onlineGame);
          } else if (state.status == OnlineRoomStatus.idle) {
            // User left the room successfully
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state.room == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final room = state.room!;
          final isHost = state.isHost;

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  '${'room_code'.tr()}: ${room.code}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Text(
                  'players_count'.tr(args: ['${state.members.length}', '${room.maxPlayers}']),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.members.length,
                    itemBuilder: (context, index) {
                      final member = state.members[index];
                      final isCurrentHost = member.userId == room.hostId;
                      return ListTile(
                        leading: Icon(
                          member.isOnline ? Icons.circle : Icons.circle_outlined,
                          color: member.isOnline ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        title: Text(member.displayName),
                        subtitle: isCurrentHost ? Text('host'.tr()) : null,
                        trailing: isHost && !isCurrentHost
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  context.read<OnlineRoomBloc>().add(
                                    KickPlayerRequested(userId: member.userId),
                                  );
                                },
                              )
                            : null,
                      );
                    },
                  ),
                ),
                if (isHost) ...[
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: () {
                      GameSelectionSheet.show(context, room.maxPlayers);
                    },
                    child: Text(room.selectedStoryId == null ? 'select_game'.tr() : 'change_game'.tr()),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: room.selectedStoryId != null && state.members.length >= 2
                        ? () {
                            context.read<OnlineRoomBloc>().add(StartGameRequested());
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('start_game'.tr()),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
