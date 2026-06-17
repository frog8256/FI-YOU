export type UMapAxisKey =
  | 'energyRhythm'
  | 'emotionAwareness'
  | 'valuesCompass'
  | 'decisionStyle'
  | 'relationshipPattern'
  | 'stressRecovery'
  | 'growthMotivation'
  | 'lifeDirection';

export type UMapAreaKey = UMapAxisKey;
export type QuestionStage = 'onboarding' | 'initial' | 'repeat';

export type SignalKey =
  | 'autonomy'
  | 'connection'
  | 'stability'
  | 'growth'
  | 'depth'
  | 'balance'
  | 'sensitivity'
  | 'recovery'
  | 'exploration'
  | 'achievement';

export type QuestionChoice = {
  id: string;
  label: string;
  signalHints: SignalKey[];
};

export type Question = {
  id: string;
  stage: QuestionStage;
  axis: UMapAxisKey;
  area: UMapAxisKey;
  prompt: string;
  choices: QuestionChoice[];
  optionalTextPrompt: string;
};

export type Answer = {
  id: string;
  questionId?: string;
  axis?: UMapAxisKey;
  area: UMapAxisKey;
  question: string;
  selectedChoiceId?: string;
  selectedChoiceLabel?: string;
  optionalText?: string;
  text: string;
  createdAt: string;
};

export type DiaryEntry = {
  id: string;
  body: string;
  moodLabel?: string;
  tags?: string[];
  createdAt: string;
};

export type UMapArea = {
  label: string;
  summary: string;
  signals: string[];
  clarity: number;
  flow: 'emerging' | 'forming' | 'clearer' | 'active';
  evidenceCount: number;
  nextDepth: string;
};

export type SignaturePayload = {
  name: string;
  summary: string;
  evidence: string[];
  confidenceNote: string;
};

export type NextQuestionPayload = {
  questionId: string;
  stage: QuestionStage;
  area: UMapAxisKey;
  axis: UMapAxisKey;
  areaLabel: string;
  question: string;
  choices: QuestionChoice[];
  optionalTextPrompt: string;
  whyThisQuestion: string;
};

export type AnalysisResult = {
  signature: SignaturePayload;
  uMap: Record<UMapAxisKey, UMapArea>;
  uMapClarity: {
    overallScore: number;
    clearAreas: string[];
    unclearAreas: string[];
    nextQuestionFocus: string[];
  };
  nextQuestion: NextQuestionPayload;
  detailAnalysis: Record<
    'selfCare' | 'workStyle' | 'relationshipCue' | 'growthDirection' | 'watchPoints',
    {
      title: string;
      summary: string;
      suggestions: string[];
      basis: string[];
    }
  >;
};

export type SafetyFinding = {
  ruleId: string;
  matched: string;
  replacement: string;
};

export type RelationInsightPayload = {
  relationId?: string;
  displayLabel?: string;
  summary: string;
  myExperienceFlow: string;
  comfortSignals: string[];
  tensionSignals: string[];
  nextReflection: string;
  boundaryNote: string;
  safetyNote: string;
  evidence: string[];
};

export type ReportTier = 'free' | 'paid';

export type ReportOutputPayload = {
  reportId: string;
  tier: ReportTier;
  title: string;
  summary: string;
  sections: Array<{
    id: string;
    title: string;
    body: string;
    basis: string[];
  }>;
  sourceSummary: {
    answerCount: number;
    diaryCount: number;
    clearAreas: string[];
    unclearAreas: string[];
  };
  refreshPolicy: string;
  paymentToneNote: string;
};

export const areaLabels: Record<UMapAxisKey, string> = {
  energyRhythm: '에너지 리듬',
  emotionAwareness: '감정 인식',
  valuesCompass: '가치 기준',
  decisionStyle: '선택 방식',
  relationshipPattern: '관계 흐름',
  stressRecovery: '긴장과 회복',
  growthMotivation: '성장 동기',
  lifeDirection: '삶의 방향'
};

export const insufficientDataCopy = {
  noRecords: '아직 흐름이 선명하지 않아요. 질문이나 Diary 기록이 쌓이면 U-Map이 더 뚜렷해질 수 있어요.',
  fewRecords: '현재 기록만으로는 조심스럽게 볼 수 있는 단서가 많지 않아요. 더 답해 볼수록 흐름이 자연스럽게 선명해져요.',
  relation: '아직 이 관계 안에서 내가 경험하는 흐름이 충분히 쌓이지 않았어요. 편안했던 순간이나 거리감이 필요했던 장면을 천천히 남겨 볼 수 있어요.',
  report: '아직 리포트를 깊게 정리하기에는 기록이 많지 않아요. 지금은 가벼운 요약으로 보고, 기록이 쌓이면 확장 리포트를 열어 보세요.'
};

export const forbiddenExpressionRules = [
  {
    id: 'fixed-type',
    pattern: /당신은\s?.*(형|유형|타입)입니다/g,
    replacement: '현재까지의 기록을 바탕으로 보면, 이런 흐름이 조금씩 보여요.'
  },
  {
    id: 'fixed-person',
    pattern: /당신은\s?이런 사람입니다/g,
    replacement: '현재 기록에서는 이런 경향이 일부 보여요.'
  },
  {
    id: 'accuracy',
    pattern: /정확도|분석 정확도/g,
    replacement: 'U-Map 선명도 또는 현재 기록 기반 흐름'
  },
  {
    id: 'diagnosis',
    pattern: /진단|치료|상담 결과|정신질환|우울증|불안장애|장애/g,
    replacement: '자기이해를 위한 기록 기반 참고 표현'
  },
  {
    id: 'destiny-relation',
    pattern: /천생연분|운명|궁합이 좋|궁합이 나쁘|반드시 헤어|반드시 만/g,
    replacement: '이 관계 안에서 내가 경험하는 흐름'
  },
  {
    id: 'career-certainty',
    pattern: /이 직업이 맞|반드시 성공|실패할 가능성이 높/g,
    replacement: '이런 환경에서 강점이 살아날 가능성이 있어요.'
  }
] as const;

