import React from "react";
import { createRoot } from "react-dom/client";
import {
  ArrowRight,
  Bell,
  BookOpen,
  CalendarDays,
  Check,
  ChevronLeft,
  ChevronRight,
  Compass,
  Database,
  FileText,
  Gift,
  Globe2,
  Home,
  LockKeyhole,
  LogOut,
  Map,
  MessageCircle,
  Pencil,
  Settings,
  ShieldCheck,
  Sparkles,
  Trash2,
  User
} from "lucide-react";
import "./styles.css";

const firstQuestions = [
  {
    question: "요즘 마음에 오래 남아 있는 장면이 있다면, 어디에서 온 걸까요?",
    options: [
      "누군가와 나눈 말이나 관계에서",
      "선택을 앞두고 망설였던 순간에서",
      "혼자 있을 때 떠오른 생각에서",
      "편해졌거나 복잡해졌던 감정에서",
      "아직 잘 모르겠어요"
    ]
  },
  {
    question: "최근 선택을 떠올렸을 때, 끝까지 지키고 싶었던 기준이 있었나요?",
    options: [
      "내 마음이 납득되는 것",
      "사람들과의 관계를 해치지 않는 것",
      "나중에 후회가 적을 것 같은 것",
      "새롭게 시도해볼 수 있는 것",
      "아직 잘 모르겠어요"
    ]
  },
  {
    question: "최근에 \"이건 한번 해보고 싶다\"고 느낀 순간이 있었나요?",
    options: ["Yes, 그런 순간이 있었어요", "No, 아직은 잘 떠오르지 않아요"]
  },
  {
    question: "요즘 마음이 조금 편해지는 순간을 알아차린 적이 있나요?",
    options: ["Yes, 떠오르는 순간이 있어요", "No, 아직은 잘 모르겠어요"]
  },
  {
    question: "앞으로 FI-YOU와 함께 가장 먼저 밝혀보고 싶은 영역은 어디인가요?",
    options: [
      "내가 중요하게 여기는 기준",
      "감정이 움직이는 방식",
      "관계에서 반복되는 흐름",
      "나를 움직이게 하는 힘",
      "앞으로의 방향과 성장"
    ],
    note: true
  }
];

const loadingMessages = [
  "아직은 더 많은 이야기가 필요해요.",
  "당신에 대해 함께 더 알아가기로 해요.",
  "이제 Home 화면으로 이동할게요."
];

const freeExploreQuestions = [
  {
    question: "오늘 가장 오래 마음에 남은 장면은 무엇이었나요?",
    options: ["대화 속 한 문장", "혼자 있던 시간", "해야 할 일을 떠올린 순간", "몸이 먼저 반응한 감정"]
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
  }
];

