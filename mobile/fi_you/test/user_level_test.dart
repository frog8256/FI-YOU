import 'package:fi_you/core/user_level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('resolves each cumulative user level in Korean by default', () {
    expect(
      UserLevel.displayName(userName: 'User', stats: const UserLevelStats()),
      '탐험가',
    );
    expect(
      UserLevel.displayName(
        userName: 'User',
        stats: const UserLevelStats(
          questionCount: 200,
          diaryCount: 15,
          attendanceDays: 14,
          joinedDays: 21,
        ),
      ),
      '관찰자',
    );
    expect(
      UserLevel.displayName(
        userName: 'User',
        stats: const UserLevelStats(
          questionCount: 600,
          diaryCount: 50,
          attendanceDays: 45,
          joinedDays: 60,
        ),
      ),
      '분석가',
    );
    expect(
      UserLevel.displayName(
        userName: 'User',
        stats: const UserLevelStats(
          questionCount: 1200,
          diaryCount: 120,
          attendanceDays: 90,
          joinedDays: 120,
        ),
      ),
      '설계자',
    );
    expect(
      UserLevel.displayName(
        userName: 'JongHwan',
        stats: const UserLevelStats(
          questionCount: 2000,
          diaryCount: 250,
          attendanceDays: 180,
          joinedDays: 300,
        ),
      ),
      'JongHwan',
    );
  });

  test(
    'keeps the previous level when one cumulative requirement is missing',
    () {
      final level = UserLevel.fromStats(
        const UserLevelStats(
          questionCount: 600,
          diaryCount: 50,
          attendanceDays: 44,
          joinedDays: 60,
        ),
      );

      expect(level.titleForLanguage('ko'), '관찰자');
    },
  );

  test('supports English labels for future language settings', () {
    expect(
      UserLevel.displayName(
        userName: 'User',
        stats: const UserLevelStats(
          questionCount: 1200,
          diaryCount: 120,
          attendanceDays: 90,
          joinedDays: 120,
        ),
        languageCode: 'en',
      ),
      'Architect',
    );
  });
}