export const axisDefinitions: Record<UMapAxisKey, string> = {
  energyRhythm: '에너지가 차오르고 소모되는 방식, 혼자/함께/루틴/변화에서 느끼는 리듬',
  emotionAwareness: '감정을 알아차리고 이름 붙이며 다루는 방식',
  valuesCompass: '선택의 기준이 되는 가치, 포기하기 어려운 태도와 우선순위',
  decisionStyle: '결정할 때 정보를 모으고 확신을 얻는 방식',
  relationshipPattern: '관계 안에서 편안함, 거리감, 연결감을 경험하는 흐름',
  stressRecovery: '긴장 신호를 알아차리고 회복을 시도하는 방식',
  growthMotivation: '계속 움직이게 만드는 동기와 성취의 의미',
  lifeDirection: '앞으로 더 자주 만들고 싶은 삶의 감각과 방향'
};

const areaOrder = Object.keys(areaLabels) as UMapAxisKey[];

export const questionCatalog: Question[] = [
  {
    id: 'onboarding-001',
    stage: 'onboarding',
    axis: 'energyRhythm',
    area: 'energyRhythm',
    prompt: 'FI-YOU를 처음 시작하는 지금, 나를 알아가는 방식으로 가장 편하게 느껴지는 것은 무엇인가요?',
    choices: [
      { id: 'short', label: '짧은 질문에 가볍게 답하기', signalHints: ['recovery', 'stability'] },
      { id: 'write', label: '생각을 조금 적어 보며 정리하기', signalHints: ['depth'] },
      { id: 'pattern', label: '반복되는 흐름을 차분히 보기', signalHints: ['stability', 'depth'] },
      { id: 'explore', label: '새로운 관점으로 나를 탐색하기', signalHints: ['exploration', 'growth'] }
    ],
    optionalTextPrompt: '처음 기대하는 느낌이 있다면 짧게 적어도 좋아요.'
  },
  {
    id: 'onboarding-002',
    stage: 'onboarding',
    axis: 'valuesCompass',
    area: 'valuesCompass',
    prompt: '최근의 나를 돌아볼 때, 지금 가장 놓치고 싶지 않은 감각은 무엇인가요?',
    choices: [
      { id: 'calm', label: '차분함', signalHints: ['recovery', 'stability'] },
      { id: 'honest', label: '솔직함', signalHints: ['depth', 'autonomy'] },
      { id: 'connection', label: '연결감', signalHints: ['connection'] },
      { id: 'progress', label: '조금씩 나아지는 느낌', signalHints: ['growth', 'achievement'] }
    ],
    optionalTextPrompt: '왜 그 감각이 떠올랐는지 한 문장만 더해도 좋아요.'
  },
  {
    id: 'onboarding-003',
    stage: 'onboarding',
    axis: 'relationshipPattern',
    area: 'relationshipPattern',
    prompt: '관계나 일상 안에서 요즘 나에게 가장 필요한 여백은 어디에 가까운가요?',
    choices: [
      { id: 'alone', label: '혼자 정리할 시간', signalHints: ['autonomy', 'recovery'] },
      { id: 'talk', label: '편하게 말할 수 있는 대화', signalHints: ['connection', 'sensitivity'] },
      { id: 'pace', label: '내 속도를 지킬 수 있는 공간', signalHints: ['autonomy', 'stability'] },
      { id: 'change', label: '익숙함에서 벗어나는 작은 변화', signalHints: ['exploration', 'growth'] }
    ],
    optionalTextPrompt: '떠오르는 장면이 있다면 내 경험 중심으로 적어 주세요.'
  },
  {
    id: 'onboarding-004',
    stage: 'onboarding',
    axis: 'lifeDirection',
    area: 'lifeDirection',
    prompt: '앞으로 FI-YOU가 더 자주 비춰 줬으면 하는 내 모습은 무엇인가요?',
    choices: [
      { id: 'emotion', label: '내 감정의 흐름', signalHints: ['sensitivity', 'depth'] },
      { id: 'choice', label: '내 선택의 기준', signalHints: ['autonomy', 'depth'] },
      { id: 'relation', label: '관계 안에서의 나', signalHints: ['connection', 'balance'] },
      { id: 'growth', label: '조금씩 달라지는 나', signalHints: ['growth', 'achievement'] }
    ],
    optionalTextPrompt: '특히 궁금한 영역이 있다면 적어 주세요.'
  },
  {
    id: 'energy-001',
    stage: 'initial',
    axis: 'energyRhythm',
    area: 'energyRhythm',
    prompt: '하루가 끝났을 때, 에너지가 조금 회복됐다고 느끼는 순간은 어디에 가까운가요?',
    choices: [
      { id: 'quiet', label: '혼자 조용히 정리하는 시간', signalHints: ['recovery', 'depth'] },
      { id: 'talk', label: '누군가와 편하게 나눈 대화', signalHints: ['connection', 'recovery'] },
      { id: 'routine', label: '익숙한 루틴을 지킨 느낌', signalHints: ['stability'] },
      { id: 'new', label: '새로운 자극이나 변화', signalHints: ['exploration'] }
    ],
    optionalTextPrompt: '떠오르는 장면이 있다면 짧게 적어도 좋아요.'
  },
  {
    id: 'energy-002',
    stage: 'initial',
    axis: 'energyRhythm',
    area: 'energyRhythm',
    prompt: '요즘 나의 리듬을 가장 자주 흐트러뜨리는 순간은 무엇에 가까운가요?',
    choices: [
      { id: 'too-fast', label: '속도를 맞추기 어려울 때', signalHints: ['stability', 'recovery'] },
      { id: 'too-many', label: '동시에 신경 쓸 일이 많을 때', signalHints: ['balance', 'sensitivity'] },
      { id: 'no-space', label: '혼자 정리할 시간이 없을 때', signalHints: ['autonomy', 'recovery'] },
      { id: 'same-loop', label: '반복되는 하루가 답답할 때', signalHints: ['exploration'] }
    ],
    optionalTextPrompt: '최근 그런 순간이 있었다면 가볍게 적어 주세요.'
  },
  {
    id: 'emotion-001',
    stage: 'initial',
    axis: 'emotionAwareness',
    area: 'emotionAwareness',
    prompt: '요즘 마음에 오래 남는 감정을 알아차릴 때, 보통 어떤 방식이 먼저 오나요?',
    choices: [
      { id: 'body', label: '몸의 긴장이나 피로로 먼저 느껴요', signalHints: ['sensitivity', 'recovery'] },
      { id: 'thought', label: '생각이 많아지면서 알아차려요', signalHints: ['depth'] },
      { id: 'words', label: '말하거나 기록하면서 분명해져요', signalHints: ['connection', 'depth'] },
      { id: 'later', label: '시간이 지난 뒤에야 알게 돼요', signalHints: ['sensitivity'] }
    ],
    optionalTextPrompt: '최근에 그런 감정을 느낀 상황이 있다면 적어도 좋아요.'
  },
  {
    id: 'emotion-002',
    stage: 'initial',
    axis: 'emotionAwareness',
    area: 'emotionAwareness',
    prompt: '감정이 커질 때, 나에게 가장 도움이 되는 반응은 무엇인가요?',
    choices: [
      { id: 'name', label: '감정에 이름을 붙여 보기', signalHints: ['depth', 'sensitivity'] },
      { id: 'pause', label: '잠시 멈추고 숨 고르기', signalHints: ['recovery'] },
      { id: 'share', label: '믿는 사람에게 말하기', signalHints: ['connection'] },
      { id: 'move', label: '몸을 움직이며 환기하기', signalHints: ['recovery', 'exploration'] }
    ],
    optionalTextPrompt: '나에게 잘 맞았던 방식이 있다면 적어 주세요.'
  },
  {
    id: 'values-001',
    stage: 'initial',
    axis: 'valuesCompass',
    area: 'valuesCompass',
    prompt: '최근 선택 하나를 떠올렸을 때, 끝까지 지키고 싶었던 기준은 무엇에 가까웠나요?',
    choices: [
      { id: 'honesty', label: '솔직함과 납득 가능함', signalHints: ['depth', 'autonomy'] },
      { id: 'care', label: '상대에 대한 배려', signalHints: ['connection', 'balance'] },
      { id: 'quality', label: '완성도와 책임감', signalHints: ['achievement', 'stability'] },
      { id: 'freedom', label: '내가 선택했다는 감각', signalHints: ['autonomy', 'exploration'] }
    ],
    optionalTextPrompt: '그 기준이 중요했던 이유가 있다면 한 문장만 더해 주세요.'
  },
  {
    id: 'values-002',
    stage: 'initial',
    axis: 'valuesCompass',
    area: 'valuesCompass',
    prompt: '누군가에게 설명하지 않아도 내 안에서 중요하게 남는 기준은 무엇인가요?',
    choices: [
      { id: 'fair', label: '공정함', signalHints: ['balance', 'stability'] },
      { id: 'warm', label: '다정함', signalHints: ['connection', 'sensitivity'] },
      { id: 'growth', label: '성장 가능성', signalHints: ['growth', 'exploration'] },
      { id: 'truth', label: '진심과 일관성', signalHints: ['depth', 'autonomy'] }
    ],
    optionalTextPrompt: '이 기준이 드러났던 최근 장면이 있다면 적어 주세요.'
  },
  {
    id: 'decision-001',
    stage: 'initial',
    axis: 'decisionStyle',
    area: 'decisionStyle',
    prompt: '중요한 결정을 할 때, “이제 정리됐다”는 느낌은 언제 생기나요?',
    choices: [
      { id: 'enough-info', label: '필요한 정보를 충분히 모았을 때', signalHints: ['stability', 'depth'] },
      { id: 'inner-yes', label: '마음 안에서 납득이 됐을 때', signalHints: ['autonomy', 'sensitivity'] },
      { id: 'talked-through', label: '믿는 사람과 이야기해 봤을 때', signalHints: ['connection', 'balance'] },
      { id: 'small-test', label: '작게 시도해 보고 감이 왔을 때', signalHints: ['growth', 'exploration'] }
    ],
    optionalTextPrompt: '최근 결정에서 이 기준이 어떻게 작동했는지 적어도 좋아요.'
  },
  {
    id: 'decision-002',
    stage: 'initial',
    axis: 'decisionStyle',
    area: 'decisionStyle',
    prompt: '선택지가 여러 개일 때, 가장 먼저 확인하고 싶은 것은 무엇인가요?',
    choices: [
      { id: 'risk', label: '무엇이 부담이 될 수 있는지', signalHints: ['stability', 'sensitivity'] },
      { id: 'meaning', label: '내게 어떤 의미가 있는지', signalHints: ['depth', 'autonomy'] },
      { id: 'people', label: '주변 사람에게 어떤 영향이 있는지', signalHints: ['connection', 'balance'] },
      { id: 'possibility', label: '어떤 가능성이 열리는지', signalHints: ['exploration', 'growth'] }
    ],
    optionalTextPrompt: '최근 이런 선택을 한 적이 있다면 적어 주세요.'
  },
  {
    id: 'relation-001',
    stage: 'initial',
    axis: 'relationshipPattern',
    area: 'relationshipPattern',
    prompt: '관계 안에서 편안함을 느끼는 순간은 무엇에 가장 가까운가요?',
    choices: [
      { id: 'accepted', label: '내 속도를 존중받을 때', signalHints: ['autonomy', 'connection'] },
      { id: 'honest', label: '솔직히 말해도 괜찮을 때', signalHints: ['connection', 'sensitivity'] },
      { id: 'balanced', label: '주고받는 균형이 맞을 때', signalHints: ['balance'] },
      { id: 'space', label: '가까워도 여백이 있을 때', signalHints: ['autonomy', 'recovery'] }
    ],
    optionalTextPrompt: '떠오르는 관계 장면이 있다면 상대를 평가하지 않고 내 경험 중심으로 적어 주세요.'
  },
  {
    id: 'relation-002',
    stage: 'initial',
    axis: 'relationshipPattern',
    area: 'relationshipPattern',
    prompt: '관계에서 거리를 조금 조절하고 싶어지는 순간은 보통 언제인가요?',
    choices: [
      { id: 'too-close', label: '속도가 너무 빠르게 느껴질 때', signalHints: ['autonomy', 'sensitivity'] },
      { id: 'unclear', label: '말의 의미가 불분명할 때', signalHints: ['depth', 'connection'] },
      { id: 'unbalanced', label: '주고받음이 맞지 않는다고 느낄 때', signalHints: ['balance'] },
      { id: 'tired', label: '내 에너지가 이미 많이 줄어 있을 때', signalHints: ['recovery', 'sensitivity'] }
    ],
    optionalTextPrompt: '상대를 단정하지 않고 내 느낌 중심으로 적어 주세요.'
  },
  {
    id: 'stress-001',
    stage: 'initial',
    axis: 'stressRecovery',
    area: 'stressRecovery',
    prompt: '부담이 커질 때, 실제로 조금 도움이 되는 회복 방식은 무엇인가요?',
    choices: [
      { id: 'pause', label: '잠시 멈추고 혼자 있기', signalHints: ['recovery', 'autonomy'] },
      { id: 'organize', label: '해야 할 일을 작게 정리하기', signalHints: ['stability', 'balance'] },
      { id: 'share', label: '누군가에게 상황을 말하기', signalHints: ['connection', 'recovery'] },
      { id: 'move', label: '걷기, 움직임, 장소 바꾸기', signalHints: ['exploration', 'recovery'] }
    ],
    optionalTextPrompt: '요즘 가장 잘 맞았던 회복 방식을 적어도 좋아요.'
  },
  {
    id: 'stress-002',
    stage: 'initial',
    axis: 'stressRecovery',
    area: 'stressRecovery',
    prompt: '긴장이 쌓이고 있다는 신호를 가장 먼저 알아차리는 곳은 어디인가요?',
    choices: [
      { id: 'body', label: '몸의 피로감이나 뻣뻣함', signalHints: ['sensitivity', 'recovery'] },
      { id: 'mind', label: '반복되는 생각', signalHints: ['depth', 'sensitivity'] },
      { id: 'pace', label: '일의 속도나 집중력 변화', signalHints: ['achievement', 'stability'] },
      { id: 'relation', label: '사람을 대하는 여유 변화', signalHints: ['connection', 'balance'] }
    ],
    optionalTextPrompt: '최근 알아차린 신호가 있다면 적어 주세요.'
  },
  {
    id: 'growth-001',
    stage: 'initial',
    axis: 'growthMotivation',
    area: 'growthMotivation',
    prompt: '무언가를 계속 해내고 싶어지는 힘은 보통 어디에서 오나요?',
    choices: [
      { id: 'meaning', label: '이 일의 의미가 느껴질 때', signalHints: ['depth', 'growth'] },
      { id: 'progress', label: '조금씩 나아지는 게 보일 때', signalHints: ['growth', 'achievement'] },
      { id: 'promise', label: '누군가와의 약속이나 책임이 있을 때', signalHints: ['connection', 'stability'] },
      { id: 'choice', label: '내가 선택한 일이라는 감각이 있을 때', signalHints: ['autonomy', 'achievement'] }
    ],
    optionalTextPrompt: '최근 오래 지속한 일이 있다면 무엇이 힘이 됐는지 적어 주세요.'
  },
  {
    id: 'growth-002',
    stage: 'initial',
    axis: 'growthMotivation',
    area: 'growthMotivation',
    prompt: '작지만 “나아졌다”고 느끼게 하는 변화는 어떤 쪽에 가까운가요?',
    choices: [
      { id: 'skill', label: '할 수 있는 일이 늘어날 때', signalHints: ['growth', 'achievement'] },
      { id: 'self-trust', label: '나를 조금 더 믿게 될 때', signalHints: ['autonomy', 'stability'] },
      { id: 'relation', label: '관계에서 더 편하게 표현할 때', signalHints: ['connection', 'sensitivity'] },
      { id: 'meaning', label: '내가 왜 하는지 더 분명해질 때', signalHints: ['depth'] }
    ],
    optionalTextPrompt: '최근 작게 나아졌다고 느낀 순간이 있다면 적어 주세요.'
  },
  {
    id: 'direction-001',
    stage: 'initial',
    axis: 'lifeDirection',
    area: 'lifeDirection',
    prompt: '앞으로의 삶에서 조금 더 자주 만들고 싶은 감각은 무엇인가요?',
    choices: [
      { id: 'calm', label: '차분함과 안정감', signalHints: ['stability', 'recovery'] },
      { id: 'connection', label: '좋은 사람들과의 연결감', signalHints: ['connection'] },
      { id: 'expansion', label: '넓어지고 탐색하는 감각', signalHints: ['exploration', 'growth'] },
      { id: 'ownership', label: '내 삶을 직접 고르는 감각', signalHints: ['autonomy'] }
    ],
    optionalTextPrompt: '그 감각이 필요한 이유가 있다면 짧게 적어도 좋아요.'
  },
  {
    id: 'direction-002',
    stage: 'initial',
    axis: 'lifeDirection',
    area: 'lifeDirection',
    prompt: '지금 삶의 방향을 아주 조금 조정한다면, 가장 먼저 달라졌으면 하는 것은 무엇인가요?',
    choices: [
      { id: 'time', label: '시간을 쓰는 방식', signalHints: ['stability', 'autonomy'] },
      { id: 'relation', label: '사람들과 연결되는 방식', signalHints: ['connection', 'balance'] },
      { id: 'work', label: '일이나 목표를 대하는 방식', signalHints: ['achievement', 'growth'] },
      { id: 'rest', label: '쉬고 회복하는 방식', signalHints: ['recovery', 'sensitivity'] }
    ],
    optionalTextPrompt: '가장 먼저 바꾸고 싶은 작은 장면이 있다면 적어 주세요.'
  },
  {
    id: 'repeat-energy-001',
    stage: 'repeat',
    axis: 'energyRhythm',
    area: 'energyRhythm',
    prompt: '지난 기록 이후, 에너지가 조금 달라졌다고 느낀 순간이 있었나요?',
    choices: [
      { id: 'more-stable', label: '조금 더 안정됐어요', signalHints: ['stability', 'recovery'] },
      { id: 'more-open', label: '새로운 자극이 필요했어요', signalHints: ['exploration'] },
      { id: 'more-social', label: '사람과의 연결이 도움이 됐어요', signalHints: ['connection'] },
      { id: 'more-alone', label: '혼자 있는 시간이 필요했어요', signalHints: ['autonomy', 'recovery'] }
    ],
    optionalTextPrompt: '달라진 장면이 있다면 짧게 남겨 주세요.'
  },
  {
    id: 'repeat-emotion-001',
    stage: 'repeat',
    axis: 'emotionAwareness',
    area: 'emotionAwareness',
    prompt: '최근 Diary나 답변을 돌아볼 때, 반복해서 보이는 감정의 결은 무엇에 가까운가요?',
    choices: [
      { id: 'calm', label: '차분해지려는 흐름', signalHints: ['recovery', 'stability'] },
      { id: 'sensitive', label: '작은 변화에 민감해지는 흐름', signalHints: ['sensitivity'] },
      { id: 'curious', label: '이유를 더 알고 싶은 흐름', signalHints: ['depth', 'exploration'] },
      { id: 'connected', label: '누군가와 나누고 싶은 흐름', signalHints: ['connection'] }
    ],
    optionalTextPrompt: '반복되는 감정 단어가 있다면 적어 주세요.'
  },
  {
    id: 'repeat-values-001',
    stage: 'repeat',
    axis: 'valuesCompass',
    area: 'valuesCompass',
    prompt: '최근 기록에서 계속 중요하게 남는 기준은 이전과 비교해 어떤가요?',
    choices: [
      { id: 'same', label: '비슷하게 유지되고 있어요', signalHints: ['stability'] },
      { id: 'clearer', label: '조금 더 분명해졌어요', signalHints: ['depth', 'growth'] },
      { id: 'changing', label: '다른 기준이 올라오고 있어요', signalHints: ['exploration'] },
      { id: 'conflict', label: '두 기준 사이에서 조율 중이에요', signalHints: ['balance', 'sensitivity'] }
    ],
    optionalTextPrompt: '어떤 기준들이 떠오르는지 적어도 좋아요.'
  },
  {
    id: 'repeat-relation-001',
    stage: 'repeat',
    axis: 'relationshipPattern',
    area: 'relationshipPattern',
    prompt: '최근 관계 안에서 내가 더 잘 알아차리게 된 흐름은 무엇인가요?',
    choices: [
      { id: 'pace', label: '내게 맞는 속도', signalHints: ['autonomy', 'stability'] },
      { id: 'signal', label: '불편함이 시작되는 신호', signalHints: ['sensitivity', 'recovery'] },
      { id: 'dialogue', label: '대화가 편안해지는 조건', signalHints: ['connection'] },
      { id: 'balance', label: '주고받음의 균형', signalHints: ['balance'] }
    ],
    optionalTextPrompt: '상대 평가가 아니라 내 경험 중심으로 적어 주세요.'
  },
  {
    id: 'repeat-growth-001',
    stage: 'repeat',
    axis: 'growthMotivation',
    area: 'growthMotivation',
    prompt: '지난 기록 이후, 내가 작게라도 이어 온 것은 무엇에 가까운가요?',
    choices: [
      { id: 'routine', label: '작은 루틴', signalHints: ['stability', 'achievement'] },
      { id: 'learning', label: '배움이나 시도', signalHints: ['growth', 'exploration'] },
      { id: 'self-care', label: '나를 돌보는 행동', signalHints: ['recovery', 'sensitivity'] },
      { id: 'conversation', label: '관계를 위한 대화', signalHints: ['connection', 'balance'] }
    ],
    optionalTextPrompt: '이어 온 일이 있다면 작아도 괜찮으니 적어 주세요.'
  }
];