function App() {
  const initialScreen = new URLSearchParams(window.location.search).get("screen");
  const [step, setStep] = React.useState(initialScreen === "home" ? "home" : "intro");
  const [activeTab, setActiveTab] = React.useState("home");
  const [questionIndex, setQuestionIndex] = React.useState(0);
  const [answers, setAnswers] = React.useState({});
  const [note, setNote] = React.useState("");

  const startQuestions = () => {
    setQuestionIndex(0);
    setAnswers({});
    setNote("");
    setStep("question");
  };

  const selectedOption = answers[questionIndex] ?? "";

  const goNextQuestion = () => {
    if (questionIndex < firstQuestions.length - 1) {
      setQuestionIndex((current) => current + 1);
      return;
    }
    setStep("feedback");
  };

  return (
    <main className="app-shell">
      <div className="aurora aurora-one" />
      <div className="aurora aurora-two" />
      <section className="phone-frame" aria-label="FI-YOU first run">
        <StatusBar />
        {step === "intro" && <IntroScreen onNext={() => setStep("login")} />}
        {step === "login" && (
          <LoginScreen onBack={() => setStep("intro")} onContinue={() => setStep("profile")} />
        )}
        {step === "profile" && (
          <ProfileSetupScreen onBack={() => setStep("login")} onComplete={() => setStep("ready")} />
        )}
        {step === "ready" && <ReadyScreen onBack={() => setStep("profile")} onStart={startQuestions} />}
        {step === "question" && (
          <QuestionScreen
            question={firstQuestions[questionIndex]}
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
          />
        )}
        {step === "feedback" && (
          <FeedbackScreen
            onContinue={() => {
              setActiveTab("home");
              setStep("home");
            }}
          />
        )}
        {step === "home" && (
          <MainAppShell activeTab={activeTab} onTabChange={setActiveTab} onExplore={startQuestions} />
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

function IntroScreen({ onNext }) {
  return (
    <div className="screen intro-screen">
      <div className="brand-block">
        <div className="brand-mark"><Sparkles size={24} /></div>
        <p className="eyebrow">AI Self Discovery Platform</p>
        <h1>FI-YOU</h1>
        <p className="brand-subtitle">Figure Yourself</p>
      </div>

      <div className="hero-orbit" aria-hidden="true">
        <span className="orbit-dot dot-a" />
        <span className="orbit-dot dot-b" />
        <span className="orbit-dot dot-c" />
        <div className="core-glow"><Compass size={34} /></div>
      </div>

      <section className="glass-card intro-card">
        <h2>나를 판단하지 않고, 천천히 이해하는 곳</h2>
        <p>
          FI-YOU는 지속적인 질문과 기록을 통해 지금의 나를 관찰하고, 시간이 흐를수록
          더 자연스러운 자기이해를 도와주는 AI 기반 Self Discovery 플랫폼입니다.
        </p>
      </section>

      <div className="principle-list">
        <Principle icon={<MessageCircle size={18} />} text="대화를 통해 현재의 경향을 들여다봐요" />
        <Principle icon={<Sparkles size={18} />} text="고정된 이름표가 아니라 변화하는 흐름을 보여줘요" />
        <Principle icon={<LockKeyhole size={18} />} text="의료적 판단이나 상담이 아닌 자기탐구를 돕습니다" />
      </div>

      <button className="primary-button" type="button" onClick={onNext}>
        다음
        <ArrowRight size={19} />
      </button>
    </div>
  );
}

function LoginScreen({ onBack, onContinue }) {
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
        <h1>대화가 쌓이면 나의 지도가 선명해져요</h1>
        <p>Google 계정으로 안전하게 시작하고, 질문과 다이어리를 통해 나만의 U-Map을 만들어보세요.</p>
      </div>

      <section className="glass-card account-card">
        <div className="account-icon"><Sparkles size={24} /></div>
        <h2>처음이라면 무료로 시작해요</h2>
        <ul>
          <li><Check size={16} />첫 질문과 다이어리 기록</li>
          <li><Check size={16} />U-Map 흐름 확인</li>
          <li><Check size={16} />현재 보이는 경향 미리보기</li>
        </ul>
      </section>

      <button className="google-button" type="button" onClick={onContinue}>
        <GoogleIcon />
        Google로 계속하기
      </button>

      <p className="legal-copy">
        계속하면 FI-YOU의 서비스 약관과 개인정보 처리방침에 동의하게 됩니다.
        FI-YOU는 의료적 진단이나 심리상담을 제공하지 않습니다.
      </p>
    </div>
  );
}

function ProfileSetupScreen({ onBack, onComplete }) {
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
        <span>기본 프로필</span>
        <i />
      </header>

      <section className="profile-hero">
        <p className="eyebrow">First step</p>
        <h1>당신을 뭐라고 부를까요?</h1>
        <p>닉네임도 좋아요. FI-YOU 안에서 편하게 불릴 이름을 알려주세요.</p>
      </section>

      <section className="glass-card form-card">
        <label className="field-label" htmlFor="nickname">이름 또는 닉네임</label>
        <input
          id="nickname"
          className="text-field"
          value={nickname}
          onChange={(event) => setNickname(event.target.value)}
          placeholder="예: 유진"
          autoComplete="nickname"
        />

        <div className="birth-heading">
          <div>
            <label className="field-label" htmlFor="birth-year">나이를 알려주세요.</label>
            <p>생년월일</p>
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
        <p>나이는 당신을 분류하기 위한 정보가 아니에요. 고민의 시기와 표현 방식을 더 섬세하게 맞추기 위해 사용됩니다.</p>
      </section>

      <button className="primary-button setup-button" type="button" disabled={!isComplete} onClick={onComplete}>
        {isComplete ? "FI-YOU 시작하기" : "이름과 생년월일을 입력해주세요"}
      </button>
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
        <p>다섯 개의 짧은 질문으로 시작해요. 정답은 없고, 지금 가까운 쪽을 고르면 충분합니다.</p>
      </div>

      <div className="ready-cta-area">
        <p className="ready-terms-above">
          첫 질문을 시작하면 FI-YOU의 서비스 약관과 개인정보 처리방침에 동의한 것으로 간주돼요.
        </p>
        <button className="primary-button" type="button" onClick={onStart}>
          첫 질문 시작하기
          <ArrowRight size={19} />
        </button>
        <p className="ready-terms-below">
          FI-YOU는 의료적 진단이나 심리상담을 제공하지 않으며, 대화를 바탕으로 자기이해를 돕는 Self Discovery 서비스예요.
        </p>
      </div>
    </div>
  );
}

function QuestionScreen({ question, questionIndex, selectedOption, note, onBack, onSelect, onNoteChange, onNext }) {
  const isLast = questionIndex === firstQuestions.length - 1;

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
        <p className="eyebrow">{isLast ? "Next direction" : "Quick choice"}</p>
        <h1>{question.question}</h1>
        <p>정답은 없어요. 지금 가까운 쪽이면 충분해요.</p>
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
        <section className="note-card">
          <label htmlFor="discovery-note">조금 더 남기고 싶다면</label>
          <p>궁금한 이유가 있다면 짧게 남겨도 좋아요. 적지 않아도 다음 질문으로 이어갈 수 있어요.</p>
          <textarea
            id="discovery-note"
            value={note}
            onChange={(event) => onNoteChange(event.target.value.slice(0, 300))}
            placeholder="예: 관계에서 비슷한 고민이 반복되는 이유가 궁금해요."
          />
          <span>{note.length} / 300</span>
        </section>
      )}

      <button className="primary-button question-button" type="button" disabled={!selectedOption} onClick={onNext}>
        {!selectedOption ? "가까운 쪽을 골라주세요" : isLast ? "첫 단서 저장하기" : "다음"}
        {selectedOption && <ArrowRight size={19} />}
      </button>
    </div>
  );
}

