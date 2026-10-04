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
            // Navigate to role reveal — NOT directly to the game page.
            // Each player must privately see their own role before proceeding.
            Navigator.pushReplacementNamed(context, RouteNames.onlineRoleReveal);
          } else if (state.status == OnlineRoomStatus.idle) {
            // User left the room successfully
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state.room == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show a full-screen loading indicator during the 'starting' transition
          // so players can't interact while the server assigns roles.
          if (state.status == OnlineRoomStatus.loading && state.room != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('game_starting'.tr()),
                ],
              ),
            );
          }

          final room = state.room!;
          final isHost = state.isHost;
          final memberCount = state.members.length;
          final requiredPlayers = room.requiredPlayers;

          // canStart: story selected AND member count == required player count
          final canStart = room.canStart(memberCount);

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
                // Show player count with required count if story is selected
                Text(
                  requiredPlayers != null
                      ? 'players_count_required'.tr(
                          args: ['$memberCount', '$requiredPlayers'],
                        )
                      : 'players_count'.tr(
                          args: ['$memberCount', '${room.maxPlayers}'],
                        ),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: requiredPlayers != null && memberCount != requiredPlayers
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
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
                    onPressed: () async {
                      final story = await GameSelectionSheet.show(
                        context,
                        currentMemberCount: memberCount,
                      );
                      if (story != null && context.mounted) {
                        context.read<OnlineRoomBloc>().add(
                          SelectGameRequested(
                            storyId: story.id,
                            gameMode: 'standard',
                          ),
                        );
                      }
                    },
                    child: Text(room.selectedStoryId == null ? 'select_game'.tr() : 'change_game'.tr()),
                  ),
                  SizedBox(height: 10.h),
                  ElevatedButton(
                    onPressed: canStart
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
                  // Hint text when story selected but count is wrong
                  if (room.selectedStoryId != null && !canStart && requiredPlayers != null)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'need_players_hint'.tr(
                          args: ['$requiredPlayers', '$memberCount'],
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                        textAlign: TextAlign.center,
                      ),
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