const signalLexicon: Record<SignalKey, string[]> = {
  autonomy: ['내가', '스스로', '혼자', '선택', '자율', '내 방식', '주도', '독립', '속도'],
  connection: ['사람', '관계', '대화', '함께', '친구', '가족', '연결', '공유', '표현'],
  stability: ['안정', '계획', '정리', '루틴', '확실', '꾸준', '기준', '예측', '유지'],
  growth: ['성장', '배우', '나아', '변화', '연습', '개선', '확장', '달라'],
  depth: ['의미', '생각', '기록', '이해', '깊', '납득', '이유', '진심'],
  balance: ['균형', '조율', '맞추', '배려', '공정', '중간', '서로', '영향'],
  sensitivity: ['감정', '마음', '기분', '상처', '불안', '편안', '긴장', '민감'],
  recovery: ['회복', '쉬', '멈추', '잠시', '숨', '정리', '에너지', '여백'],
  exploration: ['새로운', '탐색', '시도', '자극', '바꾸', '여행', '가능성', '궁금'],
  achievement: ['완성', '목표', '성과', '해내', '책임', '집중', '결과', '진전']
};

const axisKeywordLexicon: Record<UMapAxisKey, string[]> = {
  energyRhythm: ['에너지', '리듬', '피로', '쉬', '혼자', '함께', '루틴', '회복', '여백'],
  emotionAwareness: ['감정', '마음', '기분', '긴장', '불안', '편안', '상처', '몸'],
  valuesCompass: ['가치', '기준', '중요', '포기', '진심', '공정', '배려', '책임'],
  decisionStyle: ['선택', '결정', '고민', '납득', '정보', '시도', '확신', '가능성'],
  relationshipPattern: ['관계', '사람', '대화', '거리', '가까', '표현', '존중', '균형'],
  stressRecovery: ['부담', '스트레스', '긴장', '회복', '압박', '쉬', '멈추', '정리'],
  growthMotivation: ['성장', '배움', '목표', '진전', '완성', '책임', '해내', '지속'],
  lifeDirection: ['삶', '방향', '앞으로', '미래', '바꾸', '원하', '감각', '장면']
};

