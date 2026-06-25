import 'package:fi_you/core/user_level.dart';
import 'package:fi_you/mock/fi_you_mock_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LaunchStatus { checking, signedOut, onboardingRequired, ready, error }

class LaunchSnapshot {
  const LaunchSnapshot({required this.status, this.message});

  final LaunchStatus status;
  final String? message;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.onboardingComplete,
    required this.starBalance,
    required this.profileLine,
    this.levelStats = const UserLevelStats(),
  });

  final String name;
  final String email;
  final bool onboardingComplete;
  final int starBalance;
  final String profileLine;
  final UserLevelStats levelStats;

  int get level => UserLevel.fromStats(levelStats).level;

  String get levelDisplayName {
    return levelDisplayNameFor();
  }

  String levelDisplayNameFor({String languageCode = 'ko'}) {
    return UserLevel.displayName(
      userName: name,
      stats: levelStats,
      languageCode: languageCode,
    );
  }

  UserProfile copyWith({
    String? name,
    String? email,
    bool? onboardingComplete,
    int? starBalance,
    String? profileLine,
    UserLevelStats? levelStats,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      starBalance: starBalance ?? this.starBalance,
      profileLine: profileLine ?? this.profileLine,
      levelStats: levelStats ?? this.levelStats,
    );
  }
}

const journyReportStarCost = 1;
const relationMapStarCost = 1;
const uMapDetailReportStarCost = 1;

class StarSpendException implements Exception {
  const StarSpendException(this.code);

  final String code;

  bool get isInsufficientBalance => code == 'insufficient_star';

  @override
  String toString() => 'StarSpendException($code)';
}

class JournyReport {
  const JournyReport({
    required this.id,
    required this.title,
    required this.summary,
    required this.sourceWindowLabel,
    required this.sourceCounts,
    required this.timelineEvents,
    required this.patterns,
    required this.turningPoints,
    required this.nextSteps,
    required this.evidence,
    required this.createdAt,
    this.starCost = journyReportStarCost,
  });

  final String id;
  final String title;
  final String summary;
  final String sourceWindowLabel;
  final Map<String, int> sourceCounts;
  final List<JournyTimelineEvent> timelineEvents;
  final List<JournyInsightBlock> patterns;
  final List<JournyInsightBlock> turningPoints;
  final List<JournyInsightBlock> nextSteps;
  final List<JournyEvidenceItem> evidence;
  final DateTime createdAt;
  final int starCost;

  factory JournyReport.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    final id = _stringValue(map['id']).trim();
    final title = _explorationText(_stringValue(map['title'])).trim();
    final sourceWindowLabel = _explorationText(
      _stringValue(map['sourceWindowLabel']),
    ).trim();
    return JournyReport(
      id: id.isEmpty ? 'journy-${DateTime.now().microsecondsSinceEpoch}' : id,
      title: title.isEmpty ? 'Journy Report' : title,
      summary: _explorationText(_stringValue(map['summary'])),
      sourceWindowLabel: sourceWindowLabel.isEmpty
          ? '최근 기록 기반'
          : sourceWindowLabel,
      sourceCounts: _intMap(map['sourceCounts']),
      timelineEvents: _objectList(
        map['timelineEvents'],
      ).map(JournyTimelineEvent.fromJson).toList(),
      patterns: _objectList(
        map['patterns'],
      ).map(JournyInsightBlock.fromJson).toList(),
      turningPoints: _objectList(
        map['turningPoints'],
      ).map(JournyInsightBlock.fromJson).toList(),
      nextSteps: _objectList(
        map['nextSteps'],
      ).map(JournyInsightBlock.fromJson).toList(),
      evidence: _objectList(
        map['evidence'],
      ).map(JournyEvidenceItem.fromJson).toList(),
      createdAt:
          DateTime.tryParse(_stringValue(map['createdAt'])) ?? DateTime.now(),
      starCost: (map['starCost'] as num?)?.toInt() ?? journyReportStarCost,
    );
  }
}

class JournyTimelineEvent {
  const JournyTimelineEvent({
    required this.dateLabel,
    required this.title,
    required this.body,
  });

  final String dateLabel;
  final String title;
  final String body;

  factory JournyTimelineEvent.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return JournyTimelineEvent(
      dateLabel: _explorationText(_stringValue(map['dateLabel'])),
      title: _explorationText(_stringValue(map['title'])),
      body: _explorationText(_stringValue(map['body'])),
    );
  }
}

class JournyInsightBlock {
  const JournyInsightBlock({
    required this.title,
    required this.body,
    required this.confidenceLabel,
  });

  final String title;
  final String body;
  final String confidenceLabel;

  factory JournyInsightBlock.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return JournyInsightBlock(
      title: _explorationText(_stringValue(map['title'])),
      body: _explorationText(_stringValue(map['body'])),
      confidenceLabel: _explorationText(_stringValue(map['confidenceLabel'])),
    );
  }
}

class JournyEvidenceItem {
  const JournyEvidenceItem({
    required this.label,
    required this.body,
    required this.sourceType,
  });

  final String label;
  final String body;
  final String sourceType;

  factory JournyEvidenceItem.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return JournyEvidenceItem(
      label: _explorationText(_stringValue(map['label'])),
      body: _explorationText(_stringValue(map['body'])),
      sourceType: _explorationText(_stringValue(map['sourceType'])),
    );
  }
}

class UMapDetailReport {
  const UMapDetailReport({
    required this.id,
    required this.title,
    required this.coreSentence,
    required this.summary,
    required this.dataSufficiency,
    required this.sourceCounts,
    required this.keywords,
    required this.sections,
    required this.actionPlans,
    required this.recordingGuides,
    required this.evidence,
    required this.createdAt,
    this.starCost = uMapDetailReportStarCost,
  });

  final String id;
  final String title;
  final String coreSentence;
  final String summary;
  final UMapDataSufficiency dataSufficiency;
  final Map<String, int> sourceCounts;
  final List<String> keywords;
  final List<UMapReportSection> sections;
  final List<UMapActionPlan> actionPlans;
  final List<String> recordingGuides;
  final List<JournyEvidenceItem> evidence;
  final DateTime createdAt;
  final int starCost;

  factory UMapDetailReport.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    final id = _stringValue(map['id']).trim();
    final title = _explorationText(_stringValue(map['title'])).trim();
    return UMapDetailReport(
      id: id.isEmpty
          ? 'umap-report-${DateTime.now().microsecondsSinceEpoch}'
          : id,
      title: title.isEmpty ? 'U-Map 상세 리포트' : title,
      coreSentence: _explorationText(_stringValue(map['coreSentence'])),
      summary: _explorationText(_stringValue(map['summary'])),
      dataSufficiency: UMapDataSufficiency.fromJson(map['dataSufficiency']),
      sourceCounts: _intMap(map['sourceCounts']),
      keywords: _stringList(map['keywords']).map(_explorationText).toList(),
      sections: _objectList(
        map['sections'],
      ).map(UMapReportSection.fromJson).toList(),
      actionPlans: _objectList(
        map['actionPlans'],
      ).map(UMapActionPlan.fromJson).toList(),
      recordingGuides: _stringList(
        map['recordingGuides'],
      ).map(_explorationText).toList(),
      evidence: _objectList(
        map['evidence'],
      ).map(JournyEvidenceItem.fromJson).toList(),
      createdAt:
          DateTime.tryParse(_stringValue(map['createdAt'])) ?? DateTime.now(),
      starCost: (map['starCost'] as num?)?.toInt() ?? uMapDetailReportStarCost,
    );
  }
}

