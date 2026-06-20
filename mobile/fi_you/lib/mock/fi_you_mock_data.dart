import 'package:flutter/material.dart';

class DiaryEntry {
  const DiaryEntry({
    required this.id,
    required this.yearLabel,
    required this.dateLabel,
    required this.title,
    required this.preview,
    required this.starReward,
    this.people,
    this.editable = true,
    this.editWindowLabel = '내일 오전 9시까지 수정 가능',
  });

  final String id;
  final String yearLabel;
  final String dateLabel;
  final String title;
  final String preview;
  final int starReward;
  final String? people;
  final bool editable;
  final String editWindowLabel;

  DiaryEntry copyWith({
    String? id,
    String? yearLabel,
    String? dateLabel,
    String? title,
    String? preview,
    int? starReward,
    String? people,
    bool? editable,
    String? editWindowLabel,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      yearLabel: yearLabel ?? this.yearLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      title: title ?? this.title,
      preview: preview ?? this.preview,
      starReward: starReward ?? this.starReward,
      people: people ?? this.people,
      editable: editable ?? this.editable,
      editWindowLabel: editWindowLabel ?? this.editWindowLabel,
    );
  }
}

class AxisSummary {
  const AxisSummary({
    required this.label,
    required this.value,
    required this.copy,
    required this.icon,
    required this.color,
    required this.recordCount,
    required this.recentSource,
    required this.clue,
    this.locked = false,
  });

  final String label;
  final double value;
  final String copy;
  final IconData icon;
  final Color color;
  final int recordCount;
  final String recentSource;
  final String clue;
  final bool locked;
}

class SettingItem {
  const SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

enum QuestionAnswerType { choice, text, mixed }

class QuestionStep {
  const QuestionStep({
    required this.type,
    required this.title,
    required this.description,
    this.options = const [],
  });

