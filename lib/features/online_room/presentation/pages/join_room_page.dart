import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../shared/errors/app_error_localizer.dart';
import '../bloc/online_room_bloc.dart';
import '../bloc/online_room_event.dart';
import '../bloc/online_room_state.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _joinRoom() {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_invalid_room_code'.tr())),
      );
      return;
    }
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('error_display_name_required'.tr())),
      );
      return;
    }

    final password = _passwordController.text.trim();
    context.read<OnlineRoomBloc>().add(
      JoinRoomRequested(
        code: code,
        displayName: name,
        password: password.isEmpty ? null : password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('join_room'.tr())),
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
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'room_code'.tr(),
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'your_name'.tr(),
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
                  onPressed: _joinRoom,
                  child: Text('join'.tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