const signatureNames: Record<SignalKey, string> = {
  autonomy: '자기 리듬으로 방향을 고르는 흐름',
  connection: '관계의 온도를 살피며 이어지는 흐름',
  stability: '흔들림 속에서도 기준을 세우는 흐름',
  growth: '작은 진전에서 힘을 얻는 흐름',
  depth: '안쪽의 의미를 천천히 밝히는 흐름',
  balance: '사이의 균형을 조율하는 흐름',
  sensitivity: '마음의 결을 세밀하게 감지하는 흐름',
  recovery: '멈춤과 회복으로 다시 정돈되는 흐름',
  exploration: '새로운 가능성 쪽으로 넓어지는 흐름',
  achievement: '의미 있는 완성도를 향해 밀도를 높이는 흐름'
};

export function getNextQuestion(answers: Answer[] = [], diaryEntries: DiaryEntry[] = []): NextQuestionPayload {
  const answeredQuestionIds = new Set(answers.map((answer) => answer.questionId).filter(Boolean));
  const unansweredOnboarding = questionCatalog.find((question) => question.stage === 'onboarding' && !answeredQuestionIds.has(question.id));

  if (unansweredOnboarding) {
    return toNextQuestionPayload(unansweredOnboarding, '처음 U-Map의 바탕을 부담 없이 열기 위한 질문입니다.');
  }

  const uMap = buildUMap(answers, diaryEntries);
  const recentAxes = answers.slice(-3).map((answer) => answer.axis ?? answer.area);
  const rankedAxes = areaOrder
    .map((area) => ({
      area,
      clarity: uMap[area].clarity,
      recentPenalty: recentAxes.includes(area) ? 8 : 0
    }))
    .sort((a, b) => a.clarity + a.recentPenalty - (b.clarity + b.recentPenalty));
  const targetAxis = rankedAxes[0].area;
  const stage: QuestionStage = answers.length < 12 ? 'initial' : 'repeat';
  const selected =
    questionCatalog.find((question) => question.axis === targetAxis && question.stage === stage && !answeredQuestionIds.has(question.id)) ??
    questionCatalog.find((question) => question.axis === targetAxis && !answeredQuestionIds.has(question.id)) ??
    questionCatalog.find((question) => question.stage === 'repeat' && !answeredQuestionIds.has(question.id)) ??
    questionCatalog.find((question) => question.axis === targetAxis) ??
    questionCatalog[0];

  return toNextQuestionPayload(selected, `${areaLabels[selected.axis]} 축의 단서가 아직 더 쌓이면 좋겠어요. 현재 기록을 조금 더 선명하게 보기 위한 질문입니다.`);
}

