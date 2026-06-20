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

class HomeMockData {
  const HomeMockData({
    required this.userName,
    required this.starCount,
    required this.levelLabel,
    required this.uMapVisibility,
    required this.uMapLevelLabel,
    required this.uMapHelpText,
    required this.axisClues,
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
  final String diaryPrompt;
  final String todayClue;
  final String nextQuestion;
  final String estimatedQuestionTime;
  final List<HomeActivityMetric> activityMetrics;
  final String latestUpdateLabel;
}

const homeMockData = HomeMockData(
  userName: 'User',
  starCount: 124,
  levelLabel: 'Level 2',
  uMapVisibility: 0.34,
  uMapLevelLabel: '기록 기반 자기탐색 흐름',
  uMapHelpText: '질문과 Diary가 쌓이면 8개 축이 더 섬세하게 나타납니다.',
  axisClues: [
    HomeAxisClue(label: '에너지', value: 78, color: Color(0xFFA78BFA)),
    HomeAxisClue(label: '회복', value: 72, color: Color(0xFF7DD3FC)),
    HomeAxisClue(label: '관계', value: 65, color: Color(0xFFC4B5FD)),
    HomeAxisClue(label: '감정', value: 58, color: Color(0xFFFB7185)),
    HomeAxisClue(label: '선택', value: 80, color: Color(0xFFF7C948)),
    HomeAxisClue(label: '몰입', value: 70, color: Color(0xFF60A5FA)),
    HomeAxisClue(label: '갈등', value: 40, color: Color(0xFFF87171)),
    HomeAxisClue(label: '성장', value: 82, color: Color(0xFF8B5CF6)),
  ],
  diaryPrompt: '오늘 있었던 장면 하나를 짧게 남겨보세요. 작은 기록이 U-Map의 단서가 됩니다.',
  todayClue: '최근 기록에서 조용히 생각을 정리한 뒤 움직일 때 편안함이 커지는 흐름이 보입니다.',
  nextQuestion: '오늘 가장 오래 마음에 남은 장면은 어디에서 가까워졌나요?',
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
      value: '0개',
      icon: Icons.edit_note_rounded,
      color: Color(0xFF7DD3FC),
    ),
    HomeActivityMetric(
      label: '단서',
      value: '2개',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFF7C948),
    ),
    HomeActivityMetric(
      label: 'U-Map',
      value: '3개 변화',
      icon: Icons.radar_rounded,
      color: Color(0xFF6EE7B7),
    ),
  ],
);
