import React from "react";
import { createRoot } from "react-dom/client";
import {
  ArrowLeft,
  BarChart3,
  BookOpen,
  Bot,
  CalendarDays,
  Check,
  ChevronRight,
  CircleUserRound,
  Compass,
  CreditCard,
  Download,
  Flame,
  Gem,
  Heart,
  Home,
  Map,
  MessageCircle,
  Moon,
  PenLine,
  Plus,
  Send,
  Settings,
  ShieldCheck,
  Sparkles,
  Star,
  Store,
  UserRound,
  Users,
  Zap
} from "lucide-react";
import {
  Area,
  AreaChart,
  Line,
  LineChart,
  PolarAngleAxis,
  PolarGrid,
  PolarRadiusAxis,
  Radar,
  RadarChart,
  ResponsiveContainer
} from "recharts";
import "./styles.css";

const mapData = [
  { subject: "가치관", value: 91 },
  { subject: "성격", value: 82 },
  { subject: "감정", value: 68 },
  { subject: "관계", value: 74 },
  { subject: "의사결정", value: 63 },
  { subject: "동기", value: 87 }
];

const tabs = [
  { id: "home", label: "홈", icon: Home },
  { id: "diary", label: "다이어리", icon: BookOpen },
  { id: "explore", label: "탐구", icon: Sparkles, featured: true },
  { id: "map", label: "U-Map", icon: Map },
  { id: "profile", label: "프로필", icon: UserRound }
];

const traitTop = [
  ["자유 지향성", 91],
  ["성장 욕구", 82],
  ["독립성", 76],
  ["회복력", 72],
  ["호기심", 68]
];

const growthItems = [
  ["자신감", "+12%", "up"],
  ["불안", "-18%", "down"],
  ["사회적 에너지", "+8%", "up"],
  ["계획성", "+4%", "up"],
  ["고민 시간", "-15%", "down"],
  ["행동력", "+9%", "up"]
];

const miniSeries = [
  { a: 16, b: 24, c: 21, d: 34, e: 42 },
  { a: 42, b: 31, c: 28, d: 22, e: 18 }
];

function App() {
  const [screen, setScreen] = React.useState("home");
  const activeTab = ["question", "session"].includes(screen) ? "explore" : screen === "growth" || screen === "report" ? "map" : screen;
  const showNav = !["question", "session", "relationship", "store", "report", "growth"].includes(screen);

  return (
    <div className="app-shell">
      <div className="ambient ambient-a" />
      <div className="ambient ambient-b" />
      <main className="phone">
        <StatusBar />
        <div className="screen">
          {screen === "home" && <HomeScreen go={setScreen} />}
          {screen === "explore" && <ExploreScreen go={setScreen} />}
          {screen === "question" && <QuestionScreen go={setScreen} />}
          {screen === "session" && <SessionScreen go={setScreen} />}
          {screen === "map" && <HumanMapScreen go={setScreen} />}
          {screen === "growth" && <GrowthScreen go={setScreen} />}
          {screen === "diary" && <DiaryScreen go={setScreen} />}
          {screen === "profile" && <ProfileScreen go={setScreen} />}
          {screen === "relationship" && <RelationshipScreen go={setScreen} />}
          {screen === "store" && <StoreScreen go={setScreen} />}
          {screen === "report" && <ReportScreen go={setScreen} />}
        </div>
        {showNav && <BottomNav active={activeTab} go={setScreen} />}
      </main>
    </div>
  );
}

function StatusBar() {
  return (
    <div className="status-bar">
      <span>9:41</span>
      <span className="status-dots">●●●  5G  ▰</span>
    </div>
  );
}

function Header({ title, onBack, action }) {
  return (
    <header className="top-header">
      {onBack ? <button className="icon-btn" onClick={onBack} aria-label="뒤로가기"><ArrowLeft size={18} /></button> : <span />}
      <h1>{title}</h1>
      {action || <button className="icon-btn" aria-label="설정"><Settings size={17} /></button>}
    </header>
  );
}

function BottomNav({ active, go }) {
  return (
    <nav className="bottom-nav">
      {tabs.map(({ id, label, icon: Icon, featured }) => (
        <button key={id} className={`${active === id ? "active" : ""} ${featured ? "featured" : ""}`} onClick={() => go(id)}>
          <Icon size={18} />
          <span>{label}</span>
        </button>
      ))}
    </nav>
  );
}