class UMapDataSufficiency {
  const UMapDataSufficiency({
    required this.score,
    required this.label,
    required this.items,
  });

  final int score;
  final String label;
  final List<UMapDataSufficiencyItem> items;

  factory UMapDataSufficiency.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return UMapDataSufficiency(
      score: (map['score'] as num?)?.toInt() ?? 0,
      label: _explorationText(_stringValue(map['label'])),
      items: _objectList(
        map['items'],
      ).map(UMapDataSufficiencyItem.fromJson).toList(),
    );
  }
}

class UMapDataSufficiencyItem {
  const UMapDataSufficiencyItem({
    required this.label,
    required this.value,
    required this.status,
  });

  final String label;
  final String value;
  final String status;

  factory UMapDataSufficiencyItem.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return UMapDataSufficiencyItem(
      label: _explorationText(_stringValue(map['label'])),
      value: _explorationText(_stringValue(map['value'])),
      status: _explorationText(_stringValue(map['status'])),
    );
  }
}

class UMapReportSection {
  const UMapReportSection({
    required this.type,
    required this.title,
    required this.body,
    required this.insights,
    required this.evidenceLabels,
  });

  final String type;
  final String title;
  final String body;
  final List<String> insights;
  final List<String> evidenceLabels;

  factory UMapReportSection.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return UMapReportSection(
      type: _stringValue(map['type']),
      title: _explorationText(_stringValue(map['title'])),
      body: _explorationText(_stringValue(map['body'])),
      insights: _stringList(map['insights']).map(_explorationText).toList(),
      evidenceLabels: _stringList(
        map['evidenceLabels'],
      ).map(_explorationText).toList(),
    );
  }
}

class UMapActionPlan {
  const UMapActionPlan({
    required this.title,
    required this.body,
    required this.horizon,
  });

  final String title;
  final String body;
  final String horizon;

  factory UMapActionPlan.fromJson(Object? data) {
    final map = _optionalMap(data) ?? const <String, dynamic>{};
    return UMapActionPlan(
      title: _explorationText(_stringValue(map['title'])),
      body: _explorationText(_stringValue(map['body'])),
      horizon: _explorationText(_stringValue(map['horizon'])),
    );
  }
}

