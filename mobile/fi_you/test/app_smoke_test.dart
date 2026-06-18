import 'package:fi_you/app/fi_you_app.dart';
import 'package:fi_you/data/repositories/mock_self_discovery_repository.dart';
import 'package:fi_you/data/repositories/repository_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows auth screen on first launch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selfDiscoveryRepositoryProvider.overrideWithValue(MockSelfDiscoveryRepository()),
        ],
        child: const FiYouApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('FI-YOU'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
  });
}
