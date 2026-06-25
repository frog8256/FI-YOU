import 'package:fi_you/data/fi_you_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Mock repository creates a 1 Star Journy report', () async {
    SharedPreferences.setMockInitialValues({
      'fi_you.dev.signed_in': true,
      'fi_you.dev.onboarding_complete': true,
      'fi_you.dev.name': 'Tester',
      'fi_you.dev.email': 'tester@fi-you.local',
      'fi_you.dev.star_balance': 900,
      'fi_you.dev.level': 9,
    });

    final repository = MockFiYouRepository();
    await repository.restoreLaunchState();

    expect(repository.profile?.starBalance, 900 - journyReportStarCost);

    final report = await repository.generateJournyReport();

    expect(repository.profile?.starBalance, 900);
    expect(report.starCost, journyReportStarCost);
    expect(report.title.trim(), isNotEmpty);
    expect(report.timelineEvents, isNotEmpty);
    expect(report.nextSteps, isNotEmpty);
  });
}