UMapDetailReport buildMockUMapDetailReport({
  required DateTime now,
  required List<DiaryEntry> recentDiaries,
  required List<AxisSummary> axesForReport,
  String idPrefix = 'mock-umap-report',
}) {
  final recordCount = axesForReport.fold<int>(
    recentDiaries.length + 8,
    (total, axis) => total + axis.recordCount,
  );

  return UMapDetailReport(
    id: '$idPrefix-${now.microsecondsSinceEpoch}',
    title: 'U-Map 상세 리포트',
    coreSentence:
        '분석결과: 현재 기록은 조용한 몰입, 스스로 정한 기준, 독립적인 선택권이 있을 때 가장 안정적으로 힘이 나는 패턴을 보여줍니다.',
    summary:
        '이 리포트는 질문 응답, Diary, U-Map 축에서 반복된 단서를 묶어 만든 mock 분석결과입니다. 사람 자체를 고정해서 정의하지 않고, 현재 기록에서 충분히 반복된 선호, 적합 조건, 마찰 조건을 명확하게 제시합니다.',
    dataSufficiency: UMapDataSufficiency(
      score: 86,
      label: '명확한 결과 제시 가능',
      items: [
        UMapDataSufficiencyItem(
          label: '반복 단서',
          value: '$recordCount',
          status: '충분',
        ),
        const UMapDataSufficiencyItem(
          label: '해석 영역',
          value: '8개',
          status: '균형',
        ),
        UMapDataSufficiencyItem(
          label: '최근 기록',
          value: recentDiaries.isEmpty ? 'Mock' : recentDiaries.first.dateLabel,
          status: '반영',
        ),
      ],
    ),
    sourceCounts: {
      'nodes': axesForReport.isEmpty ? 28 : axesForReport.length * 6,
      'records': recordCount,
      'diary': recentDiaries.isEmpty ? 3 : recentDiaries.length,
    },
    keywords: const ['조용한 몰입', '독립 선택권', '높은 기준', '감정 정리 후 실행', '직접적인 기대치'],
    sections: const [
      UMapReportSection(
        type: 'clear_results',
        title: '명확한 분석결과',
        body:
            '현재 기록에서 가장 강한 결과는 선택 기준이 분명할수록 오래 집중하고, 기준이 흐려질수록 안정감이 빠르게 낮아진다는 점입니다.',
        insights: [
          '반복 단서는 조용한 환경, 높은 내부 기준, 선택권이 있는 구조로 모입니다.',
          '이 결과는 성격을 단정하는 말이 아니라, 현재 기록에서 반복 확인된 행동 조건입니다.',
        ],
        evidenceLabels: [
          'U-Map 28 nodes',
          'Diary 3 records',
          'Question 11 answers',
        ],
      ),
      UMapReportSection(
        type: 'preference_results',
        title: '좋아하는 것 / 싫어하는 것',
        body:
            '좋아하는 조건은 깊이 생각할 시간, 명확한 책임 범위, 방해가 적은 집중 환경입니다. 싫어하는 조건은 즉흥적인 방향 변경, 모호한 역할, 계속 바뀌는 우선순위입니다.',
        insights: [
          '선호: 자율성, 정리된 목표, 혼자 판단할 수 있는 여백.',
          '비선호: 즉흥적 변경, 애매한 책임, 감정적으로 압박하는 소통.',
        ],
        evidenceLabels: ['가치 기준', '선택 방식', '긴장과 회복'],
      ),
      UMapReportSection(
        type: 'interest_results',
        title: '관심이 모이는 영역',
        body:
            '관심은 사람 자체보다 현상이 왜 반복되는지, 선택이 어떤 기준에서 작동하는지, 복잡한 상황을 구조로 바꾸는 방식에 강하게 모입니다.',
        insights: [
          '관찰 기록, 패턴 찾기, 전략 정리에 자연스럽게 에너지가 붙습니다.',
          '단순 소비형 관심보다 흐름을 해석하고 체계화하는 관심이 더 강합니다.',
        ],
        evidenceLabels: ['Diary 표현', 'U-Map 연결 노드'],
      ),
      UMapReportSection(
        type: 'aptitude_work_fit',
        title: '적성 / 일하는 방식',
        body: '현재 기록 기준으로는 빠른 반응형 업무보다 깊이 읽고, 기준을 세우고, 결과물을 다듬는 일에 더 잘 맞습니다.',
        insights: [
          '잘 맞음: 리서치, 기획, 글쓰기, 제품 사고, 디자인 콘텐츠 구조화.',
          '덜 맞음: 권한 없는 조율, 기준 없이 속도만 요구되는 업무, 계속 끊기는 작업.',
        ],
        evidenceLabels: ['실행 리듬', '의사결정', '성장 동기'],
      ),
      UMapReportSection(
        type: 'career_type_fit',
        title: '어울리는 직업 부류',
        body:
            '직업명 하나를 정답처럼 제시하기보다 역할 부류로 보면, 세계관이 있는 개인 기여형 역할과 명확한 소유권이 있는 결과물 중심 역할이 강한 축입니다.',
        insights: [
          '추천 부류: 전략/리서치형, 제품 기획형, 브랜드 콘텐츠 설계형, 전문 개인기여자형.',
          '주의 부류: 상시 대면 영업, 위기 대응, 권한 없이 갈등만 조율하는 역할.',
        ],
        evidenceLabels: ['가치 기준', '선호 방향', '선택 방식'],
      ),
      UMapReportSection(
        type: 'relationship_fit',
        title: '잘 맞는 사람 / 마찰이 나는 사람',
        body:
            '잘 맞는 사람은 기대치를 직접 말하고, 혼자 회복할 시간을 존중하며, 감정의 압박보다 기준과 맥락으로 대화하는 사람입니다.',
        insights: [
          '잘 맞음: 명확한 소통, 약속 준수, 조용한 배려, 독립성 존중.',
          '마찰 가능: 돌려 말하기, 즉각 확인 요구, 감정 반응을 압박하는 관계.',
        ],
        evidenceLabels: ['관계 흐름', '감정 인식'],
      ),
      UMapReportSection(
        type: 'personality_temperament',
        title: '성향 / 기질',
        body:
            '현재 기질 패턴은 신중함, 기준 지향, 내적 정리 욕구, 조용한 회복 리듬이 강합니다. 감정은 바로 표출하기보다 먼저 해석하고 이름 붙이는 흐름을 보입니다.',
        insights: [
          '강점: 깊게 보고, 흐름을 연결하고, 완성도를 끌어올리는 힘.',
          '주의: 생각이 많아질수록 시작이 늦어지거나 자기 기준이 과도해질 수 있음.',
        ],
        evidenceLabels: ['감정 인식', '긴장과 회복', '자기 기준'],
      ),
      UMapReportSection(
        type: 'friction_conditions',
        title: '마찰 조건',
        body: '가장 큰 마찰은 기준은 높은데 권한은 낮고, 방해는 많고, 회복 시간은 부족한 환경에서 생깁니다.',
        insights: [
          '마찰 신호: 결정 피로, 과열 정리, 시작 지연, 조용한 거리두기.',
          '완충 조건: 책임 범위 명확화, 집중 시간 보호, 피드백 기준 문서화.',
        ],
        evidenceLabels: ['스트레스 반응', '선택 피로'],
      ),
      UMapReportSection(
        type: 'needs_more_records',
        title: '추가 기록이 필요한 부분',
        body:
            '아직 더 확인해야 할 부분은 독립성의 핵심이 자유 욕구인지, 책임 욕구인지, 창작 통제권인지입니다. 이 차이가 커리어 추천의 정확도를 더 높입니다.',
        insights: [
          '다음 질문은 자율성의 이유를 분리해서 확인해야 합니다.',
          '관계 영역은 잘 맞았던 실제 장면 기록이 쌓이면 더 명확해집니다.',
        ],
        evidenceLabels: ['다음 질문 필요', '관계 기록 부족'],
      ),
    ],
    actionPlans: const [
      UMapActionPlan(
        title: '이번 주 업무 기준 3개만 남기기',
        body: '해야 할 일을 늘리기보다 이번 주 결과물의 기준을 3개로 줄여보세요. 기준을 줄이면 실행 속도가 올라갑니다.',
        horizon: '이번 주',
      ),
      UMapActionPlan(
        title: '집중 시간 90분을 먼저 확보하기',
        body: '하루 중 가장 방해가 적은 시간을 깊은 작업에 먼저 배치하세요. 현재 패턴은 조용한 선집중에서 힘이 납니다.',
        horizon: '오늘',
      ),
      UMapActionPlan(
        title: '관계 대화에서 기대치를 문장으로 남기기',
        body: '불편한 관계일수록 내가 기대한 것, 실제 일어난 것, 다음에 필요한 것을 분리해서 기록하세요.',
        horizon: '다음 대화',
      ),
    ],
    recordingGuides: const [
      '오늘 가장 에너지가 났던 시간은 언제였고, 그때 어떤 권한이나 여백이 있었나요?',
      '최근 싫었던 상황은 사람 때문이었나요, 기준이 모호해서였나요, 회복 시간이 부족해서였나요?',
      '자율성이 필요했던 시간에서 내가 원한 것은 자유, 책임, 프라이버시, 창작 통제권 중 무엇에 가까웠나요?',
      '나와 잘 맞는 사람에게 반복해서 보이는 말투와 행동은 무엇인가요?',
    ],
    evidence: [
      ...recentDiaries.isNotEmpty
          ? recentDiaries
                .take(2)
                .map(
                  (entry) => JournyEvidenceItem(
                    label: entry.title,
                    body: entry.preview,
                    sourceType: 'Diary',
                  ),
                )
          : const [
              JournyEvidenceItem(
                label: '혼자 정리하고 실행한 시간',
                body: '방해가 적고 기준이 분명했던 시간에 집중이 오래 유지되었다는 기록입니다.',
                sourceType: 'Diary',
              ),
              JournyEvidenceItem(
                label: '기대치가 불분명했던 대화',
                body: '상대보다 기대치가 불분명했던 점에서 피로가 커졌다는 기록입니다.',
                sourceType: 'Diary',
              ),
            ],
      const JournyEvidenceItem(
        label: '선택 방식',
        body: '결정 전에 기준을 먼저 확인하려는 응답이 반복되었습니다.',
        sourceType: 'U-Map',
      ),
      const JournyEvidenceItem(
        label: '긴장과 회복',
        body: '압박 이후 조용한 회복 시간이 필요하다는 단서가 반복되었습니다.',
        sourceType: 'U-Map',
      ),
      const JournyEvidenceItem(
        label: '가치 기준',
        body: '속도보다 납득 가능한 이유와 소유권을 중시하는 응답이 연결되었습니다.',
        sourceType: 'Question',
      ),
    ],
    createdAt: now,
  );
}

class OnboardingQuestionOption {
  const OnboardingQuestionOption({
    required this.id,
    required this.label,
    required this.sequence,
  });

  final String id;
  final String label;
  final int sequence;
}

class OnboardingQuestion {
  const OnboardingQuestion({
    required this.id,
    required this.questionSet,
    required this.sequence,
    required this.prompt,
    required this.options,
    this.helperText,
    this.axisKeys = const [],
  });

  final String id;
  final String questionSet;
  final int sequence;
  final String prompt;
  final String? helperText;
  final List<String> axisKeys;
  final List<OnboardingQuestionOption> options;
}

class QuestionAnswerInput {
  const QuestionAnswerInput({
    required this.questionSet,
    required this.questionId,
    this.selectedOptionId,
    this.optionalText,
    this.skipped = false,
  });

  final String questionSet;
  final String questionId;
  final String? selectedOptionId;
  final String? optionalText;
  final bool skipped;
}

enum ExplorationCardType {
  binaryChoice,
  multipleChoice,
  prioritySelection,
  scenarioChoice,
}

class ExplorationCardOption {
  const ExplorationCardOption({required this.id, required this.label});

  final String id;
  final String label;
}

class ExplorationCard {
  const ExplorationCard({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    this.requiredSelections = 1,
  });

  final String id;
  final ExplorationCardType type;
  final String question;
  final List<ExplorationCardOption> options;
  final int requiredSelections;

  bool get allowsMultipleSelection =>
      type == ExplorationCardType.prioritySelection;
}

class ExplorationAnswerInput {
  const ExplorationAnswerInput({
    required this.cardId,
    required this.selectedOptionIds,
    this.userNote,
  });

  final String cardId;
  final List<String> selectedOptionIds;
  final String? userNote;
}

class InsightSupportingNode {
  const InsightSupportingNode({
    required this.nodeId,
    required this.nodeName,
    this.parentNodeId,
    this.parentNode,
  });