export function analyzeAnswers(answers: Answer[] = [], diaryEntries: DiaryEntry[] = []): AnalysisResult {
  const profile = scoreSignals(answers, diaryEntries);
  const topSignal = getTopSignal(profile);
  const uMap = buildUMap(answers, diaryEntries);
  const clarityValues = Object.values(uMap).map((area) => area.clarity);
  const overallScore = Math.round(clarityValues.reduce((sum, value) => sum + value, 0) / clarityValues.length);
  const clearAreas = Object.values(uMap)
    .filter((area) => area.clarity >= 55)
    .map((area) => area.label);
  const unclearAreas = Object.values(uMap)
    .filter((area) => area.clarity < 35)
    .map((area) => area.label);
  const nextQuestionFocus = Object.values(uMap)
    .sort((a, b) => a.clarity - b.clarity)
    .slice(0, 3)
    .map((area) => area.label);

  return {
    signature: {
      name: signatureNames[topSignal],
      summary: `현재까지의 기록을 바탕으로 보면, ${describeSignal(topSignal)} 흐름이 조금씩 보여요.`,
      evidence: buildEvidence(answers, diaryEntries, topSignal),
      confidenceNote:
        'Signature는 고정 유형이 아니라 현재까지의 기록에서 보이는 흐름 요약입니다. 답변과 Diary가 쌓이면 자연스럽게 달라질 수 있어요.'
    },
    uMap,
    uMapClarity: {
      overallScore,
      clearAreas,
      unclearAreas,
      nextQuestionFocus
    },
    nextQuestion: getNextQuestion(answers, diaryEntries),
    detailAnalysis: buildDetailAnalysis(topSignal, answers, diaryEntries)
  };
}

