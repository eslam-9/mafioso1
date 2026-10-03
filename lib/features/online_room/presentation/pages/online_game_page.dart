import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';
import '../bloc/online_room_state.dart';
import '../widgets/online_game_tabs.dart';

class OnlineGamePage extends StatefulWidget {
  const OnlineGamePage({super.key});

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('investigation'.tr()),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'story_and_clues'.tr()),
            Tab(text: 'voting'.tr()),
          ],
        ),
      ),
      body: BlocConsumer<OnlineRoomBloc, OnlineRoomState>(
        listener: (context, state) {
          if (state.status == OnlineRoomStatus.idle || state.room == null) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state.session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return OnlineGameTabs(
            tabController: _tabController,
            alivePlayers: state.alivePlayers,
          );
        },
      ),
    );
  }
}