  final String nodeId;
  final String nodeName;
  final String? parentNodeId;
  final String? parentNode;

  factory InsightSupportingNode.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return const InsightSupportingNode(nodeId: '', nodeName: '');
    }
    return InsightSupportingNode(
      nodeId: _stringValue(map['node_id']),
      nodeName: _explorationText(_stringValue(map['node_name'])),
      parentNodeId: _nullableString(map['parent_node_id']),
      parentNode: _nullableString(
        _explorationText(_stringValue(map['parent_node'])),
      ),
    );
  }
}

class UserInsight {
  const UserInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.supportingNodes,
    required this.confidenceLevel,
    this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final List<InsightSupportingNode> supportingNodes;
  final String confidenceLevel;
  final DateTime? createdAt;

  bool get isEmpty => title.trim().isEmpty && description.trim().isEmpty;

  factory UserInsight.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return const UserInsight(
        id: '',
        type: '',
        title: '',
        description: '',
        supportingNodes: [],
        confidenceLevel: '',
      );
    }
    return UserInsight(
      id: _stringValue(map['insight_id'] ?? map['id']),
      type: _stringValue(map['insight_type']),
      title: _explorationText(_stringValue(map['title'])),
      description: _explorationText(_stringValue(map['description'])),
      supportingNodes: _objectList(map['supporting_nodes'])
          .map(InsightSupportingNode.fromJson)
          .where((node) => node.nodeName.trim().isNotEmpty)
          .toList(),
      confidenceLevel: _stringValue(map['confidence_level']),
      createdAt: DateTime.tryParse(_stringValue(map['created_at'])),
    );
  }
}

class InsightFeedResponse {
  const InsightFeedResponse({
    required this.feedTitle,
    required this.insights,
    this.sections = const [],
    this.errorMessage,
  });

  factory InsightFeedResponse.empty({String? errorMessage}) {
    return InsightFeedResponse(
      feedTitle: '최근 탐험',
      insights: const [],
      errorMessage: errorMessage,
    );
  }

  final String feedTitle;
  final List<UserInsight> insights;
  final List<String> sections;
  final String? errorMessage;

  bool get isEmpty => insights.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  factory InsightFeedResponse.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return InsightFeedResponse.empty(errorMessage: 'insight_feed_malformed');
    }
    final insights = _objectList(
      map['insights'],
    ).map(UserInsight.fromJson).where((insight) => !insight.isEmpty).toList();
    final feedTitle = _stringValue(map['feed_title']).trim();
    return InsightFeedResponse(
      feedTitle: feedTitle.isEmpty ? '최근 탐험' : feedTitle,
      sections: _stringList(map['sections']).map(_explorationText).toList(),
      insights: insights,
    );
  }
}

class StorySupportingInsight {
  const StorySupportingInsight({
    required this.insightId,
    required this.insightType,
    required this.title,
  });

  final String insightId;
  final String insightType;
  final String title;

  factory StorySupportingInsight.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return const StorySupportingInsight(
        insightId: '',
        insightType: '',
        title: '',
      );
    }
    return StorySupportingInsight(
      insightId: _stringValue(map['insight_id'] ?? map['id']),
      insightType: _stringValue(map['insight_type']),
      title: _explorationText(_stringValue(map['title'])),
    );
  }
}

class UserStory {
  const UserStory({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.supportingInsights,
    this.createdAt,
    this.updatedAt,
    this.active = true,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final List<StorySupportingInsight> supportingInsights;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool active;

  bool get isEmpty => title.trim().isEmpty && description.trim().isEmpty;

  factory UserStory.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return const UserStory(
        id: '',
        type: '',
        title: '',
        description: '',
        supportingInsights: [],
      );
    }
    return UserStory(
      id: _stringValue(map['story_id'] ?? map['id']),
      type: _stringValue(map['story_type']),
      title: _storyTitleFor(
        _stringValue(map['story_type']),
        _stringValue(map['title']),
      ),
      description: _explorationText(_stringValue(map['description'])),
      supportingInsights: _objectList(map['supporting_insights'])
          .map(StorySupportingInsight.fromJson)
          .where((insight) => insight.title.trim().isNotEmpty)
          .toList(),
      createdAt: DateTime.tryParse(_stringValue(map['created_at'])),
      updatedAt: DateTime.tryParse(_stringValue(map['updated_at'])),
      active: map['active'] is bool ? map['active'] as bool : true,
    );
  }
}

class StoryFeedResponse {
  const StoryFeedResponse({
    required this.feedTitle,
    required this.stories,
    this.sections = const [],
    this.errorMessage,
  });

  factory StoryFeedResponse.empty({String? errorMessage}) {
    return StoryFeedResponse(
      feedTitle: '나의 이야기',
      stories: const [],
      errorMessage: errorMessage,
    );
  }

  final String feedTitle;
  final List<UserStory> stories;
  final List<String> sections;
  final String? errorMessage;

  bool get isEmpty => stories.isEmpty;
  bool get hasError => errorMessage != null && errorMessage!.trim().isNotEmpty;

  factory StoryFeedResponse.fromJson(Object? data) {
    final map = _optionalMap(data);
    if (map == null) {
      return StoryFeedResponse.empty(errorMessage: 'story_feed_malformed');
    }
    final stories = _objectList(
      map['stories'],
    ).map(UserStory.fromJson).where((story) => !story.isEmpty).toList();
    final feedTitle = _stringValue(map['feed_title']).trim();
    return StoryFeedResponse(
      feedTitle: feedTitle.isEmpty ? '나의 이야기' : feedTitle,
      sections: _stringList(map['sections']).map(_storySectionLabel).toList(),
      stories: stories,
    );
  }
}

class ClueInsight {
  const ClueInsight({
    required this.id,
    required this.title,
    required this.body,
    required this.sourceCount,
    required this.diaryCount,
    required this.questionCount,
    required this.axes,
    required this.sources,
    this.hidden = false,
    this.disagreed = false,
    this.reported = false,
    this.userNote,
  });

  final String id;
  final String title;
  final String body;
  final int sourceCount;
  final int diaryCount;
  final int questionCount;
  final List<String> axes;
  final List<String> sources;
  final bool hidden;
  final bool disagreed;
  final bool reported;
  final String? userNote;

  ClueInsight copyWith({
    bool? hidden,
    bool? disagreed,
    bool? reported,
    String? userNote,
  }) {
    return ClueInsight(
      id: id,
      title: title,
      body: body,
      sourceCount: sourceCount,
      diaryCount: diaryCount,
      questionCount: questionCount,
      axes: axes,
      sources: sources,
      hidden: hidden ?? this.hidden,
      disagreed: disagreed ?? this.disagreed,
      reported: reported ?? this.reported,
      userNote: userNote ?? this.userNote,
    );
  }
}

abstract class FiYouRepository extends ChangeNotifier {
  UserProfile? get profile;
  List<DiaryEntry> get diaryEntries;
  List<AxisSummary> get axes;
  ClueInsight get todayInsight;
  bool get hasLowUMapData;
  bool get storeBillingConnected;