function GlassCard({ children, className = "", onClick, ariaLabel }) {
  const interactive = Boolean(onClick);
  return (
    <section
      className={`glass-card ${interactive ? "clickable-card" : ""} ${className}`}
      onClick={onClick}
      onKeyDown={(event) => {
        if (!interactive) return;
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          onClick();
        }
      }}
      role={interactive ? "button" : undefined}
      tabIndex={interactive ? 0 : undefined}
      aria-label={interactive ? ariaLabel : undefined}
    >
      {children}
    </section>
  );
}

function HomeScreen({ go }) {
  return (
    <div className="page home-page">
      <div className="brand-row">
        <div>
          <div className="logo">FI·YOU</div>
          <p>Figure Yourself</p>
        </div>
        <button className="pill point-pill" onClick={() => go("store")}><Gem size={15} />120P</button>
      </div>
      <h2 className="greeting">안녕하세요, 지우님 👋</h2>
      <p className="muted">오늘도 당신을 발견해 볼까요?</p>

      <GlassCard className="hero-progress">
        <div>
          <span className="eyebrow">탐구 진행도</span>
          <h3>Lv. 7 탐험가</h3>
          <strong>735 / 1,000 XP</strong>
          <Progress value={73.5} />
        </div>
        <div className="orb-field"><Sparkles size={18} /></div>
      </GlassCard>

      <GlassCard className="map-preview" onClick={() => go("map")} ariaLabel="U-Map 보기">
        <div className="card-title-row">
          <div>
            <span className="eyebrow">U-Map</span>
            <h3>현재까지 보이는 나의 경향</h3>
          </div>
          <ChevronRight size={18} />
        </div>
        <div className="radar-mini"><RadarVisual /></div>
      </GlassCard>

      <div className="metric-grid">
        <Metric label="발견된 특성" value="184개" icon={Sparkles} />
        <Metric label="분석 신뢰도" value="72%" icon={ShieldCheck} />
        <Metric label="누적 질문 수" value="27 / 30" icon={MessageCircle} />
        <Metric label="관계 분석" value="확장 가능" icon={Users} onClick={() => go("relationship")} ariaLabel="관계 분석 보기" />
      </div>

      <GlassCard className="question-card">
        <div className="icon-glow"><Moon size={18} /></div>
        <div>
          <span className="eyebrow">오늘의 질문</span>
          <p>최근에 나답다고 느꼈던 순간은 언제였나요?</p>
        </div>
      </GlassCard>
      <button className="primary-btn" onClick={() => go("question")}>질문 시작하기 <ChevronRight size={18} /></button>
    </div>
  );
}

function ExploreScreen({ go }) {
  return (
    <div className="page">
      <Header title="Explore" action={<button className="icon-btn" aria-label="탐구 설정"><Compass size={18} /></button>} />
      <GlassCard className="explore-hero">
        <span className="eyebrow">오늘의 탐구</span>
        <h2>질문과 대화로 나의 지도를 조금 더 선명하게</h2>
        <p>테스트 결과가 아니라, 현재까지의 대화를 바탕으로 경향을 발견해요.</p>
      </GlassCard>
      <div className="action-stack">
        <GlassCard className="action-card" onClick={() => go("question")} ariaLabel="AI 질문 탐구 시작">
          <div className="icon-glow"><MessageCircle size={20} /></div>
          <div><h3>AI 질문 탐구</h3><p>12 / 30 진행 중 · 답변당 5P</p></div>
          <ChevronRight size={18} />
        </GlassCard>
        <GlassCard className="action-card" onClick={() => go("session")} ariaLabel="자유 탐구 세션 시작">
          <div className="icon-glow"><Bot size={20} /></div>
          <div><h3>자유 탐구 세션</h3><p>관계, 감정, 가치관을 깊게 묻고 정리해요 · 30P</p></div>
          <ChevronRight size={18} />
        </GlassCard>
      </div>
      <GlassCard>
        <h3>추천 탐구 주제</h3>
        <div className="chip-wrap">
          {["인간관계", "연애", "가족", "감정", "가치관", "진로", "자유 탐구"].map((x) => <span className="chip" key={x}>{x}</span>)}
        </div>
      </GlassCard>
    </div>
  );
}

