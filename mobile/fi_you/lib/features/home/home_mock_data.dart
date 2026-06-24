import 'package:flutter/material.dart';

class HomeAxisClue {
  const HomeAxisClue({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

class HomeActivityMetric {
  const HomeActivityMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class HomeJourneyMetric {
  const HomeJourneyMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class HomeRecommendation {
  const HomeRecommendation({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

const homeStatsMetrics = [
  HomeActivityMetric(
    label: '총 출석',
    value: '18일',
    icon: Icons.calendar_month_rounded,
    color: Color(0xFFC4B5FD),
  ),
  HomeActivityMetric(
    label: '연속 출석',
    value: '5일',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFF7DD3FC),
  ),
  HomeActivityMetric(
    label: '총 Diary',
    value: '12개',
    icon: Icons.edit_note_rounded,
    color: Color(0xFFF7C948),
  ),
  HomeActivityMetric(
    label: '연속 작성',
    value: '3일',
    icon: Icons.history_edu_rounded,
    color: Color(0xFF6EE7B7),
  ),
];

class HomeMockData {
  const HomeMockData({
    required this.userName,
    required this.starCount,
    required this.levelLabel,
    required this.uMapVisibility,
    required this.uMapLevelLabel,
    required this.uMapHelpText,
    required this.axisClues,
    required this.journeyMetrics,
    required this.universeSummaryTitle,
    required this.universeOneLiner,
    required this.universeSummaryBody,
    required this.universeSummarySupport,
    required this.recommendations,
    required this.diaryPrompt,
    required this.todayClue,
    required this.nextQuestion,
    required this.estimatedQuestionTime,
    required this.activityMetrics,
    required this.latestUpdateLabel,
  });

  final String userName;
  final int starCount;
  final String levelLabel;
  final double uMapVisibility;
  final String uMapLevelLabel;
  final String uMapHelpText;
  final List<HomeAxisClue> axisClues;
  final List<HomeJourneyMetric> journeyMetrics;
  final String universeSummaryTitle;
  final String universeOneLiner;
  final String universeSummaryBody;
  final String universeSummarySupport;
  final List<HomeRecommendation> recommendations;
  final String diaryPrompt;
  final String todayClue;
  final String nextQuestion;
  final String estimatedQuestionTime;
  final List<HomeActivityMetric> activityMetrics;
  final String latestUpdateLabel;

  HomeMockData copyWith({
    String? userName,
    int? starCount,
    String? levelLabel,
    List<HomeJourneyMetric>? journeyMetrics,
    List<HomeActivityMetric>? activityMetrics,
  }) {
    return HomeMockData(
      userName: userName ?? this.userName,
      starCount: starCount ?? this.starCount,
      levelLabel: levelLabel ?? this.levelLabel,
      uMapVisibility: uMapVisibility,
      uMapLevelLabel: uMapLevelLabel,
      uMapHelpText: uMapHelpText,
      axisClues: axisClues,
      journeyMetrics: journeyMetrics ?? this.journeyMetrics,
      universeSummaryTitle: universeSummaryTitle,
      universeOneLiner: universeOneLiner,
      universeSummaryBody: universeSummaryBody,
      universeSummarySupport: universeSummarySupport,
      recommendations: recommendations,
      diaryPrompt: diaryPrompt,
      todayClue: todayClue,
      nextQuestion: nextQuestion,
      estimatedQuestionTime: estimatedQuestionTime,
      activityMetrics: activityMetrics ?? this.activityMetrics,
      latestUpdateLabel: latestUpdateLabel,
    );
  }
}

const homeMockData = HomeMockData(
  userName: 'User',
  starCount: 124,
  levelLabel: '관찰자',
  uMapVisibility: 0.68,
  uMapLevelLabel: '현재 기록을 바탕으로 탐구 중인 우주입니다.',
  uMapHelpText: '질문과 Diary가 쌓이면 10개 노드가 더 선명하게 연결됩니다.',
  axisClues: [
    HomeAxisClue(label: '관계 반응', value: 82, color: Color(0xFFA78BFA)),
    HomeAxisClue(label: '탐험 흐름', value: 78, color: Color(0xFF7DD3FC)),
    HomeAxisClue(label: '감정 신호', value: 68, color: Color(0xFFFB7185)),
    HomeAxisClue(label: '회복 패턴', value: 74, color: Color(0xFFC4B5FD)),
    HomeAxisClue(label: '선택 기준', value: 81, color: Color(0xFFF7C948)),
    HomeAxisClue(label: '몰입 방향', value: 76, color: Color(0xFF60A5FA)),
    HomeAxisClue(label: '갈등 반응', value: 59, color: Color(0xFFF87171)),
    HomeAxisClue(label: '표현 확장', value: 72, color: Color(0xFF8B5CF6)),
  ],
  journeyMetrics: [
    HomeJourneyMetric(label: '탐구 시작', value: '18일'),
    HomeJourneyMetric(label: '총 출석', value: '18일'),
    HomeJourneyMetric(label: '연속 출석', value: '5일'),
    HomeJourneyMetric(label: 'Diary', value: '12개'),
    HomeJourneyMetric(label: '연속 작성', value: '3일'),
  ],
  universeSummaryTitle: '',
  universeOneLiner: '차분한 전략가',
  universeSummaryBody:
      'User님은 조용히 생각을 정리하고, 중요한 선택 앞에서 기준을 세워가는 모습이 강하게 보입니다. 감정에 바로 반응하기보다 상황을 한 번 더 바라보고, 오래 가져갈 수 있는 방향을 찾는 편에 가까워요. 최근 기록에서는 주변의 흐름을 관찰하면서도 스스로 납득할 수 있는 기준을 만들려는 변화가 뚜렷합니다.',
  universeSummarySupport: '',
  recommendations: [
    HomeRecommendation(
      label: '취향 활동 추천',
      value: '산책과 사진',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF7DD3FC),
    ),
    HomeRecommendation(
      label: '비슷한 인물',
      value: '관찰형 리더',
      icon: Icons.local_florist_rounded,
      color: Color(0xFF6EE7B7),
    ),
    HomeRecommendation(
      label: '추천 관계',
      value: '행동형 조력자',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFC4B5FD),
    ),
  ],
  diaryPrompt: '오늘 있었던 장면과 나의 행동, 결정, 생각, 감정을 짧게 남겨보세요. 기록은 나를 이해하는 단서가 됩니다.',
  todayClue: '최근 기록에서 혼자 생각을 정리하는 시간이 회복의 중요한 신호로 나타났어요.',
  nextQuestion: '오늘 가장 오래 마음에 남은 장면은 어디에서 시작됐나요?',
  estimatedQuestionTime: '예상 3분',
  latestUpdateLabel: '방금 전 업데이트',
  activityMetrics: [
    HomeActivityMetric(
      label: '질문',
      value: '1개',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFC4B5FD),
    ),
    HomeActivityMetric(
      label: 'Diary',
      value: '1개',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF60A5FA),
    ),
    HomeActivityMetric(
      label: '인사이트',
      value: '3개',
      icon: Icons.lightbulb_rounded,
      color: Color(0xFFF7C948),
    ),
    HomeActivityMetric(
      label: '변화 요소',
      value: '2개',
      icon: Icons.map_outlined,
      color: Color(0xFF6EE7B7),
    ),
  ],
);