  final QuestionAnswerType type;
  final String title;
  final String description;
  final List<String> options;
}

const questionFlowSteps = [
  QuestionStep(
    type: QuestionAnswerType.choice,
    title: '갈등 상황에서 나는 무엇을 먼저 떠올리나요?',
    description: '가장 가까운 반응 하나를 골라주세요.',
    options: ['내 감정', '상대의 입장', '상황의 맥락', '잠시 거리두기'],
  ),
  QuestionStep(
    type: QuestionAnswerType.text,
    title: '최근 비슷한 장면이 있었다면 어떤 순간이었나요?',
    description: '정답은 없어요. 떠오르는 장면을 짧게 적어주세요.',
  ),
  QuestionStep(
    type: QuestionAnswerType.mixed,
    title: '그때 나에게 가장 가까웠던 마음은 무엇인가요?',
    description: '선택 후 그렇게 느낀 이유를 적어주세요.',
    options: ['정리하고 싶었어요', '피하고 싶었어요', '확인하고 싶었어요', '표현하고 싶었어요'],
  ),
];

final initialDiaryEntries = [
  const DiaryEntry(
    id: 'd-001',
    yearLabel: '2026년',
    dateLabel: '6월 18일',
    title: '조용한 시간이 필요했던 날',
    preview:
        '퇴근 후 조용히 걷는 시간이 오래 필요했어요. 말보다 공기가 먼저 기억나는 날이었고, 내 속도를 조금 늦추고 싶다는 생각이 들었습니다.',
    starReward: 12,
    people: '혼자',
    editable: true,
  ),
  const DiaryEntry(
    id: 'd-002',
    yearLabel: '2026년',
    dateLabel: '6월 17일',
    title: '말보다 표정을 먼저 읽었던 시간',
    preview: '대화가 끝난 뒤에 마음이 남아 있어서 짧게 적었어요. 다음에는 내 반응을 조금 더 천천히 보고 싶습니다.',
    starReward: 12,
    people: '동료',
    editable: false,
    editWindowLabel: '수정 마감 · 기록으로 반영됨',
  ),
];

final axisSummaries = [
  const AxisSummary(
    label: '에너지 리듬',
    value: 0.64,
    copy: '하루 안에서 에너지가 차오르고 가라앉는 흐름입니다.',
    icon: Icons.waves_rounded,
    color: Color(0xFF8B5CF6),
    recordCount: 18,
    recentSource: '오늘 질문 응답',
    clue: '조용한 시간 다음에 움직임을 만드는 흐름이 반복돼요.',
  ),
  const AxisSummary(
    label: '감정 인식',
    value: 0.48,
    copy: '감정을 알아차리고 이름 붙이는 방식의 흐름입니다.',
    icon: Icons.hub_outlined,
    color: Color(0xFF7DD3FC),
    recordCount: 12,
    recentSource: '6월 18일 Diary',
    clue: '감정을 바로 판단하기보다 먼저 정리하려는 흐름이 보여요.',
  ),
  const AxisSummary(
    label: '가치 기준',
    value: 0.58,
    copy: '선택 앞에서 중요하게 여기는 기준의 흐름입니다.',
    icon: Icons.spa_outlined,
    color: Color(0xFF6EE7B7),
    recordCount: 9,
    recentSource: '최근 Diary 2개',
    clue: '속도보다 납득 가능한 이유를 기다리는 단서가 있어요.',
  ),
  const AxisSummary(
    label: '선택 방식',
    value: 0.42,
    copy: '결정을 정리하고 붙드는 방식의 흐름입니다.',
    icon: Icons.rule_rounded,
    color: Color(0xFFF7C948),
    recordCount: 7,
    recentSource: '선택형 질문',
    clue: '잠시 멈춘 뒤 기준을 확인하는 흐름일 수 있어요.',
  ),
  const AxisSummary(
    label: '관계 흐름',
    value: 0.36,
    copy: '사람과의 장면에서 반복되는 거리와 반응입니다.',
    icon: Icons.blur_circular_rounded,
    color: Color(0xFFC4B5FD),
    recordCount: 4,
    recentSource: '기록 부족',
    clue: '상대의 표정을 먼저 확인하는 단서가 있어요.',
  ),
  const AxisSummary(
    label: '긴장과 회복',
    value: 0.52,
    copy: '긴장이 생기고 다시 균형을 찾는 방식입니다.',
    icon: Icons.radar_rounded,
    color: Color(0xFF6EE7D8),
    recordCount: 6,
    recentSource: '서술형 응답',
    clue: '생각을 미리 정리할 때 긴장이 낮아지는 편이에요.',
  ),
  const AxisSummary(
    label: '성장 동기',
    value: 0.46,
    copy: '다시 움직이게 하는 작은 이유와 단서입니다.',
    icon: Icons.edit_note_rounded,
    color: Color(0xFF93C5FD),
    recordCount: 10,
    recentSource: '6월 17일 Diary',
    clue: '멈춤 직전에 다음 움직임을 찾는 모습이 보여요.',
  ),
  const AxisSummary(
    label: '삶의 방향',
    value: 0.30,
    copy: '앞으로 자주 만들고 싶은 흐름의 단서입니다.',
    icon: Icons.trending_up_rounded,
    color: Color(0xFFFBBF24),
    recordCount: 3,
    recentSource: '기록 부족',
    clue: '아직 고정된 해석이라기보다 단서가 더 필요해요.',
    locked: true,
  ),
];

class StorePackage {
  const StorePackage({
    required this.title,
    required this.stars,
    required this.price,
    required this.note,
  });

  final String title;
  final String stars;
  final String price;
  final String note;
}

const storePackages = [
  StorePackage(title: 'Small', stars: '30 Star', price: 'Google Play 연결 전', note: '자기탐구 1회에 적합해요.'),
  StorePackage(title: 'Plus', stars: '100 Star', price: 'Google Play 연결 전', note: '리포트와 확장 질문을 준비할 때 좋아요.'),
  StorePackage(title: 'Deep', stars: '300 Star', price: 'Google Play 연결 전', note: '여러 대화 콘텐츠를 여유 있게 사용할 수 있어요.'),
];

const starHistory = [
  'Diary 저장 보상 +12',
  '질문 응답 보상 +8',
  '상세 리포트 준비 중',
  'Star 구매 연결 대기',
];

final settingItems = [
  const SettingItem(title: '알림', subtitle: '질문과 Diary 리마인더', icon: Icons.notifications_none_rounded),
  const SettingItem(title: '프로필', subtitle: '이름과 기본 정보 관리', icon: Icons.person_outline_rounded),
  const SettingItem(title: '개인정보 / 데이터 삭제', subtitle: '기록과 U-Map 데이터 확인', icon: Icons.folder_open_rounded),
  const SettingItem(title: '이용약관 / 개인정보처리방침', subtitle: '서비스 이용 기준 확인', icon: Icons.privacy_tip_outlined),
  const SettingItem(title: 'AI 안내', subtitle: 'FI-YOU는 진단하거나 확정하지 않아요', icon: Icons.info_outline_rounded),
  const SettingItem(title: '로그아웃', subtitle: '현재 기기에서 세션 종료', icon: Icons.logout_rounded),
];
