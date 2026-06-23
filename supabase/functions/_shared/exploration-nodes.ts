export type ExplorationParentNode = {
  readonly id: string;
  readonly order: number;
  readonly name: string;
  readonly children: readonly ExplorationChildNode[];
};

export type ExplorationChildNode = {
  readonly id: string;
  readonly order: number;
  readonly parentId: string;
  readonly parentName: string;
  readonly name: string;
  readonly description: string;
};

export const explorationNodeTaxonomy = [
    {
        "id":  "parent_01",
        "order":  1,
        "name":  "자아상",
        "children":  [
                         {
                             "id":  "parent_01_child_01",
                             "order":  1,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기인식",
                             "description":  "자신이 어떤 사람인지 스스로 이해하는 정도"
                         },
                         {
                             "id":  "parent_01_child_02",
                             "order":  2,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기수용",
                             "description":  "자신의 장점과 약점을 받아들이는 태도"
                         },
                         {
                             "id":  "parent_01_child_03",
                             "order":  3,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기비판",
                             "description":  "자신의 부족함을 지적하고 평가하는 경향"
                         },
                         {
                             "id":  "parent_01_child_04",
                             "order":  4,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기신뢰",
                             "description":  "자신의 판단과 선택을 믿는 정도"
                         },
                         {
                             "id":  "parent_01_child_05",
                             "order":  5,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기존중감",
                             "description":  "스스로를 가치 있는 존재로 느끼는 감각"
                         },
                         {
                             "id":  "parent_01_child_06",
                             "order":  6,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자존감 안정성",
                             "description":  "상황에 따라 자존감이 흔들리는 정도"
                         },
                         {
                             "id":  "parent_01_child_07",
                             "order":  7,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "이상적 자아",
                             "description":  "되고 싶은 자신의 모습"
                         },
                         {
                             "id":  "parent_01_child_08",
                             "order":  8,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "현실적 자아",
                             "description":  "현재 자신을 바라보는 실제적 인식"
                         },
                         {
                             "id":  "parent_01_child_09",
                             "order":  9,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "사회적 자아",
                             "description":  "타인에게 보이는 자신의 이미지"
                         },
                         {
                             "id":  "parent_01_child_10",
                             "order":  10,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "숨겨진 자아",
                             "description":  "겉으로 드러내지 않는 내면의 모습"
                         },
                         {
                             "id":  "parent_01_child_11",
                             "order":  11,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "열등감",
                             "description":  "자신이 부족하거나 뒤처진다고 느끼는 감정"
                         },
                         {
                             "id":  "parent_01_child_12",
                             "order":  12,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "우월감",
                             "description":  "자신이 타인보다 낫다고 느끼는 경향"
                         },
                         {
                             "id":  "parent_01_child_13",
                             "order":  13,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기확신",
                             "description":  "자신의 생각과 방향에 대한 확고함"
                         },
                         {
                             "id":  "parent_01_child_14",
                             "order":  14,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기의심",
                             "description":  "자신의 능력과 판단을 의심하는 경향"
                         },
                         {
                             "id":  "parent_01_child_15",
                             "order":  15,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "정체성 명확성",
                             "description":  "자신이 누구인지에 대한 기준이 뚜렷한 정도"
                         },
                         {
                             "id":  "parent_01_child_16",
                             "order":  16,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "역할 인식",
                             "description":  "상황 속에서 자신이 맡은 역할을 인식하는 능력"
                         },
                         {
                             "id":  "parent_01_child_17",
                             "order":  17,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "타인의 시선 의식",
                             "description":  "타인이 자신을 어떻게 볼지 신경 쓰는 정도"
                         },
                         {
                             "id":  "parent_01_child_18",
                             "order":  18,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "인정 욕구",
                             "description":  "타인에게 인정받고 싶어 하는 마음"
                         },
                         {
                             "id":  "parent_01_child_19",
                             "order":  19,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기표현 욕구",
                             "description":  "자신의 생각과 감정을 드러내고 싶은 욕구"
                         },
                         {
                             "id":  "parent_01_child_20",
                             "order":  20,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "내면 이미지",
                             "description":  "스스로 마음속에 가지고 있는 자기 이미지"
                         },
                         {
                             "id":  "parent_01_child_21",
                             "order":  21,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "외적 이미지 관리",
                             "description":  "겉으로 보이는 모습과 인상을 관리하는 경향"
                         },
                         {
                             "id":  "parent_01_child_22",
                             "order":  22,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "실패에 대한 자기평가",
                             "description":  "실패했을 때 자신을 해석하는 방식"
                         },
                         {
                             "id":  "parent_01_child_23",
                             "order":  23,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "성공에 대한 자기평가",
                             "description":  "성공했을 때 자신을 받아들이는 방식"
                         },
                         {
                             "id":  "parent_01_child_24",
                             "order":  24,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기효능감",
                             "description":  "자신이 일을 해낼 수 있다고 믿는 감각"
                         },
                         {
                             "id":  "parent_01_child_25",
                             "order":  25,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기통제감",
                             "description":  "자신의 삶과 행동을 통제하고 있다고 느끼는 정도"
                         },
                         {
                             "id":  "parent_01_child_26",
                             "order":  26,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "내적 기준",
                             "description":  "타인의 평가보다 자신의 기준을 중시하는 정도"
                         },
                         {
                             "id":  "parent_01_child_27",
                             "order":  27,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "비교 성향",
                             "description":  "자신을 타인과 비교하는 경향"
                         },
                         {
                             "id":  "parent_01_child_28",
                             "order":  28,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "자기방어",
                             "description":  "상처나 비판으로부터 자신을 보호하려는 반응"
                         },
                         {
                             "id":  "parent_01_child_29",
                             "order":  29,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "성장 가능성 인식",
                             "description":  "자신이 더 나아질 수 있다고 믿는 정도"
                         },
                         {
                             "id":  "parent_01_child_30",
                             "order":  30,
                             "parentId":  "parent_01",
                             "parentName":  "자아상",
                             "name":  "존재감 욕구",
                             "description":  "타인과 세상 속에서 의미 있게 존재하고 싶은 욕구"
                         }
                     ]
    },
    {
        "id":  "parent_02",
        "order":  2,
        "name":  "행동패턴",
        "children":  [
                         {
                             "id":  "parent_02_child_01",
                             "order":  1,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "실행력",
                             "description":  "생각한 것을 실제 행동으로 옮기는 힘"
                         },
                         {
                             "id":  "parent_02_child_02",
                             "order":  2,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "추진력",
                             "description":  "목표를 향해 밀고 나가는 에너지"
                         },
                         {
                             "id":  "parent_02_child_03",
                             "order":  3,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "지속성",
                             "description":  "시작한 일을 꾸준히 이어가는 능력"
                         },
                         {
                             "id":  "parent_02_child_04",
                             "order":  4,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "루틴 선호",
                             "description":  "정해진 반복 구조를 편안하게 느끼는 경향"
                         },
                         {
                             "id":  "parent_02_child_05",
                             "order":  5,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "즉흥성",
                             "description":  "계획보다 순간의 판단에 따라 움직이는 경향"
                         },
                         {
                             "id":  "parent_02_child_06",
                             "order":  6,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "계획성",
                             "description":  "행동하기 전에 미리 구조를 세우는 능력"
                         },
                         {
                             "id":  "parent_02_child_07",
                             "order":  7,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "습관 형성력",
                             "description":  "반복 행동을 안정적인 습관으로 만드는 힘"
                         },
                         {
                             "id":  "parent_02_child_08",
                             "order":  8,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "미루기 성향",
                             "description":  "해야 할 일을 뒤로 늦추는 경향"
                         },
                         {
                             "id":  "parent_02_child_09",
                             "order":  9,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "완수 성향",
                             "description":  "시작한 일을 끝까지 마무리하려는 태도"
                         },
                         {
                             "id":  "parent_02_child_10",
                             "order":  10,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "시작 민감도",
                             "description":  "일을 시작하기까지 필요한 심리적 에너지"
                         },
                         {
                             "id":  "parent_02_child_11",
                             "order":  11,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "몰입력",
                             "description":  "한 가지 활동에 깊게 빠져드는 능력"
                         },
                         {
                             "id":  "parent_02_child_12",
                             "order":  12,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "집중 지속력",
                             "description":  "주의를 오래 유지하는 힘"
                         },
                         {
                             "id":  "parent_02_child_13",
                             "order":  13,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "행동 속도",
                             "description":  "생각을 행동으로 전환하는 빠르기"
                         },
                         {
                             "id":  "parent_02_child_14",
                             "order":  14,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "반응 속도",
                             "description":  "외부 상황에 즉각 대응하는 정도"
                         },
                         {
                             "id":  "parent_02_child_15",
                             "order":  15,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "에너지 관리",
                             "description":  "자신의 체력과 정신 에너지를 조절하는 능력"
                         },
                         {
                             "id":  "parent_02_child_16",
                             "order":  16,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "반복 행동",
                             "description":  "익숙한 방식을 반복하려는 경향"
                         },
                         {
                             "id":  "parent_02_child_17",
                             "order":  17,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "회피 행동",
                             "description":  "불편한 상황이나 일을 피하려는 행동"
                         },
                         {
                             "id":  "parent_02_child_18",
                             "order":  18,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "도전 행동",
                             "description":  "낯선 일이나 어려운 과제에 접근하는 태도"
                         },
                         {
                             "id":  "parent_02_child_19",
                             "order":  19,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "안정 추구 행동",
                             "description":  "위험보다 안전한 선택을 선호하는 행동"
                         },
                         {
                             "id":  "parent_02_child_20",
                             "order":  20,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "탐색 행동",
                             "description":  "새로운 정보와 가능성을 찾아보는 경향"
                         },
                         {
                             "id":  "parent_02_child_21",
                             "order":  21,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "충동성",
                             "description":  "깊이 생각하기 전에 행동하는 경향"
                         },
                         {
                             "id":  "parent_02_child_22",
                             "order":  22,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "자기관리",
                             "description":  "시간, 생활, 감정, 목표를 관리하는 능력"
                         },
                         {
                             "id":  "parent_02_child_23",
                             "order":  23,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "목표 추적력",
                             "description":  "목표 진행 상황을 확인하고 조정하는 능력"
                         },
                         {
                             "id":  "parent_02_child_24",
                             "order":  24,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "우선순위 설정",
                             "description":  "중요한 일과 덜 중요한 일을 구분하는 능력"
                         },
                         {
                             "id":  "parent_02_child_25",
                             "order":  25,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "환경 의존성",
                             "description":  "주변 환경에 따라 행동이 크게 달라지는 정도"
                         },
                         {
                             "id":  "parent_02_child_26",
                             "order":  26,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "타인 영향성",
                             "description":  "타인의 말이나 분위기에 행동이 영향을 받는 정도"
                         },
                         {
                             "id":  "parent_02_child_27",
                             "order":  27,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "독립 실행력",
                             "description":  "혼자서도 일을 시작하고 끝내는 능력"
                         },
                         {
                             "id":  "parent_02_child_28",
                             "order":  28,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "피드백 반영",
                             "description":  "조언이나 평가를 행동 개선에 활용하는 능력"
                         },
                         {
                             "id":  "parent_02_child_29",
                             "order":  29,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "실패 후 재시도",
                             "description":  "실패 이후 다시 시도하는 회복 행동"
                         },
                         {
                             "id":  "parent_02_child_30",
                             "order":  30,
                             "parentId":  "parent_02",
                             "parentName":  "행동패턴",
                             "name":  "행동 일관성",
                             "description":  "상황이 바뀌어도 행동 방식이 유지되는 정도"
                         }
                     ]
    },
    {
        "id":  "parent_03",
        "order":  3,
        "name":  "삶의 방향",
        "children":  [
                         {
                             "id":  "parent_03_child_01",
                             "order":  1,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "인생 목표",
                             "description":  "삶에서 이루고 싶은 핵심 목표"
                         },
                         {
                             "id":  "parent_03_child_02",
                             "order":  2,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "장기 비전",
                             "description":  "먼 미래에 도달하고 싶은 삶의 그림"
                         },
                         {
                             "id":  "parent_03_child_03",
                             "order":  3,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "단기 목표",
                             "description":  "가까운 시기에 달성하고 싶은 구체적 목표"
                         },
                         {
                             "id":  "parent_03_child_04",
                             "order":  4,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "성장 지향",
                             "description":  "계속 배우고 발전하려는 방향성"
                         },
                         {
                             "id":  "parent_03_child_05",
                             "order":  5,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "안정 지향",
                             "description":  "예측 가능하고 안전한 삶을 추구하는 경향"
                         },
                         {
                             "id":  "parent_03_child_06",
                             "order":  6,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "자유 지향",
                             "description":  "스스로 선택하고 통제하는 삶을 원하는 경향"
                         },
                         {
                             "id":  "parent_03_child_07",
                             "order":  7,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "성취 지향",
                             "description":  "목표 달성과 결과를 중요하게 여기는 태도"
                         },
                         {
                             "id":  "parent_03_child_08",
                             "order":  8,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "관계 지향",
                             "description":  "사람과의 연결을 삶의 중심에 두는 경향"
                         },
                         {
                             "id":  "parent_03_child_09",
                             "order":  9,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "영향력 지향",
                             "description":  "타인이나 사회에 영향을 주고 싶은 욕구"
                         },
                         {
                             "id":  "parent_03_child_10",
                             "order":  10,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "의미 추구",
                             "description":  "삶에서 깊은 의미와 이유를 찾으려는 태도"
                         },
                         {
                             "id":  "parent_03_child_11",
                             "order":  11,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "행복 기준",
                             "description":  "자신이 행복하다고 느끼는 조건"
                         },
                         {
                             "id":  "parent_03_child_12",
                             "order":  12,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "성공 기준",
                             "description":  "자신이 성공했다고 판단하는 기준"
                         },
                         {
                             "id":  "parent_03_child_13",
                             "order":  13,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "삶의 우선순위",
                             "description":  "삶에서 무엇을 먼저 선택하는지에 대한 기준"
                         },
                         {
                             "id":  "parent_03_child_14",
                             "order":  14,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "커리어 방향",
                             "description":  "일과 직업에서 향하고 싶은 방향"
                         },
                         {
                             "id":  "parent_03_child_15",
                             "order":  15,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "경제적 목표",
                             "description":  "돈과 자산에 대해 이루고 싶은 목표"
                         },
                         {
                             "id":  "parent_03_child_16",
                             "order":  16,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "창조 욕구",
                             "description":  "무언가를 만들고 표현하고 싶은 욕구"
                         },
                         {
                             "id":  "parent_03_child_17",
                             "order":  17,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "탐험 욕구",
                             "description":  "새로운 경험과 세계를 접하고 싶은 욕구"
                         },
                         {
                             "id":  "parent_03_child_18",
                             "order":  18,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "기여 욕구",
                             "description":  "타인이나 사회에 도움이 되고 싶은 마음"
                         },
                         {
                             "id":  "parent_03_child_19",
                             "order":  19,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "자기실현",
                             "description":  "자신의 가능성과 잠재력을 실현하려는 욕구"
                         },
                         {
                             "id":  "parent_03_child_20",
                             "order":  20,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "독립 욕구",
                             "description":  "타인에게 의존하지 않고 살아가고 싶은 욕구"
                         },
                         {
                             "id":  "parent_03_child_21",
                             "order":  21,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "소속 욕구",
                             "description":  "어떤 집단이나 관계 안에 속하고 싶은 마음"
                         },
                         {
                             "id":  "parent_03_child_22",
                             "order":  22,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "변화 수용성",
                             "description":  "삶의 변화와 불확실성을 받아들이는 정도"
                         },
                         {
                             "id":  "parent_03_child_23",
                             "order":  23,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "미래 확신도",
                             "description":  "자신의 미래에 대해 긍정적으로 믿는 정도"
                         },
                         {
                             "id":  "parent_03_child_24",
                             "order":  24,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "미래 불안도",
                             "description":  "앞으로의 삶에 대해 걱정과 불안을 느끼는 정도"
                         },
                         {
                             "id":  "parent_03_child_25",
                             "order":  25,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "선택의 방향성",
                             "description":  "중요한 선택들이 일정한 방향을 향하는 정도"
                         },
                         {
                             "id":  "parent_03_child_26",
                             "order":  26,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "삶의 만족도",
                             "description":  "현재 자신의 삶에 대해 느끼는 만족감"
                         },
                         {
                             "id":  "parent_03_child_27",
                             "order":  27,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "현재 몰입도",
                             "description":  "지금의 삶과 일상에 집중하고 있는 정도"
                         },
                         {
                             "id":  "parent_03_child_28",
                             "order":  28,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "장기 인내력",
                             "description":  "긴 시간 동안 목표를 위해 버티는 힘"
                         },
                         {
                             "id":  "parent_03_child_29",
                             "order":  29,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "인생 서사감",
                             "description":  "자신의 삶을 하나의 이야기로 이해하는 감각"
                         },
                         {
                             "id":  "parent_03_child_30",
                             "order":  30,
                             "parentId":  "parent_03",
                             "parentName":  "삶의 방향",
                             "name":  "목적 의식",
                             "description":  "왜 살아가고 움직이는지에 대한 내적 이유"
                         }
                     ]
    },
    {
        "id":  "parent_04",
        "order":  4,
        "name":  "성격",
        "children":  [
                         {
                             "id":  "parent_04_child_01",
                             "order":  1,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "외향성",
                             "description":  "사람과 활동에서 에너지를 얻는 경향"
                         },
                         {
                             "id":  "parent_04_child_02",
                             "order":  2,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "내향성",
                             "description":  "혼자 있는 시간과 내면에서 에너지를 얻는 경향"
                         },
                         {
                             "id":  "parent_04_child_03",
                             "order":  3,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "개방성",
                             "description":  "새로운 생각, 경험, 가능성에 열려 있는 정도"
                         },
                         {
                             "id":  "parent_04_child_04",
                             "order":  4,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "성실성",
                             "description":  "책임감 있게 계획하고 꾸준히 행동하는 성향"
                         },
                         {
                             "id":  "parent_04_child_05",
                             "order":  5,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "친화성",
                             "description":  "타인과 부드럽고 협력적으로 지내는 성향"
                         },
                         {
                             "id":  "parent_04_child_06",
                             "order":  6,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "정서 안정성",
                             "description":  "감정이 쉽게 흔들리지 않고 안정되는 정도"
                         },
                         {
                             "id":  "parent_04_child_07",
                             "order":  7,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "예민성",
                             "description":  "작은 자극이나 변화에도 민감하게 반응하는 정도"
                         },
                         {
                             "id":  "parent_04_child_08",
                             "order":  8,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "신중함",
                             "description":  "행동 전 충분히 생각하고 판단하는 성향"
                         },
                         {
                             "id":  "parent_04_child_09",
                             "order":  9,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "대담함",
                             "description":  "위험이나 불확실성 앞에서도 나아가는 성향"
                         },
                         {
                             "id":  "parent_04_child_10",
                             "order":  10,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "호기심",
                             "description":  "알고 싶고 탐구하고 싶은 마음의 강도"
                         },
                         {
                             "id":  "parent_04_child_11",
                             "order":  11,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "독립성",
                             "description":  "스스로 판단하고 움직이려는 성향"
                         },
                         {
                             "id":  "parent_04_child_12",
                             "order":  12,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "의존성",
                             "description":  "타인의 도움, 의견, 지지를 필요로 하는 경향"
                         },
                         {
                             "id":  "parent_04_child_13",
                             "order":  13,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "완벽주의",
                             "description":  "높은 기준을 세우고 완성도를 추구하는 성향"
                         },
                         {
                             "id":  "parent_04_child_14",
                             "order":  14,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "낙관성",
                             "description":  "상황이 좋아질 것이라고 기대하는 경향"
                         },
                         {
                             "id":  "parent_04_child_15",
                             "order":  15,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "비관성",
                             "description":  "부정적 가능성을 먼저 예상하는 경향"
                         },
                         {
                             "id":  "parent_04_child_16",
                             "order":  16,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "현실성",
                             "description":  "이상보다 실제 조건과 가능성을 중시하는 성향"
                         },
                         {
                             "id":  "parent_04_child_17",
                             "order":  17,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "이상주의",
                             "description":  "현실보다 가치, 의미, 가능성을 중시하는 성향"
                         },
                         {
                             "id":  "parent_04_child_18",
                             "order":  18,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "경쟁성",
                             "description":  "타인과 비교해 이기거나 앞서고 싶은 성향"
                         },
                         {
                             "id":  "parent_04_child_19",
                             "order":  19,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "협력성",
                             "description":  "함께 조율하고 도우며 성과를 내는 성향"
                         },
                         {
                             "id":  "parent_04_child_20",
                             "order":  20,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "융통성",
                             "description":  "상황에 맞춰 생각과 행동을 바꾸는 능력"
                         },
                         {
                             "id":  "parent_04_child_21",
                             "order":  21,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "고집성",
                             "description":  "자신의 생각이나 방식을 쉽게 바꾸지 않는 경향"
                         },
                         {
                             "id":  "parent_04_child_22",
                             "order":  22,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "자기통제력",
                             "description":  "충동과 감정을 조절하고 행동을 관리하는 힘"
                         },
                         {
                             "id":  "parent_04_child_23",
                             "order":  23,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "충동성",
                             "description":  "순간의 욕구나 감정에 따라 움직이는 성향"
                         },
                         {
                             "id":  "parent_04_child_24",
                             "order":  24,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "사교성",
                             "description":  "사람들과 쉽게 어울리고 관계를 만드는 성향"
                         },
                         {
                             "id":  "parent_04_child_25",
                             "order":  25,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "침착성",
                             "description":  "긴장 상황에서도 차분함을 유지하는 성향"
                         },
                         {
                             "id":  "parent_04_child_26",
                             "order":  26,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "열정성",
                             "description":  "관심 있는 일에 강한 에너지를 쏟는 성향"
                         },
                         {
                             "id":  "parent_04_child_27",
                             "order":  27,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "분석성",
                             "description":  "상황을 논리적으로 분해하고 이해하려는 성향"
                         },
                         {
                             "id":  "parent_04_child_28",
                             "order":  28,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "창의성",
                             "description":  "새롭고 독특한 방식으로 생각하는 능력"
                         },
                         {
                             "id":  "parent_04_child_29",
                             "order":  29,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "책임감",
                             "description":  "맡은 일과 관계에 대해 의무감을 느끼는 성향"
                         },
                         {
                             "id":  "parent_04_child_30",
                             "order":  30,
                             "parentId":  "parent_04",
                             "parentName":  "성격",
                             "name":  "모험성",
                             "description":  "새로운 경험과 위험을 감수하려는 성향"
                         }
                     ]
    },
    {
        "id":  "parent_05",
        "order":  5,
        "name":  "가치관",
        "children":  [
                         {
                             "id":  "parent_05_child_01",
                             "order":  1,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "자유",
                             "description":  "스스로 선택하고 결정하는 것을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_02",
                             "order":  2,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "안정",
                             "description":  "안전하고 예측 가능한 상태를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_03",
                             "order":  3,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "성취",
                             "description":  "목표 달성과 결과를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_04",
                             "order":  4,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "인정",
                             "description":  "타인에게 능력과 존재를 인정받는 것을 중시함"
                         },
                         {
                             "id":  "parent_05_child_05",
                             "order":  5,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "관계",
                             "description":  "사람과의 연결과 유대를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_06",
                             "order":  6,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "성장",
                             "description":  "배우고 발전하는 과정을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_07",
                             "order":  7,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "진정성",
                             "description":  "거짓 없이 자기답게 사는 것을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_08",
                             "order":  8,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "정의",
                             "description":  "공정함과 올바름을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_09",
                             "order":  9,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "책임",
                             "description":  "맡은 일과 역할을 다하는 것을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_10",
                             "order":  10,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "효율",
                             "description":  "시간과 자원을 효과적으로 쓰는 것을 중시함"
                         },
                         {
                             "id":  "parent_05_child_11",
                             "order":  11,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "창의성",
                             "description":  "새롭고 독창적인 표현과 생각을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_12",
                             "order":  12,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "돈",
                             "description":  "경제적 보상과 재정적 여유를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_13",
                             "order":  13,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "명예",
                             "description":  "사회적 평판과 존중을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_14",
                             "order":  14,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "영향력",
                             "description":  "타인이나 세상에 변화를 주는 것을 중시함"
                         },
                         {
                             "id":  "parent_05_child_15",
                             "order":  15,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "가족",
                             "description":  "가족과의 관계와 책임을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_16",
                             "order":  16,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "우정",
                             "description":  "친구와의 신뢰와 정서적 연결을 중시함"
                         },
                         {
                             "id":  "parent_05_child_17",
                             "order":  17,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "사랑",
                             "description":  "깊은 애정과 친밀한 관계를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_18",
                             "order":  18,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "건강",
                             "description":  "몸과 마음의 건강을 중요한 삶의 기준으로 봄"
                         },
                         {
                             "id":  "parent_05_child_19",
                             "order":  19,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "지식",
                             "description":  "배우고 이해하고 아는 것을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_20",
                             "order":  20,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "경험",
                             "description":  "다양한 체험과 순간의 가치를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_21",
                             "order":  21,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "도전",
                             "description":  "어려운 목표와 새로운 시도를 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_22",
                             "order":  22,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "평화",
                             "description":  "갈등보다 조화롭고 평온한 상태를 중시함"
                         },
                         {
                             "id":  "parent_05_child_23",
                             "order":  23,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "즐거움",
                             "description":  "재미와 기쁨, 삶의 만족감을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_24",
                             "order":  24,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "독립",
                             "description":  "타인에게 휘둘리지 않고 자립하는 것을 중시함"
                         },
                         {
                             "id":  "parent_05_child_25",
                             "order":  25,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "소속감",
                             "description":  "어떤 관계나 집단 안에 속하는 것을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_26",
                             "order":  26,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "신뢰",
                             "description":  "믿을 수 있는 관계와 약속을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_27",
                             "order":  27,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "균형",
                             "description":  "일, 관계, 감정, 생활의 조화를 중시함"
                         },
                         {
                             "id":  "parent_05_child_28",
                             "order":  28,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "품격",
                             "description":  "태도, 말, 행동의 수준과 존엄성을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_29",
                             "order":  29,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "기여",
                             "description":  "타인과 사회에 도움이 되는 삶을 중요하게 여김"
                         },
                         {
                             "id":  "parent_05_child_30",
                             "order":  30,
                             "parentId":  "parent_05",
                             "parentName":  "가치관",
                             "name":  "자기실현",
                             "description":  "자신의 가능성을 삶 속에서 펼치는 것을 중시함"
                         }
                     ]
    },
    {
        "id":  "parent_06",
        "order":  6,
        "name":  "동기",
        "children":  [
                         {
                             "id":  "parent_06_child_01",
                             "order":  1,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "성취 동기",
                             "description":  "목표를 이루고 결과를 내고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_02",
                             "order":  2,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "인정 동기",
                             "description":  "타인에게 인정받고 평가받고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_03",
                             "order":  3,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "소속 동기",
                             "description":  "사람들과 연결되고 함께하고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_04",
                             "order":  4,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "성장 동기",
                             "description":  "더 나아지고 발전하고 싶은 내적 힘"
                         },
                         {
                             "id":  "parent_06_child_05",
                             "order":  5,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "회피 동기",
                             "description":  "실패, 비난, 불편함을 피하려는 힘"
                         },
                         {
                             "id":  "parent_06_child_06",
                             "order":  6,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "보상 동기",
                             "description":  "보상이나 이익을 얻기 위해 움직이는 힘"
                         },
                         {
                             "id":  "parent_06_child_07",
                             "order":  7,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "경쟁 동기",
                             "description":  "타인보다 앞서고 싶은 마음에서 나오는 힘"
                         },
                         {
                             "id":  "parent_06_child_08",
                             "order":  8,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "기여 동기",
                             "description":  "누군가에게 도움이 되고 싶은 마음"
                         },
                         {
                             "id":  "parent_06_child_09",
                             "order":  9,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "탐구 동기",
                             "description":  "궁금한 것을 알고 이해하려는 힘"
                         },
                         {
                             "id":  "parent_06_child_10",
                             "order":  10,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "창조 동기",
                             "description":  "새로운 것을 만들고 표현하려는 힘"
                         },
                         {
                             "id":  "parent_06_child_11",
                             "order":  11,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "안정 동기",
                             "description":  "안전하고 확실한 상태를 만들려는 힘"
                         },
                         {
                             "id":  "parent_06_child_12",
                             "order":  12,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "자유 동기",
                             "description":  "스스로 선택할 수 있는 상태를 원하는 힘"
                         },
                         {
                             "id":  "parent_06_child_13",
                             "order":  13,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "권한 동기",
                             "description":  "결정권과 통제권을 갖고 싶은 욕구"
                         },
                         {
                             "id":  "parent_06_child_14",
                             "order":  14,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "영향력 동기",
                             "description":  "타인이나 환경에 영향을 주고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_15",
                             "order":  15,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "의미 동기",
                             "description":  "행동에서 깊은 이유와 가치를 찾으려는 힘"
                         },
                         {
                             "id":  "parent_06_child_16",
                             "order":  16,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "호기심 동기",
                             "description":  "새롭고 낯선 것에 끌리는 힘"
                         },
                         {
                             "id":  "parent_06_child_17",
                             "order":  17,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "관계 동기",
                             "description":  "관계를 만들고 유지하려는 내적 욕구"
                         },
                         {
                             "id":  "parent_06_child_18",
                             "order":  18,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "완성 동기",
                             "description":  "일을 끝내고 완결된 상태를 만들고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_19",
                             "order":  19,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "생존 동기",
                             "description":  "안전, 생계, 기본 욕구를 지키려는 힘"
                         },
                         {
                             "id":  "parent_06_child_20",
                             "order":  20,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "자기증명",
                             "description":  "자신의 능력과 가치를 보여주려는 욕구"
                         },
                         {
                             "id":  "parent_06_child_21",
                             "order":  21,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "두려움 기반 동기",
                             "description":  "불안이나 두려움을 피하기 위해 움직이는 힘"
                         },
                         {
                             "id":  "parent_06_child_22",
                             "order":  22,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "즐거움 기반 동기",
                             "description":  "재미와 만족을 얻기 위해 움직이는 힘"
                         },
                         {
                             "id":  "parent_06_child_23",
                             "order":  23,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "책임 기반 동기",
                             "description":  "의무감과 책임감 때문에 움직이는 힘"
                         },
                         {
                             "id":  "parent_06_child_24",
                             "order":  24,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "기대 충족 동기",
                             "description":  "타인의 기대를 만족시키려는 욕구"
                         },
                         {
                             "id":  "parent_06_child_25",
                             "order":  25,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "변화 추구 동기",
                             "description":  "현재 상태를 바꾸고 새로워지고 싶은 힘"
                         },
                         {
                             "id":  "parent_06_child_26",
                             "order":  26,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "문제 해결 동기",
                             "description":  "불편한 문제를 해결하고 정리하려는 힘"
                         },
                         {
                             "id":  "parent_06_child_27",
                             "order":  27,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "성장 압박감",
                             "description":  "더 나아져야 한다는 내적 압박"
                         },
                         {
                             "id":  "parent_06_child_28",
                             "order":  28,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "내적 만족감",
                             "description":  "스스로 만족하기 위해 움직이는 힘"
                         },
                         {
                             "id":  "parent_06_child_29",
                             "order":  29,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "외적 평가 의식",
                             "description":  "타인의 평가를 의식해 행동하는 경향"
                         },
                         {
                             "id":  "parent_06_child_30",
                             "order":  30,
                             "parentId":  "parent_06",
                             "parentName":  "동기",
                             "name":  "목표 몰입도",
                             "description":  "목표에 얼마나 강하게 집중하고 있는지의 정도"
                         }
                     ]
    },
    {
        "id":  "parent_07",
        "order":  7,
        "name":  "감정패턴",
        "children":  [
                         {
                             "id":  "parent_07_child_01",
                             "order":  1,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 민감도",
                             "description":  "감정을 빠르고 강하게 느끼는 정도"
                         },
                         {
                             "id":  "parent_07_child_02",
                             "order":  2,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 표현력",
                             "description":  "자신의 감정을 밖으로 드러내는 능력"
                         },
                         {
                             "id":  "parent_07_child_03",
                             "order":  3,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 억제",
                             "description":  "감정을 참거나 눌러두는 경향"
                         },
                         {
                             "id":  "parent_07_child_04",
                             "order":  4,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 회피",
                             "description":  "감정을 마주하기보다 피하려는 경향"
                         },
                         {
                             "id":  "parent_07_child_05",
                             "order":  5,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 폭발성",
                             "description":  "쌓인 감정이 갑자기 강하게 터지는 정도"
                         },
                         {
                             "id":  "parent_07_child_06",
                             "order":  6,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 지속성",
                             "description":  "한 번 생긴 감정이 오래 유지되는 정도"
                         },
                         {
                             "id":  "parent_07_child_07",
                             "order":  7,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 회복력",
                             "description":  "부정적 감정에서 다시 회복하는 힘"
                         },
                         {
                             "id":  "parent_07_child_08",
                             "order":  8,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "불안 패턴",
                             "description":  "걱정과 불안이 반복되는 방식"
                         },
                         {
                             "id":  "parent_07_child_09",
                             "order":  9,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "분노 패턴",
                             "description":  "화가 발생하고 표현되는 방식"
                         },
                         {
                             "id":  "parent_07_child_10",
                             "order":  10,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "슬픔 패턴",
                             "description":  "상실감이나 우울감이 나타나는 방식"
                         },
                         {
                             "id":  "parent_07_child_11",
                             "order":  11,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "기쁨 반응",
                             "description":  "긍정적 사건에 기쁨을 느끼고 표현하는 방식"
                         },
                         {
                             "id":  "parent_07_child_12",
                             "order":  12,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "죄책감",
                             "description":  "자신의 행동에 대해 잘못했다고 느끼는 감정"
                         },
                         {
                             "id":  "parent_07_child_13",
                             "order":  13,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "수치심",
                             "description":  "자기 존재나 모습이 부끄럽다고 느끼는 감정"
                         },
                         {
                             "id":  "parent_07_child_14",
                             "order":  14,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "외로움 민감도",
                             "description":  "혼자라는 느낌에 민감하게 반응하는 정도"
                         },
                         {
                             "id":  "parent_07_child_15",
                             "order":  15,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "질투심",
                             "description":  "비교나 소유감에서 생기는 불편한 감정"
                         },
                         {
                             "id":  "parent_07_child_16",
                             "order":  16,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "서운함 민감도",
                             "description":  "기대가 충족되지 않았을 때 상처받는 정도"
                         },
                         {
                             "id":  "parent_07_child_17",
                             "order":  17,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 기복",
                             "description":  "감정 상태가 오르내리는 변화 폭"
                         },
                         {
                             "id":  "parent_07_child_18",
                             "order":  18,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 안정성",
                             "description":  "감정이 일정하고 안정적으로 유지되는 정도"
                         },
                         {
                             "id":  "parent_07_child_19",
                             "order":  19,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "공감 반응",
                             "description":  "타인의 감정을 함께 느끼고 반응하는 정도"
                         },
                         {
                             "id":  "parent_07_child_20",
                             "order":  20,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 전염성",
                             "description":  "타인의 감정에 쉽게 영향을 받는 정도"
                         },
                         {
                             "id":  "parent_07_child_21",
                             "order":  21,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 인식력",
                             "description":  "지금 자신이 느끼는 감정을 알아차리는 능력"
                         },
                         {
                             "id":  "parent_07_child_22",
                             "order":  22,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 언어화",
                             "description":  "감정을 말이나 글로 표현하는 능력"
                         },
                         {
                             "id":  "parent_07_child_23",
                             "order":  23,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 조절력",
                             "description":  "감정을 적절히 다루고 조절하는 능력"
                         },
                         {
                             "id":  "parent_07_child_24",
                             "order":  24,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "부정감정 처리",
                             "description":  "불안, 분노, 슬픔 같은 감정을 처리하는 방식"
                         },
                         {
                             "id":  "parent_07_child_25",
                             "order":  25,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "긍정감정 유지",
                             "description":  "좋은 감정을 오래 유지하고 확장하는 능력"
                         },
                         {
                             "id":  "parent_07_child_26",
                             "order":  26,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정적 의사결정",
                             "description":  "감정 상태가 선택에 영향을 주는 정도"
                         },
                         {
                             "id":  "parent_07_child_27",
                             "order":  27,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "상처 민감도",
                             "description":  "말이나 행동에 쉽게 상처받는 정도"
                         },
                         {
                             "id":  "parent_07_child_28",
                             "order":  28,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "기대 실망 패턴",
                             "description":  "기대가 무너졌을 때 감정이 반응하는 방식"
                         },
                         {
                             "id":  "parent_07_child_29",
                             "order":  29,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "감정 누적성",
                             "description":  "표현되지 않은 감정이 쌓이는 경향"
                         },
                         {
                             "id":  "parent_07_child_30",
                             "order":  30,
                             "parentId":  "parent_07",
                             "parentName":  "감정패턴",
                             "name":  "내면 긴장감",
                             "description":  "겉으로 드러나지 않는 심리적 긴장 상태"
                         }
                     ]
    },
    {
        "id":  "parent_08",
        "order":  8,
        "name":  "스트레스 반응",
        "children":  [
                         {
                             "id":  "parent_08_child_01",
                             "order":  1,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "압박 민감도",
                             "description":  "부담과 압박을 얼마나 강하게 느끼는지의 정도"
                         },
                         {
                             "id":  "parent_08_child_02",
                             "order":  2,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "긴장 반응",
                             "description":  "스트레스 상황에서 몸과 마음이 긴장하는 방식"
                         },
                         {
                             "id":  "parent_08_child_03",
                             "order":  3,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "회피 반응",
                             "description":  "스트레스 원인을 피하거나 미루려는 반응"
                         },
                         {
                             "id":  "parent_08_child_04",
                             "order":  4,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "공격 반응",
                             "description":  "압박을 받을 때 날카롭게 반응하는 경향"
                         },
                         {
                             "id":  "parent_08_child_05",
                             "order":  5,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "얼어붙기 반응",
                             "description":  "스트레스 상황에서 아무것도 못 하고 멈추는 반응"
                         },
                         {
                             "id":  "parent_08_child_06",
                             "order":  6,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "과잉통제",
                             "description":  "불안을 줄이기 위해 모든 것을 통제하려는 경향"
                         },
                         {
                             "id":  "parent_08_child_07",
                             "order":  7,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "과잉생각",
                             "description":  "문제를 반복해서 생각하며 빠져드는 경향"
                         },
                         {
                             "id":  "parent_08_child_08",
                             "order":  8,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "무기력 반응",
                             "description":  "압박이 커질 때 힘이 빠지고 포기하고 싶어지는 반응"
                         },
                         {
                             "id":  "parent_08_child_09",
                             "order":  9,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "문제 해결 반응",
                             "description":  "스트레스를 해결해야 할 문제로 접근하는 방식"
                         },
                         {
                             "id":  "parent_08_child_10",
                             "order":  10,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "감정 폭발",
                             "description":  "스트레스가 한계에 다다를 때 감정이 터지는 반응"
                         },
                         {
                             "id":  "parent_08_child_11",
                             "order":  11,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "침묵 반응",
                             "description":  "힘든 상황에서 말하지 않고 닫히는 경향"
                         },
                         {
                             "id":  "parent_08_child_12",
                             "order":  12,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "도움 요청",
                             "description":  "어려울 때 타인에게 도움을 구하는 능력"
                         },
                         {
                             "id":  "parent_08_child_13",
                             "order":  13,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "혼자 버티기",
                             "description":  "힘든 상황을 혼자 감당하려는 경향"
                         },
                         {
                             "id":  "parent_08_child_14",
                             "order":  14,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "수면 영향",
                             "description":  "스트레스가 잠의 질과 양에 미치는 영향"
                         },
                         {
                             "id":  "parent_08_child_15",
                             "order":  15,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "식욕 변화",
                             "description":  "스트레스가 식욕에 영향을 주는 정도"
                         },
                         {
                             "id":  "parent_08_child_16",
                             "order":  16,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "집중력 저하",
                             "description":  "스트레스 때문에 집중이 흐트러지는 정도"
                         },
                         {
                             "id":  "parent_08_child_17",
                             "order":  17,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "신체화 반응",
                             "description":  "심리적 압박이 몸의 증상으로 나타나는 정도"
                         },
                         {
                             "id":  "parent_08_child_18",
                             "order":  18,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "불안 증가",
                             "description":  "스트레스 상황에서 불안이 커지는 정도"
                         },
                         {
                             "id":  "parent_08_child_19",
                             "order":  19,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "분노 증가",
                             "description":  "압박을 받을 때 화가 증가하는 경향"
                         },
                         {
                             "id":  "parent_08_child_20",
                             "order":  20,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "자기비난",
                             "description":  "스트레스 상황에서 자신을 탓하는 경향"
                         },
                         {
                             "id":  "parent_08_child_21",
                             "order":  21,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "타인비난",
                             "description":  "스트레스 원인을 타인에게 돌리는 경향"
                         },
                         {
                             "id":  "parent_08_child_22",
                             "order":  22,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "완벽주의 강화",
                             "description":  "압박 속에서 더 완벽하게 하려는 경향"
                         },
                         {
                             "id":  "parent_08_child_23",
                             "order":  23,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "충동 행동",
                             "description":  "스트레스 상황에서 즉흥적으로 행동하는 경향"
                         },
                         {
                             "id":  "parent_08_child_24",
                             "order":  24,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "관계 단절",
                             "description":  "힘들 때 사람들과 거리를 두는 반응"
                         },
                         {
                             "id":  "parent_08_child_25",
                             "order":  25,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "생산성 저하",
                             "description":  "스트레스가 일의 효율과 성과를 떨어뜨리는 정도"
                         },
                         {
                             "id":  "parent_08_child_26",
                             "order":  26,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "스트레스 회복력",
                             "description":  "스트레스 이후 다시 균형을 찾는 힘"
                         },
                         {
                             "id":  "parent_08_child_27",
                             "order":  27,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "스트레스 예측력",
                             "description":  "자신이 스트레스를 받을 상황을 미리 알아차리는 능력"
                         },
                         {
                             "id":  "parent_08_child_28",
                             "order":  28,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "스트레스 해소 방식",
                             "description":  "스트레스를 풀기 위해 주로 사용하는 방법"
                         },
                         {
                             "id":  "parent_08_child_29",
                             "order":  29,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "위기 적응력",
                             "description":  "갑작스러운 위기 상황에 적응하는 능력"
                         },
                         {
                             "id":  "parent_08_child_30",
                             "order":  30,
                             "parentId":  "parent_08",
                             "parentName":  "스트레스 반응",
                             "name":  "번아웃 위험도",
                             "description":  "에너지 고갈과 무기력으로 이어질 가능성"
                         }
                     ]
    },
    {
        "id":  "parent_09",
        "order":  9,
        "name":  "인간관계",
        "children":  [
                         {
                             "id":  "parent_09_child_01",
                             "order":  1,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "친밀감 욕구",
                             "description":  "가까운 관계를 맺고 싶은 마음"
                         },
                         {
                             "id":  "parent_09_child_02",
                             "order":  2,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "독립성 욕구",
                             "description":  "관계 속에서도 자기 공간을 지키고 싶은 마음"
                         },
                         {
                             "id":  "parent_09_child_03",
                             "order":  3,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "소속감 욕구",
                             "description":  "집단이나 관계 안에 포함되고 싶은 욕구"
                         },
                         {
                             "id":  "parent_09_child_04",
                             "order":  4,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "인정 욕구",
                             "description":  "관계 안에서 가치 있는 사람으로 인정받고 싶은 마음"
                         },
                         {
                             "id":  "parent_09_child_05",
                             "order":  5,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "애착 안정성",
                             "description":  "관계에서 안정감과 신뢰를 느끼는 정도"
                         },
                         {
                             "id":  "parent_09_child_06",
                             "order":  6,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 불안",
                             "description":  "버려짐, 거절, 멀어짐을 걱정하는 경향"
                         },
                         {
                             "id":  "parent_09_child_07",
                             "order":  7,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 회피",
                             "description":  "가까워지는 관계를 부담스럽게 느끼고 피하는 경향"
                         },
                         {
                             "id":  "parent_09_child_08",
                             "order":  8,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "신뢰 형성",
                             "description":  "타인을 믿고 관계를 여는 능력"
                         },
                         {
                             "id":  "parent_09_child_09",
                             "order":  9,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "신뢰 민감도",
                             "description":  "신뢰가 깨지는 상황에 민감하게 반응하는 정도"
                         },
                         {
                             "id":  "parent_09_child_10",
                             "order":  10,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "경계 설정",
                             "description":  "타인과 나 사이의 심리적 선을 정하는 능력"
                         },
                         {
                             "id":  "parent_09_child_11",
                             "order":  11,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "거리 조절",
                             "description":  "관계의 가까움과 멀어짐을 조절하는 능력"
                         },
                         {
                             "id":  "parent_09_child_12",
                             "order":  12,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "의존 성향",
                             "description":  "정서적 판단이나 안정감을 타인에게 기대는 경향"
                         },
                         {
                             "id":  "parent_09_child_13",
                             "order":  13,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "주도 성향",
                             "description":  "관계에서 방향을 잡고 이끄는 경향"
                         },
                         {
                             "id":  "parent_09_child_14",
                             "order":  14,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "배려 성향",
                             "description":  "타인의 감정과 상황을 먼저 고려하는 태도"
                         },
                         {
                             "id":  "parent_09_child_15",
                             "order":  15,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "희생 성향",
                             "description":  "자신의 욕구보다 타인을 우선하는 경향"
                         },
                         {
                             "id":  "parent_09_child_16",
                             "order":  16,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "갈등 회피",
                             "description":  "불편한 대립이나 충돌을 피하려는 경향"
                         },
                         {
                             "id":  "parent_09_child_17",
                             "order":  17,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "갈등 직면",
                             "description":  "문제를 직접 마주하고 해결하려는 태도"
                         },
                         {
                             "id":  "parent_09_child_18",
                             "order":  18,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "소통 방식",
                             "description":  "생각과 감정을 전달하는 주된 방식"
                         },
                         {
                             "id":  "parent_09_child_19",
                             "order":  19,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "감정 공유",
                             "description":  "자신의 감정을 타인과 나누는 정도"
                         },
                         {
                             "id":  "parent_09_child_20",
                             "order":  20,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "자기표현",
                             "description":  "관계 안에서 자신의 의견과 욕구를 표현하는 능력"
                         },
                         {
                             "id":  "parent_09_child_21",
                             "order":  21,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "타인 이해력",
                             "description":  "타인의 입장과 심리를 이해하는 능력"
                         },
                         {
                             "id":  "parent_09_child_22",
                             "order":  22,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "공감 능력",
                             "description":  "타인의 감정을 느끼고 반응하는 능력"
                         },
                         {
                             "id":  "parent_09_child_23",
                             "order":  23,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "거절 능력",
                             "description":  "원하지 않는 요청을 건강하게 거절하는 능력"
                         },
                         {
                             "id":  "parent_09_child_24",
                             "order":  24,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "부탁 능력",
                             "description":  "필요한 도움이나 지지를 요청하는 능력"
                         },
                         {
                             "id":  "parent_09_child_25",
                             "order":  25,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 지속성",
                             "description":  "관계를 오래 유지하고 관리하는 능력"
                         },
                         {
                             "id":  "parent_09_child_26",
                             "order":  26,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 피로도",
                             "description":  "사람들과의 관계에서 쉽게 지치는 정도"
                         },
                         {
                             "id":  "parent_09_child_27",
                             "order":  27,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "사회적 에너지",
                             "description":  "사람을 만날 때 얻거나 쓰는 에너지 수준"
                         },
                         {
                             "id":  "parent_09_child_28",
                             "order":  28,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 선택 기준",
                             "description":  "누구와 가까워질지 판단하는 기준"
                         },
                         {
                             "id":  "parent_09_child_29",
                             "order":  29,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "집단 적응력",
                             "description":  "집단 분위기와 역할에 적응하는 능력"
                         },
                         {
                             "id":  "parent_09_child_30",
                             "order":  30,
                             "parentId":  "parent_09",
                             "parentName":  "인간관계",
                             "name":  "관계 회복력",
                             "description":  "갈등이나 거리감 이후 관계를 회복하는 능력"
                         }
                     ]
    },
    {
        "id":  "parent_10",
        "order":  10,
        "name":  "의사결정",
        "children":  [
                         {
                             "id":  "parent_10_child_01",
                             "order":  1,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "직관 의존도",
                             "description":  "느낌과 직감에 따라 선택하는 정도"
                         },
                         {
                             "id":  "parent_10_child_02",
                             "order":  2,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "논리 의존도",
                             "description":  "이유와 구조를 따져 선택하는 정도"
                         },
                         {
                             "id":  "parent_10_child_03",
                             "order":  3,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "감정 의존도",
                             "description":  "현재 감정 상태가 선택에 영향을 주는 정도"
                         },
                         {
                             "id":  "parent_10_child_04",
                             "order":  4,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "데이터 의존도",
                             "description":  "수치, 근거, 정보에 기반해 선택하는 정도"
                         },
                         {
                             "id":  "parent_10_child_05",
                             "order":  5,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "신중함",
                             "description":  "결정 전 충분히 검토하려는 태도"
                         },
                         {
                             "id":  "parent_10_child_06",
                             "order":  6,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "결단력",
                             "description":  "필요한 순간 선택을 내리는 힘"
                         },
                         {
                             "id":  "parent_10_child_07",
                             "order":  7,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "우유부단함",
                             "description":  "선택을 쉽게 내리지 못하고 망설이는 경향"
                         },
                         {
                             "id":  "parent_10_child_08",
                             "order":  8,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "위험 감수성",
                             "description":  "불확실한 선택도 감당하려는 정도"
                         },
                         {
                             "id":  "parent_10_child_09",
                             "order":  9,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "안정 선호",
                             "description":  "안전하고 예측 가능한 선택을 선호하는 경향"
                         },
                         {
                             "id":  "parent_10_child_10",
                             "order":  10,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "손실 회피",
                             "description":  "얻는 것보다 잃는 것을 더 크게 의식하는 경향"
                         },
                         {
                             "id":  "parent_10_child_11",
                             "order":  11,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "기회 포착력",
                             "description":  "좋은 가능성을 빠르게 알아보고 선택하는 능력"
                         },
                         {
                             "id":  "parent_10_child_12",
                             "order":  12,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "장기 관점",
                             "description":  "선택의 미래 영향과 지속성을 고려하는 정도"
                         },
                         {
                             "id":  "parent_10_child_13",
                             "order":  13,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "단기 관점",
                             "description":  "당장의 결과와 만족을 우선하는 정도"
                         },
                         {
                             "id":  "parent_10_child_14",
                             "order":  14,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "타인 의견 영향",
                             "description":  "타인의 말과 평가가 선택에 미치는 영향"
                         },
                         {
                             "id":  "parent_10_child_15",
                             "order":  15,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "자기 확신",
                             "description":  "자신의 선택을 믿고 밀고 나가는 정도"
                         },
                         {
                             "id":  "parent_10_child_16",
                             "order":  16,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "후회 민감도",
                             "description":  "선택 이후 후회할 가능성을 크게 의식하는 정도"
                         },
                         {
                             "id":  "parent_10_child_17",
                             "order":  17,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "선택 피로도",
                             "description":  "많은 선택 앞에서 쉽게 지치는 정도"
                         },
                         {
                             "id":  "parent_10_child_18",
                             "order":  18,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "완벽한 선택 욕구",
                             "description":  "실수 없는 최선의 결정을 하려는 욕구"
                         },
                         {
                             "id":  "parent_10_child_19",
                             "order":  19,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "대안 탐색력",
                             "description":  "여러 선택지를 비교하고 찾아보는 능력"
                         },
                         {
                             "id":  "parent_10_child_20",
                             "order":  20,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "우선순위 판단",
                             "description":  "무엇이 더 중요한지 결정하는 능력"
                         },
                         {
                             "id":  "parent_10_child_21",
                             "order":  21,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "기준 명확성",
                             "description":  "선택할 때 사용하는 기준이 뚜렷한 정도"
                         },
                         {
                             "id":  "parent_10_child_22",
                             "order":  22,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "가치 기반 선택",
                             "description":  "자신의 가치관에 맞춰 결정하는 경향"
                         },
                         {
                             "id":  "parent_10_child_23",
                             "order":  23,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "목표 기반 선택",
                             "description":  "목표 달성에 유리한 방향으로 선택하는 경향"
                         },
                         {
                             "id":  "parent_10_child_24",
                             "order":  24,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "관계 기반 선택",
                             "description":  "사람과 관계에 미칠 영향을 고려해 선택하는 경향"
                         },
                         {
                             "id":  "parent_10_child_25",
                             "order":  25,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "충동 결정",
                             "description":  "순간의 감정이나 욕구로 빠르게 선택하는 경향"
                         },
                         {
                             "id":  "parent_10_child_26",
                             "order":  26,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "결정 지연",
                             "description":  "선택을 뒤로 미루고 확정하지 않는 경향"
                         },
                         {
                             "id":  "parent_10_child_27",
                             "order":  27,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "결정 후 실행력",
                             "description":  "선택한 뒤 실제 행동으로 옮기는 능력"
                         },
                         {
                             "id":  "parent_10_child_28",
                             "order":  28,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "결정 후 확신도",
                             "description":  "결정 이후 자신의 선택을 믿는 정도"
                         },
                         {
                             "id":  "parent_10_child_29",
                             "order":  29,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "실패 학습력",
                             "description":  "잘못된 선택에서 배워 다음 판단에 반영하는 능력"
                         },
                         {
                             "id":  "parent_10_child_30",
                             "order":  30,
                             "parentId":  "parent_10",
                             "parentName":  "의사결정",
                             "name":  "선택 책임감",
                             "description":  "자신의 선택 결과를 받아들이고 책임지는 태도"
                         }
                     ]
    }
] as const satisfies readonly ExplorationParentNode[];

export type ExplorationParentNodeSummary = Omit<ExplorationParentNode, "children">;

export const explorationParentNodes: readonly ExplorationParentNodeSummary[] = explorationNodeTaxonomy.map((
  { children: _children, ...parent },
) => parent);

export const explorationChildNodes: readonly ExplorationChildNode[] = explorationNodeTaxonomy.flatMap((parent) =>
  parent.children as readonly ExplorationChildNode[]
);
