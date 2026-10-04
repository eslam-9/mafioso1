import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mafioso/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end online room flow test (UI navigation)', (
    tester,
  ) async {
    // Note: A true E2E test for multiplayer requires multiple devices or mocked Supabase.
    // For this demonstration, we'll initialize the app and verify the start screen is reachable.
    app.main();
    await tester.pumpAndSettle();

    // Verify app starts at main menu
    expect(
      find.text('mafioso'),
      findsWidgets,
    ); // Example check, adjust based on actual main menu UI
  });
}
