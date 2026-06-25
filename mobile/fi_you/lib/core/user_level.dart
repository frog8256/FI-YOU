import 'package:flutter/foundation.dart';

@immutable
class UserLevelStats {
  const UserLevelStats({
    this.questionCount = 0,
    this.diaryCount = 0,
    this.attendanceDays = 0,
    this.joinedDays = 0,
  });

  final int questionCount;
  final int diaryCount;
  final int attendanceDays;
  final int joinedDays;

  UserLevelStats copyWith({
    int? questionCount,
    int? diaryCount,
    int? attendanceDays,
    int? joinedDays,
  }) {
    return UserLevelStats(
      questionCount: questionCount ?? this.questionCount,
      diaryCount: diaryCount ?? this.diaryCount,
      attendanceDays: attendanceDays ?? this.attendanceDays,
      joinedDays: joinedDays ?? this.joinedDays,
    );
  }
}

@immutable
class UserLevelDefinition {
  const UserLevelDefinition({
    required this.level,
    required this.englishTitle,
    required this.koreanTitle,
    required this.requiredQuestions,
    required this.requiredDiaries,
    required this.requiredAttendanceDays,
    required this.requiredJoinedDays,
  });

  final int level;
  final String englishTitle;
  final String koreanTitle;
  final int requiredQuestions;
  final int requiredDiaries;
  final int requiredAttendanceDays;
  final int requiredJoinedDays;

  String titleForLanguage(String languageCode) {
    return switch (languageCode.toLowerCase()) {
      'en' => englishTitle,
      _ => koreanTitle,
    };
  }

  bool isMetBy(UserLevelStats stats) {
    return stats.questionCount >= requiredQuestions &&
        stats.diaryCount >= requiredDiaries &&
        stats.attendanceDays >= requiredAttendanceDays &&
        stats.joinedDays >= requiredJoinedDays;
  }
}

const userLevelDefinitions = <UserLevelDefinition>[
  UserLevelDefinition(
    level: 1,
    englishTitle: 'Explorer',
    koreanTitle: '탐험가',
    requiredQuestions: 0,
    requiredDiaries: 0,
    requiredAttendanceDays: 0,
    requiredJoinedDays: 0,
  ),
  UserLevelDefinition(
    level: 2,
    englishTitle: 'Observer',
    koreanTitle: '관찰자',
    requiredQuestions: 200,
    requiredDiaries: 15,
    requiredAttendanceDays: 14,
    requiredJoinedDays: 21,
  ),
  UserLevelDefinition(
    level: 3,
    englishTitle: 'Analyst',
    koreanTitle: '분석가',
    requiredQuestions: 600,
    requiredDiaries: 50,
    requiredAttendanceDays: 45,
    requiredJoinedDays: 60,
  ),
  UserLevelDefinition(
    level: 4,
    englishTitle: 'Architect',
    koreanTitle: '설계자',
    requiredQuestions: 1200,
    requiredDiaries: 120,
    requiredAttendanceDays: 90,
    requiredJoinedDays: 120,
  ),
  UserLevelDefinition(
    level: 5,
    englishTitle: '',
    koreanTitle: '',
    requiredQuestions: 2000,
    requiredDiaries: 250,
    requiredAttendanceDays: 180,
    requiredJoinedDays: 300,
  ),
];

class UserLevel {
  const UserLevel._();

  static UserLevelDefinition fromStats(UserLevelStats stats) {
    for (final definition in userLevelDefinitions.reversed) {
      if (definition.isMetBy(stats)) {
        return definition;
      }
    }
    return userLevelDefinitions.first;
  }

  static String displayName({
    required String userName,
    required UserLevelStats stats,
    String languageCode = 'ko',
  }) {
    final definition = fromStats(stats);
    if (definition.level == 5) {
      final trimmed = userName.trim();
      return trimmed.isEmpty ? 'User' : trimmed;
    }
    return definition.titleForLanguage(languageCode);
  }
}