  Future<LaunchSnapshot> restoreLaunchState();
  Future<void> signIn();
  Future<UserProfile> saveProfileBasics({
    required String name,
    DateTime? birthday,
  });
  Future<List<OnboardingQuestion>> loadOnboardingQuestions({
    String questionSet = 'onboarding_required',
  });
  Future<void> saveOnboardingAnswer(QuestionAnswerInput input);
  Future<ExplorationCard> loadNextExplorationCard();
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input);
  Future<InsightFeedResponse> getInsightFeed();
  Future<StoryFeedResponse> getStoryFeed();
  Future<void> completeOnboarding({
    required String name,
    DateTime? birthday,
    String? focusArea,
  });
  Future<void> signOut();
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  });
  Future<DiaryEntry> updateDiary(DiaryEntry entry);
  Future<void> deleteDiary(String id);
  Future<UserProfile> spendStars({required String reason, required int amount});
  Future<JournyReport> generateJournyReport();
  Future<UMapDetailReport> generateUMapDetailReport();
  Future<ClueInsight> saveQuestionAnswers(List<String> answers);
  Future<void> updateInsightNote(String note);
  Future<void> hideInsight();
  Future<void> disagreeInsight();
  Future<void> reportInsight(String reason);
}

class MockFiYouRepository extends FiYouRepository {
  static const _signedInKey = 'fi_you.dev.signed_in';
  static const _onboardingCompleteKey = 'fi_you.dev.onboarding_complete';
  static const _nameKey = 'fi_you.dev.name';
  static const _emailKey = 'fi_you.dev.email';
  static const _starBalanceKey = 'fi_you.dev.star_balance';
  static const _questionCountKey = 'fi_you.dev.question_count';
  static const _diaryCountKey = 'fi_you.dev.diary_count';
  static const _attendanceDaysKey = 'fi_you.dev.attendance_days';
  static const _joinedDaysKey = 'fi_you.dev.joined_days';

  UserProfile? _profile;
  final List<DiaryEntry> _diaryEntries = List.of(initialDiaryEntries);
  ClueInsight _todayInsight = const ClueInsight(
    id: 'insight-today',
    title: '오늘 발견된 단서',
    body: '혼자 생각을 정리하는 시간과 회복을 필요로 하는 흐름이 보여요. 아직 확정된 해석은 아니에요.',
    sourceCount: 12,
    diaryCount: 2,
    questionCount: 3,
    axes: ['관계 흐름', '감정 인식'],
    sources: ['6월 18일 Diary', '오늘 질문 답변', '최근 감정 기록'],
  );

  @override
  UserProfile? get profile => _profile;

  @override
  List<DiaryEntry> get diaryEntries => List.unmodifiable(_diaryEntries);

  @override
  List<AxisSummary> get axes => List.unmodifiable(axisSummaries);

  @override
  ClueInsight get todayInsight => _todayInsight;

  @override
  bool get hasLowUMapData => _diaryEntries.length < 3;

  @override
  bool get storeBillingConnected => false;