function QuestionScreen({ go }) {
  const [selected, setSelected] = React.useState(0);
  const options = [
    "혼자만의 시간을 가지며 충전하고 싶어요",
    "새로운 경험이나 여행을 떠나고 싶어요",
    "친구나 사람들을 만나며 시간을 보내고 싶어요",
    "내가 좋아하는 취미나 활동에 몰두하고 싶어요",
    "즉흥적으로 생각나는 대로 결정하고 싶어요"
  ];
  return (
    <div className="page detail-page">
      <Header title="질문 탐구" onBack={() => go("explore")} action={<button className="pill">5P</button>} />
      <div className="question-progress"><span>12 / 30</span><Progress value={40} /></div>
      <GlassCard className="question-main">
        <span className="eyebrow">AI 질문</span>
        <h2>휴일이 생긴다면 가장 하고 싶은 일은?</h2>
        <p>가장 자연스럽게 끌리는 선택을 골라주세요.</p>
        <div className="option-list">
          {options.map((option, i) => (
            <button key={option} className={`option ${selected === i ? "selected" : ""}`} onClick={() => setSelected(i)}>
              <span>{i + 1}</span>{option}{selected === i && <Check size={16} />}
            </button>
          ))}
        </div>
      </GlassCard>
      <GlassCard className="textarea-card">
        <label>선택 이유</label>
        <textarea placeholder="여기에 자유롭게 입력해주세요..." maxLength="300" />
        <small>0 / 300</small>
      </GlassCard>
      <button className="primary-btn bottom-action" onClick={() => go("explore")}>다음 질문 <ChevronRight size={18} /></button>
    </div>
  );
}

function SessionScreen({ go }) {
  return (
    <div className="page detail-page session-page">
      <Header title="자유 탐구" onBack={() => go("explore")} action={<button className="pill">30P</button>} />
      <div className="session-stats">
        <Stat label="메시지" value="4 / 7" />
        <Stat label="입력 글자" value="2,450 / 10,000" />
        <Stat label="출력 글자" value="4,890 / 15,000" />
      </div>
      <GlassCard>
        <h3>주제 선택</h3>
        <div className="chip-wrap">
          {["인간관계", "연애", "가족", "감정", "가치관", "진로", "자유 탐구"].map((x, i) => <span className={`chip ${i === 3 ? "active" : ""}`} key={x}>{x}</span>)}
        </div>
      </GlassCard>
      <div className="chat-panel">
        <div className="bubble ai">최근 감정이 반복되는 상황을 함께 살펴볼게요. 어떤 순간에 가장 마음이 흔들렸나요?</div>
        <div className="bubble me">사람들과 약속이 많아질수록 즐겁지만 금방 지치는 것 같아요.</div>
        <div className="bubble ai">현재까지의 대화를 보면 연결 욕구와 회복 시간이 함께 중요해 보여요. 지친 뒤 회복에 도움이 된 행동이 있었나요?</div>
      </div>
      <div className="composer">
        <input placeholder="나를 탐구하는 질문을 이어가세요" />
        <button><Send size={18} /></button>
      </div>
      <button className="ghost-btn" onClick={() => go("explore")}>탐구 종료하기</button>
    </div>
  );
}

function HumanMapScreen({ go }) {
  return (
    <div className="page">
      <Header title="U-Map" action={<button className="icon-btn" aria-label="지도 설정"><Settings size={17} /></button>} />
      <TabRow items={["전체", "성격", "가치관", "감정", "관계", "동기"]} active="전체" />
      <GlassCard className="radar-card">
        <RadarVisual />
      </GlassCard>
      <GlassCard className="summary-card">
        <Sparkles size={19} />
        <p>현재까지의 대화를 바탕으로, 당신은 성장과 자유를 추구하며 새로운 가능성을 탐색하는 경향이 보여요.</p>
      </GlassCard>
      <GlassCard className="action-card" onClick={() => go("growth")} ariaLabel="Growth 변화 추적 보기">
        <div className="icon-glow"><BarChart3 size={20} /></div>
        <div><h3>Growth</h3><p>U-Map 변화 흐름과 최근 3개월 패턴</p></div>
        <ChevronRight size={18} />
      </GlassCard>
      <GlassCard>
        <h3>주요 특성 TOP 5</h3>
        <TraitBars data={traitTop} />
      </GlassCard>
      <button className="primary-btn" onClick={() => go("report")}><Download size={18} />PDF 리포트 미리보기</button>
    </div>
  );
}

function GrowthScreen({ go }) {
  return (
    <div className="page detail-page">
      <Header title="Growth" onBack={() => go("map")} action={<button className="icon-btn" aria-label="기간 선택"><CalendarDays size={17} /></button>} />
      <TabRow items={["전체", "3개월", "6개월", "1년"]} active="3개월" />
      <h3 className="section-title">지난 3개월 변화</h3>
      <div className="growth-list">
        {growthItems.map((item, i) => <GrowthItem key={item[0]} item={item} data={miniSeries[item[2] === "up" ? 0 : 1]} />)}
      </div>
      <GlassCard className="summary-card">
        <Flame size={19} />
        <p>지난 3개월 동안 불안감이 줄어들고 사회적 에너지가 증가하는 긍정적인 변화가 나타났어요.</p>
      </GlassCard>
    </div>
  );
}

