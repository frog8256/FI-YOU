import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/data/supabase_fi_you_repository.dart';
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

  testWidgets(
    'Supabase repository delivers, answers, and advances exploration cards',
    (tester) async {
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
      final first = await repository.loadNextExplorationCard();
      _expectUsableCard(first);

      final selectedOptionIds = _selectedOptionIds(first);
      await repository.submitExplorationAnswer(
        ExplorationAnswerInput(
          cardId: first.id,
          selectedOptionIds: selectedOptionIds,
        ),
      );

      final second = await repository.loadNextExplorationCard();
      _expectUsableCard(second);

      final history = await client
          .from('user_card_history')
          .select('id, answered')
          .order('created_at', ascending: false)
          .limit(2);
      final answers = await client
          .from('user_card_answers')
          .select('id')
          .limit(1);

      expect(history.length, greaterThanOrEqualTo(2));
      expect(
        history.any((row) => row['id'] == first.id && row['answered'] == true),
        isTrue,
      );
      expect(answers.length, greaterThanOrEqualTo(1));
    },
  );
}

void _expectUsableCard(ExplorationCard card) {
  expect(card.id, isNotEmpty);
  expect(card.question, isNotEmpty);
  expect(card.options.length, greaterThanOrEqualTo(2));
  for (final option in card.options) {
    expect(option.id, isNotEmpty);
    expect(option.label, isNotEmpty);
  }
}

List<String> _selectedOptionIds(ExplorationCard card) {
  if (!card.allowsMultipleSelection) {
    return [card.options.first.id];
  }
  final required = card.requiredSelections.clamp(2, 3).toInt();
  return card.options.take(required).map((option) => option.id).toList();
}