export function findUnsafeExpressions(text: string): SafetyFinding[] {
  return forbiddenExpressionRules.flatMap((rule) => {
    const matches = Array.from(text.matchAll(rule.pattern));
    return matches.map((match) => ({
      ruleId: rule.id,
      matched: match[0],
      replacement: rule.replacement
    }));
  });
}

export function analyzeRelation(input: {
  relationId?: string;
  displayLabel?: string;
  notes?: string[];
  answers?: Answer[];
  diaryEntries?: DiaryEntry[];
}): RelationInsightPayload {
  const notes = input.notes ?? [];
  const relationAnswers = (input.answers ?? []).filter((answer) => (answer.axis ?? answer.area) === 'relationshipPattern');
  const relationDiary = (input.diaryEntries ?? []).filter((entry) => axisKeywordLexicon.relationshipPattern.some((word) => entry.body.includes(word)));
  const evidence = [
    ...relationAnswers.slice(-2).map((answer) => trimSignal(answer.optionalText || answer.selectedChoiceLabel || answer.text)),
    ...relationDiary.slice(-2).map((entry) => trimSignal(entry.body)),
    ...notes.slice(-2).map(trimSignal)
  ].filter(Boolean);
  const combinedText = evidence.join(' ');
  const comfortSignals = ['편안', '존중', '대화', '솔직', '균형', '여백']
    .filter((word) => combinedText.includes(word))
    .map((word) => `${word}과 관련된 편안함 단서`);
  const tensionSignals = ['부담', '거리', '불편', '빠르', '지치', '긴장']
    .filter((word) => combinedText.includes(word))
    .map((word) => `${word}과 관련된 거리감 단서`);

  return {
    relationId: input.relationId,
    displayLabel: input.displayLabel,
    summary:
      evidence.length > 0
        ? '현재 기록을 바탕으로 보면, 이 관계 안에서 내가 편안함과 거리감을 느끼는 조건이 조금씩 드러나고 있어요.'
        : insufficientDataCopy.relation,
    myExperienceFlow:
      evidence.length > 0
        ? '상대를 단정하기보다, 내가 어떤 속도와 대화 방식에서 안정감을 느끼는지 살펴보는 단계로 보여요.'
        : '아직 관계 흐름을 읽기에는 기록이 적어요.',
    comfortSignals: comfortSignals.length > 0 ? comfortSignals : ['아직 편안함의 조건이 충분히 드러나지 않았어요.'],
    tensionSignals: tensionSignals.length > 0 ? tensionSignals : ['아직 거리감이나 긴장 단서가 충분히 드러나지 않았어요.'],
    nextReflection: '다음에는 이 관계 안에서 편안했던 장면과 조금 거리를 두고 싶었던 장면을 하나씩 남겨 보세요.',
    boundaryNote: '이 결과는 상대가 어떤 사람인지 판단하지 않고, 이 관계 안에서 내가 경험한 흐름만 다룹니다.',
    safetyNote: '관계 분석은 상대 성향, 관계의 미래, 지속 여부를 단정하는 데 사용하지 않습니다.',
    evidence: evidence.length > 0 ? evidence : ['아직 관계 기록이 충분하지 않습니다.']
  };
}

