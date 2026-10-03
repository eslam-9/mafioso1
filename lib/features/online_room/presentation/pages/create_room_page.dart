import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/errors/app_error_localizer.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';
import '../bloc/online_room_state.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPageState();
}

class _CreateRoomPageState extends State<CreateRoomPage> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _createRoom() {
    final name = _nameController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_room_name_required'.tr())),
      );
      return;
    }
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_display_name_required'.tr())),
      );
      return;
    }

    final password = _passwordController.text.trim();
    context.read<OnlineRoomBloc>().add(
      CreateRoomRequested(
        name: name,
        password: password.isEmpty ? null : password,
        displayName: displayName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('create_room'.tr())),
      body: BlocConsumer<OnlineRoomBloc, OnlineRoomState>(
        listener: (context, state) {
          if (state.status == OnlineRoomStatus.inLobby) {
            Navigator.pushReplacementNamed(context, RouteNames.onlineLobby);
          } else if (state.status == OnlineRoomStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppErrorLocalizer.localize(state.error!))),
            );
          }
        },
        builder: (context, state) {
          if (state.status == OnlineRoomStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'your_name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'room_name'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'password_optional'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 40.h),
                ElevatedButton(
                  onPressed: _createRoom,
                  child: Text('create'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
