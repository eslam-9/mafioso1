import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_state.dart';
import '../bloc/online_room_event.dart';

class OnlineRoleRevealPage extends StatefulWidget {
  const OnlineRoleRevealPage({super.key});

  @override
  State<OnlineRoleRevealPage> createState() => _OnlineRoleRevealPageState();
}

class _OnlineRoleRevealPageState extends State<OnlineRoleRevealPage> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('your_role'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<OnlineRoomBloc>().add(LeaveRoomRequested());
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: BlocConsumer<OnlineRoomBloc, OnlineRoomState>(
        listener: (context, state) {
          if (state.status == OnlineRoomStatus.error) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state.room == null || state.gamePlayers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = getIt<AuthService>().currentUserId;
          final myGamePlayer = state.gamePlayers.firstWhere(
            (p) => p.userId == currentUserId,
          );

          final isKiller = myGamePlayer.role == 'killer';
          final roleKey = isKiller ? 'killer' : 'innocent';
          final roleColor = isKiller ? AppColors.bloodRed : Colors.blueAccent;

          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'tap_to_reveal_role'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 40.h),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isRevealed = true;
                    });
                  },
                  child: Container(
                    height: 250.h,
                    decoration: BoxDecoration(
                      color: _isRevealed ? roleColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isRevealed ? roleColor : Theme.of(context).dividerColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isRevealed ? roleColor.withValues(alpha: 0.3) : Colors.black12,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isRevealed
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                roleKey.tr(),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: roleColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.5, 0.5)),
                              SizedBox(height: 20.h),
                              Text(
                                'you_are_character'.tr(args: [myGamePlayer.storyCharacterName ?? '']),
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 500.ms),
                            ],
                          )
                        : Icon(
                            Icons.help_outline,
                            size: 100.r,
                            color: Theme.of(context).disabledColor,
                          ),
                  ),
                ),
                SizedBox(height: 40.h),
                if (_isRevealed)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, RouteNames.onlineGame);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('proceed_to_game'.tr()),
                  ).animate().fadeIn(delay: 1.seconds),
              ],
            ),
          );
        },
      ),
    );
  }
}