  @override
  Future<LaunchSnapshot> restoreLaunchState() async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final prefs = await SharedPreferences.getInstance();
    final signedIn = prefs.getBool(_signedInKey) ?? true;
    if (!signedIn) {
      return const LaunchSnapshot(status: LaunchStatus.signedOut);
    }
    _profile = UserProfile(
      name: prefs.getString(_nameKey) ?? 'User',
      email: prefs.getString(_emailKey) ?? 'user@fi-you.local',
      onboardingComplete: prefs.getBool(_onboardingCompleteKey) ?? true,
      starBalance: prefs.getInt(_starBalanceKey) ?? 150,
      levelStats: UserLevelStats(
        questionCount: prefs.getInt(_questionCountKey) ?? 200,
        diaryCount: prefs.getInt(_diaryCountKey) ?? 15,
        attendanceDays: prefs.getInt(_attendanceDaysKey) ?? 14,
        joinedDays: prefs.getInt(_joinedDaysKey) ?? 21,
      ),
      profileLine: '관찰과 탐구를 좋아하는',
    );
    notifyListeners();
    return LaunchSnapshot(
      status: _profile!.onboardingComplete
          ? LaunchStatus.ready
          : LaunchStatus.onboardingRequired,
    );
  }

  @override
  Future<void> signIn() async {
    _profile = const UserProfile(
      name: 'User',
      email: 'user@fi-you.local',
      onboardingComplete: true,
      starBalance: 150,
      levelStats: UserLevelStats(
        questionCount: 200,
        diaryCount: 15,
        attendanceDays: 14,
        joinedDays: 21,
      ),
      profileLine: '관찰과 탐구를 좋아하는',
    );
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<void> completeOnboarding({
    required String name,
    DateTime? birthday,
    String? focusArea,
  }) async {
    await saveProfileBasics(name: name);
    _profile = _profile!.copyWith(onboardingComplete: true);
    await _persistProfile();
    notifyListeners();
  }

  @override
  Future<UserProfile> saveProfileBasics({
    required String name,
    DateTime? birthday,
  }) async {
    _profile =
        (_profile ??
                const UserProfile(
                  name: 'User',
                  email: 'user@fi-you.local',
                  onboardingComplete: false,
                  starBalance: 150,
                  levelStats: UserLevelStats(
                    questionCount: 200,
                    diaryCount: 15,
                    attendanceDays: 14,
                    joinedDays: 21,
                  ),
                  profileLine: '관찰과 탐구를 좋아하는',
                ))
            .copyWith(name: name.trim().isEmpty ? 'User' : name.trim());
    await _persistProfile();
    notifyListeners();
    return _profile!;
  }

  @override
  Future<List<OnboardingQuestion>> loadOnboardingQuestions({
    String questionSet = 'onboarding_required',
  }) async {
    return [
      for (var index = 0; index < questionFlowSteps.length; index++)
        OnboardingQuestion(
          id: 'mock-question-$index',
          questionSet: questionSet,
          sequence: index + 1,
          prompt: questionFlowSteps[index].title,
          helperText: questionFlowSteps[index].description,
          options: [
            for (
              var optionIndex = 0;
              optionIndex < questionFlowSteps[index].options.length;
              optionIndex++
            )
              OnboardingQuestionOption(
                id: 'mock-question-$index-option-$optionIndex',
                label: questionFlowSteps[index].options[optionIndex],
                sequence: optionIndex + 1,
              ),
          ],
        ),
    ];
  }

  @override
  Future<void> saveOnboardingAnswer(QuestionAnswerInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  int _mockExplorationIndex = 0;

  @override
  Future<ExplorationCard> loadNextExplorationCard() async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final cards = [
      const ExplorationCard(
        id: 'mock-exploration-1',
        type: ExplorationCardType.scenarioChoice,
        question: '요즘 마음이 자연스럽게 향하는 장면은 어디에 가까운가요?',
        options: [
          ExplorationCardOption(id: 'scene-alone', label: '혼자 조용히 정리하는 시간'),
          ExplorationCardOption(id: 'scene-people', label: '사람들과 나누며 선명해지는 시간'),
          ExplorationCardOption(id: 'scene-new', label: '새로운 것을 시도해보는 장면'),
          ExplorationCardOption(id: 'scene-steady', label: '익숙한 리듬을 지키는 하루'),
        ],
      ),
      const ExplorationCard(
        id: 'mock-exploration-2',
        type: ExplorationCardType.prioritySelection,
        question: '지금 더 살펴보고 싶은 흐름을 두 가지 골라본다면요?',
        requiredSelections: 2,
        options: [
          ExplorationCardOption(id: 'flow-choice', label: '내 선택의 기준'),
          ExplorationCardOption(id: 'flow-feeling', label: '반복되는 감정'),
          ExplorationCardOption(id: 'flow-relation', label: '관계 안의 거리감'),
          ExplorationCardOption(id: 'flow-action', label: '행동으로 옮기는 힘'),
        ],
      ),
      const ExplorationCard(
        id: 'mock-exploration-3',
        type: ExplorationCardType.binaryChoice,
        question: '요즘 나는 변화보다 안정 쪽에 조금 더 가까운가요?',
        options: [
          ExplorationCardOption(id: 'yes', label: '네, 안정에 더 끌려요'),
          ExplorationCardOption(id: 'no', label: '아니요, 변화가 더 가까워요'),
        ],
      ),
    ];
    final card = cards[_mockExplorationIndex % cards.length];
    _mockExplorationIndex += 1;
    return card;
  }

  @override
  Future<void> submitExplorationAnswer(ExplorationAnswerInput input) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    _todayInsight = _todayInsight.copyWith(
      userNote: '방금 남긴 탐험 응답을 U-Map 단서에 더해두었어요.',
    );
    notifyListeners();
  }

  @override
  Future<InsightFeedResponse> getInsightFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return InsightFeedResponse(
      feedTitle: '최근 탐험',
      sections: const ['반복해서 나타나는 흐름', '함께 보이는 연결', '조금씩 선명해지는 방향'],
      insights: const [
        UserInsight(
          id: 'mock-insight-1',
          type: 'emerging_pattern',
          title: '반복해서 나타나는 방향',
          description: '최근 탐험에서는 스스로 고르는 선택이 여러 장면에서 반복해서 나타납니다.',
          supportingNodes: [
            InsightSupportingNode(
              nodeId: 'mock-node-1',
              nodeName: '스스로 고르는 방향',
              parentNode: '탐험',
            ),
            InsightSupportingNode(
              nodeId: 'mock-node-2',
              nodeName: '선택의 리듬',
              parentNode: '결정',
            ),
          ],
          confidenceLevel: 'forming',
        ),
        UserInsight(
          id: 'mock-insight-2',
          type: 'internal_tension',
          title: '선명함과 움직일 여백',
          description: '어떤 답변은 선명한 선택으로 향하고, 어떤 답변은 가능성을 남겨두는 장면으로 이어집니다.',
          supportingNodes: [
            InsightSupportingNode(
              nodeId: 'mock-node-3',
              nodeName: '선명함',
              parentNode: '결정',
            ),
          ],
          confidenceLevel: 'early',
        ),
        UserInsight(
          id: 'mock-insight-3',
          type: 'exploration_gap',
          title: '아직 열려 있는 탐험 영역',
          description: '우주의 몇몇 영역은 아직 조용히 남아 있어, 앞으로의 카드에서 새롭게 이어질 여백이 있습니다.',
          supportingNodes: [],
          confidenceLevel: 'early',
        ),
      ],
    );
  }

  @override
  Future<StoryFeedResponse> getStoryFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return StoryFeedResponse(
      feedTitle: '나의 이야기',
      sections: const ['현재의 장', '선명해지는 방향', '아직 조용한 영역'],
      stories: const [
        UserStory(
          id: 'mock-story-1',
          type: 'current_chapter',
          title: '현재의 장',
          description: '최근 탐험은 여러 흐름을 하나의 조용한 장으로 모으고 있어요.',
          supportingInsights: [
            StorySupportingInsight(
              insightId: 'mock-insight-1',
              insightType: 'emerging_pattern',
              title: '반복해서 나타나는 방향',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-2',
              insightType: 'consistent_theme',
              title: '작은 선택들이 이어지는 장면',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-3',
              insightType: 'exploration_gap',
              title: '아직 열려 있는 탐험 영역',
            ),
          ],
        ),
        UserStory(
          id: 'mock-story-2',
          type: 'emerging_direction',
          title: '선명해지는 방향',
          description:
              'One thread appears to be moving from scattered observations toward a more connected path.',
          supportingInsights: [
            StorySupportingInsight(
              insightId: 'mock-insight-4',
              insightType: 'consistent_theme',
              title: 'Connections appearing across areas',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-5',
              insightType: 'emerging_pattern',
              title: 'A repeated direction in recent cards',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-6',
              insightType: 'change_over_time',
              title: 'A gentle shift in recent exploration',
            ),
          ],
        ),
        UserStory(
          id: 'mock-story-3',
          type: 'hidden_territory',
          title: 'A quiet area still waiting',
          description:
              'Some parts of the universe still feel spacious, as if they may become meaningful later.',
          supportingInsights: [
            StorySupportingInsight(
              insightId: 'mock-insight-7',
              insightType: 'exploration_gap',
              title: 'A quieter area remains open',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-8',
              insightType: 'exploration_gap',
              title: 'More cards may bring shape here',
            ),
            StorySupportingInsight(
              insightId: 'mock-insight-9',
              insightType: 'consistent_theme',
              title: 'A thread beginning near the edges',
            ),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> signOut() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, false);
    notifyListeners();
  }

  Future<void> _persistProfile() async {
    final profile = _profile;
    if (profile == null) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_signedInKey, true);
    await prefs.setBool(_onboardingCompleteKey, profile.onboardingComplete);
    await prefs.setString(_nameKey, profile.name);
    await prefs.setString(_emailKey, profile.email);
    await prefs.setInt(_starBalanceKey, profile.starBalance);
    await prefs.setInt(_questionCountKey, profile.levelStats.questionCount);
    await prefs.setInt(_diaryCountKey, profile.levelStats.diaryCount);
    await prefs.setInt(_attendanceDaysKey, profile.levelStats.attendanceDays);
    await prefs.setInt(_joinedDaysKey, profile.levelStats.joinedDays);
  }

  @override
  Future<DiaryEntry> saveDiary({
    required String title,
    required String body,
    String? people,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final now = DateTime.now();
    final entry = DiaryEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      yearLabel: '${now.year}년',
      dateLabel: '${now.month}월 ${now.day}일',
      title: title.trim().isEmpty ? '오늘의 Diary' : title.trim(),
      preview: body.trim(),
      starReward: 12,
      people: people?.trim().isNotEmpty == true ? people!.trim() : null,
      editable: true,
      editWindowLabel: '내일 오전 9시까지 수정 가능',
    );
    _diaryEntries.insert(0, entry);
    _todayInsight = _todayInsight.copyWith(
      userNote: '최근 Diary 기록을 U-Map 단서에 반영할 준비가 되었어요.',
    );
    notifyListeners();
    return entry;
  }

  @override
  Future<DiaryEntry> updateDiary(DiaryEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    final index = _diaryEntries.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      _diaryEntries.insert(0, entry);
    } else {
      _diaryEntries[index] = entry;
    }
    notifyListeners();
    return entry;
  }

  @override
  Future<void> deleteDiary(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 140));
    _diaryEntries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  @override
  Future<UserProfile> spendStars({
    required String reason,
    required int amount,
  }) async {
    if (amount <= 0) {
      throw const StarSpendException('amount_must_be_positive');
    }
    final profile = _profile;
    if (profile == null) {
      throw const StarSpendException('not_authenticated');
    }
    if (profile.starBalance < amount) {
      throw const StarSpendException('insufficient_star');
    }

    await Future<void>.delayed(const Duration(milliseconds: 160));
    final next = profile.copyWith(starBalance: profile.starBalance - amount);
    _profile = next;
    await _persistProfile();
    notifyListeners();
    return next;
  }

  @override
  Future<JournyReport> generateJournyReport() async {
    if (journyReportStarCost > 0) {
      await spendStars(reason: 'journy_report', amount: journyReportStarCost);
    }
    final now = DateTime.now();
    final recentDiaries = _diaryEntries.take(5).toList();
    final leadingAxes = axes.take(3).toList();
    return JournyReport(
      id: 'mock-journy-${now.microsecondsSinceEpoch}',
      title: '조심스럽게 방향을 다시 잡는 시기',
      summary:
          '최근 기록에서는 감정을 먼저 정리한 뒤 선택의 방향을 천천히 좁혀가려는 흐름이 보여요. 아직 결론보다 관찰이 더 중요한 챕터입니다.',
      sourceWindowLabel: '자기탐구의 기록',
      sourceCounts: {
        'diary': recentDiaries.length,
        'answers': 3,
        'uMapSignals': leadingAxes.length,
      },
      timelineEvents: [
        for (final entry in recentDiaries)
          JournyTimelineEvent(
            dateLabel: entry.dateLabel,
            title: entry.title,
            body: entry.preview.trim().isEmpty
                ? '기록의 세부 내용보다, 이 시점에 남겼다는 사실이 흐름의 근거가 됩니다.'
                : entry.preview.trim(),
          ),
        if (recentDiaries.isEmpty)
          const JournyTimelineEvent(
            dateLabel: 'Today',
            title: 'Journy를 시작할 준비',
            body: '아직 기록이 적어서 첫 리포트는 현재 U-Map 신호를 중심으로 구성했어요.',
          ),
      ],
      patterns: [
        for (final axis in leadingAxes)
          JournyInsightBlock(
            title: axis.label,
            body: axis.copy,
            confidenceLabel: axis.value >= 0.7 ? '반복 신호 강함' : '형성 중',
          ),
      ],
      turningPoints: const [
        JournyInsightBlock(
          title: '감정을 먼저 정리하려는 전환',
          body: '최근 흐름은 바로 행동하기보다 마음 안의 기준을 먼저 분리하려는 쪽으로 기울고 있어요.',
          confidenceLabel: '중간 확신',
        ),
      ],
      nextSteps: const [
        JournyInsightBlock(
          title: '다음 탐구 질문',
          body: '요즘 내가 미루고 있는 선택은 두려움 때문일까, 아니면 아직 더 알아야 할 정보가 있어서일까?',
          confidenceLabel: '추천',
        ),
        JournyInsightBlock(
          title: '다음 Diary 프롬프트',
          body: '오늘의 선택 중 하나를 골라, 내가 지키고 싶었던 기준을 한 문장으로 적어보세요.',
          confidenceLabel: '추천',
        ),
      ],
      evidence: [
        for (final entry in recentDiaries.take(3))
          JournyEvidenceItem(
            label: entry.title,
            body: entry.preview,
            sourceType: 'Diary',
          ),
        for (final axis in leadingAxes.take(2))
          JournyEvidenceItem(
            label: axis.label,
            body: axis.copy,
            sourceType: 'U-Map',
          ),
      ],
      createdAt: now,
    );
  }

  @override
  Future<UMapDetailReport> generateUMapDetailReport() async {
    if (uMapDetailReportStarCost > 0) {
      await spendStars(
        reason: 'u_map_detail_report',
        amount: uMapDetailReportStarCost,
      );
    }

    final now = DateTime.now();
    final recentDiaries = _diaryEntries.take(6).toList();
    final leadingAxes = axes.take(5).toList();
    final sourceCount = leadingAxes.fold<int>(
      recentDiaries.length,
      (total, axis) => total + axis.recordCount,
    );
    final sufficiencyScore = mathMinInt(
      96,
      42 + recentDiaries.length * 7 + leadingAxes.length * 5,
    );

    return UMapDetailReport(
      id: 'mock-umap-report-${now.microsecondsSinceEpoch}',
      title: 'U-Map 상세 리포트',
      coreSentence:
          '지금의 U-Map은 여러 생각을 흩어두기보다, 선택 기준과 감정 흐름을 다시 정리하려는 방향으로 모이고 있습니다.',
      summary:
          '최근 노드와 기록에서는 성장, 정리, 선택, 회복이 함께 나타납니다. 이 리포트는 사용자를 유형으로 단정하지 않고, U-Map에 남은 근거를 바탕으로 현재의 구조와 다음 행동을 정리합니다.',
      dataSufficiency: UMapDataSufficiency(
        score: sufficiencyScore,
        label: sufficiencyScore >= 75 ? '분석 충실도 높음' : '분석 충실도 보통',
        items: [
          UMapDataSufficiencyItem(
            label: 'U-Map 노드',
            value: '${leadingAxes.length * 6}',
            status: leadingAxes.length >= 4 ? '충분' : '보강 필요',
          ),
          UMapDataSufficiencyItem(
            label: '기록 근거',
            value: '$sourceCount',
            status: sourceCount >= 20 ? '충분' : '보통',
          ),
          UMapDataSufficiencyItem(
            label: '최근성',
            value: recentDiaries.isEmpty
                ? '기록 없음'
                : recentDiaries.first.dateLabel,
            status: recentDiaries.isEmpty ? '부족' : '반영됨',
          ),
        ],
      ),
      sourceCounts: {
        'nodes': leadingAxes.length * 6,
        'records': sourceCount,
        'diary': recentDiaries.length,
      },
      keywords: [
        for (final axis in leadingAxes.take(4)) axis.label,
        '선택 기준',
        '회복 루틴',
      ],
      sections: [
        UMapReportSection(
          type: 'structure',
          title: 'U-Map 구조 분석',
          body:
              '중심 노드는 단일한 결론보다 여러 판단 기준을 비교하는 방식으로 연결되어 있습니다. 특히 높은 점수의 축들은 현재 사용자가 무엇을 원하는지보다, 어떤 조건에서 움직일 수 있는지를 더 강하게 보여줍니다.',
          insights: [
            '강한 노드는 최근 관심사의 중심으로, 약한 노드는 아직 기록이 더 필요한 영역으로 해석됩니다.',
            '선택과 감정 관련 노드가 함께 움직일 때 실행 부담이 커질 수 있습니다.',
          ],
          evidenceLabels: leadingAxes
              .take(3)
              .map((axis) => axis.label)
              .toList(),
        ),
        UMapReportSection(
          type: 'themes',
          title: '주요 주제군',
          body:
              '반복 주제는 크게 자기이해, 선택 기준, 관계와 거리감, 회복 루틴으로 묶입니다. 이 주제들은 따로 존재하기보다 하나의 생활 리듬 안에서 서로 영향을 주고 있습니다.',
          insights: [
            '목표를 세우는 힘은 있지만, 목표를 일상 단위로 낮추는 장치가 더 필요합니다.',
            '관계 기록은 사건보다 해석의 비중이 높아질 때 피로감이 커질 수 있습니다.',
          ],
          evidenceLabels: recentDiaries
              .take(2)
              .map((entry) => entry.title)
              .toList(),
        ),
        const UMapReportSection(
          type: 'patterns',
          title: '반복 패턴과 내적 충돌',
          body:
              '기록상 새로운 시도에 대한 기대와 실패를 피하고 싶은 마음이 함께 나타납니다. 문제는 의지 부족이라기보다, 시도 직후의 불확실성을 버틸 수 있는 작은 절차가 아직 약한 쪽에 가깝습니다.',
          insights: [
            '결정을 미루는 순간에는 정보 부족보다 기준 과다가 더 크게 작동할 수 있습니다.',
            '감정이 정리된 뒤에는 행동 가능성이 높아지는 흐름이 보입니다.',
          ],
          evidenceLabels: ['최근 Diary', 'U-Map 상위 노드'],
        ),
        const UMapReportSection(
          type: 'strength',
          title: '강점과 자원',
          body:
              '사용자의 기록은 단순한 감정 배출보다 원인을 이해하려는 방향으로 전개됩니다. 복잡한 상황을 한 번에 결론내기보다 구조화하려는 힘이 강점으로 보입니다.',
          insights: ['자기성찰 능력과 연결 사고가 강합니다.', '기록을 통해 감정 부담을 낮추는 회복 자원이 있습니다.'],
          evidenceLabels: ['감정 기록', '연결 노드'],
        ),
        const UMapReportSection(
          type: 'risk',
          title: '주의 신호',
          body:
              '최근 흐름에서는 해야 할 일과 생각할 일이 늘어나는 반면, 회복을 위한 기록은 상대적으로 적게 보입니다. 목표를 더 추가하기보다 기존 목표를 유지할 수 있는 리듬을 먼저 만드는 편이 좋습니다.',
          insights: [
            '결정 피로가 쌓이면 선택을 더 미루는 루프가 생길 수 있습니다.',
            '자기비판이 강해질 때는 행동 단위를 더 작게 낮추는 것이 필요합니다.',
          ],
          evidenceLabels: ['목표 노드', '피로 관련 기록'],
        ),
      ],
      actionPlans: const [
        UMapActionPlan(
          title: '결정 노드 하나를 기준 3개로 줄이기',
          body: '가장 오래 남아 있는 고민 노드 하나를 고르고, 선택 기준을 세 개만 남겨보세요.',
          horizon: '오늘',
        ),
        UMapActionPlan(
          title: '목표 노드에 20분 행동 붙이기',
          body: '큰 목표를 유지하되, 다음 행동을 20분 안에 끝나는 단위로 다시 연결하세요.',
          horizon: '이번 주',
        ),
        UMapActionPlan(
          title: '관계 기록을 사건, 해석, 요청으로 분리하기',
          body: '관계 피로가 있는 기록은 사실과 해석을 나눠 쓰면 다음 선택이 선명해집니다.',
          horizon: '이번 달',
        ),
      ],
      recordingGuides: const [
        '오늘 내가 에너지를 가장 많이 쓴 곳은 어디였나?',
        '내가 미룬 것은 무엇이고, 그 뒤에는 어떤 감정이 있었나?',
        '지금 지키고 싶은 기준은 무엇이며, 내려놓아도 되는 기준은 무엇인가?',
        '반복해서 떠오른 사람이나 상황은 무엇인가?',
      ],
      evidence: [
        for (final entry in recentDiaries.take(3))
          JournyEvidenceItem(
            label: entry.title,
            body: entry.preview,
            sourceType: 'Diary',
          ),
        for (final axis in leadingAxes.take(3))
          JournyEvidenceItem(
            label: axis.label,
            body: axis.copy,
            sourceType: 'U-Map',
          ),
      ],
      createdAt: now,
    );
  }

  @override
  Future<ClueInsight> saveQuestionAnswers(List<String> answers) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    _todayInsight = ClueInsight(
      id: 'insight-${DateTime.now().microsecondsSinceEpoch}',
      title: '새로 발견한 단서',
      body: '갈등 장면에서 감정을 먼저 정리하려는 흐름을 기록했어요.',
      sourceCount: answers.length + _diaryEntries.length,
      diaryCount: _diaryEntries.length,
      questionCount: answers.length,
      axes: const ['관계 흐름', '감정 인식'],
      sources: [
        '오늘 질문 응답 ${answers.length}개',
        if (_diaryEntries.isNotEmpty) _diaryEntries.first.title,
      ],
    );
    notifyListeners();
    return _todayInsight;
  }

  @override
  Future<void> updateInsightNote(String note) async {
    _todayInsight = _todayInsight.copyWith(userNote: note.trim());
    notifyListeners();
  }

  @override
  Future<void> hideInsight() async {
    _todayInsight = _todayInsight.copyWith(hidden: true);
    notifyListeners();
  }

  @override
  Future<void> disagreeInsight() async {
    _todayInsight = _todayInsight.copyWith(disagreed: true);
    notifyListeners();
  }

  @override
  Future<void> reportInsight(String reason) async {
    _todayInsight = _todayInsight.copyWith(
      reported: true,
      userNote: reason.trim().isEmpty ? '문제 신고가 접수되었어요.' : reason.trim(),
    );
    notifyListeners();
  }
}