function FeedbackScreen({ onContinue }) {
  const [messageIndex, setMessageIndex] = React.useState(0);

  React.useEffect(() => {
    const timer = window.setTimeout(onContinue, 4300);
    return () => window.clearTimeout(timer);
  }, [onContinue]);

  React.useEffect(() => {
    const interval = window.setInterval(() => {
      setMessageIndex((current) => Math.min(current + 1, loadingMessages.length - 1));
    }, 1300);

    return () => window.clearInterval(interval);
  }, [loadingMessages.length]);

  return (
    <div className="screen feedback-screen">
      <div className="map-ghost" aria-hidden="true">
        <Map size={36} />
        <span /><span /><span />
      </div>
      <section className="feedback-copy">
        <p className="eyebrow">Building U-Map</p>
        <h1>첫 단서를 U-Map에 남기는 중이에요</h1>
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

function MainAppShell({ activeTab, onTabChange, onExplore }) {
  const [freeLoopOpen, setFreeLoopOpen] = React.useState(false);

  const openFreeLoop = () => {
    onTabChange("explore");
    setFreeLoopOpen(true);
  };

  if (freeLoopOpen) {
    return (
      <div className="main-app-screen">
        <FreeQuestionLoop onClose={() => setFreeLoopOpen(false)} />
      </div>
    );
  }

  return (
    <div className="main-app-screen">
      {activeTab === "home" && <HomeScreen onExplore={openFreeLoop} />}
      {activeTab === "diary" && <DiaryScreen />}
      {activeTab === "explore" && <ExploreScreen onExplore={openFreeLoop} />}
      {activeTab === "map" && <UMapScreen />}
      {activeTab === "settings" && <SettingsScreen />}
      <BottomNav activeTab={activeTab} onTabChange={onTabChange} />
    </div>
  );
}

function HomeScreen({ onExplore }) {
  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="home-topbar">
        <div>
          <p className="eyebrow">FI-YOU</p>
          <h1>오늘의 탐구</h1>
        </div>
        <button className="status-pill" type="button" aria-label="보유 Star 150, 현재 레벨 탐험가">
          <span className="status-pill-section point-section">
            <Sparkles size={14} />
            150
          </span>
          <span className="status-pill-section level-badge">탐험가</span>
        </button>
      </header>

      <section className="glass-card next-question-card">
        <p className="card-kicker">다음 행동</p>
        <h2>오늘의 질문으로 U-Map을 조금 더 밝혀볼까요?</h2>
        <p>30개의 무료 탐구가 남아 있어요. 짧게 선택만 해도 다음 단서가 쌓입니다.</p>
        <div className="free-progress">
          <span>무료 탐구</span>
          <strong>5 / 35</strong>
        </div>
        <div className="mini-progress" aria-hidden="true">
          <span style={{ width: "14%" }} />
        </div>
        <button className="primary-button" type="button" onClick={onExplore}>
          오늘의 질문 시작하기
          <ArrowRight size={19} />
        </button>
      </section>

      <section className="glass-card u-map-home-card">
        <div className="home-card-head">
          <div>
            <p className="card-kicker">U-Map</p>
            <h2>아직은 흐릿한 윤곽이에요</h2>
          </div>
          <Map size={22} />
        </div>
        <div className="u-map-preview" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
        <p>첫 단서가 들어왔고, 질문과 Diary가 쌓이면 감정, 관계, 가치관의 흐름이 더 자연스럽게 보일 거예요.</p>
      </section>

      <section className="home-two-col">
        <button className="glass-card home-action-card" type="button">
          <BookOpen size={21} />
          <span>다이어리</span>
          <strong>오늘 남기고 싶은 장면이 있나요?</strong>
        </button>
        <button className="glass-card home-action-card" type="button" onClick={onExplore}>
          <Sparkles size={21} />
          <span>다음 행동</span>
          <strong>질문 하나 더 이어가기</strong>
        </button>
      </section>

      <section className="locked-content-card">
        <LockKeyhole size={17} />
        <div>
          <strong>심층 분석은 아직 잠겨 있어요</strong>
          <p>Star는 질문이 아니라 더 깊은 분석과 리포트를 열 때 사용됩니다.</p>
        </div>
      </section>
    </div>
  );
}

function DiaryScreen() {
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

  const savedEntry = {
    date: "6월 13일",
    title: title || diaryEntries[0].title,
    self: todaySelf || diaryEntries[0].self,
    preview: body || diaryEntries[0].preview,
    mood: emotion,
    tags: tags.length ? tags : diaryEntries[0].tags
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
        onSave={() => {
          setSavedToast(true);
          setMode("detail");
        }}
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
        onToastDone={() => setSavedToast(false)}
      />
    );
  }

  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="diary-topbar diary-topbar-v2">
        <div className="diary-title-lockup">
          <span className="diary-title-icon"><Sparkles size={20} /></span>
          <div>
            <p className="eyebrow">Self Discovery Log</p>
            <h1>Diary</h1>
          </div>
        </div>
        <button className="diary-calendar-button" type="button" onClick={() => setCalendarOpen(true)} aria-label="기록 캘린더 열기">
          <CalendarDays size={18} />
        </button>
      </header>

      <button className="glass-card home-hero diary-write-card" type="button" aria-label="오늘의 단서 기록하기" onClick={() => setMode("write")}>
        <p className="eyebrow">Today</p>
        <h1>오늘의 나를 설명하는 장면이 있나요?</h1>
        <p>좋았던 것, 맞지 않았던 것, 내 기준이 드러난 순간을 남겨보세요. 감정은 그 장면을 이해하는 작은 신호로만 살펴볼게요.</p>
        <span className="diary-write-cta">다이어리 작성하기</span>
      </button>

      <div className="home-list">
        <div><span>오늘의 나</span><strong>내 기준을 확인하는 중</strong></div>
        <div><span>반복 단서</span><strong>관계 · 회복 · 선택 기준</strong></div>
      </div>

      <p className="diary-reward-note">50자 이상 남기면 오늘의 Diary 보상 +12 Star</p>

      <section className="diary-list-section">
        <div className="section-heading">
          <h2>저장된 다이어리</h2>
          <span>카드로 다시 보기</span>
        </div>
        {deleteToast && (
          <button className="diary-delete-toast" type="button" onClick={() => setDeleteToast(false)}>
            Diary 보상 12 Star가 회수돼요. 보유 Star가 12 미만이면 0으로 조정됩니다.
          </button>
        )}
        <DiaryYearCardsV3
          year="2026"
          entries={[diaryEntries[0], diaryEntries[1]].filter((entry) => !deletedCards.includes(entry.title))}
          onOpen={() => setMode("detail")}
          onEdit={() => setMode("write")}
          onDelete={(entry) => {
            setDeletedCards((current) => [...current, entry.title]);
            setDeleteToast(true);
          }}
        />
        <DiaryYearCardsV3
          year="2025"
          entries={[diaryEntries[2], diaryEntries[3]].filter((entry) => !deletedCards.includes(entry.title))}
          onOpen={() => setMode("detail")}
          onEdit={() => setMode("write")}
          onDelete={(entry) => {
            setDeletedCards((current) => [...current, entry.title]);
            setDeleteToast(true);
          }}
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
          <span>{rewardReady ? "오늘의 단서가 충분히 남았어요." : "50자 이상 남기면 오늘의 Diary 보상 +12 Star"}</span>
          <strong>{body.trim().length} / 50</strong>
        </div>
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

function DiaryWriteV3({ title, body, emotion, onBack, onTitleChange, onBodyChange, onEmotionChange, onSave }) {
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
        <textarea id="diary-body-v3" value={body} onChange={(event) => onBodyChange(event.target.value)} placeholder="오늘 좋았던 것, 맞지 않았던 것, 내 기준이 드러난 장면을 자유롭게 남겨주세요." />

        <div className="ai-mood-box mood-summary-box">
          <div>
            <strong>기분 및 감정</strong>
            <span>AI가 본문을 읽고 제안할 수 있어요. 감정은 보조 신호로만 살펴볼게요.</span>
          </div>
          <span className="emotion-pill mood-current">{emotion}</span>
          <button className="mood-edit-button" type="button" onClick={() => setEmotionOpen(true)}>
            직접 선택
          </button>
        </div>

        <div className="diary-editor-meta">
          <span>{rewardReady ? "오늘의 단서가 충분히 남았어요." : "50자 이상 남기면 오늘의 Diary 보상 +12 Star"}</span>
          <strong>{body.trim().length} / 50</strong>
        </div>
      </section>

      <button className="primary-button setup-button diary-save-button" type="button" onClick={onSave}>
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
            <p className="mood-sheet-copy">감정은 기록을 이해하기 위한 작은 신호예요. 지금 더 가까운 표현을 골라주세요.</p>
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

function DiaryDetailV3({ entry, body, emotion, onBack, onBodyChange, onEmotionChange, savedToast, onToastDone }) {
  const [editing, setEditing] = React.useState(false);
  const [deleteNotice, setDeleteNotice] = React.useState(false);
  const emotions = ["차분함", "복잡함", "기대감", "불편함", "편안함"];

  return (
    <div className="screen diary-edit-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onBack} aria-label="이전으로">
          <ChevronLeft size={22} />
        </button>
        <span>Diary</span>
        <i />
      </header>

      {savedToast && (
        <button className="diary-toast" type="button" onClick={onToastDone}>
          오늘의 기록에서 나를 이해할 단서가 생겼어요. +12 Star
        </button>
      )}
      {deleteNotice && (
        <button className="diary-delete-toast" type="button" onClick={() => setDeleteNotice(false)}>
          Diary 보상 12 Star가 회수돼요. 보유 Star가 12 미만이면 0으로 조정됩니다.
        </button>
      )}

      <section className="diary-detail-card">
        <div className="diary-detail-head">
          <p className="eyebrow">2026년 {entry.date}</p>
          <div className="diary-card-actions" aria-label="Diary 작업">
            <button type="button" onClick={() => setEditing((value) => !value)} aria-label="수정하기">
              <Pencil size={14} />
            </button>
            <button type="button" className="danger" onClick={() => setDeleteNotice(true)} aria-label="삭제하기">
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
            <button className="primary-button" type="button" onClick={() => setEditing(false)}>수정 저장하기</button>
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
                <button type="button" onClick={onEdit} aria-label="수정하기">
                  <Pencil size={14} />
                </button>
                <button type="button" className="danger" onClick={() => onDelete(entry)} aria-label="삭제하기">
                  <Trash2 size={14} />
                </button>
              </div>
            </div>
            <button className="diary-entry-open" type="button" onClick={onOpen}>
              <strong>{entry.title}</strong>
              <p>{compactPreview(entry.preview)}</p>
              <div className="diary-card-pills">
                <span className="emotion-pill">{entry.mood}</span>
              </div>
            </button>
            <p className="diary-delete-policy">삭제 시 Diary 보상 12 Star가 회수돼요. 보유 Star가 12 미만이면 0으로 조정됩니다.</p>
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

      <p className="diary-reward-note">50자 이상 남기면 오늘의 Diary 보상 +12 Star</p>

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
          <span>{rewardReady ? "보상 조건이 충족됐어요." : "50자 이상 남기면 오늘의 Diary 보상 +12 Star"}</span>
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
                <p>본문에서 읽힌 분위기를 사용자가 직접 조정하는 mock 영역입니다.</p>
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

function CalendarModal({ selectedDay, onClose, onOpenDetail, onSelectDay }) {
  const days = Array.from({ length: 30 }, (_, index) => index + 1);
  const diaryDays = new Set([4, 9, 13, 21]);
  const attendanceDays = new Set([1, 2, 4, 8, 9, 13, 18, 21, 27]);

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
            const hasAttendance = attendanceDays.has(day);
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
                  {hasAttendance && <i aria-label="Star 보상"><Sparkles size={10} />10</i>}
                </span>
              </button>
            );
          })}
        </div>

        <section className="calendar-preview">
          <p className="eyebrow">6월 {selectedDay}일</p>
          <h3>{selectedDay === 13 ? "오늘 마음에 남은 장면" : "기록 미리보기"}</h3>
          <p>
            {selectedDay === 13
              ? "오늘의 기록이 U-Map에 단서로 남았어요. +12 Star"
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

function ExploreScreen({ onExplore }) {
  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="top-row">
        <span />
        <span>탐구</span>
        <i />
      </header>
      <section className="glass-card home-hero">
        <div className="home-icon"><Sparkles size={24} /></div>
        <p className="eyebrow">Explore</p>
        <h1>다음 질문으로 나를 더 살펴봐요</h1>
        <p>Home 이후에는 30개의 무료 질문으로 U-Map의 흐릿한 영역을 천천히 밝혀갑니다.</p>
      </section>
      <button className="primary-button setup-button" type="button" onClick={onExplore}>
        질문 이어가기
        <ArrowRight size={19} />
      </button>
    </div>
  );
}

function UMapScreen() {
  const [mapMode, setMapMode] = React.useState("initial");
  const isClear = mapMode === "clear";
  const statusRows = isClear
    ? [
        ["Growth", "변화 흐름 보기", "active"],
        ["비교 보기", "지난 나와 비교", "active"],
        ["관계 연결", "상대 U-Map과 연결", "active"]
      ]
    : [
        ["Growth", "변화 흐름 보기", "active"],
        ["비교 보기", "지난 나와 비교 준비 중", "muted"],
        ["관계 연결", "잠금 · 50 Star", "locked"]
      ];
  const insightItems = isClear
    ? [
        "새로운 가능성을 탐색하려는 경향이 보여요",
        "혼자 정리하는 시간이 회복에 도움이 되는 편이에요",
        "관계에서는 진정성과 거리감의 균형을 중요하게 보는 흐름이 있어요",
        "선택할 때 내 기준을 확인하려는 단서가 늘고 있어요",
        "복잡한 상황을 구조화하려는 역량 단서가 보여요"
      ]
    : [
        "새로운 가능성을 탐색하려는 단서가 조금씩 보이고 있어요",
        "혼자 정리하는 시간이 회복에 닿아 있을 수 있어요",
        "관계에서 중요하게 보는 기준은 더 살펴보는 중이에요"
      ];
  const openAreas = [
    "갈등 상황의 반응",
    "반복되는 선택 기준",
    "에너지 회복 방식",
    "협업에서 강점이 드러나는 순간"
  ];

  return (
    <div className="screen home-screen u-map-screen with-bottom-nav">
      <header className="diary-topbar u-map-topbar">
        <div className="diary-title-lockup">
          <span className="diary-title-icon u-map-title-icon"><Map size={20} /></span>
          <h1>U-Map</h1>
        </div>
      </header>

      <div className="u-map-mode-switch" role="tablist" aria-label="U-Map 상태 보기">
        <button className={!isClear ? "active" : ""} type="button" onClick={() => setMapMode("initial")} role="tab" aria-selected={!isClear}>
          초기
        </button>
        <button className={isClear ? "active" : ""} type="button" onClick={() => setMapMode("clear")} role="tab" aria-selected={isClear}>
          선명한 U-Map
        </button>
      </div>

      <section className={`glass-card u-map-primary-card ${isClear ? "clear" : "initial"}`}>
        <div className="u-map-card-head">
          <p className="eyebrow">U-Map</p>
          {isClear && <span>Unlocked · 선명도 72%</span>}
        </div>
        <h1>{isClear ? "윤곽이 더 선명해졌어요" : "아직은 흐릿한 윤곽이에요"}</h1>
        <p>
          {isClear
            ? "질문과 Diary에서 반복된 단서가 쌓이면서 관계, 가치관, 감정 흐름이 더 또렷하게 보이고 있어요."
            : "첫 단서가 생겼고, 질문과 Diary가 쌓이면 감정, 관계, 가치관의 흐름이 더 선명해질 거예요."}
        </p>
        <div className={`u-map-preview u-map-preview-large ${isClear ? "clear" : "initial"}`} aria-hidden="true">
          <span />
          <span />
          <span />
          {isClear && (
            <>
              <i />
              <b />
            </>
          )}
        </div>
      </section>

      <section className="u-map-detail-section">
        <div className="section-heading">
          <h2>FI-YOU가 분석한 당신</h2>
          <span>{isClear ? "단서 5개" : "초기 단서"}</span>
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
        {statusRows.map(([label, value, state]) => (
          <div className={state === "locked" ? "locked" : state === "muted" ? "muted" : ""} key={label}>
            <span>{label}</span>
            <strong>{state === "locked" && <LockKeyhole size={12} />}{value}</strong>
          </div>
        ))}
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

function SettingsScreen() {
  const settingsItems = [
    ["계정 설정", "로그인, 기본 정보", User],
    ["Star / 보상 내역", "출석 +10 · Diary +12 · 광고 +15", Gift],
    ["알림 설정", "질문과 기록 리마인드", Bell],
    ["언어 설정", "한국어", Globe2],
    ["서비스 약관 / 개인정보 처리방침", "동의 문서 확인", FileText],
    ["데이터 관리", "기록 내보내기와 삭제", Database],
    ["로그아웃", "현재 계정에서 나가기", LogOut]
  ];

  return (
    <div className="screen home-screen with-bottom-nav">
      <header className="top-row">
        <span />
        <span>Settings</span>
        <i />
      </header>

      <section className="settings-profile-card">
        <div className="settings-avatar"><User size={26} /></div>
        <div className="settings-profile-main">
          <p className="eyebrow">내 정보</p>
          <h1>지우님</h1>
          <span>1996.06.13 · 탐험가</span>
        </div>
        <button className="edit-profile-button" type="button" aria-label="수정하기">
          <Pencil size={14} />
        </button>
        <div className="settings-profile-meta">
          <div><span>보유 Star</span><strong><Sparkles size={13} />150</strong></div>
          <div><span>레벨 타이틀</span><strong>탐험가</strong></div>
        </div>
      </section>

      <button className="settings-pdf-card" type="button" aria-label="지금까지 기록 PDF 리포트 다운로드">
        <span className="settings-row-icon"><FileText size={18} /></span>
        <span>
          <strong>기록 PDF 리포트</strong>
          <em>지금까지의 단서와 흐름 Download</em>
        </span>
        <small>100 Star</small>
      </button>

      <section className="settings-section">
        {settingsItems.map(([title, description, Icon]) => (
          <button className="settings-row" type="button" key={title}>
            <span className="settings-row-icon"><Icon size={18} /></span>
            <span>
              <strong>{title}</strong>
              <em>{description}</em>
            </span>
            <ChevronRight size={17} />
          </button>
        ))}
      </section>
    </div>
  );
}

function FreeQuestionLoop({ onClose }) {
  const [index, setIndex] = React.useState(0);
  const [selected, setSelected] = React.useState("");
  const [memo, setMemo] = React.useState("");
  const [feedback, setFeedback] = React.useState(false);
  const question = freeExploreQuestions[index % freeExploreQuestions.length];
  const displayIndex = index + 1;

  const goNext = () => {
    setFeedback(true);
    window.setTimeout(() => {
      setFeedback(false);
      setSelected("");
      setMemo("");
      setIndex((current) => Math.min(current + 1, 29));
    }, 760);
  };

  return (
    <div className="screen free-question-screen">
      <header className="top-row">
        <button className="icon-button" type="button" onClick={onClose} aria-label="탐구 닫기">
          <ChevronLeft size={22} />
        </button>
        <span>무료 탐구 {displayIndex} / 30</span>
        <i />
      </header>

      <div className="question-progress" aria-hidden="true">
        <span style={{ width: `${(displayIndex / 30) * 100}%` }} />
      </div>

      {feedback && <div className="mini-feedback">U-Map에 작은 단서가 더해졌어요.</div>}

      <section className="question-copy">
        <p className="eyebrow">Self Discovery</p>
        <h1>{question.question}</h1>
        <p>정답은 없어요. 오늘의 나에게 가까운 쪽을 골라주세요.</p>
      </section>

      <div className="option-list multi-option-list">
        {question.options.map((option) => (
          <button className={`option-card ${selected === option ? "selected" : ""}`} type="button" key={option} onClick={() => setSelected(option)}>
            <span>{option}</span>
            {selected === option && <Check size={18} />}
          </button>
        ))}
      </div>

      <section className="note-card">
        <label htmlFor="free-note">조금 더 남기고 싶다면 적어주세요.</label>
        <textarea
          id="free-note"
          value={memo}
          onChange={(event) => setMemo(event.target.value.slice(0, 220))}
          placeholder="상황이나 이유가 떠오른다면 짧게 남겨도 좋아요."
        />
        <span>{memo.length} / 220</span>
      </section>

      <button className="primary-button question-button" type="button" disabled={!selected} onClick={goNext}>
        {displayIndex >= 30 ? "오늘은 여기까지" : "다음 질문"}
        {selected && <ArrowRight size={19} />}
      </button>
    </div>
  );
}

function BottomNav({ activeTab, onTabChange }) {
  const tabs = [
    { id: "home", label: "홈", icon: Home },
    { id: "diary", label: "다이어리", icon: BookOpen },
    { id: "explore", label: "탐구", icon: Sparkles, primary: true },
    { id: "map", label: "U-Map", icon: Map },
    { id: "settings", label: "Settings", icon: Settings }
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