function DiaryScreen({ go }) {
  return (
    <div className="page detail-page">
      <Header title="Diary" onBack={() => go("profile")} action={<button className="icon-btn" aria-label="기록 작성"><PenLine size={17} /></button>} />
      <GlassCard className="diary-card">
        <span className="eyebrow">오늘의 감정 기록</span>
        <div className="mood-row">
          {["차분함", "기대", "피곤", "고마움"].map((x, i) => <button className={i === 1 ? "mood active" : "mood"} key={x}>{x}</button>)}
        </div>
      </GlassCard>
      <GlassCard className="textarea-card">
        <label>오늘의 한 줄 메모</label>
        <textarea placeholder="오늘 나에게 남은 장면을 적어보세요." />
      </GlassCard>
      <GlassCard>
        <h3>최근 기록</h3>
        {["새로운 일을 시작하기 전에는 설렘과 긴장이 같이 올라왔다.", "혼자 산책한 뒤 생각이 훨씬 정리됐다.", "대화가 깊어질수록 에너지가 다시 생겼다."].map((x, i) => (
          <div className="record-row" key={x}><span>6.{10 - i}</span><p>{x}</p></div>
        ))}
      </GlassCard>
      <GlassCard className="summary-card">
        <Moon size={19} />
        <p>반복 기록에서 새로운 시작 전 긴장과, 혼자 회복한 뒤 다시 연결을 찾는 패턴이 보여요.</p>
      </GlassCard>
    </div>
  );
}

function RelationshipScreen({ go }) {
  return (
    <div className="page detail-page">
      <Header title="Relationship" onBack={() => go("profile")} action={<button className="pill">50P</button>} />
      <GlassCard className="relation-hero">
        <div className="avatar-pair"><Avatar name="나" /><Heart className="heart-link" size={22} /><Avatar name="상대" /></div>
        <span className="pill">관계 유형: 연인</span>
      </GlassCard>
      <TabRow items={["요약", "잘 맞는 점", "충돌 가능성", "소통 스타일"]} active="요약" />
      <GlassCard className="summary-card">
        <Users size={19} />
        <p>두 U-Map은 가치관의 방향이 비교적 가깝고, 의사결정 속도와 감정 표현 방식에서는 조율이 필요해 보여요.</p>
      </GlassCard>
      <GlassCard>
        <h3>주요 궁합 점수</h3>
        <TraitBars data={[["가치관", 78], ["성격", 71], ["의사소통", 65], ["생활 방식", 60]]} suffix="%" />
      </GlassCard>
      <GlassCard>
        <h3>주의가 필요한 영역</h3>
        {["의사결정 속도 차이", "감정 표현 방식 차이", "독립성 필요 수준 차이"].map((x) => <div className="notice-row" key={x}><Zap size={15} />{x}</div>)}
      </GlassCard>
      <button className="primary-btn">상세 분석 보기 (50P)</button>
    </div>
  );
}

function StoreScreen({ go }) {
  return (
    <div className="page detail-page">
      <Header title="Point & Store" onBack={() => go("profile")} action={<button className="pill">포인트 내역</button>} />
      <GlassCard className="point-balance"><CreditCard size={28} /><span>보유 포인트</span><strong>120P</strong></GlassCard>
      <StoreSection title="포인트 획득 방법" items={[["출석 보상", "매일 +10P"], ["광고 시청", "1회 +15P"]]} />
      <StoreSection title="포인트 사용" items={[["질문 1개", "5P"], ["자유 탐구 세션", "30P"], ["PDF 리포트", "100P"], ["지인 추가", "100P"], ["관계 분석", "50P"], ["성장 리포트", "150P"]]} />
      <StoreSection title="포인트 구매" items={[["100P", "$0.99"], ["550P", "$4.99"], ["1,200P", "$9.99"]]} />
    </div>
  );
}

function ReportScreen({ go }) {
  const contents = ["프로필 요약", "성격 분석", "가치관 분석", "감정 패턴", "관계 패턴", "의사결정 방식", "숨겨진 특성", "상충되는 특성", "성장 포인트", "U-Map"];
  return (
    <div className="page detail-page">
      <Header title="PDF Preview" onBack={() => go("map")} action={<button className="icon-btn" aria-label="리포트 다운로드"><Download size={17} /></button>} />
      <GlassCard className="report-cover">
        <div className="report-mark">FI·YOU</div>
        <h2>Human Discovery Report</h2>
        <p>생성일 2026.06.11</p>
      </GlassCard>
      <GlassCard>
        <h3>포함 내용</h3>
        <div className="report-list">
          {contents.map((x) => <div key={x}><Check size={15} />{x}</div>)}
        </div>
      </GlassCard>
      <button className="primary-btn"><Download size={18} />PDF 다운로드 (100P)</button>
    </div>
  );
}

