import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Status values for tracking rating prompt interactions.
enum RateDialogStatus { notAsked, remindLater, rated, declined }

/// Service to handle app rating prompt logic and persistence.
class RatingService {
  static const String _key = 'app_rating_status';
  final SharedPreferences _prefs;

  RatingService(this._prefs);

  /// Checks if the rating dialog should be displayed.
  /// True if the user has not been asked yet, or requested to be reminded later.
  bool get shouldShowDialog {
    final status = _readStatus();
    return status == RateDialogStatus.notAsked ||
        status == RateDialogStatus.remindLater;
  }

  /// Launches the Google Play Store URL for Mafioso.
  Future<bool> openPlayStore() async {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.mafioso.game',
    );
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Mark status as Rated.
  Future<void> markAsRated() async => _writeStatus(RateDialogStatus.rated);

  /// Mark status as Remind Later.
  Future<void> markAsRemindLater() async =>
      _writeStatus(RateDialogStatus.remindLater);

  /// Mark status as Declined.
  Future<void> markAsDeclined() async =>
      _writeStatus(RateDialogStatus.declined);

  RateDialogStatus _readStatus() {
    final value = _prefs.getString(_key);
    if (value == null) return RateDialogStatus.notAsked;

    switch (value) {
      case 'remindLater':
        return RateDialogStatus.remindLater;
      case 'rated':
        return RateDialogStatus.rated;
      case 'declined':
        return RateDialogStatus.declined;
      default:
        return RateDialogStatus.notAsked;
    }
  }

  Future<void> _writeStatus(RateDialogStatus status) async {
    await _prefs.setString(_key, status.name);
  }
}