export function buildReportPayload(analysis: AnalysisResult, options: { reportId: string; tier: ReportTier; answerCount: number; diaryCount: number }): ReportOutputPayload {
  const paidSummary =
    options.tier === 'paid'
      ? '유료 리포트는 판정 기능이 아니라, 현재 기록을 더 깊고 긴 호흡으로 정리해 흐름을 더 선명하게 살펴보는 확장 보기입니다.'
      : '무료 요약은 현재 기록에서 보이는 핵심 흐름을 가볍게 확인하는 보기입니다.';

  return {
    reportId: options.reportId,
    tier: options.tier,
    title: options.tier === 'paid' ? '확장 자기탐구 리포트' : '현재 흐름 요약',
    summary: `${paidSummary} ${analysis.signature.summary}`,
    sections: [
      {
        id: 'signature',
        title: 'Signature 흐름',
        body: analysis.signature.summary,
        basis: analysis.signature.evidence
      },
      {
        id: 'u-map-clarity',
        title: 'U-Map 선명도',
        body: `현재 비교적 선명한 축은 ${analysis.uMapClarity.clearAreas.join(', ') || '아직 없음'}이고, 더 살펴볼 축은 ${analysis.uMapClarity.unclearAreas.join(', ') || '아직 없음'}입니다.`,
        basis: analysis.uMapClarity.nextQuestionFocus
      },
      {
        id: 'next-step',
        title: '다음 탐구',
        body: analysis.nextQuestion.whyThisQuestion,
        basis: [analysis.nextQuestion.question]
      }
    ],
    sourceSummary: {
      answerCount: options.answerCount,
      diaryCount: options.diaryCount,
      clearAreas: analysis.uMapClarity.clearAreas,
      unclearAreas: analysis.uMapClarity.unclearAreas
    },
    refreshPolicy: '새 질문 답변이나 Diary 기록이 쌓이면 리포트 내용은 달라질 수 있습니다.',
    paymentToneNote: 'Star 또는 유료 리포트는 자기이해를 압박하거나 불안을 자극하지 않아야 하며, 질문 자체는 판매하지 않습니다.'
  };
}

function toNextQuestionPayload(question: Question, whyThisQuestion: string): NextQuestionPayload {
  return {
    questionId: question.id,
    stage: question.stage,
    area: question.axis,
    axis: question.axis,
    areaLabel: areaLabels[question.axis],
    question: question.prompt,
    choices: question.choices,
    optionalTextPrompt: question.optionalTextPrompt,
    whyThisQuestion
  };
}

function scoreSignals(answers: Answer[], diaryEntries: DiaryEntry[] = []) {
  const scores = Object.fromEntries(Object.keys(signalLexicon).map((key) => [key, 0])) as Record<SignalKey, number>;

  for (const answer of answers) {
    const question = questionCatalog.find((item) => item.id === answer.questionId);
    const choice = question?.choices.find((item) => item.id === answer.selectedChoiceId);

    for (const hint of choice?.signalHints ?? []) {
      scores[hint] += 2;
    }

    addLexiconScores(scores, `${answer.selectedChoiceLabel ?? ''} ${answer.optionalText ?? ''} ${answer.text}`);
  }

  for (const entry of diaryEntries) {
    addLexiconScores(scores, `${entry.body} ${entry.moodLabel ?? ''} ${(entry.tags ?? []).join(' ')}`);
  }

  if (answers.length === 0 && diaryEntries.length === 0) {
    scores.depth = 1;
  }

  return scores;
}

function addLexiconScores(scores: Record<SignalKey, number>, text: string) {
  for (const [signal, words] of Object.entries(signalLexicon) as [SignalKey, string[]][]) {
    scores[signal] += words.filter((word) => text.includes(word)).length;
  }
}

function buildUMap(answers: Answer[] = [], diaryEntries: DiaryEntry[] = []): Record<UMapAxisKey, UMapArea> {
  return Object.fromEntries(
    areaOrder.map((area) => {
      const areaAnswers = answers.filter((answer) => (answer.axis ?? answer.area) === area);
      const diaryHits = diaryEntries.filter((entry) => axisKeywordLexicon[area].some((word) => entry.body.includes(word)));
      const evidenceCount = areaAnswers.length + Math.min(3, diaryHits.length);
      const optionalTextLength = areaAnswers.reduce((sum, answer) => sum + (answer.optionalText?.length ?? answer.text.length), 0);
      const diaryTextLength = diaryHits.reduce((sum, entry) => sum + entry.body.length, 0);
      const clarity = Math.min(92, evidenceCount * 12 + Math.round(optionalTextLength / 20) + Math.round(diaryTextLength / 80));
      const signals = [
        ...areaAnswers.slice(-2).map((answer) => trimSignal(answer.selectedChoiceLabel ?? answer.text)),
        ...diaryHits.slice(-2).map((entry) => `Diary: ${trimSignal(entry.body)}`)
      ].filter(Boolean);

      return [
        area,
        {
          label: areaLabels[area],
          summary:
            evidenceCount > 0
              ? `현재까지의 기록에서는 ${areaLabels[area]}에 대한 단서가 ${evidenceCount}개 정도 쌓였어요.`
              : `${areaLabels[area]} 축은 아직 충분히 드러나지 않았어요.`,
          signals,
          clarity,
          flow: getFlow(clarity),
          evidenceCount,
          nextDepth:
            evidenceCount > 0
              ? `${areaLabels[area]} 안에서 반복되는 선택의 이유를 더 보면 흐름이 선명해질 수 있어요.`
              : `${areaLabels[area]}을 가볍게 열 수 있는 구체적인 경험 질문이 필요해요.`
        }
      ];
    })
  ) as Record<UMapAxisKey, UMapArea>;
}

