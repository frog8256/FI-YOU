import React from "react";
import { createRoot } from "react-dom/client";
import {
  ArrowRight,
  Bell,
  BookOpen,
  CalendarDays,
  Check,
  ChevronDown,
  ChevronLeft,
  ChevronRight,
  ChevronUp,
  Compass,
  Database,
  FileText,
  Flame,
  Globe2,
  Heart,
  Home,
  LockKeyhole,
  LogOut,
  MessageCircle,
  Orbit,
  Pencil,
  Settings,
  ShieldCheck,
  Share2,
  Sparkles,
  Trash2,
  User
} from "lucide-react";
import "./styles.css";
import { kpiEvents, trackEvent } from "./lib/analytics";
import { supportedLanguages, t } from "./lib/i18n";
import {
  completeOnboarding,
  createRelation,
  ensureProfile,
  fetchAnsweredQuestionIds,
  fetchCalendarDayStates,
  fetchDiaries,
  fetchEntitlements,
  fetchLatestUMapSnapshot,
  fetchQuestions,
  getSession,
  getStarBalance,
  grantAttendanceStar,
  grantDiaryStarOnce,
  isInsufficientStarError,
  onAuthStateChange,
  recordAppEvent,
  recordLegalConsent,
  requestAccountDeletion,
  requestDataExport,
  saveDiary,
  signInWithGoogle,
  signOut,
  softDeleteDiary,
  spendStar,
  unlockEntitlement,
  updateProfile,
  upsertAnswer,
  upsertOnboardingAnswer,
  upsertRelationAnswer
} from "./lib/p0Data";

const chunk = (...chunks) => chunks;

const firstQuestions = [
  {
    question: t("onboarding.q1.prompt"),
    options: [
      t("onboarding.q1.option1"),
      t("onboarding.q1.option2"),
      t("onboarding.q1.option3"),
      t("onboarding.q1.option4"),
      t("onboarding.q1.option5")
    ]
  },
  {
    question: t("onboarding.q2.prompt"),
    options: [
      t("onboarding.q2.option1"),
      t("onboarding.q2.option2"),
      t("onboarding.q2.option3"),
      t("onboarding.q2.option4"),
      t("onboarding.q2.option5")
    ]
  },
  {
    question: t("onboarding.q3.prompt"),
    options: [t("onboarding.q3.option1"), t("onboarding.q3.option2")]
  },
  {
    question: t("onboarding.q4.prompt"),
    options: [t("onboarding.q4.option1"), t("onboarding.q4.option2")]
  },
  {
    question: t("onboarding.q5.prompt"),
    options: [
      t("onboarding.q5.option1"),
      t("onboarding.q5.option2"),
      t("onboarding.q5.option3"),
      t("onboarding.q5.option4"),
      t("onboarding.q5.option5")
    ],
    note: true
  }
];

const loadingMessages = [
  t("transition.message.moreSignals"),
  t("transition.message.clearer"),
  t("transition.message.home")
];

const uMapAxisData = [
  { key: "explore", label: "탐구성", initial: 36, clear: 72 },
  { key: "independent", label: "독립성", initial: 41, clear: 66 },
  { key: "relation", label: "관계지향", initial: 34, clear: 64 },
  { key: "growth", label: "성장지향", initial: 38, clear: 70 },
  { key: "emotion", label: "감정민감도", initial: 32, clear: 62 },
  { key: "stability", label: "안정추구", initial: 45, clear: 74 },
  { key: "initiative", label: "진취성", initial: 35, clear: 68 },
  { key: "expression", label: "자기표현", initial: 30, clear: 58 }
];

function getAxisValue(axis, mode, scores = null) {
  const aliases = {
    explore: ["explore", "exploration", "curiosity"],
    independent: ["independent", "independence", "autonomy"],
    relation: ["relation", "relationship", "relationship_orientation"],
    growth: ["growth", "growth_orientation"],
    emotion: ["emotion", "emotional_sensitivity"],
    stability: ["stability", "stability_seeking"],
    initiative: ["initiative", "action", "execution"],
    expression: ["expression", "self_expression"]
  };
  const keys = aliases[axis.key] || [axis.key];
  const fromSnapshot = scores && keys.map((key) => Number(scores[key])).find((value) => Number.isFinite(value));
  return Number.isFinite(fromSnapshot) ? fromSnapshot : axis[mode];
}

function buildRadarPoints(mode, scale = 1, scores = null) {
  return uMapAxisData
    .map((axis, index) => {
      const angle = -Math.PI / 2 + (index / uMapAxisData.length) * Math.PI * 2;
      const value = getAxisValue(axis, mode, scores) * scale;
      const radius = Math.min(44, Math.max(10, value * 0.44));
      const x = 50 + Math.cos(angle) * radius;
      const y = 50 + Math.sin(angle) * radius;
      return `${x.toFixed(1)},${y.toFixed(1)}`;
    })
    .join(" ");
}

function UMapPreview({ mode = "initial", size = "compact", showLabels = false, scores = null }) {
  const axisPoints = uMapAxisData.map((axis, index) => {
    const angle = -Math.PI / 2 + (index / uMapAxisData.length) * Math.PI * 2;
    const x = 50 + Math.cos(angle) * 44;
    const y = 50 + Math.sin(angle) * 44;
    const labelX = 50 + Math.cos(angle) * 51;
    const labelY = 50 + Math.sin(angle) * 51;
    return { x, y, labelX, labelY, label: axis.label };
  });
  const polygonPoints = buildRadarPoints(mode, mode === "clear" ? 1 : 0.92, scores);

  return (
    <div className={`u-map-preview ${size === "large" ? "u-map-preview-large" : "u-map-preview-compact"} ${mode}`}>
      <svg viewBox="0 0 100 100" role="img" aria-label="U-Map preview">
        <circle className="u-map-ring outer" cx="50" cy="50" r="44" />
        <circle className="u-map-ring middle" cx="50" cy="50" r="30" />
        <circle className="u-map-ring inner" cx="50" cy="50" r="16" />
        {axisPoints.map((axis) => (
          <line className="u-map-spoke" x1="50" y1="50" x2={axis.x} y2={axis.y} key={axis.label} />
        ))}
        <polygon className="u-map-shape" points={polygonPoints} />
        <circle className="u-map-core" cx="50" cy="50" r={mode === "clear" ? "4.2" : "3.4"} />
        {showLabels && axisPoints.filter((_, index) => [0, 2, 5].includes(index)).map((axis) => (
          <text className="u-map-axis-label" x={axis.labelX} y={axis.labelY} textAnchor="middle" dominantBaseline="middle" key={axis.label}>
            {axis.label}
          </text>
        ))}
      </svg>
    </div>
  );
}

function StarCostPill({ amount, suffix = "", className = "", as = "span", ...props }) {
  const Component = as;
  return (
    <Component className={`star-cost-pill ${className}`.trim()} {...props}>
      <Sparkles size={13} />
      <span>
        {amount}
        {suffix && <small>{suffix}</small>}
      </span>
    </Component>
  );
}

function StarTopUpSheet({ balance = 150, onClose }) {
  const [mode, setMode] = React.useState("purchase");
  const [adNoticeOpen, setAdNoticeOpen] = React.useState(false);
  const [purchaseNotice, setPurchaseNotice] = React.useState("");
  const packages = [
    [t("star.sheet.package.first"), 100, "$0.99", t("star.sheet.package.firstHint")],
    [t("star.sheet.package.basic"), 120, "$1.99", ""],
    [t("star.sheet.package.explore"), 350, "$4.99", t("star.sheet.package.recommended")],
    [t("star.sheet.package.deep"), 800, "$9.99", ""],
    [t("star.sheet.package.long"), 1800, "$19.99", ""]
  ];
  const earnLoops = [
    ["Diary 기록", "+12 Star", "50자 이상 오늘의 단서를 남기면 하루 한 번 받을 수 있어요."],
    ["출석", "+10 Star", "앱에 들어와 오늘의 흐름을 이어가면 쌓여요."],
    ["광고 리워드", "+15 Star", "광고 리워드는 준비 중이며, 기록 루프 안에서 Star를 모으는 방식으로 연결할 예정이에요."]
  ];
  const isEarnMode = mode === "earn";

  return (
    <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label={isEarnMode ? t("star.sheet.earnTitle") : t("star.sheet.title")}>
      <div className="calendar-sheet star-topup-sheet">
        <header className="calendar-header">
          <button className="icon-button" type="button" onClick={onClose} aria-label="닫기">
            <ChevronLeft size={21} />
          </button>
          <div>
            <p className="eyebrow">Star</p>
            <h2>{isEarnMode ? t("star.sheet.earnTitle") : t("star.sheet.title")}</h2>
          </div>
          <span />
        </header>
        <div className="star-topup-balance">
          <span>{t("star.sheet.balance")}</span>
          <StarCostPill amount={balance} />
        </div>
        {!isEarnMode ? (
          <>
            <p className="star-topup-copy">{t("star.sheet.copy")}</p>
            <p className="star-topup-status-note">{t("star.sheet.status")}</p>
            <button
              className="star-sheet-mode-cta"
              type="button"
              onClick={() => {
                setPurchaseNotice("");
                setMode("earn");
              }}
            >
              <span>
                <Sparkles size={15} />
                {t("star.sheet.earnButton")}
              </span>
              <ChevronRight size={16} />
            </button>
            <div className="star-sheet-divider" aria-hidden="true" />
            <div className="star-package-list" aria-label="Star 연결 준비 중 항목">
              {packages.map(([label, amount, price, badge]) => (
                <button
                  className={`star-package-row pending ${badge === t("star.sheet.package.recommended") ? "recommended" : ""}`}
                  type="button"
                  key={label}
                  onClick={() => setPurchaseNotice(t("star.sheet.package.notice"))}
                  aria-disabled="true"
                  aria-label={`${label} ${amount} Star ${price}`}
                >
                  <span>
                    <strong>{label}</strong>
                    {badge && <em>{badge}</em>}
                  </span>
                  <span className="star-package-value">
                    <StarCostPill amount={amount} />
                    <b>{price}</b>
                    <small>준비 중</small>
                  </span>
                </button>
              ))}
            </div>
            {purchaseNotice && <div className="ad-reward-notice" role="status">{purchaseNotice}</div>}
          </>
        ) : (
          <>
            <p className="star-topup-copy">{t("star.sheet.earn.copy")}</p>
            <button
              className="star-sheet-mode-cta"
              type="button"
              onClick={() => {
                setAdNoticeOpen(false);
                setMode("purchase");
              }}
            >
              <span>
                <Sparkles size={15} />
                {t("star.sheet.purchaseButton")}
              </span>
              <ChevronRight size={16} />
            </button>
            <div className="star-sheet-divider" aria-hidden="true" />
            <button className="ad-reward-cta" type="button" onClick={() => setAdNoticeOpen(true)} aria-label="광고시청 후 Star 15 획득하기">
              <span>
                <Sparkles size={16} />
                {t("star.sheet.ad.cta")}
              </span>
              <StarCostPill amount="+15" className="star-reward-pill" />
            </button>
            {adNoticeOpen && (
              <div className="ad-reward-notice" role="status">
                {t("star.sheet.ad.notice")}
              </div>
            )}
            <div className="star-earn-list">
              {earnLoops.map(([label, amount, copy]) => (
                <article className="star-earn-row" key={label}>
                  <div>
                    <strong>{label}</strong>
                    <p>{copy}</p>
                  </div>
                  <span>{amount}</span>
                </article>
              ))}
            </div>
          </>
        )}
        <button className="secondary-button star-topup-close-button" type="button" onClick={onClose}>
          {t("common.later")}
        </button>
      </div>
    </div>
  );
}

const freeExploreQuestions = [
  {
    question: "오늘 가장 오래 마음에 남은 장면은 무엇이었나요?",
    options: ["대화 속 한 문장", "혼자 있던 시간", "해야 할 일을 떠올린 순간", "몸이 먼저 반응한 감정", "아직 잘 모르겠어요"]
  },
  {
    question: "지금 나에게 조금 더 필요한 것은 무엇일까요?",
    options: ["정리할 시간", "가벼운 실행", "누군가와 나누는 대화", "충분한 쉼", "아직 잘 모르겠어요"]
  },
  {
    question: "최근 선택 앞에서 가장 신경 쓰였던 부분은 무엇인가요?",
    options: ["내 마음의 납득", "관계의 균형", "후회가 적을지", "지금 감당 가능한지"]
  },
  {
    question: "요즘 나를 조금 움직이게 하는 힘은 어디에서 오나요?",
    options: ["궁금함", "책임감", "더 나아지고 싶은 마음", "작은 약속"]
  },
  {
    question: "오늘의 나를 한 문장에 가깝게 고른다면요?",
    options: ["천천히 정리하는 중", "조금 지쳤지만 버티는 중", "다시 움직이고 싶은 중", "편안한 흐름을 찾는 중"]
  },
  {
    question: "요즘 더 알고 싶어진 나의 모습은 어느 쪽인가요?",
    options: ["왜 망설이는지", "무엇에 끌리는지", "어떤 관계가 편한지", "어떤 속도가 맞는지", "아직 잘 모르겠어요"]
  },
  {
    question: "혼자 있는 시간이 필요해지는 순간은 언제인가요?",
    options: ["생각이 많아질 때", "관계가 복잡하게 느껴질 때", "선택을 앞두고 있을 때", "몸이 지쳐 있을 때"]
  },
  {
    question: "관계 안에서 편안함이 생기는 조건은 무엇인가요?",
    options: ["천천히 들어주는 태도", "서로의 선을 지키는 분위기", "부담 없는 대화", "예측 가능한 반응", "아직 잘 모르겠어요"]
  },
  {
    question: "최근 나를 작게라도 움직이게 한 것은 무엇인가요?",
    options: ["해보고 싶은 마음", "해야 한다는 책임감", "누군가와의 약속", "나아지고 싶은 마음", "아직 떠오르지 않아요"]
  },
  {
    question: "마음이 복잡해질 때 먼저 나타나는 반응은 무엇인가요?",
    options: ["생각이 많아져요", "말수가 줄어요", "몸이 무거워져요", "누군가에게 말하고 싶어요", "아직 잘 모르겠어요"]
  },
  {
    question: "안정감을 느끼는 순간은 언제인가요?",
    options: ["계획이 보일 때", "믿을 수 있는 사람이 있을 때", "혼자 정리할 시간이 있을 때", "해야 할 일이 줄었을 때"]
  },
  {
    question: "새로운 일을 앞두고 가장 먼저 확인하는 것은 무엇인가요?",
    options: ["내가 왜 하는지", "지금 감당 가능한지", "누구와 함께하는지", "작게 시작할 수 있는지"]
  },
  {
    question: "내 생각을 표현하고 싶어지는 순간은 언제인가요?",
    options: ["오해가 생겼을 때", "중요한 기준이 흔들릴 때", "좋은 아이디어가 떠올랐을 때", "고마움이 생겼을 때", "아직 잘 모르겠어요"]
  },
  {
    question: "요즘 반복되는 선택의 기준은 무엇인가요?",
    options: ["후회가 적은 쪽", "내 마음이 납득되는 쪽", "관계를 해치지 않는 쪽", "새롭게 시도하는 쪽"]
  },
  {
    question: "최근 좋았던 순간에는 어떤 조건이 있었나요?",
    options: ["편한 사람", "조용한 환경", "분명한 목표", "자유로운 선택", "아직 잘 모르겠어요"]
  },
  {
    question: "맞지 않는다고 느낀 순간은 어디에서 왔나요?",
    options: ["속도가 너무 빨라서", "기준이 흐려져서", "관계가 부담스러워서", "내 리듬을 잃어서"]
  },
  {
    question: "요즘 나에게 필요한 회복 방식은 무엇인가요?",
    options: ["혼자 정리하기", "가볍게 움직이기", "누군가와 나누기", "충분히 쉬기", "아직 잘 모르겠어요"]
  },
  {
    question: "어떤 상황에서 호기심이 살아나나요?",
    options: ["새로운 관점을 만날 때", "이유를 파고들 때", "직접 해볼 수 있을 때", "사람들의 이야기를 들을 때"]
  },
  {
    question: "내 리듬을 지키고 싶어지는 순간은 언제인가요?",
    options: ["요구가 많아질 때", "말을 빨리 해야 할 때", "선택을 재촉받을 때", "혼자 생각할 시간이 없을 때"]
  },
  {
    question: "사람들과 함께 있을 때 더 알고 싶어지는 것은 무엇인가요?",
    options: ["내가 편해지는 조건", "내가 조심하는 이유", "내가 기대하는 태도", "내가 거리감을 느끼는 지점"]
  },
  {
    question: "요즘 성장하고 싶다고 느낀 장면이 있었나요?",
    options: ["작게 시작하고 싶었어요", "더 배우고 싶었어요", "반복을 바꾸고 싶었어요", "아직 떠오르지 않아요"]
  },
  {
    question: "감정이 오래 남을 때 그 이유는 어디에 가까운가요?",
    options: ["중요한 말이 있었어요", "기준이 흔들렸어요", "기대가 있었어요", "몸이 지쳐 있었어요", "아직 잘 모르겠어요"]
  },
  {
    question: "안정적인 선택이라고 느끼는 기준은 무엇인가요?",
    options: ["예측 가능해요", "내가 납득돼요", "관계가 무리 없어요", "작게라도 이어갈 수 있어요"]
  },
  {
    question: "실행으로 옮기기 쉬운 조건은 무엇인가요?",
    options: ["작게 시작할 수 있을 때", "이유가 분명할 때", "누군가와 약속했을 때", "실패해도 괜찮을 때"]
  },
  {
    question: "내 마음을 말하기 어려운 순간은 언제인가요?",
    options: ["상대 반응이 걱정될 때", "생각이 정리되지 않았을 때", "관계가 어색해질까 봐", "내 기준이 확실하지 않을 때"]
  },
  {
    question: "오늘의 기록에서 더 남기고 싶은 단서는 무엇인가요?",
    options: ["좋았던 것", "맞지 않았던 것", "선택의 이유", "관계 속 장면", "회복에 도움 된 것"]
  },
  {
    question: "내가 자주 확인하는 질문은 무엇인가요?",
    options: ["이게 나에게 맞을까", "내가 감당할 수 있을까", "관계가 괜찮을까", "지금 시작해도 될까"]
  },
  {
    question: "최근 나에게 맞았던 환경은 어떤 쪽이었나요?",
    options: ["조용한 환경", "자율적인 환경", "함께 조율하는 환경", "목표가 분명한 환경", "아직 잘 모르겠어요"]
  },
  {
    question: "반복되는 미룸 뒤에는 무엇이 있었나요?",
    options: ["기준을 더 확인하고 싶었어요", "부담이 컸어요", "시작 단위가 컸어요", "에너지가 부족했어요", "아직 잘 모르겠어요"]
  },
  {
    question: "지금 U-Map에서 더 살펴보고 싶은 흐름은 무엇인가요?",
    options: ["나를 움직이는 힘", "관계 안의 나", "회복과 리듬", "내 기준과 선택", "표현 방식"]
  }
];

const exploreTopics = [
  {
    id: "motive",
    title: "나를 움직이는 것",
    description: "무엇이 나를 시작하게 하고, 계속 가게 만드는지 살펴봐요.",
    axes: ["성장지향", "진취성", "탐구성"],
    firstQuestion: "요즘 나를 조금이라도 움직이게 하는 힘은 어디에서 오나요?"
  },
  {
    id: "relation",
    title: "관계 속의 나",
    description: "사람들과 함께 있을 때 편안해지는 순간과 조심스러워지는 지점을 알아봐요.",
    axes: ["관계지향", "자기표현", "감정민감도"],
    firstQuestion: "사람들과 있을 때 마음이 놓이는 순간은 언제인가요?"
  },
  {
    id: "recovery",
    title: "회복과 리듬",
    description: "지친 뒤 다시 나다워지는 방식과 나에게 맞는 속도를 살펴봐요.",
    axes: ["안정추구", "독립성", "감정민감도"],
    firstQuestion: "지친 날에 나를 조금 회복시켜주는 것은 무엇인가요?"
  }
];

