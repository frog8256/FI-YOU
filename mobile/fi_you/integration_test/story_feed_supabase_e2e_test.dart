import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/data/supabase_fi_you_repository.dart';
import 'package:fi_you/features/explore/story_feed_screen.dart';
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

  testWidgets('live Supabase story feed renders persisted stories', (
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
    var feed = await repository.getStoryFeed();
    if (feed.isEmpty) {
      await client.functions.invoke('story-feed', body: {'refresh': true});
      feed = await repository.getStoryFeed();
    }

    expect(feed.hasError, isFalse);
    expect(feed.stories, isNotEmpty);
    final storyTitles = [
      for (final story in feed.stories)
        if (story.title.trim().isNotEmpty) story.title,
    ];
    expect(storyTitles, isNotEmpty);

    final persistedRows = await client
        .from('user_stories')
        .select('id,title,active')
        .eq('active', true)
        .limit(20);
    expect(persistedRows, isNotEmpty);

    await tester.pumpWidget(
      FiYouRepositoryScope(
        repository: repository,
        child: const MaterialApp(home: StoryFeedScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Story'), findsWidgets);
    await _expectAnyStoryTitleVisible(tester, storyTitles);
    for (final forbidden in [
      'story_id',
      'story_type',
      'supporting_insights',
      'personality type',
      'diagnosis',
      'analysis result',
      'score',
      'assessment',
      'profile',
    ]) {
      expect(find.textContaining(forbidden), findsNothing);
    }
  });
}

Future<void> _expectAnyStoryTitleVisible(
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
  fail('No live story title was visible in the Story Feed UI.');
}
