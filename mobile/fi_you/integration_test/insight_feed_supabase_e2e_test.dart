import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/data/supabase_fi_you_repository.dart';
import 'package:fi_you/features/explore/insight_feed_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
);
const _e2eEmail = String.fromEnvironment('E2E_SUPABASE_EMAIL');
const _e2ePassword = String.fromEnvironment('E2E_SUPABASE_PASSWORD');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('live Supabase insight feed renders persisted insights', (
    tester,
  ) async {
    expect(_supabaseUrl, isNotEmpty);
    expect(_supabasePublishableKey, isNotEmpty);
    expect(_e2eEmail, isNotEmpty);
    expect(_e2ePassword, isNotEmpty);

    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabasePublishableKey,
    );
    final client = Supabase.instance.client;
    await client.auth.signInWithPassword(
      email: _e2eEmail,
      password: _e2ePassword,
    );

    final repository = SupabaseFiYouRepository(client);
    for (var index = 0; index < 3; index += 1) {
      final card = await repository.loadNextExplorationCard();
      await repository.submitExplorationAnswer(
        ExplorationAnswerInput(
          cardId: card.id,
          selectedOptionIds: _selectedOptionIds(card),
          userNote: 'codex live insight feed ui e2e $index',
        ),
      );
    }

    final feed = await repository.getInsightFeed();
    expect(feed.hasError, isFalse);
    expect(feed.insights, isNotEmpty);
    final insightTitles = [
      for (final insight in feed.insights)
        if (insight.title.trim().isNotEmpty) insight.title,
    ];
    expect(insightTitles, isNotEmpty);

    final persistedRows = await client
        .from('user_insights')
        .select('id,title,active')
        .eq('active', true)
        .limit(20);
    expect(persistedRows, isNotEmpty);

    await tester.pumpWidget(
      FiYouRepositoryScope(
        repository: repository,
        child: const MaterialApp(home: InsightFeedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Things Becoming Clearer'), findsOneWidget);
    await _expectAnyInsightTitleVisible(tester, insightTitles);
    expect(find.textContaining('personality type'), findsNothing);
    expect(find.textContaining('diagnosis'), findsNothing);
    expect(find.textContaining('score'), findsNothing);
  });
}

Future<void> _expectAnyInsightTitleVisible(
  WidgetTester tester,
  List<String> titles,
) async {
  for (var attempt = 0; attempt < 8; attempt += 1) {
    for (final title in titles) {
      if (find.text(title).evaluate().isNotEmpty) {
        expect(find.text(title), findsWidgets);
        return;
      }
    }
    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pumpAndSettle();
  }
  fail('No live insight title was visible in the Insight Feed UI.');
}

List<String> _selectedOptionIds(ExplorationCard card) {
  if (!card.allowsMultipleSelection) {
    return [card.options.first.id];
  }
  final required = card.requiredSelections.clamp(2, 3).toInt();
  return card.options.take(required).map((option) => option.id).toList();
}