const starLedgerItems = [
  ["출석", "+10", "오늘 FI-YOU에 돌아왔어요.", "2026.06.15"],
  ["Diary 작성", "+12", "50자 이상 오늘의 기록을 남겼어요.", "2026.06.14"],
  ["자유탐구", "-30", "떠오른 주제로 깊게 이어갔어요.", "2026.06.13"],
  ["연애 성향", "-50", "관계 흐름 분석의 특화 항목을 열었어요.", "2026.06.12"],
  ["관계 분석", "-50", "관계 안에서 반복되는 흐름을 살펴봤어요.", "2026.06.11"]
];

function PricingPage() {
  const starPackages = [
    ["First Purchase", "100 Star", "$0.99", "One-time welcome pack"],
    ["Basic Pack", "120 Star", "$1.99", ""],
    ["Explore Pack", "350 Star", "$4.99", "Most popular"],
    ["Deep Pack", "800 Star", "$9.99", ""],
    ["Long Journey Pack", "1,800 Star", "$19.99", ""]
  ];
  const starUses = [
    ["Free Exploration Session", "30 Star"],
    ["Love Tendency Analysis", "50 Star"],
    ["Relation-Map", "80 Star / person"],
    ["Past Self Comparison", "30 Star"]
  ];
  const rewards = [
    ["Daily check-in", "+10 Star"],
    ["Diary entry", "+12 Star"],
    ["Rewarded ad", "+15 Star"]
  ];

  return (
    <main className="pricing-page">
      <section className="pricing-hero">
        <div className="brand-mark pricing-mark">
          <Sparkles size={28} />
        </div>
        <p className="eyebrow">AI Self Discovery Platform</p>
        <h1>FI-YOU Pricing</h1>
        <p>
          FI-YOU uses Star credits to unlock deeper self-discovery features,
          including exploration sessions, Relation-Map, and extended analysis.
        </p>
      </section>

      <section className="pricing-section glass-card">
        <div className="pricing-section-header">
          <div>
            <p className="eyebrow">Star Credits</p>
            <h2>Star Packages</h2>
          </div>
          <StarCostPill amount="150" />
        </div>
        <div className="pricing-package-grid">
          {starPackages.map(([name, amount, price, badge]) => (
            <article className={`pricing-package ${badge === "Most popular" ? "featured" : ""}`} key={name}>
              <div>
                <span>{name}</span>
                {badge && <em>{badge}</em>}
              </div>
              <strong>{amount}</strong>
              <p>{price}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="pricing-two-column">
        <article className="pricing-section glass-card">
          <p className="eyebrow">Use Star</p>
          <h2>Unlock deeper features</h2>
          <div className="pricing-list">
            {starUses.map(([label, cost]) => (
              <div className="pricing-row" key={label}>
                <span>{label}</span>
                <strong>{cost}</strong>
              </div>
            ))}
          </div>
        </article>

        <article className="pricing-section glass-card">
          <p className="eyebrow">Earn Star</p>
          <h2>Free rewards</h2>
          <div className="pricing-list">
            {rewards.map(([label, amount]) => (
              <div className="pricing-row" key={label}>
                <span>{label}</span>
                <strong>{amount}</strong>
              </div>
            ))}
          </div>
        </article>
      </section>

      <section className="pricing-section pricing-policy glass-card">
        <ShieldCheck size={22} />
        <div>
          <h2>Important notice</h2>
          <p>
            FI-YOU does not provide medical diagnosis, psychological counseling, or treatment.
            Analysis results are self-understanding references based on the user's records and conversations.
          </p>
          <p>
            For payment support or refund requests, contact support@fi-you.com.
            Used Star credits may be excluded from refunds.
          </p>
        </div>
      </section>

      <a className="pricing-home-link" href="/">
        Go to FI-YOU
        <ArrowRight size={18} />
      </a>
    </main>
  );
}

function App() {
  const isPricingPage = window.location.pathname.replace(/\/+$/, "") === "/pricing";
  if (isPricingPage) {
    return <PricingPage />;
  }

  const initialScreen = new URLSearchParams(window.location.search).get("screen")?.trim().toLowerCase();
  const isAuthReturn = initialScreen === "home" || initialScreen === "auth";
  const [step, setStep] = React.useState(isAuthReturn ? "auth-loading" : "intro");
  const [activeTab, setActiveTab] = React.useState("home");
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [answers, setAnswers] = React.useState({});
  const [note, setNote] = React.useState("");
  const [session, setSession] = React.useState(null);
  const [profile, setProfile] = React.useState(null);
  const [onboardingQuestions, setOnboardingQuestions] = React.useState(firstQuestions);
  const [freeQuestions, setFreeQuestions] = React.useState(freeExploreQuestions);
  const [relationQuestions, setRelationQuestions] = React.useState([]);
  const [starBalance, setStarBalance] = React.useState(150);
  const [latestUMapSnapshot, setLatestUMapSnapshot] = React.useState(null);
  const [entitlements, setEntitlements] = React.useState([]);
  const [authNotice, setAuthNotice] = React.useState("");
  const [profileNotice, setProfileNotice] = React.useState("");
  const [questionNotice, setQuestionNotice] = React.useState("");
  const [profileSaving, setProfileSaving] = React.useState(false);
  const [questionSaving, setQuestionSaving] = React.useState(false);
  const profileSavingRef = React.useRef(false);
  const questionSavingRef = React.useRef(false);
  const userId = session?.user?.id;

  React.useEffect(() => {
    if (!window.sessionStorage.getItem("fiyou_session_id")) {
      window.sessionStorage.setItem("fiyou_session_id", crypto.randomUUID());
    }
  }, []);

  const loadUserData = React.useCallback(async (nextSession) => {
    if (!nextSession?.user) return;
    try {
      const nextProfile = await ensureProfile(nextSession.user);
      setProfile(nextProfile);
      await recordLegalConsent({ locale: nextProfile?.preferred_language || "ko" }).catch((error) => {
        console.warn("Legal consent record skipped", error);
      });
      await grantAttendanceStar().catch(() => null);
      const [requiredQuestions, basicQuestions, relationMapQuestions, answeredFreeIds, balance, snapshot, entitlementRows] = await Promise.all([
        fetchQuestions("onboarding_required"),
        fetchQuestions("basic_free"),
        fetchQuestions("relation_map"),
        fetchAnsweredQuestionIds("answers", nextSession.user.id).catch(() => new Set()),
        getStarBalance(),
        fetchLatestUMapSnapshot().catch(() => null),
        fetchEntitlements().catch(() => [])
      ]);
      if (requiredQuestions.length) setOnboardingQuestions(requiredQuestions);
      if (basicQuestions.length) setFreeQuestions(basicQuestions.filter((question) => !answeredFreeIds.has(question.id)));
      if (relationMapQuestions.length) setRelationQuestions(relationMapQuestions);
      setStarBalance(balance);
      setLatestUMapSnapshot(snapshot);
      setEntitlements(entitlementRows);
      if (initialScreen !== "intro" && nextProfile?.onboarding_completed) {
        setStep("home");
      } else if (initialScreen !== "intro") {
        const hasProfileBasics = Boolean(nextProfile?.nickname && nextProfile?.birthday);
        setStep(hasProfileBasics ? "ready" : "profile");
      }
    } catch (error) {
      console.warn("Supabase bootstrap failed", error);
      setAuthNotice("저장된 데이터를 불러오지 못했어요. 네트워크와 Supabase 설정을 확인해주세요.");
    }
  }, [initialScreen]);

  React.useEffect(() => {
    let alive = true;
    getSession()
      .then(async (nextSession) => {
        if (!alive) return;
        setSession(nextSession);
        if (nextSession) {
          await loadUserData(nextSession);
          return;
        }
        if (isAuthReturn) setStep("login");
      })
      .catch((error) => {
        console.warn("Supabase session failed", error);
      });

    const { data } = onAuthStateChange((nextSession) => {
      setSession(nextSession);
      if (nextSession) {
        trackEvent(kpiEvents.googleLoginCompleted, { provider: "google" });
        loadUserData(nextSession);
      }
    });

    return () => {
      alive = false;
      data?.subscription?.unsubscribe?.();
    };
  }, [loadUserData]);

  React.useEffect(() => {
    const handler = (event) => {
      if (!session?.user?.id || !event.detail?.name) return;
      recordAppEvent(event.detail.name, event.detail.properties || {}).catch((error) => {
        console.warn("KPI event record skipped", error);
      });
    };
    window.addEventListener("fiyou:kpi", handler);
    return () => window.removeEventListener("fiyou:kpi", handler);
  }, [session?.user?.id]);

  const goHome = React.useCallback(() => {
    setActiveTab("home");
    setStep("home");
    const nextUrl = new URL(window.location.href);
    nextUrl.searchParams.set("screen", "home");
    window.history.replaceState({}, "", `${nextUrl.pathname}?${nextUrl.searchParams.toString()}${nextUrl.hash}`);
  }, []);

  const startQuestions = () => {
    setQuestionIndex(0);
    setAnswers({});
    setNote("");
    setStep("question");
  };

  const selectedOption = answers[questionIndex] ?? "";
  const currentOnboardingQuestion = onboardingQuestions[questionIndex] || firstQuestions[questionIndex];

  const goNextQuestion = async () => {
    if (questionSavingRef.current) return;
    setQuestionNotice("");
    if (userId && currentOnboardingQuestion?.id) {
      const selectedRecord = currentOnboardingQuestion.optionRecords?.find((option) => option.label === selectedOption);
      try {
        questionSavingRef.current = true;
        setQuestionSaving(true);
        await upsertOnboardingAnswer({
          userId,
          questionId: currentOnboardingQuestion.id,
          selectedOptionId: selectedRecord?.id || null,
          optionalText: note
        });
      } catch (error) {
        console.warn("Failed to save onboarding answer", error);
        setQuestionNotice("답변을 저장하지 못했어요. 연결을 확인한 뒤 다시 시도해주세요.");
        return;
      } finally {
        questionSavingRef.current = false;
        setQuestionSaving(false);
      }
    }

    const onboardingTotal = onboardingQuestions.length || firstQuestions.length;
    if (questionIndex < onboardingTotal - 1) {
      setQuestionIndex((current) => current + 1);
      setNote("");
      return;
    }
    if (userId) {
      try {
        questionSavingRef.current = true;
        setQuestionSaving(true);
        const nextProfile = await completeOnboarding(userId);
        setProfile(nextProfile);
      } catch (error) {
        console.warn("Failed to complete onboarding", error);
        setQuestionNotice("첫 단서 완료 상태를 저장하지 못했어요. 잠시 후 다시 시도해주세요.");
        return;
      } finally {
        questionSavingRef.current = false;
        setQuestionSaving(false);
      }
    }
    setStep("feedback");
  };

  const handleGoogleLogin = async () => {
    setAuthNotice("");
    trackEvent(kpiEvents.googleLoginStarted);
    try {
      const { error } = await signInWithGoogle();
      if (error) throw error;
    } catch (error) {
      console.warn("Google OAuth failed", error);
      setAuthNotice("Google 로그인 연결을 확인하지 못했어요. 잠시 후 다시 시도해주세요.");
    }
  };

  const handleProfileComplete = async ({ nickname, birthday }) => {
    if (profileSavingRef.current) return;
    setProfileNotice("");
    if (userId) {
      try {
        profileSavingRef.current = true;
        setProfileSaving(true);
        const nextProfile = await updateProfile(userId, { nickname, birthday });
        setProfile(nextProfile);
      } catch (error) {
        console.warn("Failed to save profile", error);
        setProfileNotice("프로필을 저장하지 못했어요. 연결을 확인한 뒤 다시 시도해주세요.");
        return;
      } finally {
        profileSavingRef.current = false;
        setProfileSaving(false);
      }
    }
    setStep("ready");
  };

  const saveFreeAnswer = async (question, selected, optionalText) => {
    if (!userId || !question?.id) return;
    const selectedRecord = question.optionRecords?.find((option) => option.label === selected);
    await upsertAnswer({
      userId,
      questionId: question.id,
      selectedOptionId: selectedRecord?.id || null,
      optionalText
    });
    setFreeQuestions((current) => current.filter((item) => item.id !== question.id));
    trackEvent(kpiEvents.questionAnswered, {
      questionId: question.id,
      hasOptionalText: Boolean(optionalText?.trim())
    });
    try {
      setLatestUMapSnapshot(await fetchLatestUMapSnapshot());
    } catch (error) {
      console.warn("Failed to refresh U-Map snapshot after answer", error);
    }
  };

  const refreshStarBalance = React.useCallback(async () => {
    if (!session) return;
    try {
      setStarBalance(await getStarBalance());
    } catch (error) {
      console.warn("Failed to refresh Star balance", error);
    }
  }, [session]);

  const refreshUMapSnapshot = React.useCallback(async () => {
    if (!session) return;
    try {
      setLatestUMapSnapshot(await fetchLatestUMapSnapshot());
    } catch (error) {
      console.warn("Failed to refresh U-Map snapshot", error);
    }
  }, [session]);

  return (
    <main className="app-shell">
      <div className="aurora aurora-one" />
      <div className="aurora aurora-two" />
      <section className="phone-frame" aria-label="FI-YOU first run">
        <StatusBar />
        {step === "auth-loading" && <AuthReturnScreen />}
        {step === "intro" && <IntroScreen onNext={() => setStep("login")} />}
        {step === "login" && (
          <LoginScreen onBack={() => setStep("intro")} onContinue={handleGoogleLogin} notice={authNotice} />
        )}
        {step === "profile" && (
          <ProfileSetupScreen onBack={() => setStep("login")} onComplete={handleProfileComplete} saving={profileSaving} notice={profileNotice} />
        )}
        {step === "ready" && <ReadyScreen onBack={() => setStep("profile")} onStart={startQuestions} />}
        {step === "question" && (
          <QuestionScreen
            question={currentOnboardingQuestion}
            questionIndex={questionIndex}
            selectedOption={selectedOption}
            note={note}
            onBack={() => {
              if (questionIndex === 0) {
                setStep("ready");
                return;
              }
              setQuestionIndex((current) => current - 1);
            }}
            onSelect={(option) => setAnswers((current) => ({ ...current, [questionIndex]: option }))}
            onNoteChange={setNote}
            onNext={goNextQuestion}
            saving={questionSaving}
            notice={questionNotice}
          />
        )}
        {step === "feedback" && (
          <FeedbackScreen onContinue={goHome} />
        )}
        {step === "home" && (
          <MainAppShell
            activeTab={activeTab}
            onTabChange={setActiveTab}
            onExplore={startQuestions}
            session={session}
            profile={profile}
            freeQuestions={freeQuestions}
            relationQuestions={relationQuestions}
            starBalance={starBalance}
            onStarBalanceChange={setStarBalance}
            onStarBalanceRefresh={refreshStarBalance}
            onUMapSnapshotRefresh={refreshUMapSnapshot}
            onSaveFreeAnswer={saveFreeAnswer}
            latestUMapSnapshot={latestUMapSnapshot}
            entitlements={entitlements}
          />
        )}
      </section>
    </main>
  );
}

function StatusBar() {
  return (
    <div className="status-bar">
      <span>9:41</span>
      <span className="status-icons">●●● 5G ▰</span>
    </div>
  );
}

function AuthReturnScreen() {
  return (
    <div className="screen feedback-screen auth-return-screen">
      <div className="map-ghost" aria-hidden="true">
        <Orbit size={32} />
        <span /><span /><span />
      </div>
      <section className="feedback-copy">
        <p className="eyebrow">FI-YOU</p>
        <h1>{t("auth.return.title")}</h1>
        <div className="loading-lines">
          <p>{t("auth.return.copy")}</p>
        </div>
      </section>
      <div className="loading-dots" aria-label="이어갈 화면 확인 중">
        <span />
        <span />
        <span />
      </div>
    </div>
  );
}

function IntroScreen({ onNext }) {
  return (
    <div className="screen intro-screen">
      <div className="brand-block">
        <div className="brand-mark"><Sparkles size={24} /></div>
        <p className="eyebrow">{t("onboarding.brand.eyebrow")}</p>
        <h1>FI-YOU</h1>
        <p className="brand-subtitle">{t("onboarding.brand.subtitle")}</p>
      </div>

      <div className="hero-orbit" aria-hidden="true">
        <span className="orbit-dot dot-a" />
        <span className="orbit-dot dot-b" />
        <span className="orbit-dot dot-c" />
        <div className="core-glow"><Compass size={34} /></div>
      </div>

      <section className="glass-card intro-card">
        <ChunkText as="h2" chunks={chunk(t("onboarding.intro.title.line1"), t("onboarding.intro.title.line2"))} />
        <p>{t("onboarding.intro.body")}</p>
      </section>

      <div className="principle-list">
        <Principle icon={<MessageCircle size={18} />} text={t("onboarding.principle.discovery")} />
        <Principle icon={<Sparkles size={18} />} text={t("onboarding.principle.flow")} />
        <Principle icon={<LockKeyhole size={18} />} text={t("onboarding.principle.notice")} />
      </div>

      <button
        className="primary-button"
        type="button"
        onClick={onNext}
        aria-label="온보딩 다음"
        data-testid="intro-next-button"
      >
        {t("common.next")}
        <ArrowRight size={19} />
      </button>
    </div>
  );
}

function LoginScreen({ onBack, onContinue, notice }) {
  return (
    <div className="screen login-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>시작하기</span>
        <i />
      </header>

      <div className="login-copy">
        <p className="eyebrow">Welcome to FI-YOU</p>
        <ChunkText as="h1" chunks={chunk(t("auth.login.title.line1"), t("auth.login.title.line2"))} />
        <p>{t("auth.login.body")}</p>
      </div>

      <section className="glass-card account-card">
        <div className="account-icon"><Sparkles size={24} /></div>
        <h2>{t("auth.login.card.title")}</h2>
        <ul>
          <li><Check size={16} />{t("auth.login.card.item.questions")}</li>
          <li><Check size={16} />{t("auth.login.card.item.umap")}</li>
          <li><Check size={16} />{t("auth.login.card.item.preview")}</li>
        </ul>
      </section>

      <button
        className="google-button"
        type="button"
        onClick={onContinue}
        aria-label="Google로 계속하기"
        data-testid="google-login-button"
      >
        <GoogleIcon />
        {t("auth.login.google")}
      </button>

      {notice && <p className="legal-copy">{notice}</p>}
      <p className="legal-copy">{t("auth.legal.notice")}</p>
    </div>
  );
}

function ProfileSetupScreen({ onBack, onComplete, saving = false, notice = "" }) {
  const [nickname, setNickname] = React.useState("");
  const [birth, setBirth] = React.useState({ year: "", month: "", day: "" });
  const monthRef = React.useRef(null);
  const dayRef = React.useRef(null);

  const isComplete = nickname.trim() && birth.year.length === 4 && birth.month.length === 2 && birth.day.length === 2;

  const updateBirth = (field, value) => {
    const maxLength = field === "year" ? 4 : 2;
    const nextValue = value.replace(/\D/g, "").slice(0, maxLength);
    setBirth((current) => ({ ...current, [field]: nextValue }));
    if (field === "year" && nextValue.length === 4) monthRef.current?.focus();
    if (field === "month" && nextValue.length === 2) dayRef.current?.focus();
  };

  return (
    <div className="screen profile-setup-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>{t("profileSetup.header")}</span>
        <i />
      </header>

      <section className="profile-hero">
        <p className="eyebrow">{t("profileSetup.eyebrow")}</p>
        <h1>{t("profileSetup.title")}</h1>
      </section>

      <section className="glass-card form-card">
        <label className="field-label" htmlFor="nickname">{t("profileSetup.nickname")}</label>
        <input
          id="nickname"
          className="text-field"
          value={nickname}
          onChange={(event) => setNickname(event.target.value)}
          placeholder={t("profileSetup.nickname.placeholder")}
          autoComplete="nickname"
        />

        <div className="birth-heading">
          <div>
            <label className="field-label" htmlFor="birth-year">{t("profileSetup.birth.label")}</label>
            <p>{t("profileSetup.birth.helper")}</p>
          </div>
        </div>

        <div className="birth-grid" aria-label="생년월일">
          <input id="birth-year" className="date-field" inputMode="numeric" maxLength={4} value={birth.year} onChange={(event) => updateBirth("year", event.target.value)} placeholder="YYYY" autoComplete="bday-year" />
          <input ref={monthRef} className="date-field" inputMode="numeric" maxLength={2} value={birth.month} onChange={(event) => updateBirth("month", event.target.value)} placeholder="MM" autoComplete="bday-month" />
          <input ref={dayRef} className="date-field" inputMode="numeric" maxLength={2} value={birth.day} onChange={(event) => updateBirth("day", event.target.value)} placeholder="DD" autoComplete="bday-day" />
        </div>
      </section>

      <section className="reassurance-card">
        <ShieldCheck size={19} />
        <p>나이는 당신을 분류하기 위한 정보가 아니에요. 이후 질문을 더 섬세하게 맞추기 위해 사용됩니다.</p>
      </section>

      <button
        className="primary-button setup-button"
        type="button"
        disabled={!isComplete || saving}
        onClick={() => onComplete({
          nickname: nickname.trim(),
          birthday: `${birth.year}-${birth.month}-${birth.day}`
        })}
      >
        {saving ? "프로필 저장 중" : isComplete ? "FI-YOU 시작하기" : "이름과 생년월일을 입력해주세요"}
      </button>
      {notice && <p className="legal-copy">{notice}</p>}
    </div>
  );
}

function ReadyScreen({ onBack, onStart }) {
  return (
    <div className="screen ready-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>첫 단서 준비</span>
        <i />
      </header>

      <div className="ready-content">
        <div className="ready-mark"><Sparkles size={32} /></div>
        <p className="eyebrow">U-Map starts here</p>
        <h1>좋아요, 이제 첫 단서를 남겨볼까요?</h1>
        <p>다섯 개의 짧은 질문으로 시작해요. 지금 가까운 쪽을 고르면 충분합니다.</p>
      </div>

      <div className="ready-cta-area">
        <p className="ready-terms-above">첫 질문을 시작하면 서비스 약관과 개인정보 처리방침에 동의하게 됩니다.</p>
        <button className="primary-button" type="button" onClick={onStart}>
          첫 질문 시작하기
          <ArrowRight size={19} />
        </button>
        <p className="ready-terms-below">FI-YOU는 전문적 판단을 대신하지 않는 자기이해 서비스예요.</p>
      </div>
    </div>
  );
}

function QuestionScreen({ question, questionIndex, selectedOption, note, onBack, onSelect, onNoteChange, onNext, saving = false, notice = "" }) {
  const isLast = questionIndex === firstQuestions.length - 1;
  const [noteSheetOpen, setNoteSheetOpen] = React.useState(false);
  const notePreview = note.trim() ? `${note.trim().slice(0, 28)}${note.trim().length > 28 ? "..." : ""}` : "";

  return (
    <div className="screen question-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>첫 단서 {questionIndex + 1} / 5</span>
        <i />
      </header>

      <div className="question-progress" aria-hidden="true">
        <span style={{ width: `${((questionIndex + 1) / firstQuestions.length) * 100}%` }} />
      </div>

      <section className="question-copy">
        <p className="eyebrow">{isLast ? "다음 탐구 방향" : "첫 단서"}</p>
        <h1 className="question-heading">{question.question}</h1>
        <p>지금 가까운 쪽이면 충분해요.</p>
      </section>

      <div className={`option-list ${question.options.length > 2 ? "multi-option-list" : ""}`}>
        {question.options.map((option) => (
          <button
            className={`option-card ${selectedOption === option ? "selected" : ""}`}
            type="button"
            key={option}
            onClick={() => onSelect(option)}
          >
            <span>{option}</span>
            {selectedOption === option && <Check size={18} />}
          </button>
        ))}
      </div>

      {question.note && (
        <section className="note-card onboarding-note-card">
          <div className="onboarding-note-separator" aria-hidden="true" />
          <div className="onboarding-note-label">선택한 답을 조금 더 설명하기</div>
          <button className={`onboarding-note-row ${notePreview ? "filled" : ""}`} type="button" onClick={() => setNoteSheetOpen(true)}>
            <span>
              {notePreview ? <strong>{notePreview}</strong> : <em>더 자세히 알려주세요. 적지 않아도 괜찮아요.</em>}
            </span>
            {notePreview ? <Check size={18} /> : <ChevronRight size={18} />}
          </button>
        </section>
      )}

      <button className="primary-button question-button" type="button" disabled={!selectedOption || saving} onClick={onNext}>
        {saving ? "저장 중" : !selectedOption ? "가까운 쪽을 골라주세요" : isLast ? "첫 단서 저장하기" : "다음"}
        {selectedOption && <ArrowRight size={19} />}
      </button>
      {notice && <p className="legal-copy">{notice}</p>}

      {question.note && noteSheetOpen && (
        <div className="calendar-overlay onboarding-note-overlay" role="dialog" aria-modal="true" aria-label="선택 서술 입력">
          <div className="calendar-sheet onboarding-note-sheet">
            <header className="calendar-header">
              <h2>조금 더 남기고 싶다면</h2>
              <button className="icon-button" type="button" onClick={() => setNoteSheetOpen(false)} aria-label="닫기">
                <ChevronDown size={21} />
              </button>
            </header>
            <textarea
              id="discovery-note"
              value={note}
              onChange={(event) => onNoteChange(event.target.value.slice(0, 300))}
              placeholder="선택한 질문에 대해 더 자세히 알려주세요. 적지 않아도 괜찮아요."
              autoFocus
            />
            <div className="onboarding-note-sheet-meta">
              <span>{note.length} / 300</span>
              <button className="primary-button" type="button" onClick={() => setNoteSheetOpen(false)}>
                저장
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function FeedbackScreen({ onContinue }) {
  const [messageIndex, setMessageIndex] = React.useState(0);
  const continueRef = React.useRef(onContinue);

  React.useEffect(() => {
    continueRef.current = onContinue;
  }, [onContinue]);

  React.useEffect(() => {
    let completed = false;
    const complete = () => {
      if (completed) return;
      completed = true;
      continueRef.current();
    };
    const timer = window.setTimeout(complete, 4300);
    const fallback = window.setTimeout(complete, 5200);
    return () => {
      completed = true;
      window.clearTimeout(timer);
      window.clearTimeout(fallback);
    };
  }, []);

  React.useEffect(() => {
    const interval = window.setInterval(() => {
      setMessageIndex((current) => Math.min(current + 1, loadingMessages.length - 1));
    }, 1300);

    return () => window.clearInterval(interval);
  }, [loadingMessages.length]);

  return (
    <div className="screen feedback-screen">
      <div className="map-ghost" aria-hidden="true">
        <Orbit size={36} />
        <span /><span /><span />
      </div>
      <section className="feedback-copy">
        <p className="eyebrow">{t("transition.eyebrow")}</p>
        <h1>{t("transition.title")}</h1>
        <div className="loading-lines">
          <p key={loadingMessages[messageIndex]}>{loadingMessages[messageIndex]}</p>
        </div>
      </section>
      <div className="loading-dots" aria-label="Home으로 이동 중">
        <span />
        <span />
        <span />
      </div>
    </div>
  );
}

function MainAppShell({
  activeTab,
  onTabChange,
  onExplore,
  session,
  profile,
  freeQuestions,
  relationQuestions,
  starBalance: syncedStarBalance = 150,
  onStarBalanceChange,
  onStarBalanceRefresh,
  onUMapSnapshotRefresh,
  onSaveFreeAnswer,
  latestUMapSnapshot,
  entitlements
}) {
  const [freeLoopOpen, setFreeLoopOpen] = React.useState(false);
  const [loveUnlocked, setLoveUnlocked] = React.useState(false);
  const [mapFlow, setMapFlow] = React.useState("main");
  const [pendingStarUse, setPendingStarUse] = React.useState(null);
  const [starTopUpOpen, setStarTopUpOpen] = React.useState(false);
  const [starBalance, setStarBalance] = React.useState(syncedStarBalance);
  const [starActionPending, setStarActionPending] = React.useState(false);
  const [starActionNotice, setStarActionNotice] = React.useState("");
  const starActionPendingRef = React.useRef(false);

  React.useEffect(() => {
    setStarBalance(syncedStarBalance);
  }, [syncedStarBalance]);

  React.useEffect(() => {
    const unlocked = entitlements?.some((item) => item.entitlement_type === "love_analysis");
    if (unlocked) setLoveUnlocked(true);
  }, [entitlements]);

  const openFreeLoop = () => {
    onTabChange("explore");
    setFreeLoopOpen(true);
  };

  const openStarTopUp = () => {
    setStarTopUpOpen(true);
  };

  const closeStarTopUp = () => {
    setStarTopUpOpen(false);
  };

  const handleSpendFreeExplore = async () => {
    if (starActionPendingRef.current) return false;
    if (!session) return true;
    try {
      starActionPendingRef.current = true;
      setStarActionPending(true);
      await spendStar({
        reason: "free_explore",
        amount: 30,
        refType: "free_explore_session",
        refId: crypto.randomUUID()
      });
      trackEvent(kpiEvents.starSpent, { reason: "free_explore", amount: 30 });
      await onStarBalanceRefresh?.();
      return true;
    } catch (error) {
      if (isInsufficientStarError(error)) {
        trackEvent(kpiEvents.starShortageShown, { reason: "free_explore", amount: 30 });
        openStarTopUp("free_explore");
        return false;
      }
      console.warn("Failed to spend Star for free explore", error);
      return false;
    } finally {
      starActionPendingRef.current = false;
      setStarActionPending(false);
    }
  };

  const handleUnlockLove = async () => {
    if (starActionPendingRef.current) return;
    if (!session) {
      openStarTopUp("love");
      return;
    }
    try {
      starActionPendingRef.current = true;
      setStarActionPending(true);
      await unlockEntitlement({ type: "love_analysis", cost: 50, refId: null });
      trackEvent(kpiEvents.starSpent, { reason: "love_analysis", amount: 50 });
      setLoveUnlocked(true);
      await onStarBalanceRefresh?.();
    } catch (error) {
      if (isInsufficientStarError(error)) {
        trackEvent(kpiEvents.starShortageShown, { reason: "love_analysis", amount: 50 });
        openStarTopUp("love");
      }
      else console.warn("Failed to unlock love analysis", error);
    } finally {
      starActionPendingRef.current = false;
      setStarActionPending(false);
    }
  };

  const handleConfirmStarUse = async () => {
    if (starActionPendingRef.current) return;
    if (!pendingStarUse) return;
    setStarActionNotice("");
    if (!session) {
      setMapFlow(pendingStarUse.after);
      return;
    }
    try {
      starActionPendingRef.current = true;
      setStarActionPending(true);
      if (pendingStarUse.kind === "compare") {
        await unlockEntitlement({ type: "past_compare", cost: 30, refId: null });
        trackEvent(kpiEvents.starSpent, { reason: "past_compare", amount: 30 });
      }
      if (pendingStarUse.kind === "relation") {
        const relationDraft = pendingStarUse.partner || {};
        const savedRelation = relationDraft.id
          ? relationDraft
          : await createRelation({
            userId: session.user.id,
            name: relationDraft.name,
            relationshipType: relationDraft.type
          });
        await unlockEntitlement({ type: "relation_map", cost: 80, refId: savedRelation.id });
        setPendingStarUse((current) => current ? { ...current, partner: savedRelation } : current);
        trackEvent(kpiEvents.starSpent, { reason: "relation_map", amount: 80 });
      }
      await onStarBalanceRefresh?.();
      setMapFlow(pendingStarUse.after);
    } catch (error) {
      if (isInsufficientStarError(error)) {
        trackEvent(kpiEvents.starShortageShown, { reason: pendingStarUse.kind, amount: pendingStarUse.cost });
        openStarTopUp(pendingStarUse.kind);
      }
      else {
        console.warn("Failed to unlock Star content", error);
        setStarActionNotice("Star 사용을 완료하지 못했어요. 잠시 후 다시 시도해주세요.");
      }
    } finally {
      starActionPendingRef.current = false;
      setStarActionPending(false);
    }
  };

  if (freeLoopOpen) {
    return (
      <div className="main-app-screen">
        <FreeQuestionLoop questions={freeQuestions} onAnswer={onSaveFreeAnswer} onClose={() => setFreeLoopOpen(false)} />
      </div>
    );
  }

  if (mapFlow === "growth") {
    return (
      <div className="main-app-screen">
        <GrowthScreen
          onBack={() => setMapFlow("main")}
          onOpenCompare={() => {
            setPendingStarUse({
              kind: "compare",
              title: "과거의 나와 비교하기",
              ctaLabel: "과거 비교 열기",
              cost: 30,
              description: "첫 단서 시점과 최근 기록을 나란히 보며 변화한 흐름을 살펴봐요.",
              after: "compareResult"
            });
            setMapFlow("starConfirm");
          }}
        />
      </div>
    );
  }

  if (mapFlow === "starConfirm" && pendingStarUse) {
    return (
      <div className="main-app-screen">
        <StarUseConfirmScreen
          action={pendingStarUse}
          balance={starBalance}
          onBack={() => setMapFlow(pendingStarUse.kind === "relation" ? "relationStart" : "growth")}
          onConfirm={handleConfirmStarUse}
          pending={starActionPending}
          notice={starActionNotice}
        />
      </div>
    );
  }

  if (mapFlow === "compareResult") {
    return (
      <div className="main-app-screen">
        <PastCompareResultScreen onBack={() => setMapFlow("growth")} />
      </div>
    );
  }

  if (mapFlow === "relationStart") {
    return (
      <div className="main-app-screen">
        <RelationStartScreen
          onBack={() => setMapFlow("main")}
          onOpenConfirm={(partner) => {
            setStarActionNotice("");
            setPendingStarUse({
              kind: "relation",
              title: "Relation-Map",
              ctaLabel: "Relation-Map 열기",
              cost: 80,
              description: `${partner.name || "상대"}님과의 관계 안에서 내가 경험하는 흐름을 Relation-Map으로 정리해요.`,
              after: "relationQuestions",
              partner
            });
            setMapFlow("starConfirm");
          }}
        />
      </div>
    );
  }

  if (mapFlow === "relationQuestions") {
    return (
      <div className="main-app-screen">
        <RelationQuestionScreen
          partner={pendingStarUse?.partner}
          questions={relationQuestions}
          onBack={() => setMapFlow("relationStart")}
          onAnswer={async (question, selected, memo) => {
            if (!session?.user?.id || !pendingStarUse?.partner?.id || !question?.id) return;
            const selectedRecord = question.optionRecords?.find((option) => option.label === selected);
            await upsertRelationAnswer({
              userId: session.user.id,
              relationId: pendingStarUse.partner.id,
              questionId: question.id,
              selectedOptionId: selectedRecord?.id || null,
              optionalText: memo
            });
            await onUMapSnapshotRefresh?.();
          }}
          onComplete={() => setMapFlow("relationResult")}
        />
      </div>
    );
  }

  if (mapFlow === "relationResult") {
    return (
      <div className="main-app-screen">
        <RelationMapResultScreen partner={pendingStarUse?.partner} onBack={() => setMapFlow("main")} />
      </div>
    );
  }

  return (
    <div className="main-app-screen">
      {activeTab === "home" && (
        <HomeScreen onExplore={openFreeLoop} starBalance={starBalance} snapshot={latestUMapSnapshot} onOpenTopUp={() => openStarTopUp()} />
      )}
      {activeTab === "diary" && <DiaryScreen session={session} onStarBalanceRefresh={onStarBalanceRefresh} onUMapSnapshotRefresh={onUMapSnapshotRefresh} />}
      {activeTab === "explore" && <ExploreScreen onExplore={openFreeLoop} onStartFreeExplore={handleSpendFreeExplore} starBalance={starBalance} />}
      {activeTab === "map" && (
        <UMapScreen
          onOpenGrowth={() => setMapFlow("growth")}
          onOpenRelationship={() => setMapFlow("relationStart")}
          snapshot={latestUMapSnapshot}
        />
      )}
      {activeTab === "settings" && (
        <SettingsScreen
          loveUnlocked={loveUnlocked}
          profile={profile}
          session={session}
          onUnlockLove={handleUnlockLove}
          starBalance={starBalance}
          onStarBalanceChange={setStarBalance}
          onDataReset={onUMapSnapshotRefresh}
          onSignOut={() => signOut().catch((error) => console.warn("Sign out failed", error))}
        />
      )}
      <BottomNav activeTab={activeTab} onTabChange={onTabChange} />
      {starTopUpOpen && (
        <StarTopUpSheet
          balance={starBalance}
          onClose={closeStarTopUp}
        />
      )}
    </div>
  );
}

function HomeScreen({ onExplore, starBalance = 150, snapshot, onOpenTopUp }) {
  const hasSnapshot = Boolean(snapshot?.axis_scores && Object.keys(snapshot.axis_scores).length);
  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="home-topbar app-page-header">
        <div className="home-title-only">
          <h1>{t("home.header")}</h1>
        </div>
        <button className="status-pill" type="button" onClick={onOpenTopUp} aria-label={`Star 관리, 보유 Star ${starBalance}`}>
          <span className="status-pill-section point-section">
            <Sparkles size={14} />
            {starBalance}
          </span>
          <span className="status-pill-section level-badge">탐험가</span>
        </button>
      </header>

      <section className="glass-card next-question-card">
        <p className="card-kicker">{t("home.next.kicker")}</p>
        <h2>{t("home.next.title")}</h2>
        <p>{t("home.next.body")}</p>
        <div className="free-progress">
          <span>{t("home.progress.label")}</span>
          <strong>5 / 35</strong>
        </div>
        <div className="mini-progress" aria-hidden="true">
          <span style={{ width: "14%" }} />
        </div>
        <button className="primary-button" type="button" onClick={onExplore}>
          {t("home.question.cta")}
          <ArrowRight size={19} />
        </button>
      </section>

      <section className="glass-card u-map-home-card">
        <div className="home-card-head">
          <div>
            <p className="card-kicker home-kicker-lockup"><Orbit size={14} />U-Map</p>
            <h2>{hasSnapshot ? t("home.umap.ready") : t("home.umap.empty")}</h2>
          </div>
        </div>
        <UMapPreview mode={hasSnapshot ? "clear" : "initial"} size="compact" showLabels scores={snapshot?.axis_scores} />
        <div className="u-map-home-status" aria-label="U-Map 현재 상태">
          <span>{t("home.umap.status.first")}</span>
          <span>{t("home.umap.status.next")}</span>
        </div>
      </section>

      <section className="home-two-col">
        <button className="glass-card home-action-card" type="button">
          <span className="home-action-lockup"><BookOpen size={16} />다이어리</span>
          <strong>오늘의 장면 남기기</strong>
        </button>
        <button className="glass-card home-action-card" type="button" onClick={onExplore}>
          <span className="home-action-lockup"><Sparkles size={16} />다음 행동</span>
          <strong>질문 하나 더 이어가기</strong>
        </button>
      </section>

      <section className="locked-content-card">
        <LockKeyhole size={17} />
        <div>
          <strong>더 깊은 보기는 준비 중이에요</strong>
          <p>기본 질문과 U-Map은 계속 이어지고, 일부 상세 흐름은 기록이 더 쌓인 뒤 열 수 있어요.</p>
        </div>
      </section>

    </div>
  );
}

function DiaryScreen({ session, onStarBalanceRefresh, onUMapSnapshotRefresh }) {
  const [calendarOpen, setCalendarOpen] = React.useState(false);
  const [selectedDay, setSelectedDay] = React.useState(13);
  const [mode, setMode] = React.useState("list");
  const [title, setTitle] = React.useState("");
  const [todaySelf, setTodaySelf] = React.useState("");
  const [emotion, setEmotion] = React.useState("차분함");
  const [body, setBody] = React.useState("");
  const [tags, setTags] = React.useState(["관계", "내 기준"]);
  const [savedToast, setSavedToast] = React.useState(false);
  const [deletedCards, setDeletedCards] = React.useState([]);
  const [deleteToast, setDeleteToast] = React.useState(false);
  const [dbDiaries, setDbDiaries] = React.useState([]);
  const [calendarDays, setCalendarDays] = React.useState(null);
  const [calendarDaysError, setCalendarDaysError] = React.useState(false);
  const [selectedEntry, setSelectedEntry] = React.useState(null);
  const [diaryError, setDiaryError] = React.useState("");
  const [diaryNotice, setDiaryNotice] = React.useState("");
  const userId = session?.user?.id;

  const diaryEntries = [
    {
      date: "6월 13일",
      title: "조용히 내 기준을 확인한 날",
      self: "사람들 사이에서도 내 속도를 지키고 싶었던 나",
      preview: "퇴근 후 조용히 걷던 시간이 오래 남았어요. 말보다 공기가 먼저 기억나는 날이었고, 내 속도를 조금 늦추고 싶다는 생각이 들었습니다.",
      mood: "차분함",
      tags: ["관계", "내 기준", "회복"]
    },
    {
      date: "6월 9일",
      title: "말보다 표정이 먼저 떠오른 날",
      self: "상대의 반응을 오래 곱씹는 나",
      preview: "대화가 끝난 뒤에도 마음에 남은 장면을 적었어요.",
      mood: "복잡함",
      tags: ["관계", "소통"]
    },
    {
      date: "12월 28일",
      title: "다시 시작한 기록",
      self: "멈춰 있던 생각을 다시 꺼내보는 나",
      preview: "한동안 미뤄둔 생각을 짧게 꺼내봤어요.",
      mood: "기대감",
      tags: ["성장", "시작"]
    },
    {
      date: "11월 4일",
      title: "편안해진 순간",
      self: "예상보다 괜찮았던 하루를 기억하는 나",
      preview: "예상보다 괜찮았던 하루의 작은 단서를 남겼어요.",
      mood: "편안함",
      tags: ["환경", "회복"]
    }
  ];
  const toDiaryCard = React.useCallback((row) => {
    const date = row.entry_date
      ? new Date(`${row.entry_date}T00:00:00`).toLocaleDateString("ko-KR", { month: "long", day: "numeric" })
      : "오늘";
    return {
      id: row.id,
      date,
      title: row.title,
      self: "DB에 저장된 나의 기록",
      preview: row.body,
      mood: row.mood_label || row.ai_emotion_label || "차분함",
      tags: ["기준", "선택"]
    };
  }, []);

  const loadDiaries = React.useCallback(async () => {
    if (!userId) return;
    try {
      const rows = await fetchDiaries(userId);
      setDbDiaries(rows.map(toDiaryCard));
      setDiaryError("");
    } catch (error) {
      console.warn("Failed to fetch diaries", error);
      setDiaryError("Diary 기록을 불러오지 못했어요. 잠시 후 다시 확인해주세요.");
    }
  }, [toDiaryCard, userId]);

  const loadCalendarDays = React.useCallback(async () => {
    if (!userId) {
      setCalendarDays([]);
      setCalendarDaysError(false);
      return;
    }
    try {
      const rows = await fetchCalendarDayStates(new Date());
      setCalendarDays(rows);
      setCalendarDaysError(false);
    } catch (error) {
      console.warn("Failed to fetch calendar day states", error);
      setCalendarDays([]);
      setCalendarDaysError(true);
    }
  }, [userId]);

  React.useEffect(() => {
    loadDiaries();
    loadCalendarDays();
  }, [loadDiaries, loadCalendarDays]);

  const visibleDiaries = userId ? dbDiaries : [];

  const savedEntry = {
    id: selectedEntry?.id,
    date: selectedEntry?.date || "오늘",
    title: title || "오늘의 나",
    self: todaySelf || "나를 이해하는 단서",
    preview: body || "",
    mood: emotion,
    tags: tags.length ? tags : []
  };

  const openEntry = (entry) => {
    setSelectedEntry(entry);
    setTitle(entry.title);
    setBody(entry.preview);
    setEmotion(entry.mood || "차분함");
    setMode("detail");
  };

  const editEntry = (entry) => {
    setSelectedEntry(entry);
    setTitle(entry.title);
    setBody(entry.preview);
    setEmotion(entry.mood || "차분함");
    setMode("write");
  };

  const handleSaveDiary = async () => {
    if (body.trim().length < 50) {
      setDiaryError("본문을 50자 이상 남기면 Diary를 저장할 수 있어요.");
      return false;
    }
    if (userId) {
      try {
        const isEditing = Boolean(selectedEntry?.id);
        const saved = await saveDiary({
          userId,
          id: selectedEntry?.id,
          title,
          body,
          moodLabel: emotion
        });
        const nextEntry = toDiaryCard(saved);
        setSelectedEntry(nextEntry);
        if (!isEditing && body.trim().length >= 50) {
          try {
            await grantDiaryStarOnce(saved.id);
            await onStarBalanceRefresh?.();
            trackEvent(kpiEvents.starEarned, { reason: "diary", amount: 12 });
          } catch (rewardError) {
            console.warn("Diary Star grant skipped or failed", rewardError);
          }
        }
        await onUMapSnapshotRefresh?.();
        await loadDiaries();
        await loadCalendarDays();
        setDiaryNotice(isEditing ? "수정된 내용이 저장되었어요. Star는 첫 작성 때만 반영돼요." : "이번 Diary에서 나를 이해하는 단서가 생겼어요. +12 Star");
        trackEvent(isEditing ? kpiEvents.diaryUpdated : kpiEvents.diaryCreated, { diaryId: saved.id });
        setDiaryError("");
      } catch (error) {
        console.warn("Failed to save diary", error);
        setDiaryError("Diary 저장에 실패했어요. 네트워크 상태를 확인하고 다시 시도해주세요.");
        return false;
      }
    } else {
      setDiaryError("로그인 후 Diary를 저장할 수 있어요.");
      return false;
    }
    setSavedToast(true);
    setMode("detail");
    return true;
  };

  const handleDeleteDiary = async (entry) => {
    if (entry.id) {
      try {
        await softDeleteDiary(entry.id);
        await onStarBalanceRefresh?.();
        await onUMapSnapshotRefresh?.();
        await loadDiaries();
        await loadCalendarDays();
        setDiaryError("");
      } catch (error) {
        console.warn("Failed to delete diary", error);
        setDiaryError("Diary 삭제에 실패했어요. 잠시 후 다시 시도해주세요.");
        return false;
      }
    }
    setDeletedCards((current) => [...current, entry.title]);
    setDeleteToast(true);
    trackEvent(kpiEvents.diaryDeleted, { diaryId: entry.id });
    return true;
  };

  if (mode === "write") {
    return (
      <DiaryWriteV3
        title={title}
        body={body}
        emotion={emotion}
        onBack={() => setMode("list")}
        onTitleChange={setTitle}
        onBodyChange={setBody}
        onEmotionChange={setEmotion}
        onSave={handleSaveDiary}
        error={diaryError}
      />
    );
  }

  if (mode === "detail") {
    return (
      <DiaryDetailV3
        entry={savedEntry}
        body={savedEntry.preview}
        emotion={emotion}
        onBack={() => setMode("list")}
        onBodyChange={setBody}
        onEmotionChange={setEmotion}
        savedToast={savedToast}
        savedMessage={diaryNotice}
        onToastDone={() => setSavedToast(false)}
        onSaveEdit={handleSaveDiary}
        onDelete={handleDeleteDiary}
      />
    );
  }

  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="diary-topbar diary-topbar-v2 app-page-header">
        <div className="diary-title-lockup">
          <span className="diary-title-icon"><BookOpen size={20} /></span>
          <h1>Diary</h1>
        </div>
        <button className="diary-calendar-button" type="button" onClick={() => setCalendarOpen(true)} aria-label="기록 캘린더 열기">
          <CalendarDays size={18} />
        </button>
      </header>

      <button className="glass-card home-hero diary-write-card" type="button" aria-label="오늘의 단서 기록하기" onClick={() => setMode("write")}>
        <p className="eyebrow">Today</p>
        <h1>오늘 나를 설명하는 장면이 있었나요?</h1>
        <p>좋았던 것, 맞지 않았던 것, 내 기준이 보인 순간을 남겨보세요.</p>
        <span className="diary-write-cta">다이어리 작성하기</span>
      </button>

      <div className="home-list">
        <div><span>오늘의 나</span><strong>내 기준을 확인하는 중</strong></div>
        <div><span>반복 단서</span><strong>관계 · 회복 · 선택 기준</strong></div>
      </div>

      <p className="diary-reward-note">오늘의 단서가 쌓였어요 · +12 Star</p>

      <section className="diary-list-section">
        <div className="section-heading">
          <h2>저장된 다이어리</h2>
          <span>카드로 다시 보기</span>
        </div>
        {deleteToast && (
          <button className="diary-delete-toast" type="button" onClick={() => setDeleteToast(false)}>
            삭제하면 지급된 12 Star가 회수될 수 있어요.
          </button>
        )}
        {visibleDiaries.length > 0 && <DiaryYearCardsV3
          year="2026"
          entries={visibleDiaries.filter((entry) => !deletedCards.includes(entry.title))}
          onOpen={openEntry}
          onEdit={editEntry}
          onDelete={handleDeleteDiary}
        />}
        {false && !dbDiaries.length && (
          <DiaryYearCardsV3
            year="2025"
            entries={[diaryEntries[2], diaryEntries[3]].filter((entry) => !deletedCards.includes(entry.title))}
            onOpen={openEntry}
            onEdit={editEntry}
            onDelete={handleDeleteDiary}
          />
        )}
        {diaryError && <p className="diary-inline-error">{diaryError}</p>}
        {!visibleDiaries.length && (
          <section className="glass-card diary-empty-state">
            <Sparkles size={18} />
            <strong>아직 저장된 Diary가 없어요</strong>
            <p>오늘의 장면과 기준을 남기면 이곳에 실제 기록이 쌓입니다.</p>
          </section>
        )}
      </section>

      {calendarOpen && (
        <CalendarModal
          selectedDay={selectedDay}
          calendarDays={calendarDays}
          calendarDaysError={calendarDaysError}
          diaryEntries={visibleDiaries}
          isAuthenticated={Boolean(userId)}
          onClose={() => setCalendarOpen(false)}
          onOpenDetail={() => {
            setCalendarOpen(false);
            setMode("detail");
          }}
          onSelectDay={setSelectedDay}
        />
      )}
    </div>
  );
}

function DiaryWriteV2({ title, body, emotion, onBack, onTitleChange, onBodyChange, onEmotionChange, onSave }) {
  const emotions = ["차분함", "복잡함", "기대감", "불편함", "편안함"];
  const [emotionSheetOpen, setEmotionSheetOpen] = React.useState(false);
  const rewardReady = body.trim().length >= 50;

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>오늘의 나</span>
        <i />
      </header>

      <section className="diary-editor-card self-discovery-editor">
        <label htmlFor="diary-title">제목 작성</label>
        <input id="diary-title" value={title} onChange={(event) => onTitleChange(event.target.value)} placeholder="예: 내 기준을 확인한 날" />

        <label htmlFor="diary-body">본문 작성</label>
        <textarea id="diary-body" value={body} onChange={(event) => onBodyChange(event.target.value)} placeholder="오늘 좋았던 것, 맞지 않았던 것, 내 기준이 드러난 장면을 자유롭게 남겨주세요." />

        <div className="ai-mood-box">
          <div>
            <strong>기분 및 감정</strong>
            <span>AI가 본문을 읽고 제안할 수 있어요. 언제든 수정 가능합니다.</span>
          </div>
          <div className="mood-summary-row">
            <span className="emotion-pill">{emotion}</span>
            <button className="text-button" type="button" onClick={() => setEmotionSheetOpen(true)}>
              수정
            </button>
          </div>
        </div>

        <div className="diary-editor-meta">
          <span>{rewardReady ? "오늘의 단서가 쌓였어요 · +12 Star" : "50자 이상 남기면 오늘의 단서가 쌓여요."}</span>
          <strong>{body.trim().length} / 50</strong>
        </div>
        {error && <p className="diary-inline-error">{error}</p>}
      </section>

      <button className="primary-button setup-button diary-save-button" type="button" onClick={onSave}>
        저장하기
      </button>

      {emotionSheetOpen && (
        <EmotionEditSheet
          emotion={emotion}
          emotions={emotions}
          onChange={onEmotionChange}
          onClose={() => setEmotionSheetOpen(false)}
        />
      )}
    </div>
  );
}

function EmotionEditSheet({ emotion, emotions, onChange, onClose }) {
  return (
    <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label="기분 및 감정 수정">
      <div className="emotion-sheet">
        <header className="calendar-header">
          <button className="icon-button" type="button" onClick={onClose} aria-label="닫기">
            <ChevronLeft size={21} />
          </button>
          <div>
            <p className="eyebrow">Diary</p>
            <h2>기분 및 감정 수정</h2>
          </div>
          <span />
        </header>
        <p>감정은 오늘의 기록을 이해하는 보조 신호예요. 가장 가까운 상태만 골라도 충분합니다.</p>
        <div className="emotion-chip-list">
          {emotions.map((item) => (
            <button className={emotion === item ? "emotion-chip active" : "emotion-chip"} type="button" key={item} onClick={() => onChange(item)}>
              {item}
            </button>
          ))}
        </div>
        <button className="primary-button" type="button" onClick={onClose}>
          적용하기
        </button>
      </div>
    </div>
  );
}

function DiaryDetailV2({ entry, body, emotion, onBack, onBodyChange, onEmotionChange, savedToast, onToastDone }) {
  const [editing, setEditing] = React.useState(false);
  const emotions = ["차분함", "복잡함", "기대감", "불편함", "편안함"];

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>Diary</span>
        <button className="text-button" type="button" onClick={() => setEditing((value) => !value)}>
          {editing ? "보기" : "수정"}
        </button>
      </header>

      {savedToast && (
        <button className="diary-toast" type="button" onClick={onToastDone}>
          오늘의 기록에서 나를 이해할 단서가 생겼어요. +12 Star
        </button>
      )}

      <section className="diary-detail-card">
        <p className="eyebrow">2026년 {entry.date}</p>
        <h1>{entry.title}</h1>
        {editing ? (
          <>
            <div className="emotion-chip-list">
              {emotions.map((item) => (
                <button className={emotion === item ? "emotion-chip active" : "emotion-chip"} type="button" key={item} onClick={() => onEmotionChange(item)}>
                  {item}
                </button>
              ))}
            </div>
            <textarea value={body} onChange={(event) => onBodyChange(event.target.value)} />
            <p className="edit-reward-note">수정은 언제든 가능하지만 Star는 하루 첫 작성 때만 지급돼요.</p>
            <button className="primary-button" type="button" onClick={() => setEditing(false)}>수정 저장하기</button>
          </>
        ) : (
          <>
            <p className="diary-self-line">{entry.self}</p>
            <div className="diary-card-pills">
              <span className="emotion-pill">{entry.mood}</span>
              {entry.tags.map((tag) => <span className="tag-pill" key={tag}>{tag}</span>)}
            </div>
            <p>{body}</p>
          </>
        )}
      </section>
    </div>
  );
}

function DiaryYearCards({ year, entries, onOpen }) {
  return (
    <div className="diary-year-group">
      <h3>{year}</h3>
      <div className="diary-entry-list">
        {entries.map((entry) => (
          <button className="diary-entry-card" type="button" key={`${year}-${entry.date}-${entry.title}`} onClick={onOpen}>
            <div className="diary-entry-card-head">
              <span>{entry.date}</span>
              <ChevronRight size={17} />
            </div>
            <strong>{entry.title}</strong>
            <p>{entry.preview}</p>
            <div className="diary-card-pills">
              <span className="emotion-pill">{entry.mood}</span>
              {entry.tags.slice(0, 3).map((tag) => <span className="tag-pill" key={tag}>{tag}</span>)}
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function DiaryWriteV3({ title, body, emotion, onBack, onTitleChange, onBodyChange, onEmotionChange, onSave, error }) {
  const [emotionOpen, setEmotionOpen] = React.useState(false);
  const emotions = ["차분함", "복잡함", "기대감", "불편함", "편안함"];
  const rewardReady = body.trim().length >= 50;

  return (
    <div className="screen diary-edit-screen diary-write-v3-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>오늘의 나</span>
        <i />
      </header>

      <section className="diary-editor-card self-discovery-editor">
        <label htmlFor="diary-title-v3">제목 작성</label>
        <input id="diary-title-v3" value={title} onChange={(event) => onTitleChange(event.target.value)} placeholder="예: 내 기준을 확인한 날" />

        <label htmlFor="diary-body-v3">본문 작성</label>
        <textarea id="diary-body-v3" value={body} onChange={(event) => onBodyChange(event.target.value)} placeholder="좋았던 것, 맞지 않았던 것, 내 기준이 보인 장면을 자유롭게 남겨주세요." />

        <section className="diary-clue-helper">
          <strong>기준/선택 단서</strong>
          <p>오늘의 선택, 좋았던 것, 맞지 않았던 것을 함께 남기면 나를 이해하는 흐름이 더 잘 보여요.</p>
        </section>

        <div className="ai-mood-box mood-summary-box">
          <div>
            <strong>기분 및 감정</strong>
          <span>감정은 오늘의 반응을 이해하는 힌트로만 살펴볼게요.</span>
          </div>
          <span className="emotion-pill mood-current">{emotion}</span>
          <button className="mood-edit-button" type="button" onClick={() => setEmotionOpen(true)}>
            직접 선택
          </button>
        </div>

        <div className="diary-editor-meta">
          <span>{rewardReady ? "오늘의 단서가 쌓였어요 · +12 Star" : "50자 이상 남기면 오늘의 단서가 쌓여요."}</span>
          <strong>{body.trim().length} / 50</strong>
        </div>
        {error && <p className="diary-inline-error">{error}</p>}
      </section>

      <button className="primary-button setup-button diary-save-button" type="button" onClick={onSave} disabled={!rewardReady}>
        저장하기
      </button>

      {emotionOpen && (
        <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label="기분 및 감정 수정">
          <div className="calendar-sheet mood-sheet">
            <header className="calendar-header">
              <button className="icon-button" type="button" onClick={() => setEmotionOpen(false)} aria-label="닫기">
                <ChevronLeft size={21} />
              </button>
              <div>
                <p className="eyebrow">Mood Signal</p>
                <h2>기분 및 감정 수정</h2>
              </div>
              <span />
            </header>
            <p className="mood-sheet-copy">감정은 오늘의 반응을 이해하는 힌트로만 살펴볼게요. 가까운 표현을 골라주세요.</p>
            <div className="emotion-chip-list mood-sheet-options">
              {emotions.map((item) => (
                <button
                  className={emotion === item ? "emotion-chip active" : "emotion-chip"}
                  type="button"
                  key={item}
                  onClick={() => {
                    onEmotionChange(item);
                    setEmotionOpen(false);
                  }}
                >
                  {item}
                </button>
              ))}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function DiaryDetailV3({ entry, body, emotion, onBack, onBodyChange, onEmotionChange, savedToast, savedMessage, onToastDone, onSaveEdit, onDelete }) {
  const [editing, setEditing] = React.useState(false);
  const [deleteNotice, setDeleteNotice] = React.useState(false);
  const emotions = ["차분함", "복잡함", "기대감", "불편함", "편안함"];

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>오늘의 나</span>
        <i />
      </header>

      {savedToast && (
        <button className="diary-toast" type="button" onClick={onToastDone}>
          {savedMessage || "Diary가 저장되었어요."}
        </button>
      )}
      {deleteNotice && (
        <button className="diary-delete-toast" type="button" onClick={() => setDeleteNotice(false)}>
          <span>삭제하면 지급된 12 Star가 회수될 수 있어요.</span>
        </button>
      )}

      <section className="diary-detail-card">
        <div className="diary-detail-head">
          <p className="eyebrow">2026년 {entry.date}</p>
          <div className="diary-card-actions" aria-label="Diary 작업">
            <button type="button" onClick={() => setEditing((value) => !value)} aria-label="수정하기">
              <Pencil size={14} />
            </button>
            <button type="button" className="danger" onClick={async () => {
              setDeleteNotice(true);
              const deleted = await onDelete?.(entry);
              if (deleted) onBack();
            }} aria-label="삭제하기">
              <Trash2 size={14} />
            </button>
          </div>
        </div>
        <h1>{entry.title}</h1>
        {editing ? (
          <>
            <div className="emotion-chip-list">
              {emotions.map((item) => (
                <button className={emotion === item ? "emotion-chip active" : "emotion-chip"} type="button" key={item} onClick={() => onEmotionChange(item)}>
                  {item}
                </button>
              ))}
            </div>
            <textarea value={body} onChange={(event) => onBodyChange(event.target.value)} />
            <p className="edit-reward-note">수정은 언제든 가능하지만 Star는 하루 첫 작성 때만 지급돼요.</p>
            <button className="primary-button" type="button" onClick={async () => {
              const saved = await onSaveEdit?.();
              if (saved) setEditing(false);
            }}>수정 저장하기</button>
          </>
        ) : (
          <>
            <div className="diary-card-pills">
              <span className="emotion-pill">{entry.mood}</span>
            </div>
            <p>{body}</p>
          </>
        )}
      </section>
    </div>
  );
}

function DiaryYearCardsV3({ year, entries, onOpen, onEdit, onDelete }) {
  const compactPreview = (text) => (text.length > 30 ? `${text.slice(0, 30)}...` : text);

  return (
    <div className="diary-year-group">
      <h3>{year}</h3>
      <div className="diary-entry-list">
        {entries.map((entry) => (
          <article className="diary-entry-card" key={`${year}-${entry.date}-${entry.title}`}>
            <div className="diary-entry-card-head">
              <span>{entry.date}</span>
              <div className="diary-card-actions" aria-label={`${entry.title} 작업`}>
                <button type="button" onClick={() => onEdit(entry)} aria-label="수정하기">
                  <Pencil size={14} />
                </button>
                <button type="button" className="danger" onClick={() => onDelete(entry)} aria-label="삭제하기">
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
            <button className="diary-entry-open" type="button" onClick={() => onOpen(entry)}>
              <strong>{entry.title}</strong>
              <p>{compactPreview(entry.preview)}</p>
            </button>
          </article>
        ))}
      </div>
    </div>
  );
}

function LegacyDiaryScreen() {
  const [calendarOpen, setCalendarOpen] = React.useState(false);
  const [selectedDay, setSelectedDay] = React.useState(13);
  const [mode, setMode] = React.useState("list");
  const [diaryTitle, setDiaryTitle] = React.useState("오늘 마음에 남은 장면");
  const [emotion, setEmotion] = React.useState("차분함");
  const [body, setBody] = React.useState("");
  const [tags, setTags] = React.useState(["내 기준", "맞는 환경"]);
  const [savedToast, setSavedToast] = React.useState(false);

  const diaryEntries = [
    ["6월 13일 · 오늘 마음에 남은 장면", "퇴근 후 조용히 걷던 시간이 오래 남았어요. 말보다 공기가 먼저 기억나는 날이었고, 내 속도를 조금 늦추고 싶다는 생각이 들었습니다."],
    ["6월 9일 · 말보다 표정이 먼저 떠오른 날", "대화가 끝난 뒤에도 마음에 남은 장면을 적었어요."],
    ["12월 28일 · 다시 시작한 기록", "한동안 미뤄둔 생각을 짧게 꺼내봤어요."],
    ["11월 4일 · 편안해진 순간", "예상보다 괜찮았던 하루의 작은 단서를 남겼어요."]
  ];

  if (mode === "write") {
    return (
      <DiaryWriteScreen
        title={diaryTitle}
        body={body}
        emotion={emotion}
        tags={tags}
        onBack={() => setMode("list")}
        onTitleChange={setDiaryTitle}
        onBodyChange={setBody}
        onEmotionChange={setEmotion}
        onTagsChange={setTags}
        onSave={() => {
          setSavedToast(true);
          setMode("detail");
        }}
      />
    );
  }

  if (mode === "detail") {
    return (
      <DiaryDetailScreen
        title={diaryTitle}
        body={body || diaryEntries[0][1]}
        emotion={emotion}
        tags={tags}
        onBack={() => setMode("list")}
        onTitleChange={setDiaryTitle}
        onBodyChange={setBody}
        onEmotionChange={setEmotion}
        onTagsChange={setTags}
        savedToast={savedToast}
        onToastDone={() => setSavedToast(false)}
      />
    );
  }

  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="diary-topbar">
        <div className="diary-title-wrap">
          <span className="diary-title-icon" aria-hidden="true">
            <BookOpen size={19} />
          </span>
          <div>
          <p className="eyebrow">FI-YOU</p>
          <h1>Diary</h1>
          </div>
        </div>
        <button className="calendar-trigger" type="button" onClick={() => setCalendarOpen(true)} aria-label="기록 캘린더 열기">
          <CalendarDays size={18} />
        </button>
      </header>

      <button className="glass-card home-hero diary-write-card" type="button" aria-label="오늘의 단서 기록하기" onClick={() => setMode("write")}>
        <div className="home-icon"><BookOpen size={24} /></div>
        <p className="eyebrow">오늘의 단서</p>
        <h1>나를 설명하는 장면을 남겨볼까요?</h1>
        <p>좋았던 것, 맞지 않았던 것, 내 기준이 드러난 순간을 남기면 U-Map이 조금씩 더 섬세해집니다.</p>
        <span className="diary-write-cta">다이어리 작성하기</span>
      </button>

      <div className="home-list">
        <div><span>오늘의 나</span><strong>조용한 환경에서 더 편안함</strong></div>
        <div><span>반복 단서</span><strong>선택 기준을 천천히 발견 중</strong></div>
      </div>

      <p className="diary-reward-note">오늘의 단서가 쌓였어요 · +12 Star</p>

      <section className="diary-list-section">
        <div className="section-heading">
          <h2>작성한 다이어리</h2>
          <span>무한 스크롤 준비</span>
        </div>
        <DiaryYearGroup
          year="2026"
          entries={[
            diaryEntries[0],
            diaryEntries[1]
          ]}
          onOpen={() => setMode("detail")}
        />
        <DiaryYearGroup
          year="2025"
          entries={[
            diaryEntries[2],
            diaryEntries[3]
          ]}
          onOpen={() => setMode("detail")}
        />
      </section>

      {calendarOpen && (
        <CalendarModal
          selectedDay={selectedDay}
          onClose={() => setCalendarOpen(false)}
          onOpenDetail={() => {
            setCalendarOpen(false);
            setMode("detail");
          }}
          onSelectDay={setSelectedDay}
        />
      )}
    </div>
  );
}

function DiaryWriteScreen({ title, body, emotion, tags, onBack, onTitleChange, onBodyChange, onEmotionChange, onTagsChange, onSave }) {
  const emotions = ["차분함", "설렘", "지침", "불안", "기쁨"];
  const tagOptions = ["내 기준", "좋았던 것", "맞지 않았던 것", "관계", "환경"];
  const rewardReady = body.trim().length >= 50;
  const toggleTag = (tag) => {
    onTagsChange(tags.includes(tag) ? tags.filter((item) => item !== tag) : [...tags, tag]);
  };

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>Diary 작성</span>
        <i />
      </header>

      <section className="diary-editor-card">
        <p className="eyebrow">오늘의 나</p>
        <label htmlFor="diary-title">제목 작성</label>
        <input
          id="diary-title"
          className="diary-title-input"
          value={title}
          onChange={(event) => onTitleChange(event.target.value)}
          placeholder="예: 내가 편안해지는 환경을 알게 된 날"
        />

        <label htmlFor="diary-body">본문 작성</label>
        <textarea
          id="diary-body"
          value={body}
          onChange={(event) => onBodyChange(event.target.value)}
          placeholder="오늘 나를 설명해주는 장면을 남겨주세요. 좋았던 것, 맞지 않았던 것, 선택의 기준, 관계에서 반복된 흐름처럼 작은 단서도 좋아요."
        />
        <div className="diary-editor-meta">
          <span>{rewardReady ? "오늘의 단서가 쌓였어요 · +12 Star" : "50자 이상 남기면 오늘의 단서가 쌓여요."}</span>
          <strong>{body.trim().length} / 50</strong>
        </div>

        <div className="ai-mood-box">
          <div>
            <label>기분 및 감정</label>
            <p>나중에는 AI가 본문을 읽고 자동으로 채워줘요. 지금은 직접 고쳐둘 수 있습니다.</p>
          </div>
          <div className="emotion-chip-list compact">
            {emotions.map((item) => (
              <button className={emotion === item ? "emotion-chip active" : "emotion-chip"} type="button" key={item} onClick={() => onEmotionChange(item)}>
                {item}
              </button>
            ))}
          </div>
        </div>

        <div className="diary-tag-field">
          <label htmlFor="diary-tag-input">태그 (선택)</label>
          <div className="tag-chip-list">
            {tagOptions.map((tag) => (
              <button className={tags.includes(tag) ? "tag-chip active" : "tag-chip"} type="button" key={tag} onClick={() => toggleTag(tag)}>
                {tag}
              </button>
            ))}
          </div>
          <input id="diary-tag-input" className="diary-title-input" placeholder="예: 맞는 환경, 내 기준" />
        </div>
      </section>

      <button className="primary-button setup-button" type="button" onClick={onSave}>
        저장하기
      </button>
    </div>
  );
}

function DiaryDetailScreen({ title, body, emotion, tags, onBack, onTitleChange, onBodyChange, onEmotionChange, onTagsChange, savedToast, onToastDone }) {
  const [editing, setEditing] = React.useState(false);
  const emotions = ["차분함", "설렘", "지침", "불안", "기쁨"];
  const tagOptions = ["내 기준", "좋았던 것", "맞지 않았던 것", "관계", "환경"];
  const toggleTag = (tag) => {
    onTagsChange(tags.includes(tag) ? tags.filter((item) => item !== tag) : [...tags, tag]);
  };

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>Diary</span>
        <button className="text-button" type="button" onClick={() => setEditing((value) => !value)}>
          {editing ? "보기" : "수정"}
        </button>
      </header>

      {savedToast && (
        <button className="diary-toast" type="button" onClick={onToastDone}>
          오늘의 기록이 U-Map에 단서로 남았어요. +12 Star
        </button>
      )}

      <section className="diary-detail-card">
        <p className="eyebrow">2026년 6월 13일</p>
        <h1>{title || "오늘 마음에 남은 장면"}</h1>
        {editing ? (
          <>
            <label htmlFor="detail-title">제목 작성</label>
            <input
              id="detail-title"
              className="diary-title-input"
              value={title}
              onChange={(event) => onTitleChange(event.target.value)}
            />
            <div className="ai-mood-box">
              <div>
                <label>기분 및 감정</label>
                <p>본문에서 읽힌 분위기를 사용자가 직접 조정할 수 있어요.</p>
              </div>
              <div className="emotion-chip-list compact">
                {emotions.map((item) => (
                  <button className={emotion === item ? "emotion-chip active" : "emotion-chip"} type="button" key={item} onClick={() => onEmotionChange(item)}>
                    {item}
                  </button>
                ))}
              </div>
            </div>
            <label htmlFor="detail-body">본문 작성</label>
            <textarea id="detail-body" value={body} onChange={(event) => onBodyChange(event.target.value)} />
            <div className="diary-tag-field">
              <label>태그 (선택)</label>
              <div className="tag-chip-list">
                {tagOptions.map((tag) => (
                  <button className={tags.includes(tag) ? "tag-chip active" : "tag-chip"} type="button" key={tag} onClick={() => toggleTag(tag)}>
                    {tag}
                  </button>
                ))}
              </div>
            </div>
            <p className="edit-reward-note">수정은 언제든 가능하지만 Star는 하루 첫 작성 때만 지급돼요.</p>
            <button className="primary-button" type="button" onClick={() => setEditing(false)}>수정 저장하기</button>
          </>
        ) : (
          <>
            <div className="diary-pill-row">
              <span className="emotion-pill">{emotion}</span>
              {tags.map((tag) => <span className="tag-pill" key={tag}>{tag}</span>)}
            </div>
            <p>{body}</p>
          </>
        )}
      </section>
    </div>
  );
}

function DiaryYearGroup({ year, entries, onOpen }) {
  return (
    <div className="diary-year-group">
      <h3>{year}</h3>
      <div className="diary-entry-list">
        {entries.map(([title, preview], index) => {
          const [date, heading] = title.split(" · ");
          const entryTags = index % 2 === 0 ? ["내 기준", "차분함"] : ["관계", "맞지 않았던 것"];
          return (
          <button className="diary-entry-card" type="button" key={title} onClick={onOpen}>
            <div className="diary-entry-card-head">
              <span>{date}</span>
              <ChevronRight size={17} />
            </div>
            <strong>{heading || title}</strong>
            <p>{preview}</p>
            <div className="diary-entry-tags">
              {entryTags.map((tag) => <span key={tag}>{tag}</span>)}
            </div>
          </button>
          );
        })}
      </div>
    </div>
  );
}

function CalendarModal({
  selectedDay,
  calendarDays = null,
  calendarDaysError = false,
  diaryEntries = [],
  attendanceDays = null,
  isAuthenticated = false,
  onClose,
  onOpenDetail,
  onSelectDay
}) {
  const extractDay = (dateText = "") => {
    const match = String(dateText).match(/(\d{1,2})\s*일/);
    return match ? Number(match[1]) : null;
  };
  const extractCalendarDay = (row) => {
    if (!row?.day_date) return null;
    const day = new Date(`${row.day_date}T00:00:00`).getDate();
    return Number.isFinite(day) ? day : null;
  };
  const compactPreview = (text = "") => (text.length > 42 ? `${text.slice(0, 42)}...` : text);
  const backendCalendarRows = Array.isArray(calendarDays) ? calendarDays : [];
  const hasBackendCalendar = backendCalendarRows.length > 0;
  const calendarByDay = new Map(
    backendCalendarRows
      .map((row) => [extractCalendarDay(row), row])
      .filter(([day]) => Number.isFinite(day))
  );
  const diaryByDay = new Map(
    diaryEntries
      .map((entry) => [extractDay(entry.date), entry])
      .filter(([day]) => Number.isFinite(day))
  );
  const fallbackDiaryDays = [4, 9, 13, 21];
  const useMockFallback = !hasBackendCalendar && !isAuthenticated && !calendarDaysError;
  const days = hasBackendCalendar
    ? Array.from(calendarByDay.keys()).sort((a, b) => a - b)
    : Array.from({ length: 30 }, (_, index) => index + 1);
  const diaryDays = new Set(
    hasBackendCalendar
      ? backendCalendarRows.filter((row) => row.diary_written).map(extractCalendarDay).filter((day) => Number.isFinite(day))
      : useMockFallback
        ? fallbackDiaryDays
        : diaryByDay.keys()
  );
  const attendanceSet = new Set(
    hasBackendCalendar
      ? backendCalendarRows.filter((row) => row.attended).map(extractCalendarDay).filter((day) => Number.isFinite(day))
      : attendanceDays || (useMockFallback ? [1, 2, 4, 8, 9, 13, 18, 21, 27] : [])
  );
  const starByDay = new Map(
    hasBackendCalendar
      ? backendCalendarRows
          .map((row) => [extractCalendarDay(row), Number(row.star_earned || 0)])
          .filter(([day]) => Number.isFinite(day))
      : []
  );
  const activeCalendarDay = calendarByDay.get(selectedDay);
  const activeEntry = diaryByDay.get(selectedDay);
  const activeHasDiary = diaryDays.has(selectedDay);
  const activeStarEarned = Number(activeCalendarDay?.star_earned || 0);

  return (
    <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label="기록 캘린더">
      <div className="calendar-sheet">
        <header className="calendar-header">
          <button className="icon-button" type="button" onClick={onClose} aria-label="캘린더 닫기">
            <ChevronLeft size={21} />
          </button>
          <div>
            <h2>Calendar</h2>
          </div>
          <span />
        </header>

        <div className="month-switcher">
          <button type="button">‹</button>
          <strong>2026년 6월</strong>
          <button type="button">›</button>
        </div>

        <div className="calendar-weekdays" aria-hidden="true">
          {["월", "화", "수", "목", "금", "토", "일"].map((day) => <span key={day}>{day}</span>)}
        </div>

        <div className="calendar-grid">
          {days.map((day) => {
            const hasDiary = diaryDays.has(day);
            const hasAttendance = attendanceSet.has(day);
            const starEarned = Number(starByDay.get(day) || 0);
            const active = selectedDay === day;
            return (
              <button
                className={`calendar-day ${active ? "active" : ""}`}
                type="button"
                key={day}
                onClick={() => onSelectDay(day)}
              >
                <strong>{day}</strong>
                <span className="day-badges">
                  {hasDiary && <em aria-label="다이어리 작성"><Pencil size={11} /></em>}
                  {(hasAttendance || starEarned !== 0) && (
                    <i aria-label={`Star ${starEarned || 10}`}>
                      <Sparkles size={10} />
                      {starEarned > 0 ? `+${starEarned}` : starEarned < 0 ? starEarned : "10"}
                    </i>
                  )}
                </span>
              </button>
            );
          })}
        </div>

        <section className="calendar-preview">
          <p className="eyebrow">6월 {selectedDay}일</p>
          <h3>{activeEntry?.title || (activeHasDiary ? "기록이 남아 있어요" : "기록 미리보기")}</h3>
          {hasBackendCalendar && (
            <div className="calendar-preview-meta">
              {activeCalendarDay?.attended && <span>출석</span>}
              {activeCalendarDay?.diary_written && <span>Diary 작성</span>}
              {activeStarEarned !== 0 && <span>{activeStarEarned > 0 ? `+${activeStarEarned}` : activeStarEarned} Star</span>}
              {activeCalendarDay?.diary_id && <span>Diary 연결됨</span>}
            </div>
          )}
          <p>
            {calendarDaysError
              ? "캘린더 데이터를 불러오지 못했어요. 실제 기록은 잠시 후 다시 확인해주세요."
              : activeEntry
              ? compactPreview(activeEntry.preview)
              : activeCalendarDay?.diary_written
                ? "이 날짜에 남긴 Diary 기록이 있어요."
                : activeHasDiary
                ? "이 날짜의 기록이 U-Map에 단서로 남아 있어요."
                : "이 날짜의 기록을 열람하거나 새 다이어리를 남길 수 있어요."}
          </p>
          <button className="small-cta" type="button" onClick={onOpenDetail}>
            기록 열람하기
          </button>
        </section>
      </div>
    </div>
  );
}

function ExploreScreen({ onExplore, onStartFreeExplore, starBalance = 150 }) {
  const [topic, setTopic] = React.useState(null);
  const [freeMode, setFreeMode] = React.useState("hub");

  const startFreeExplore = async () => {
    const canStart = await onStartFreeExplore?.();
    if (canStart !== false) setFreeMode("chat");
  };

  if (topic) {
    return (
      <TopicExploreScreen
        topic={topic}
        onBack={() => setTopic(null)}
        onStart={onExplore}
      />
    );
  }

  if (freeMode === "confirm") {
    return (
      <FreeExploreConfirmScreen
        onBack={() => setFreeMode("hub")}
        onStart={startFreeExplore}
      />
    );
  }

  if (freeMode === "chat") {
    return <FreeExploreChatScreen onBack={() => setFreeMode("confirm")} onClose={() => setFreeMode("hub")} />;
  }

  return (
    <div className="screen home-screen explore-screen with-bottom-nav">
      <header className="diary-topbar app-page-header">
        <div className="diary-title-lockup">
          <span className="diary-title-icon"><Sparkles size={20} /></span>
          <h1>Explore</h1>
        </div>
        <span className="explore-star-pill" aria-label={`보유 Star ${starBalance}`}>
          <Sparkles size={13} />
          {starBalance}
        </span>
      </header>

      <section className="explore-intro">
        <h1>{t("explore.title")}</h1>
        <p>{t("explore.body")}</p>
      </section>

      <section className="explore-status-card glass-card" aria-label="현재 나의 탐구 현황">
        <div className="explore-section-head">
          <strong>{t("explore.status.title")}</strong>
          <span>조금 선명해지는 중</span>
        </div>
        <div className="explore-status-body">
          <UMapPreview mode="initial" size="compact" />
          <div className="explore-status-grid">
            <span><em>완료한 질문</em><strong>12개</strong></span>
            <span><em>쌓인 단서</em><strong>18개</strong></span>
            <span><em>더 알아갈 영역</em><strong>회복과 리듬</strong></span>
          </div>
        </div>
      </section>

      <section className="explore-recommend-card glass-card">
        <div className="explore-section-head">
          <strong>{t("explore.recommend.title")}</strong>
        </div>
        <p>오늘은 선택보다, 왜 그 선택이 마음에 남았는지 살펴볼까요?</p>
        <div className="explore-topic-tags">
          <span>감정 흐름</span>
          <span>관계 기준</span>
          <span>회복 방식</span>
        </div>
      </section>

      <section className="explore-topic-section">
        <h2>{t("explore.topic.title")}</h2>
        <div className="explore-topic-list">
          {exploreTopics.map((item) => (
            <button type="button" key={item.id} onClick={() => setTopic(item)}>
              {item.title}
            </button>
          ))}
        </div>
      </section>

      <div className="explore-cta-stack">
        <button className="primary-button" type="button" onClick={onExplore}>
          {t("home.question.cta")}
          <ArrowRight size={19} />
        </button>
        <button className="secondary-button explore-free-button" type="button" onClick={() => setFreeMode("confirm")}>
          <span>자유탐구 열기</span>
          <StarCostPill amount={30} />
        </button>
      </div>
    </div>
  );
}

function TopicExploreScreen({ topic, onBack, onStart }) {
  return (
    <div className="screen home-screen topic-explore-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="Explore로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <span>주제별 탐구</span>
        <i />
      </header>

      <section className="glass-card topic-detail-card">
        <p className="eyebrow">Topic</p>
        <h1>{topic.title}</h1>
        <p>{topic.description}</p>
      </section>

      <section className="topic-axis-section">
        <h2>연결되는 U-Map 축</h2>
        <div className="topic-axis-list">
          {topic.axes.map((axis) => (
            <span key={axis}>{axis}</span>
          ))}
        </div>
      </section>

      <section className="glass-card topic-question-card">
        <span>첫 질문 preview</span>
        <p>{topic.firstQuestion}</p>
      </section>

      <button className="primary-button setup-button" type="button" onClick={onStart}>
        이 주제로 시작하기
        <ArrowRight size={19} />
      </button>
    </div>
  );
}

function FreeExploreConfirmScreen({ onBack, onStart }) {
  const items = [
    "자유탐구를 열면 필요한 Star를 확인한 뒤 시작해요.",
    "이번 세션에서는 최대 7개의 메시지를 주고받을 수 있어요.",
    "입력은 최대 10,000자까지 가능해요.",
    "답변은 최대 15,000자까지 제공돼요.",
    "정해진 질문이 아니라, 지금 떠오른 주제로 깊게 이어갈 수 있어요."
  ];

  return (
    <div className="screen home-screen free-confirm-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="Explore로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <span>자유탐구</span>
        <i />
      </header>

      <section className="glass-card free-confirm-card">
        <Sparkles size={22} />
        <h1>지금 떠오른 주제로 이어가요</h1>
        <p>FI-YOU는 답을 단정하기보다, 남긴 기록에서 보이는 흐름을 함께 정리합니다.</p>
        <div className="free-confirm-list">
          {items.map((item) => (
            <span key={item}>{item}</span>
          ))}
        </div>
      </section>

      <div className="free-confirm-actions">
        <button className="primary-button" type="button" onClick={onStart}>
          <span>자유탐구 열기</span>
          <StarCostPill amount={30} />
          <ArrowRight size={19} />
        </button>
        <button className="secondary-button" type="button" onClick={onBack}>
          조금 더 생각해볼게요
        </button>
      </div>
    </div>
  );
}

function FreeExploreChatScreen({ onBack, onClose }) {
  const [summaryOpen, setSummaryOpen] = React.useState(false);
  const messages = [
    ["ai", "지금 궁금한 나의 모습이나 반복되는 장면을 편하게 적어주세요. 저는 답을 단정하기보다, 현재까지의 단서에서 어떤 흐름이 보이는지 함께 정리해볼게요."],
    ["user", "요즘 시작은 하고 싶은데 계속 미루게 되는 장면이 반복돼요."],
    ["ai", "미루는 행동만 보기보다, 시작 전에 어떤 기준을 확인하려는지 같이 볼 수 있어요. 최근에 가장 마음에 남은 미룸의 장면은 언제였나요?"]
  ];

  return (
    <div className="screen home-screen free-chat-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="확인 화면으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <span>자유탐구</span>
        <button className="text-button" type="button" onClick={onClose}>닫기</button>
      </header>

      <div className="free-chat-status" aria-label="자유탐구 사용 현황">
        <span>메시지 4/7</span>
        <span>입력 2,450/10,000</span>
        <span>출력 4,890/15,000</span>
      </div>

      <section className="free-chat-thread">
        {messages.map(([role, copy], index) => (
          <article className={`free-chat-bubble ${role}`} key={`${role}-${index}`}>
            <p>{copy}</p>
          </article>
        ))}
      </section>

      {summaryOpen && (
        <section className="glass-card free-chat-summary">
          <strong>이번 탐구에서 몇 가지 단서가 정리됐어요.</strong>
          <p>시작을 미루는 장면 뒤에는 방향을 확인하고 싶은 마음과, 내 기준에 맞게 움직이고 싶은 흐름이 함께 보여요.</p>
        </section>
      )}

      <div className="free-chat-input">
        <textarea placeholder="지금 떠오른 장면이나 질문을 적어주세요." />
        <button className="primary-button" type="button" onClick={() => setSummaryOpen(true)}>
          탐구 종료하기
        </button>
      </div>
    </div>
  );
}

function UMapScreen({ onOpenGrowth, onOpenRelationship, snapshot }) {
  const [mapMode, setMapMode] = React.useState("initial");
  const hasSnapshot = Boolean(snapshot);
  const dominantSignals = Array.isArray(snapshot?.dominant_signals) ? snapshot.dominant_signals : [];
  const isClear = hasSnapshot && mapMode === "clear";
  const axisSummaries = isClear
    ? [
      ["탐구성", "새 가능성 탐색"],
      ["관계지향", "진정성과 거리감"],
      ["안정추구", "납득 가능한 기준"],
      ["진취성", "작게 옮기는 힘"]
    ]
    : [
      ["탐구성", "관찰 중"],
      ["관계지향", "단서 수집 중"],
      ["안정추구", "흐름 확인 중"],
      ["진취성", "더 필요해요"]
    ];
  const statusRows = isClear
    ? [
      ["Growth", "변화 흐름과 과거 비교", "active", ArrowRight],
      ["관계 연결", "Relation-Map 만들기", "active", MessageCircle]
    ]
    : [
      ["Growth", "변화 흐름과 과거 비교", "active", ArrowRight],
      ["관계 연결", "1명당", "locked", MessageCircle]
    ];
  const insightItems = dominantSignals.length
    ? dominantSignals.slice(0, 5).map((signal) => signal.evidence || signal.axis || "현재까지의 기록에서 반복되는 단서가 보여요.")
    : isClear
    ? [
      "새로운 가능성을 탐색하려는 흐름이 보여요.",
      "혼자 정리하는 시간이 회복과 연결되는 단서가 있어요.",
      "관계에서는 진정성과 거리감의 균형을 중요하게 보는 흐름이 보여요.",
      "선택할 때 내 기준을 확인하려는 단서가 늘고 있어요.",
      "아이디어를 실제 행동으로 옮기려는 경향이 보여요."
    ]
    : [
      "새로운 가능성을 탐색하려는 단서가 조금씩 보이고 있어요.",
      "혼자 정리하는 시간이 회복과 연결될 수 있어요.",
      "관계에서 중요하게 보는 기준은 더 살펴보는 중이에요."
    ];
  const openAreas = [
    "갈등 상황의 반응",
    "반복되는 선택 기준",
    "에너지 회복 방식",
    "협업에서 강점이 드러나는 순간"
  ];

  return (
    <div className="screen home-screen u-map-screen with-bottom-nav">
      <header className="diary-topbar u-map-topbar app-page-header">
        <div className="diary-title-lockup">
          <span className="diary-title-icon u-map-title-icon"><Orbit size={20} /></span>
          <h1>U-Map</h1>
        </div>
      </header>

      {hasSnapshot && <div className="u-map-mode-switch" role="tablist" aria-label="U-Map 상태 보기">
        <button className={!isClear ? "active" : ""} type="button" onClick={() => setMapMode("initial")} role="tab" aria-selected={!isClear}>
          현재 윤곽
        </button>
        <button className={isClear ? "active" : ""} type="button" onClick={() => setMapMode("clear")} role="tab" aria-selected={isClear}>
          선명한 예시
        </button>
      </div>}

      <section className={`glass-card u-map-primary-card ${isClear ? "clear" : "initial"}`}>
        <h1>{hasSnapshot ? (isClear ? "윤곽이 선명해졌어요" : "현재 기록 기준으로 정리 중이에요") : "기록이 더 필요해요"}</h1>
        <p>
          {snapshot?.summary || (!hasSnapshot
            ? "질문과 Diary가 조금 더 쌓이면 U-Map에 현재 흐름이 표시됩니다."
            : isClear
            ? "질문과 Diary에서 반복된 단서가 쌓이면서 관계, 가치관, 감정 흐름이 더 또렷하게 보이고 있어요."
            : "첫 단서가 생겼고, 질문과 Diary가 쌓이면 감정, 관계, 가치관의 흐름이 더 선명해질 거예요.")}
        </p>
        <UMapPreview mode={isClear ? "clear" : "initial"} size="large" scores={snapshot?.axis_scores} />
        <p className="u-map-helper-line">{t("umap.helper")}</p>
        <div className="u-map-axis-summary" aria-label="대표 U-Map 축">
          {axisSummaries.map(([label, value]) => (
            <span key={label}>
              <strong>{label}</strong>
              <em>{value}</em>
            </span>
          ))}
        </div>
        <small className="u-map-updated">{snapshot?.created_at ? `Updated ${new Date(snapshot.created_at).toLocaleDateString("ko-KR")}` : "기록 대기 중"}</small>
      </section>

      <section className="u-map-detail-section">
        <div className="section-heading">
          <h2>FI-YOU가 분석한 당신</h2>
          <span>{hasSnapshot ? "현재 기록 기준" : "기록 부족"}</span>
        </div>
        <div className="u-map-insight-list">
          {insightItems.map((item) => (
            <article className="u-map-insight-card" key={item}>
              <Sparkles size={14} />
              <p>{item}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="u-map-status-list">
        {statusRows.map(([label, value, state, Icon]) => {
          const StateIcon = state === "locked" ? LockKeyhole : Icon;
          return (
            <button
              className={state === "locked" ? "locked" : state === "muted" ? "muted" : ""}
              type="button"
              key={label}
              onClick={label === "관계 연결" ? onOpenRelationship : onOpenGrowth}
            >
              <span className="u-map-status-icon"><StateIcon size={15} /></span>
              <span className="u-map-status-copy">
                <strong>{label}</strong>
                <em>
                  {value}
                  {label === "관계 연결" && state === "locked" && <StarCostPill amount={80} suffix="/ 명" className="inline-status-cost" />}
                </em>
              </span>
              <ChevronRight size={15} />
            </button>
          );
        })}
      </div>

      <section className="u-map-detail-section u-map-open-section">
        <div className="section-heading">
          <h2>아직 더 알고 싶은 영역</h2>
          <span>다음 탐구로 연결</span>
        </div>
        <div className="u-map-open-area-list">
          {openAreas.map((item) => (
            <button type="button" key={item}>
              <span>{item}</span>
              <ArrowRight size={14} />
            </button>
          ))}
        </div>
      </section>
    </div>
  );
}

function SettingsScreen({ loveUnlocked, onUnlockLove, profile, session, starBalance = 150, onStarBalanceChange, onDataReset, onSignOut }) {
  const [reportOpen, setReportOpen] = React.useState(false);
  const [settingsView, setSettingsView] = React.useState("main");
  const [settingsNotice, setSettingsNotice] = React.useState("");
  const profileFlowNotes = [
    ["최근 발견된 단서", "혼자 정리하는 시간과 관계 안에서의 거리감 조절이 반복해서 보여요.", Sparkles],
    ["반복되는 흐름", "선택 전 내 기준을 확인하려는 흐름이 질문과 Diary에서 함께 나타납니다.", Orbit],
    ["더 알아가면 좋은 영역", "갈등 상황의 반응과 에너지 회복 방식을 더 살펴보면 좋아요.", Compass],
    ...(loveUnlocked
      ? [["연애 성향", "가까워질수록 진정성과 거리감의 균형을 중요하게 보는 단서가 있어요.", Heart]]
      : [])
  ];
  const profileStats = [
    ["출석일", "12일", CalendarDays],
    ["연속 출석", "3일", Flame],
    ["질문 응답", "5", MessageCircle],
    ["발견된 나", "12", Orbit],
    ["Diary", "3", BookOpen],
    ["Star", String(starBalance), Sparkles]
  ];
  const settingsDetailItems = [
    ["프로필 / 계정", "로그인, 기본 정보", User, "profile"],
    ["언어", "한국어", Globe2, "language"],
    ["알림", "질문과 기록 리마인드", Bell, "notifications"],
    ["Star / 보상내역", "출석, Diary, Star 흐름", Sparkles, "star"],
    ["리포트", "기록 흐름 전체보기", FileText, "report"],
    ["데이터 관리", "기록 내려받기와 삭제", Database, "data"],
    ["서비스 약관", "약관, 개인정보, AI 한계", FileText, "legal"],
    ["로그아웃", "현재 계정에서 나가기", LogOut, "logout"],
    ["계정 삭제", "데이터 관리에서 요청", Trash2, "data"]
  ];

  if (settingsView === "star") {
    return <StarLedgerScreen balance={starBalance} onBalanceChange={onStarBalanceChange} onBack={() => setSettingsView("main")} />;
  }

  if (settingsView === "profile") {
    return <ProfileEditScreen profile={profile} session={session} onSaveProfile={async (values) => {
      if (!profile?.user_id) return;
      try {
        await updateProfile(profile.user_id, values);
      } catch (error) {
        console.warn("Failed to update profile", error);
      }
    }} onBack={() => setSettingsView("main")} />;
  }

  if (settingsView === "language") {
    return <LanguageSettingsScreen profile={profile} onSelectLanguage={async (language) => {
      if (!profile?.user_id) return;
      await updateProfile(profile.user_id, { preferred_language: language });
      trackEvent(kpiEvents.languageSelected, { language });
    }} onBack={() => setSettingsView("settings")} />;
  }

  if (settingsView === "notifications") {
    return <NotificationSettingsScreen onBack={() => setSettingsView("settings")} />;
  }

  if (settingsView === "data") {
    return <DataManagementScreen
      notice={settingsNotice}
      onBack={() => setSettingsView("settings")}
      onRequestExport={async () => {
        await requestDataExport({ source: "settings" });
        setSettingsNotice("데이터 내려받기 요청이 저장됐어요. 준비가 완료되면 이 화면에서 안내할게요.");
        trackEvent(kpiEvents.dataExportRequested);
      }}
      onResetRecords={async () => {
        setSettingsNotice(t("settings.data.reset.notice"));
        trackEvent(kpiEvents.recordsResetRequested);
      }}
      onRequestAccountDeletion={async () => {
        await requestAccountDeletion({ metadata: { source: "settings" } });
        setSettingsNotice("계정 삭제 요청이 저장됐어요. 처리 전까지 로그인과 데이터 접근은 유지됩니다.");
        trackEvent(kpiEvents.accountDeletionRequested);
      }}
    />;
  }

  if (settingsView === "legal") {
    return <LegalNoticeScreen onBack={() => setSettingsView("settings")} />;
  }

  if (settingsView === "settings") {
    return (
      <div className="screen home-screen with-bottom-nav">
        <header className="settings-detail-header">
          <button className="icon-button" type="button" onClick={() => setSettingsView("main")} aria-label="Profile로 돌아가기">
            <ChevronLeft size={22} />
          </button>
          <h1>{t("settings.title")}</h1>
        </header>

        <section className="settings-section">
          {settingsDetailItems.map(([title, description, Icon, view]) => (
            <button
              className="settings-row"
              type="button"
              key={title}
              onClick={view === "logout" ? onSignOut : view === "report" ? () => setReportOpen(true) : () => setSettingsView(view)}
            >
              <span className="settings-row-icon"><Icon size={18} /></span>
              <span>
                <strong>{title}</strong>
                <em>{description}</em>
              </span>
              <ChevronRight size={17} />
            </button>
          ))}
        </section>
        {reportOpen && (
          <ReportSheet
            loveUnlocked={loveUnlocked}
            onUnlockLove={onUnlockLove}
            onClose={() => setReportOpen(false)}
          />
        )}
      </div>
    );
  }

  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="diary-topbar settings-topbar app-page-header">
        <div className="diary-title-lockup">
          <span className="diary-title-icon"><User size={20} /></span>
          <h1>{t("profile.title")}</h1>
        </div>
      </header>

      <section className="settings-profile-card">
        <div className="settings-profile-main">
          <p className="settings-signal-line">{t("profile.signal")}</p>
          <h1>{profile?.nickname || "지우"}님</h1>
          <span>기록이 쌓이면 이 문장도 조금씩 달라져요.</span>
          <button className="profile-edit-button" type="button" onClick={() => setSettingsView("profile")}>
            프로필 수정
          </button>
        </div>
      </section>

      <section className="profile-trace-panel" aria-labelledby="profile-trace-title">
        <div className="profile-section-heading compact">
          <span>Trace</span>
          <h2 id="profile-trace-title">나의 탐구 요약</h2>
        </div>
        <div className="profile-stats-grid" aria-label="나의 탐구 기록">
          {profileStats.map(([label, value, Icon]) => (
            <div className="profile-stat-cell" key={label}>
              <Icon size={14} />
              <span>{label}</span>
              <strong>{value}</strong>
            </div>
          ))}
        </div>
      </section>

      <section className="profile-flow-panel report-entry-panel" aria-labelledby="profile-flow-title">
        <div className="profile-section-heading">
          <span>Report</span>
          <h2 id="profile-flow-title">최근 흐름 요약</h2>
        </div>
        <div className="profile-flow-list">
          {profileFlowNotes.map(([title, copy, Icon]) => (
            <article className="profile-flow-item" key={title}>
              <span className="profile-flow-icon"><Icon size={15} /></span>
              <div>
                <strong>{title}</strong>
                <p>{copy}</p>
              </div>
            </article>
          ))}
        </div>
        <button className="report-inline-button" type="button" onClick={() => setReportOpen(true)} aria-label="기록 흐름 전체보기 열기">
          <span>
            <strong>기록 흐름 전체보기</strong>
            <em>현재까지 보이는 단서와 흐름</em>
          </span>
          <ChevronRight size={17} />
        </button>
      </section>

      <section className="settings-section">
        <button className="settings-row" type="button" onClick={() => setSettingsView("star")} aria-label="Star 보상내역 보기">
          <span className="settings-row-icon"><Sparkles size={18} /></span>
          <span>
            <strong>Star / 보상내역</strong>
            <em>출석, Diary, 깊은 보기 흐름</em>
          </span>
          <ChevronRight size={17} />
        </button>
        <PwaInstallPrompt />
        <button className="settings-row" type="button" onClick={() => setSettingsView("settings")} aria-label="설정 상세 열기">
          <span className="settings-row-icon"><Settings size={18} /></span>
          <span>
            <strong>설정</strong>
            <em>계정, 언어, 알림, 데이터 관리</em>
          </span>
          <ChevronRight size={17} />
        </button>
      </section>
      {reportOpen && (
        <ReportSheet
          loveUnlocked={loveUnlocked}
          onUnlockLove={onUnlockLove}
          onClose={() => setReportOpen(false)}
        />
      )}
    </div>
  );
}

function PwaInstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = React.useState(null);
  const [status, setStatus] = React.useState("");
  const [installed, setInstalled] = React.useState(
    () => window.matchMedia?.("(display-mode: standalone)")?.matches || window.navigator.standalone
  );

  React.useEffect(() => {
    const handleBeforeInstall = (event) => {
      event.preventDefault();
      setDeferredPrompt(event);
      setStatus("");
    };
    const handleInstalled = () => {
      setInstalled(true);
      setDeferredPrompt(null);
      setStatus(t("settings.pwa.installed"));
    };
    window.addEventListener("beforeinstallprompt", handleBeforeInstall);
    window.addEventListener("appinstalled", handleInstalled);
    return () => {
      window.removeEventListener("beforeinstallprompt", handleBeforeInstall);
      window.removeEventListener("appinstalled", handleInstalled);
    };
  }, []);

  const handleInstall = async () => {
    if (installed) {
      setStatus(t("settings.pwa.installed"));
      return;
    }
    if (!deferredPrompt) {
      setStatus(t("settings.pwa.unavailable"));
      return;
    }
    await deferredPrompt.prompt();
    setDeferredPrompt(null);
  };

  return (
    <button className="settings-row pwa-install-row" type="button" onClick={handleInstall} aria-label={t("settings.pwa.install")}>
      <span className="settings-row-icon"><ShieldCheck size={18} /></span>
      <span>
        <strong>{installed ? t("settings.pwa.installed") : t("settings.pwa.install")}</strong>
        <em>{status || t("settings.pwa.description")}</em>
      </span>
      <ChevronRight size={17} />
    </button>
  );
}

function StarLedgerScreen({ balance = 150, onBalanceChange, onBack }) {
  const [topUpOpen, setTopUpOpen] = React.useState(false);

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="Profile로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>Star / 보상내역</h1>
      </header>

      <section className="glass-card star-ledger-hero">
        <span>보유 Star</span>
        <strong><Sparkles size={20} />{balance}</strong>
        <p>Star는 FI-YOU 안에서 더 깊은 탐구를 열 때 사용하는 단위예요.</p>
        <button className="secondary-button star-topup-entry-button" type="button" onClick={() => setTopUpOpen(true)}>
          Star 모으기 안내
        </button>
      </section>

      <section className="settings-info-card">
        <h2>Star를 얻는 방법</h2>
        <div className="star-rule-grid">
          <span><strong>출석</strong><em>+10</em></span>
          <span><strong>Diary 작성</strong><em>+12</em></span>
          <span><strong>광고 시청</strong><em>+15</em></span>
        </div>
        <p>Diary는 하루 1회, 50자 이상 작성 시 받을 수 있어요. 수정은 언제든 가능하지만 Star는 하루 첫 기록에만 반영돼요.</p>
      </section>

      <section className="settings-section">
        {starLedgerItems.map(([label, amount, description, date]) => (
          <article className={`ledger-row ${amount.startsWith("-") ? "spend" : "earn"}`} key={`${label}-${date}`}>
            <span className="ledger-icon"><Sparkles size={15} /></span>
            <div>
              <strong>{label}</strong>
              <p>{description}</p>
              <em>{date}</em>
            </div>
            <b>{amount}</b>
          </article>
        ))}
      </section>

      {topUpOpen && (
        <StarTopUpSheet
          balance={balance}
          onClose={() => setTopUpOpen(false)}
        />
      )}
    </div>
  );
}

function ProfileEditScreen({ profile, session, onSaveProfile, onBack }) {
  const [nickname, setNickname] = React.useState(profile?.nickname || "지우");
  const [birthday, setBirthday] = React.useState(profile?.birthday || "1998-06-13");
  const accountInfo = [
    ["이메일", session?.user?.email || "Google 계정 확인 중"],
    ["로그인 방식", "Google"],
    ["가입일", profile?.created_at ? new Date(profile.created_at).toLocaleDateString("ko-KR") : "2026.06.13"]
  ];

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="Profile로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>프로필 / 계정</h1>
      </header>

      <section className="glass-card profile-edit-card">
        <label htmlFor="profile-nickname">닉네임</label>
        <input id="profile-nickname" className="diary-title-input" value={nickname} onChange={(event) => setNickname(event.target.value)} />
        <p className="field-hint">닉네임은 2~20자로 표시돼요.</p>
        <label htmlFor="profile-birthday">생년월일</label>
        <input id="profile-birthday" className="diary-title-input" value={birthday} onChange={(event) => setBirthday(event.target.value)} />
        <p className="field-hint">생년월일은 미래 날짜가 될 수 없어요.</p>
        <div className="account-readonly-list" aria-label="계정 정보">
          {accountInfo.map(([label, value]) => (
            <div className="account-readonly-row" key={label}>
              <span>{label}</span>
              <strong>{value}</strong>
            </div>
          ))}
        </div>
      </section>

      <button className="primary-button setup-button" type="button" onClick={async () => {
        await onSaveProfile?.({ nickname, birthday });
        onBack();
      }}>
        저장하기
      </button>
    </div>
  );
}

function LegalNoticeScreen({ onBack }) {
  const notices = [
    [t("legal.terms.title"), t("legal.terms.copy")],
    [t("legal.privacy.title"), t("legal.privacy.copy")],
    [t("legal.ai.title"), t("legal.ai.copy")]
  ];

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="설정으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>서비스 약관</h1>
      </header>
      <section className="settings-section legal-notice-section">
        {notices.map(([title, copy]) => (
          <article className="glass-card legal-notice-card" key={title}>
            <strong>{title}</strong>
            <p>{copy}</p>
          </article>
        ))}
      </section>
    </div>
  );
}

function LanguageSettingsScreen({ profile, onSelectLanguage, onBack }) {
  const [selected, setSelected] = React.useState(profile?.preferred_language || "ko");
  const [notice, setNotice] = React.useState("");
  const handleSelect = async (code) => {
    setSelected(code);
    try {
      await onSelectLanguage?.(code);
      setNotice("언어 설정이 저장됐어요. AI 응답 언어도 이 설정을 기준으로 맞춰갈게요.");
    } catch (error) {
      console.warn("Failed to save language", error);
      setNotice("언어 설정을 저장하지 못했어요. 잠시 후 다시 시도해주세요.");
    }
  };
  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="설정으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>언어</h1>
      </header>
      <section className="settings-section">
        {supportedLanguages.map(({ code, label }) => (
          <button className={`settings-choice-row ${selected === code ? "active" : ""}`} type="button" key={code} onClick={() => handleSelect(code)}>
            <span>{label}</span>
            {selected === code && <Check size={18} />}
          </button>
        ))}
        {notice && <p className="settings-inline-notice">{notice}</p>}
        <div className="language-suggest-card">
          <span>원하는 언어가 없나요?</span>
          <button type="button">언어 제안하기</button>
        </div>
      </section>
    </div>
  );
}

function NotificationSettingsScreen({ onBack }) {
  const [allEnabled, setAllEnabled] = React.useState(true);
  const [prefs, setPrefs] = React.useState({
    today: true,
    diary: true,
    map: false,
    growth: false
  });
  const items = [
    ["today", "오늘의 탐구", "오늘 질문을 이어갈 시간을 알려드려요."],
    ["diary", "Diary 리마인드", "기록을 남길 시간을 부드럽게 알려드려요."],
    ["map", "U-Map 변화", "새로운 단서가 쌓였을 때 알려드려요."],
    ["growth", "Growth 흐름", "기록이 모이면 변화 흐름을 알려드려요."]
  ];

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="설정으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>알림</h1>
      </header>
      <section className="settings-section">
        <button className="toggle-row master-toggle-row" type="button" onClick={() => setAllEnabled((value) => !value)}>
          <span>
            <strong>전체 알림</strong>
            <em>FI-YOU 알림을 한 번에 켜고 끌 수 있어요.</em>
          </span>
          <i className={allEnabled ? "on" : ""} aria-hidden="true"><b /></i>
        </button>
        <div className="settings-divider" aria-hidden="true" />
        {items.map(([key, title, copy]) => (
          <button
            className={`toggle-row ${!allEnabled ? "disabled" : ""}`}
            type="button"
            key={key}
            onClick={() => setPrefs((current) => ({ ...current, [key]: !current[key] }))}
          >
            <span>
              <strong>{title}</strong>
              <em>{copy}</em>
            </span>
            <i className={allEnabled && prefs[key] ? "on" : ""} aria-hidden="true"><b /></i>
          </button>
        ))}
      </section>
    </div>
  );
}

function DataManagementScreen({ notice, onBack, onRequestExport, onResetRecords, onRequestAccountDeletion }) {
  const [sheet, setSheet] = React.useState(null);
  const [busy, setBusy] = React.useState(false);
  const [localNotice, setLocalNotice] = React.useState("");
  const actions = [
    ["download", t("settings.data.export.title"), t("settings.data.export.copy"), Database],
    ["reset", t("settings.data.reset.title"), t("settings.data.reset.copy"), ShieldCheck],
    ["delete", t("settings.data.delete.title"), t("settings.data.delete.copy"), Trash2]
  ];

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="설정으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>{t("settings.data.title")}</h1>
      </header>
      <section className="settings-section">
        {actions.map(([key, title, copy, Icon]) => (
          <button className={`settings-row data-action-row ${key === "delete" ? "danger" : ""}`} type="button" key={key} onClick={() => setSheet({ title, copy, key })}>
            <span className="settings-row-icon"><Icon size={18} /></span>
            <span>
              <strong>{title}</strong>
              <em>{copy}</em>
            </span>
            <ChevronRight size={17} />
          </button>
        ))}
      </section>
      {sheet && (
        <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label={sheet.title}>
          <div className="calendar-sheet data-confirm-sheet">
            <header className="calendar-header">
              <h2>{sheet.title}</h2>
              <button className="icon-button" type="button" onClick={() => setSheet(null)} aria-label="닫기">
                <ChevronDown size={21} />
              </button>
            </header>
            <p>{sheet.copy}</p>
            <button className={sheet.key === "delete" ? "secondary-button danger-soft" : "primary-button"} type="button" disabled={busy} onClick={async () => {
              if (sheet.key === "reset" && !sheet.confirmed) {
                setSheet({
                  ...sheet,
                  confirmed: true,
                  copy: t("settings.data.reset.confirmCopy")
                });
                return;
              }
              setBusy(true);
              setLocalNotice("");
              try {
                if (sheet.key === "download") await onRequestExport?.();
                if (sheet.key === "reset") await onResetRecords?.();
                if (sheet.key === "delete") await onRequestAccountDeletion?.();
                setSheet(null);
              } catch (error) {
                console.warn("Data management action failed", error);
                setLocalNotice(t("settings.data.error"));
              } finally {
                setBusy(false);
              }
            }}>
              {busy
                ? "처리 중"
                : sheet.key === "reset" && !sheet.confirmed
                  ? t("settings.data.reset.firstCta")
                  : sheet.key === "reset"
                    ? t("settings.data.reset.finalCta")
                    : "확인"}
            </button>
          </div>
        </div>
      )}
      {(notice || localNotice) && <p className="settings-inline-notice data-management-notice">{localNotice || notice}</p>}
    </div>
  );
}

function GrowthScreen({ onBack, onOpenCompare }) {
  const axisChanges = [
    ["탐구성", "질문을 통해 가능성을 더 넓게 살펴보는 흐름이 늘었어요."],
    ["안정추구", "결정을 미루기보다 납득 가능한 기준을 찾는 모습이 보여요."],
    ["자기표현", "생각을 먼저 정리한 뒤 표현하려는 단서가 이어지고 있어요."]
  ];

  return (
    <div className="screen home-screen u-map-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="U-Map으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>Growth</h1>
      </header>

      <section className="glass-card growth-hero-card">
        <p className="eyebrow">최근 변화 요약</p>
        <h1>{t("growth.hero.title")}</h1>
        <p>{t("growth.hero.copy")}</p>
      </section>

      <section className="u-map-detail-section">
        <div className="section-heading">
          <h2>축별 변화</h2>
          <span>현재 기록 기준</span>
        </div>
        <div className="growth-change-list">
          {axisChanges.map(([axis, copy]) => (
            <article className="growth-change-card" key={axis}>
              <strong>{axis}</strong>
              <p>{copy}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="glass-card growth-ai-card">
        <Sparkles size={16} />
        <p>{t("growth.comment")}</p>
      </section>

      <button className="glass-card growth-compare-card" type="button" onClick={onOpenCompare}>
        <span>
          <strong>과거의 나와 비교하기</strong>
          <em>첫 단서 시점과 최근 기록을 나란히 살펴봐요.</em>
        </span>
        <b className="inline-cost-action">
          <span>과거 비교 열기</span>
          <StarCostPill amount={30} />
        </b>
      </button>
    </div>
  );
}

function StarUseConfirmScreen({ action, balance: syncedBalance = 150, onBack, onConfirm, pending = false, notice = "" }) {
  const [topUpOpen, setTopUpOpen] = React.useState(false);
  const balance = syncedBalance;
  const after = balance - action.cost;
  const isShort = after < 0;
  const shortage = Math.abs(after);

  return (
    <div className="screen home-screen u-map-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <h1>Star 확인</h1>
      </header>

      <section className="glass-card star-confirm-card">
        <p className="eyebrow">Star 열기 확인</p>
        <h1>{action.title}</h1>
        <p>{action.description}</p>
        <div className="star-confirm-grid">
          <span><em>보유 Star</em><strong>{balance}</strong></span>
          <span><em>필요 Star</em><strong>{action.cost}</strong></span>
          <span><em>열기 후</em><strong>{after}</strong></span>
        </div>
        <div className="star-confirm-notes">
          <span>한 번 연 내용은 다시 볼 수 있어요.</span>
          {isShort ? (
            <span className="star-shortage-note">{shortage} Star가 더 필요해요.</span>
          ) : (
            <span>필요한 Star만 사용하고, 질문과 기본 U-Map은 그대로 이어갈 수 있어요.</span>
          )}
        </div>
        {notice && <p className="diary-inline-error star-confirm-error">{notice}</p>}
      </section>

      <div className="free-confirm-actions">
        <button className="primary-button cost-cta-button" type="button" disabled={pending} onClick={isShort ? () => setTopUpOpen(true) : onConfirm}>
          {isShort ? (
            <span>Star 모으기 안내</span>
          ) : pending ? (
            <span>여는 중</span>
          ) : (
            <>
              <span>{action.ctaLabel || action.title}</span>
              <StarCostPill amount={action.cost} suffix={action.kind === "relation" ? "/ 명" : ""} />
            </>
          )}
          <ArrowRight size={19} />
        </button>
        <button className="secondary-button" type="button" onClick={onBack} disabled={pending}>
          나중에 보기
        </button>
      </div>

      {topUpOpen && (
        <StarTopUpSheet balance={balance} onClose={() => setTopUpOpen(false)} />
      )}
    </div>
  );
}

function PastCompareResultScreen({ onBack }) {
  const changes = [
    ["탐구성", "첫 단서보다 질문을 넓게 바라보는 흐름"],
    ["진취성", "생각을 작게 행동으로 옮기려는 신호"],
    ["안정추구", "나에게 맞는 기준을 먼저 확인하는 방향"]
  ];

  return (
    <div className="screen home-screen u-map-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="Growth로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>과거의 나와 비교</h1>
      </header>

      <section className="compare-columns">
        <article className="glass-card">
          <span>첫 단서 시점</span>
          <strong>조심스럽게 관찰하는 상태</strong>
          <p>아직 어떤 흐름이 반복되는지 확인하는 단계였어요.</p>
        </article>
        <article className="glass-card">
          <span>최근 기록</span>
          <strong>기준을 잡고 움직이는 상태</strong>
          <p>작은 행동과 회복 방식의 단서가 더 또렷해졌어요.</p>
        </article>
      </section>

      <section className="glass-card compare-summary-card">
        <strong>변화 요약</strong>
        <p>처음에는 감정과 장면을 관찰하는 흐름이 컸고, 최근에는 선택 기준과 실행 방향을 함께 정리하려는 모습이 보입니다.</p>
      </section>

      <section className="growth-change-list">
        {changes.map(([axis, copy]) => (
          <article className="growth-change-card" key={axis}>
            <strong>{axis}</strong>
            <p>{copy}</p>
          </article>
        ))}
      </section>
    </div>
  );
}

function RelationStartScreen({ onBack, onOpenConfirm }) {
  const [name, setName] = React.useState("");
  const [type, setType] = React.useState("관심 있는 사람");
  const relationConnections = [];
  const trimmedName = name.trim();

  return (
    <div className="screen home-screen u-map-subscreen relation-start-screen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="U-Map으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>관계 연결</h1>
      </header>

      <section className="glass-card relation-start-card">
        <p className="eyebrow">Relation-Map</p>
        <h1>연결된 관계 {relationConnections.length}/10</h1>
        <p>상대가 어떤 사람인지보다, 이 관계 안에서 내가 어떤 흐름을 경험하는지 살펴볼게요.</p>
        <label htmlFor="relation-name">상대 이름</label>
        <input id="relation-name" className="diary-title-input" value={name} onChange={(event) => setName(event.target.value)} placeholder="예: 민준" />
        <label htmlFor="relation-type">관계 종류</label>
        <select id="relation-type" value={type} onChange={(event) => setType(event.target.value)}>
          {["관심 있는 사람", "연인", "친구", "가족", "동료", "기타"].map((item) => (
            <option value={item} key={item}>{item}</option>
          ))}
        </select>
      </section>

      <section className="relation-connection-section">
        <div className="section-heading">
          <h2>연결된 관계</h2>
          <span>재진입</span>
        </div>
        <div className="relation-connection-list">
          {relationConnections.length ? (
            relationConnections.map(([person, relation, status, action]) => (
              <article className="relation-connection-card" key={`${person}-${relation}`}>
                <div>
                  <strong>{person}</strong>
                  <p>{relation} · {status}</p>
                </div>
                <button type="button">{action}</button>
              </article>
            ))
          ) : (
            <article className="relation-empty-card">
              <strong>아직 연결된 관계가 없어요.</strong>
              <p>새 관계를 추가하면, 그 관계 안에서 내가 경험하는 흐름을 이어서 살펴볼 수 있어요.</p>
            </article>
          )}
        </div>
      </section>

      <button className="primary-button setup-button cost-cta-button" type="button" disabled={!trimmedName} onClick={() => onOpenConfirm({ name: trimmedName, type })}>
        <span>{trimmedName ? "Relation-Map 열기" : "상대 이름을 입력해주세요"}</span>
        <StarCostPill amount={80} suffix="/ 명" />
      </button>
    </div>
  );
}

function RelationQuestionScreen({ partner, questions, onBack, onAnswer, onComplete }) {
  const [index, setIndex] = React.useState(0);
  const [selected, setSelected] = React.useState("");
  const [memo, setMemo] = React.useState("");
  const [saving, setSaving] = React.useState(false);
  const [notice, setNotice] = React.useState("");
  const defaultRelationQuestions = [
    {
      question: "이 관계에서 가장 자주 떠오르는 장면은 무엇인가요?",
      options: ["편안한 대화", "답을 기다리는 시간", "거리감을 조절하는 순간", "내 마음을 숨기는 순간"]
    },
    {
      question: "함께 있을 때 내가 가장 조심하게 되는 부분은 무엇인가요?",
      options: ["표현의 정도", "상대의 반응", "내 속도", "관계의 방향"]
    },
    {
      question: "이 관계에서 내가 편안함을 느끼는 조건은 무엇인가요?",
      options: ["예측 가능한 태도", "충분한 대화", "서로의 시간", "부담 없는 표현"]
    },
    {
      question: "관계 안에서 반복되는 나의 반응은 어디에 가까운가요?",
      options: ["먼저 정리하기", "조심스럽게 묻기", "잠시 거리두기", "바로 표현하기"]
    }
  ];
  const questionList = questions?.length ? questions : defaultRelationQuestions;
  const current = questionList[index % questionList.length];
  const progress = index + 1;

  const next = async () => {
    if (saving) return;
    setNotice("");
    try {
      setSaving(true);
      await onAnswer?.(current, selected, memo);
    } catch (error) {
      console.warn("Failed to save relation answer", error);
      setNotice("관계 답변을 저장하지 못했어요. 연결을 확인한 뒤 다시 시도해주세요.");
      return;
    } finally {
      setSaving(false);
    }
    setSelected("");
    setMemo("");
    if (index >= Math.min(questionList.length, 20) - 1) onComplete();
    else setIndex((value) => value + 1);
  };

  return (
    <div className="screen free-question-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="관계 연결으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <span>관계 질문 {progress} / 20</span>
        <i />
      </header>
      <div className="question-progress" aria-hidden="true">
        <span style={{ width: `${(progress / 20) * 100}%` }} />
      </div>
      <section className="question-copy">
        <p className="eyebrow">{partner?.name || "이 관계"}의 Relation-Map</p>
        <h1 className="question-heading">{current.question}</h1>
      </section>
      <div className="option-list multi-option-list">
        {current.options.map((option) => (
          <button className={`option-card ${selected === option ? "selected" : ""}`} type="button" key={option} onClick={() => setSelected(option)}>
            <span>{option}</span>
            {selected === option && <Check size={18} />}
          </button>
        ))}
      </div>
      <section className="relation-written-card">
        <label htmlFor="relation-memo">조금 더 설명하기</label>
        <textarea id="relation-memo" value={memo} onChange={(event) => setMemo(event.target.value.slice(0, 300))} placeholder="이 관계에서 내가 경험하는 장면이나 반응을 적어주세요." />
      </section>
      <button className="primary-button question-button" type="button" disabled={!selected || saving} onClick={next}>
        {saving ? "저장 중" : "다음 질문"}
        {selected && <ArrowRight size={19} />}
      </button>
      {notice && <p className="legal-copy">{notice}</p>}
    </div>
  );
}

function RelationMapResultScreen({ partner, onBack }) {
  const name = partner?.name || "이 관계";
  const clues = [
    "상대의 반응을 확인한 뒤 표현하려는 흐름이 보여요.",
    "가까워지고 싶은 마음과 내 리듬을 지키고 싶은 마음이 함께 나타나요.",
    "편안함은 예측 가능한 태도와 충분한 설명에서 더 자주 생겨요."
  ];

  return (
    <div className="screen home-screen u-map-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="U-Map으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>Relation-Map</h1>
      </header>

      <section className="glass-card relation-map-card">
        <p className="eyebrow">{name}</p>
        <h1>이 관계에서 경험하는 흐름</h1>
        <UMapPreview mode="clear" size="large" />
        <p className="relation-map-helper">{t("relation.helper")}</p>
        <p>상대의 마음을 단정하지 않고, 내가 이 관계 안에서 반복해서 경험하는 반응과 조절 방식을 정리했어요.</p>
      </section>

      <section className="u-map-detail-section">
        <div className="section-heading">
          <h2>주요 단서</h2>
          <span>현재 기록 기준</span>
        </div>
        <div className="u-map-insight-list">
          {clues.map((item) => (
            <article className="u-map-insight-card" key={item}>
              <Heart size={14} />
              <p>{item}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="glass-card relation-caution-card">
        <strong>주의할 해석 패턴</strong>
        <p>상대의 마음을 단정하기보다, 내가 불편함과 편안함을 느끼는 조건을 먼저 살펴보는 것이 좋아요.</p>
      </section>
    </div>
  );
}

function RelationshipScreen({ onBack }) {
  const [partnerName, setPartnerName] = React.useState("");
  const [relationshipType, setRelationshipType] = React.useState("관심 있는 사람");
  const [opened, setOpened] = React.useState(false);
  const resultSections = ["이 관계에서 반복되는 나의 흐름", "편안함과 부담이 생기는 지점", "표현과 거리 조절의 단서"];

  return (
    <div className="screen home-screen settings-subscreen">
      <header className="settings-detail-header">
        <button className="icon-button" type="button" onClick={onBack} aria-label="U-Map으로 돌아가기">
          <ChevronLeft size={22} />
        </button>
        <h1>관계 연결</h1>
      </header>

      <section className="glass-card relationship-card">
        <p>상대가 어떤 사람인지보다, 이 관계 안에서 내가 어떤 흐름을 경험하는지 살펴볼게요.</p>
        <label htmlFor="partner-name">상대 이름</label>
        <input id="partner-name" className="diary-title-input" value={partnerName} onChange={(event) => setPartnerName(event.target.value)} placeholder="예: 민준" />
        <label htmlFor="relationship-type">관계</label>
        <select id="relationship-type" value={relationshipType} onChange={(event) => setRelationshipType(event.target.value)}>
          {["관심 있는 사람", "연인", "친구", "가족", "동료", "기타"].map((item) => (
            <option value={item} key={item}>{item}</option>
          ))}
        </select>
      </section>

      <button className="primary-button setup-button cost-cta-button" type="button" onClick={() => setOpened(true)}>
        <span>관계 흐름 열기</span>
        <StarCostPill amount={80} suffix="/ 명" />
      </button>

      {opened && (
        <section className="relationship-result-list">
          {resultSections.map((item) => (
            <article className="glass-card relationship-result-card" key={item}>
              <strong>{item}</strong>
              <p>현재까지의 기록을 바탕으로 이 관계 안에서 반복되는 반응과 조절 방식을 정리했어요.</p>
            </article>
          ))}
        </section>
      )}
    </div>
  );
}

function ReportSheet({ loveUnlocked, onUnlockLove, onClose }) {
  const [expandedSections, setExpandedSections] = React.useState({});
  const reportContent = [
    ["전체 요약", t("report.section.summary")],
    ["자기 이해", t("report.section.self")],
    ["감정과 회복", t("report.section.recovery")],
    ["관계지향", t("report.section.relation")],
    ["자기표현", t("report.section.expression")],
    ["안정 추구", t("report.section.stability")],
    ["탐색성", t("report.section.exploration")],
    ["실행력", t("report.section.action")],
    ["독립성", t("report.section.independence")]
  ];
  const toggleSection = (title) => {
    setExpandedSections((current) => ({
      ...current,
      [title]: !current[title]
    }));
  };

  return (
    <div className="calendar-overlay" role="dialog" aria-modal="true" aria-label="리포트">
      <div className="calendar-sheet report-sheet">
        <header className="calendar-header report-header">
          <div className="report-title-lockup">
            <button className="icon-button" type="button" onClick={onClose} aria-label="닫기">
              <ChevronLeft size={21} />
            </button>
        <h2>{t("report.title")}</h2>
          </div>
          <span />
        </header>
        <p className="report-sheet-copy">{t("report.copy")}</p>
        <div className="report-content-heading report-content-heading-row">
          <div>
            <span>Report</span>
            <h3>{t("report.content.title")}</h3>
          </div>
          <button className="report-action-button" type="button" aria-label="결과 공유">
            <Share2 size={15} />
            <span>결과 공유</span>
          </button>
        </div>
        <nav className="report-section-nav" aria-label="리포트 섹션 목차">
          {["전체 요약", "자기 이해", "관계지향", "Growth", "연애 성향"].map((item) => (
            <button type="button" key={item}>{item}</button>
          ))}
        </nav>
        <section className="report-full-content">
          {reportContent.map(([title, copy]) => {
            const expanded = !!expandedSections[title];
            return (
            <article className={expanded ? "expanded" : "collapsed"} key={title}>
              <h3>{title}</h3>
              <div className="report-preview-text">
                <p>{copy}</p>
              </div>
              <button className="report-more-button" type="button" onClick={() => toggleSection(title)} aria-expanded={expanded}>
                <span>{expanded ? "접기" : "더보기"}</span>
                {expanded ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
              </button>
            </article>
            );
          })}
          <article className={`${loveUnlocked ? "report-unlocked-section" : "report-locked-section locked-only"} ${loveUnlocked && expandedSections["연애 성향"] ? "expanded" : "collapsed"}`}>
            <div>
              <div className="report-locked-heading">
                <div>
                  <span>관계 흐름 분석</span>
                  <h3>연애 성향</h3>
                </div>
                {!loveUnlocked && (
                  <div className="report-love-actions">
                    <StarCostPill as="button" amount={50} className="report-star-pill" type="button" onClick={onUnlockLove} aria-label="연애 성향 열기 50 Star" />
                  </div>
                )}
              </div>
              <div className="report-preview-text">
                {loveUnlocked ? (
                  <ul className="love-unlocked-list">
                    <li>가까워지고 싶은 마음과 자기 리듬을 지키고 싶은 마음이 함께 보여요.</li>
                    <li>안정감을 느끼기 위해 예측 가능한 태도와 충분한 표현이 중요한 단서로 보입니다.</li>
                    <li>마음을 바로 드러내기보다 먼저 정리한 뒤 표현하려는 흐름이 조금씩 나타나요.</li>
                  </ul>
                ) : (
                  <>
                    <p>연애를 고정된 이름으로 나누지 않아요. 현재까지의 기록에서 친밀감, 표현, 거리감, 안정감이 어떻게 나타나는지 살펴봅니다.</p>
                    <p>기록이 더 쌓이면 연애와 친밀감 관점의 흐름을 더 자세히 펼쳐볼 수 있어요.</p>
                  </>
                )}
              </div>
            </div>
            {loveUnlocked && (
              <button className="report-more-button" type="button" onClick={() => toggleSection("연애 성향")} aria-expanded={!!expandedSections["연애 성향"]}>
                <span>{expandedSections["연애 성향"] ? "접기" : "더보기"}</span>
                {expandedSections["연애 성향"] ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
              </button>
            )}
          </article>
        </section>
        <button className="primary-button report-close-button" type="button" onClick={onClose}>
          닫기
        </button>
      </div>
    </div>
  );
}

function FreeQuestionLoop({ questions, onAnswer, onClose }) {
  const [index, setIndex] = React.useState(0);
  const [selected, setSelected] = React.useState("");
  const [memo, setMemo] = React.useState("");
  const [memoSheetOpen, setMemoSheetOpen] = React.useState(false);
  const [saving, setSaving] = React.useState(false);
  const [notice, setNotice] = React.useState("");
  const questionList = Array.isArray(questions) ? questions : freeExploreQuestions;
  const totalCount = Math.max(30, questionList.length);
  const question = questionList[index];
  const displayIndex = index + 1;
  const memoPreview = memo.trim() ? `${memo.trim().slice(0, 28)}${memo.trim().length > 28 ? "..." : ""}` : "";

  const goNext = async () => {
    if (!question || saving) return;
    const persistedQuestion = Boolean(question.id);
    setNotice("");
    try {
      setSaving(true);
      await onAnswer?.(question, selected, memo);
    } catch (error) {
      console.warn("Failed to save free question answer", error);
      setNotice("답변을 저장하지 못했어요. 연결을 확인한 뒤 다시 시도해주세요.");
      return;
    } finally {
      setSaving(false);
    }
    setMemoSheetOpen(false);
    setSelected("");
    setMemo("");
    setIndex((current) => {
      if (persistedQuestion) return Math.min(current, Math.max(0, questionList.length - 2));
      return Math.min(current + 1, Math.max(0, questionList.length - 1));
    });
  };

  if (!questionList.length || !question) {
    return (
      <div className="screen free-question-screen">
        <header className="top-row">
          <button className="icon-button" type="button" onClick={onClose} aria-label="탐구 닫기">
            <ChevronLeft size={22} />
          </button>
          <span>탐구 완료</span>
          <i />
        </header>
        <section className="question-copy">
          <p className="eyebrow">U-Map</p>
          <h1 className="question-heading">오늘의 기본 탐구를 모두 살펴봤어요.</h1>
          <p>현재까지의 단서가 U-Map에 반영되는 중이에요. Diary를 남기면 다른 흐름도 더 선명해질 수 있어요.</p>
        </section>
        <button className="primary-button question-button" type="button" onClick={onClose}>
          Home으로 돌아가기
          <ArrowRight size={19} />
        </button>
      </div>
    );
  }

  return (
    <div className="screen free-question-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onClose} aria-label="탐구 닫기">
          <ChevronLeft size={22} />
        </button>
        <span>탐구 질문 {displayIndex} / {totalCount}</span>
        <i />
      </header>

      <div className="question-progress" aria-hidden="true">
        <span style={{ width: `${(displayIndex / totalCount) * 100}%` }} />
      </div>
      <section className="question-copy">
        <p className="eyebrow">이어지는 탐구</p>
        <h1 className="question-heading">{question.question}</h1>
        <p className="question-guide">정답은 없어요. 지금 가까운 쪽이면 충분해요.</p>
      </section>

      <div className="option-list multi-option-list">
        {question.options.map((option) => (
          <button className={`option-card ${selected === option ? "selected" : ""}`} type="button" key={option} onClick={() => setSelected(option)}>
            <span>{option}</span>
            {selected === option && <Check size={18} />}
          </button>
        ))}
      </div>

      <section className="note-card onboarding-note-card question-note-card">
        <div className="onboarding-note-separator" aria-hidden="true" />
        <div className="onboarding-note-label">선택한 답을 조금 더 설명하기</div>
        <button className={`onboarding-note-row ${memoPreview ? "filled" : ""}`} type="button" onClick={() => setMemoSheetOpen(true)}>
          <span>
            {memoPreview ? <strong>{memoPreview}</strong> : <em>더 자세히 알려주세요. 적지 않아도 괜찮아요.</em>}
          </span>
          {memoPreview ? <Check size={18} /> : <ChevronRight size={18} />}
        </button>
      </section>

      <button className="primary-button question-button" type="button" disabled={!selected || saving} onClick={goNext}>
        {saving ? "저장 중" : displayIndex >= totalCount ? "오늘은 여기까지" : "다음 질문"}
        {selected && <ArrowRight size={19} />}
      </button>
      {notice && <p className="legal-copy">{notice}</p>}

      {memoSheetOpen && (
        <div className="calendar-overlay onboarding-note-overlay" role="dialog" aria-modal="true" aria-label="선택 서술 입력">
          <div className="calendar-sheet onboarding-note-sheet">
            <header className="calendar-header">
              <h2>조금 더 남기고 싶다면</h2>
              <button className="icon-button" type="button" onClick={() => setMemoSheetOpen(false)} aria-label="닫기">
                <ChevronDown size={21} />
              </button>
            </header>
            <textarea
              id="free-note"
              value={memo}
              onChange={(event) => setMemo(event.target.value.slice(0, 220))}
              placeholder="선택한 질문에 대해 더 자세히 알려주세요. 적지 않아도 괜찮아요."
              autoFocus
            />
            <div className="onboarding-note-sheet-meta">
              <span>{memo.length} / 220</span>
              <button className="primary-button" type="button" onClick={() => setMemoSheetOpen(false)}>
                저장
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function BottomNav({ activeTab, onTabChange }) {
  const tabs = [
    { id: "home", label: "홈", icon: Home },
    { id: "diary", label: "다이어리", icon: BookOpen },
    { id: "explore", label: "탐구", icon: Sparkles, primary: true },
    { id: "map", label: "U-Map", icon: Orbit },
    { id: "settings", label: "Profile", icon: User }
  ];

  return (
    <nav className="bottom-nav" aria-label="메인 탭">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const selected = activeTab === tab.id;
        return (
          <button
            key={tab.id}
            type="button"
            className={`bottom-tab ${tab.primary ? "primary-tab" : ""} ${selected ? "active" : ""}`}
            onClick={() => onTabChange(tab.id)}
            aria-current={selected ? "page" : undefined}
          >
            <span className="tab-icon"><Icon size={tab.primary ? 24 : 19} /></span>
            <span>{tab.label}</span>
          </button>
        );
      })}
    </nav>
  );
}

function Principle({ icon, text }) {
  return (
    <div className="principle">
      <span>{icon}</span>
      <p>{text}</p>
    </div>
  );
}

function ChunkText({ as: Component = "p", className, chunks }) {
  return (
    <Component className={className ? `chunk-text ${className}` : "chunk-text"}>
      {chunks.map((line) => (
        <span key={line}>{line}</span>
      ))}
    </Component>
  );
}

function GoogleIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 20 20" aria-hidden="true">
      <path fill="#4285F4" d="M19.6 10.23c0-.69-.06-1.35-.18-1.99H10v3.76h5.38a4.6 4.6 0 0 1-2 3.02v2.47h3.24c1.9-1.74 2.98-4.3 2.98-7.26Z" />
      <path fill="#34A853" d="M10 20c2.7 0 4.97-.9 6.62-2.43l-3.24-2.47c-.9.6-2.04.96-3.38.96-2.6 0-4.8-1.75-5.59-4.1H1.08v2.55A10 10 0 0 0 10 20Z" />
      <path fill="#FBBC05" d="M4.41 11.96A6 6 0 0 1 4.1 10c0-.68.11-1.34.31-1.96V5.49H1.08A10 10 0 0 0 0 10c0 1.61.39 3.14 1.08 4.51l3.33-2.55Z" />
      <path fill="#EA4335" d="M10 3.94c1.47 0 2.8.51 3.84 1.51l2.86-2.86A9.58 9.58 0 0 0 10 0 10 10 0 0 0 1.08 5.49l3.33 2.55C5.2 5.69 7.4 3.94 10 3.94Z" />
    </svg>
  );
}

createRoot(document.getElementById("root")).render(<App />);

if ("serviceWorker" in navigator && import.meta.env.PROD) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js").catch((error) => {
      console.warn("Service worker registration failed", error);
    });
  });
}