function ProfileScreen({ go }) {
  return (
    <div className="page">
      <Header title="Profile" />
      <GlassCard className="profile-card">
        <Avatar name="지우" />
        <div><h2>지우님 <span className="premium">PREMIUM</span></h2><p>@FI-YOU 탐구자 · 신뢰도 72%</p></div>
      </GlassCard>
      <GlassCard>
        <h3>핵심 특성</h3>
        <div className="chip-wrap">{["독립적", "호기심 많음", "분석적", "신중함", "유연함"].map((x) => <span className="chip" key={x}>{x}</span>)}</div>
      </GlassCard>
      <GlassCard>
        <h3>강점 TOP 5</h3>
        <TraitBars data={[["몰입성", 85], ["분석력", 78], ["학습 능력", 74], ["적응력", 72], ["창의력", 68]]} />
      </GlassCard>
      <div className="action-stack">
        <GlassCard className="action-card" onClick={() => go("diary")} ariaLabel="Diary 감정 기록 보기"><BookOpen size={20} /><div><h3>Diary</h3><p>오늘의 감정과 반복 패턴 기록</p></div><ChevronRight size={18} /></GlassCard>
        <GlassCard className="action-card" onClick={() => go("relationship")} ariaLabel="관계 분석 보기"><Users size={20} /><div><h3>관계 분석</h3><p>U-Map 기반 확장 기능</p></div><ChevronRight size={18} /></GlassCard>
        <GlassCard className="action-card" onClick={() => go("store")} ariaLabel="Point & Store 보기"><Store size={20} /><div><h3>Point & Store</h3><p>보유 120P · 리포트와 세션 구매</p></div><ChevronRight size={18} /></GlassCard>
      </div>
    </div>
  );
}

function RadarVisual() {
  return (
    <ResponsiveContainer width="100%" height="100%">
      <RadarChart data={mapData}>
        <PolarGrid stroke="rgba(160,139,255,.18)" />
        <PolarAngleAxis dataKey="subject" tick={{ fill: "#dcd8ff", fontSize: 10 }} />
        <PolarRadiusAxis angle={90} domain={[0, 100]} tick={false} axisLine={false} />
        <Radar dataKey="value" stroke="#a986ff" fill="#734cff" fillOpacity={0.55} />
      </RadarChart>
    </ResponsiveContainer>
  );
}

function Progress({ value }) {
  return <div className="progress"><span style={{ width: `${value}%` }} /></div>;
}

function Metric({ label, value, icon: Icon, onClick, ariaLabel }) {
  return (
    <GlassCard className="metric" onClick={onClick} ariaLabel={ariaLabel}>
      <Icon size={18} />
      <strong>{value}</strong>
      <span>{label}</span>
    </GlassCard>
  );
}

function TraitBars({ data, suffix = "" }) {
  return <div className="trait-bars">{data.map(([name, value]) => (
    <div className="trait-row" key={name}><span>{name}</span><div><i style={{ width: `${value}%` }} /></div><b>{value}{suffix}</b></div>
  ))}</div>;
}

function TabRow({ items, active }) {
  return <div className="tab-row">{items.map((x) => <button className={x === active ? "active" : ""} key={x}>{x}</button>)}</div>;
}

function Stat({ label, value }) {
  return <div className="stat"><span>{label}</span><strong>{value}</strong></div>;
}

function GrowthItem({ item, data }) {
  const chartData = Object.values(data).map((v, i) => ({ i, v }));
  return (
    <GlassCard className="growth-item">
      <div><span>{item[0]}</span><strong className={item[2]}>{item[1]}</strong></div>
      <ResponsiveContainer width={92} height={36}>
        <LineChart data={chartData}><Line type="monotone" dataKey="v" stroke={item[2] === "up" ? "#b56cff" : "#38bdf8"} strokeWidth={2} dot={false} /></LineChart>
      </ResponsiveContainer>
    </GlassCard>
  );
}

function Avatar({ name }) {
  return <div className="avatar"><CircleUserRound size={34} /><span>{name}</span></div>;
}

function StoreSection({ title, items }) {
  return (
    <GlassCard>
      <h3>{title}</h3>
      {items.map(([a, b]) => <div className="store-row" key={a}><span>{a}</span><strong>{b}</strong></div>)}
    </GlassCard>
  );
}

createRoot(document.getElementById("root")).render(<App />);
