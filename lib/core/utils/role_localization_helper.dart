import 'package:easy_localization/easy_localization.dart';
import '../../features/role_reveal/domain/entities/player.dart';

class RoleLocalizationHelper {
  static String getRoleDisplayName(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return 'role_killer'.tr();
      case PlayerRole.detective:
        return 'role_detective'.tr();
      case PlayerRole.innocent:
        return 'role_innocent'.tr();
    }
  }

  static String getRoleDescription(PlayerRole role) {
    switch (role) {
      case PlayerRole.killer:
        return 'role_killer_desc'.tr();
      case PlayerRole.detective:
        return 'role_detective_desc'.tr();
      case PlayerRole.innocent:
        return 'role_innocent_desc'.tr();
    }
  }
}