function getFlow(clarity: number): UMapArea['flow'] {
  if (clarity >= 75) {
    return 'active';
  }

  if (clarity >= 55) {
    return 'clearer';
  }

  if (clarity >= 25) {
    return 'forming';
  }

  return 'emerging';
}

function getTopSignal(profile: Record<SignalKey, number>): SignalKey {
  return (Object.entries(profile).sort((a, b) => b[1] - a[1])[0]?.[0] ?? 'depth') as SignalKey;
}

function describeSignal(signal: SignalKey) {
  const descriptions: Record<SignalKey, string> = {
    autonomy: '자기만의 방식과 선택권을 중요하게 여기는',
    connection: '관계의 온도와 대화의 여지를 살피는',
    stability: '안정적인 기준과 지속 가능한 리듬을 중시하는',
    growth: '작은 변화와 배움에서 동력을 얻는',
    depth: '겉으로 보이는 선택보다 안쪽의 의미를 오래 살피는',
    balance: '상황과 사람 사이에서 균형점을 찾으려는',
    sensitivity: '감정의 미세한 흐름을 놓치지 않으려는',
    recovery: '멈춤과 정리를 통해 다시 회복하려는',
    exploration: '새로운 가능성과 변화의 여지를 중요하게 보는',
    achievement: '완성도와 책임감을 통해 밀도를 높이는'
  };

  return descriptions[signal];
}

function buildEvidence(answers: Answer[], diaryEntries: DiaryEntry[], topSignal: SignalKey) {
  const matchingWords = signalLexicon[topSignal] ?? [];
  const answerEvidence = answers
    .filter((answer) => {
      const question = questionCatalog.find((item) => item.id === answer.questionId);
      const choice = question?.choices.find((item) => item.id === answer.selectedChoiceId);
      return choice?.signalHints.includes(topSignal) || matchingWords.some((word) => answer.text.includes(word));
    })
    .slice(-2)
    .map((answer) => `${areaLabels[answer.axis ?? answer.area]} 답변에서 "${trimSignal(answer.selectedChoiceLabel ?? answer.text)}"라는 단서가 보여요.`);
  const diaryEvidence = diaryEntries
    .filter((entry) => matchingWords.some((word) => entry.body.includes(word)))
    .slice(-1)
    .map((entry) => `Diary 기록에서 "${trimSignal(entry.body)}"라는 흐름이 보여요.`);
  const evidence = [...answerEvidence, ...diaryEvidence];

  if (evidence.length > 0) {
    return evidence;
  }

  return answers.length > 0 || diaryEntries.length > 0
    ? ['아직 특정 흐름이 강하게 반복되기보다는, 기록이 쌓이는 초기 단계로 보여요.']
    : ['아직 기록이 없어 기본 Signature가 임시로 표시되고 있어요.'];
}

function buildDetailAnalysis(topSignal: SignalKey, answers: Answer[], diaryEntries: DiaryEntry[]): AnalysisResult['detailAnalysis'] {
  const basis = buildEvidence(answers, diaryEntries, topSignal);

  return {
    selfCare: {
      title: '나를 돌보는 단서',
      summary: '현재 기록에서는 회복과 정리를 통해 나를 다시 살피려는 흐름을 함께 볼 수 있어요.',
      suggestions: ['부담이 커지는 신호를 한 단어로 남기기', '회복에 도움이 된 행동을 Diary에 짧게 기록하기', '오늘의 리듬을 무리 없이 조정하기'],
      basis
    },
    workStyle: {
      title: '일과 몰입의 단서',
      summary: '현재 드러난 흐름을 기준으로는 의미, 자율성, 완성도를 함께 다룰 때 몰입이 살아날 가능성이 있어요.',
      suggestions: ['시작 전 기준 한 가지 정하기', '완료 기준을 작게 잡기', '혼자 정리하는 시간과 공유 시간을 분리하기'],
      basis
    },
    relationshipCue: {
      title: '관계 안에서의 단서',
      summary: '상대를 판단하기보다, 관계 안에서 내가 편안함과 거리감을 느끼는 조건을 살펴볼 수 있어요.',
      suggestions: ['편안했던 대화의 조건 적기', '거리가 필요했던 순간의 신호 보기', '내 속도를 말로 설명하는 연습하기'],
      basis
    },
    growthDirection: {
      title: '성장 방향',
      summary: '생각을 오래 품는 힘을 유지하되, 작은 실행 단위로 바꾸는 연습이 도움이 될 수 있어요.',
      suggestions: ['기준을 문장으로 적기', '작은 결정부터 완료하기', '감정과 행동을 분리해서 기록하기'],
      basis
    },
    watchPoints: {
      title: '부담이 커질 수 있는 지점',
      summary: '빠른 단정, 과도한 비교, 감정의 여백이 없는 환경에서는 장점이 흐려질 수 있어요.',
      suggestions: ['맥락 없이 속도만 요구되는 상황 알아차리기', '상시 비교가 강한 환경에서 회복 시간 확보하기', '표현이 평가로만 돌아올 때 잠시 정리하기'],
      basis
    }
  };
}

function trimSignal(text: string) {
  const compact = text.replace(/\s+/g, ' ').trim();
  return compact.length > 44 ? `${compact.slice(0, 44)}...` : compact;
}