Map<String, dynamic>? _optionalMap(Object? data) {
  if (data is Map<String, dynamic>) {
    return data;
  }
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return null;
}

List<Object?> _objectList(Object? data) {
  if (data is List) {
    return data.cast<Object?>();
  }
  return const <Object?>[];
}

List<String> _stringList(Object? data) {
  if (data is List) {
    return data
        .map(_stringValue)
        .where((item) => item.trim().isNotEmpty)
        .toList();
  }
  return const <String>[];
}

Map<String, int> _intMap(Object? data) {
  final map = _optionalMap(data);
  if (map == null) {
    return const <String, int>{};
  }
  return {
    for (final entry in map.entries)
      entry.key: (entry.value as num?)?.toInt() ?? 0,
  };
}

String _stringValue(Object? value) => value == null ? '' : value.toString();

String _explorationText(String value) {
  return value
      .replaceAll('\uacb0\uacfc \ub9ac\ud3ec\ud2b8', '탐험 이야기')
      .replaceAll('\uc131\uaca9 \uc720\ud615', '성향의 모습')
      .replaceAll('\ubd84\uc11d', '살펴보기')
      .replaceAll('\ud3c9\uac00', '바라보기')
      .replaceAll('\uc9c4\ub2e8', '탐험')
      .replaceAll('\uc720\ud615', '모습')
      .replaceAll('\uc810\uc218', '흐름')
      .replaceAll('\ub4f1\uae09', '흐름')
      .replaceAll('\uc0c1\uc704', '큰')
      .replaceAll('\ud558\uc704', '작은')
      .replaceAll('\uac80\uc0ac', '탐험')
      .replaceAll('\ud504\ub85c\ud30c\uc77c', '이야기');
}

String _storyTitleFor(String type, String fallback) {
  switch (type) {
    case 'current_chapter':
      return '현재의 장';
    case 'emerging_direction':
      return '선명해지는 방향';
    case 'internal_tension':
      return '함께 나타나는 두 흐름';
    case 'hidden_territory':
      return '아직 조용한 영역';
    case 'change_over_time':
      return '변화의 흔적';
    default:
      return _explorationText(fallback);
  }
}

String _storySectionLabel(String value) {
  switch (value) {
    case 'Current Chapter':
      return '현재의 장';
    case 'Emerging Direction':
      return '선명해지는 방향';
    case 'Internal Tension':
    case 'Tensions':
      return '함께 나타나는 두 흐름';
    case 'Hidden Territory':
    case 'Unexplored Territory':
      return '아직 조용한 영역';
    case 'Change Over Time':
      return '변화의 흔적';
    default:
      return _explorationText(value);
  }
}

String? _nullableString(Object? value) {
  final text = _stringValue(value).trim();
  return text.isEmpty ? null : text;
}

int mathMinInt(int a, int b) => a < b ? a : b;

class FiYouRepositoryScope extends InheritedNotifier<FiYouRepository> {
  const FiYouRepositoryScope({
    required FiYouRepository repository,
    required super.child,
    super.key,
  }) : super(notifier: repository);

  static FiYouRepository of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<FiYouRepositoryScope>();
    assert(scope != null, 'FiYouRepositoryScope is missing.');
    return scope!.notifier!;
  }
}
