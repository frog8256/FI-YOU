/* eslint-disable react-refresh/only-export-components */
import { createContext, ReactNode, useContext, useEffect, useMemo, useState } from 'react';

export type Language = 'kr' | 'en';

const translations = {
  kr: {
    navItems: [
      { label: '서비스', href: '/#service' },
      { label: 'U-Map', href: '/#u-map' },
      { label: '작동 방식', href: '/#how-it-works' },
      { label: '앱 출시 안내', href: '/#android-launch' }
    ],
    common: {
      download: 'Android 출시 안내',
      brandSubtitle: 'AI 기반 Self Discovery 플랫폼'
    },
    hero: {
      badge: 'AI Self-Discovery Companion',
      titleTop: '나를 단정하지 않고,',
      titleBottom: '흐름으로 이해해요.',
      description:
        'FI-YOU는 Flutter Android 앱에서 질문, Diary, U-Map, Signature를 통해 사용자가 자신의 기록을 차분히 돌아볼 수 있도록 돕는 AI 기반 Self Discovery 플랫폼입니다.',
      primaryCta: 'Android 대기 등록',
      secondaryCta: '서비스 먼저 보기',
      phoneEyebrow: 'Android Release Preview',
      phoneTitle: '기록이 쌓이며 보이는 나의 흐름',
      nextQuestion: '최근 내 마음이 자주 향하는 곳은 어디인가요?',
      navLabels: ['Home', 'Diary', 'Explore', 'U-Map', 'Profile']
    },
    about: {
      eyebrow: 'FI-YOU가 돕는 것',
      title: '기록을 바탕으로 나를 더 선명하게 바라보는 앱',
      cards: [
        {
          title: 'Diary로 남기는 순간',
          body: '감정, 생각, 관계의 단서를 짧게 기록하고 다시 돌아볼 수 있는 자기 관찰 흐름을 제공합니다.'
        },
        {
          title: 'U-Map으로 보는 흐름',
          body: 'U-Map은 현재까지의 답변과 Diary를 바탕으로 만들어지는 참고용 지도입니다. 고정된 유형표가 아닙니다.'
        },
        {
          title: 'Signature로 정리되는 단서',
          body: 'Signature는 기록에서 반복적으로 드러나는 표현과 선택의 흐름을 부드럽게 요약합니다.'
        },
        {
          title: '진단이 아닌 자기 이해',
          body: 'FI-YOU는 심리상담, 의료 진단, 치료를 제공하지 않습니다. 중요한 문제는 전문가의 도움을 함께 고려해야 합니다.'
        }
      ]
    },
    how: {
      eyebrow: 'How It Works',
      title: '앱 안에서 이어지는 조용한 자기 탐구 루프',
      steps: [
        {
          title: '질문에 답하기',
          body: '앱이 제안하는 질문에 답하며 오늘의 생각과 감정을 기록합니다.'
        },
        {
          title: 'Diary로 맥락 남기기',
          body: '하루의 사건, 감정, 관계 단서를 Diary에 쌓아 자기 관찰의 재료를 만듭니다.'
        },
        {
          title: 'U-Map 확인하기',
          body: '현재 기록을 바탕으로 형성된 U-Map을 참고해 나의 흐름을 살펴봅니다.'
        },
        {
          title: 'Signature 돌아보기',
          body: '반복되는 표현과 선택의 패턴을 참고용 요약으로 확인합니다.'
        }
      ]
    },
    stories: {
      eyebrow: 'Android Release',
      title: '출시 전 웹사이트에서 안내할 핵심 기능',
      previous: '이전 안내',
      next: '다음 안내',
      cards: [
        {
          title: 'U-Map',
          body: '현재 기록 기반의 자기 이해 지도입니다. 성격을 확정적으로 판정하거나 고정된 유형으로 정의하지 않습니다.',
          status: '출시 핵심'
        },
        {
          title: 'Diary',
          body: '질문 답변과 일상 기록을 모아 나중에 돌아볼 수 있는 자기 관찰 자료로 정리합니다.',
          status: '출시 핵심'
        },
        {
          title: 'Signature',
          body: '답변과 Diary에서 드러나는 반복 단서를 참고용 문장으로 요약합니다.',
          status: '출시 핵심'
        }
      ]
    },
    finalCta: {
      title: 'FI-YOU Android 앱 출시를 준비 중입니다',
      body: '웹사이트는 앱을 대신하지 않습니다. 출시 전에는 브랜드와 이용 안내를 확인하고, 출시 후에는 Play Store에서 Android 앱으로 이어집니다.',
      primaryCta: '대기 등록 준비 중',
      secondaryCta: 'Play Store 링크 예정'
    },
    footer: {
      service: '서비스',
      company: '회사',
      support: '지원',
      diary: 'Diary',
      report: '앱 출시 안내',
      about: '소개',
      launch: 'Android 출시',
      contact: '문의하기',
      terms: '이용약관',
      privacy: '개인정보처리방침',
      disclaimer: '면책 고지',
      refund: '환불 정책'
    },
    legal: {
      updated: '최종 업데이트: 2026년 6월 17일',
      sourceNote: '이 문서는 Android 공식 출시 전 안내용 초안입니다. Product QA & Policy Lead 검수가 필요합니다.',
      pages: {
        terms: {
          eyebrow: 'Terms of Service',
          title: '이용약관',
          intro: 'FI-YOU는 Android 앱을 중심으로 질문, Diary, U-Map, Signature를 제공하는 AI 기반 Self Discovery 플랫폼입니다.',
          sections: [
            {
              title: '서비스의 성격',
              body: 'FI-YOU는 사용자가 직접 입력한 답변과 기록을 바탕으로 자기 이해를 돕는 참고 정보를 제공합니다. 성격을 확정하거나 사람을 유형으로 고정하지 않습니다.'
            },
            {
              title: '비의료 및 비상담 고지',
              body: 'FI-YOU는 심리상담, 의료 진단, 치료, 법률 또는 금융 조언을 제공하지 않습니다. 건강, 안전, 법적 문제 등 중요한 사안은 적절한 전문가와 상의해야 합니다.'
            },
            {
              title: '사용자 기록 관리',
              body: '사용자는 자신의 답변, Diary, 관계 기록 등 민감할 수 있는 정보를 신중하게 작성하고 관리해야 합니다. 타인의 개인정보나 동의받지 않은 민감정보를 입력하지 않아야 합니다.'
            },
            {
              title: '출시 전 안내',
              body: '웹사이트의 CTA와 기능 설명은 Android 앱 출시 준비 상태를 안내하기 위한 것이며, 실제 기능 제공 범위는 앱 출시 버전과 앱 마켓 정책에 따라 달라질 수 있습니다.'
            }
          ]
        },
        privacy: {
          eyebrow: 'Privacy Policy',
          title: '개인정보처리방침',
          intro: 'FI-YOU는 Android 앱에서 사용자가 입력한 답변과 기록을 U-Map, Diary, Signature 제공을 위해 처리할 수 있습니다.',
          sections: [
            {
              title: '처리될 수 있는 정보',
              body: '서비스 이용 과정에서 계정 정보, 기본 프로필, 질문 답변, Diary, 감정 및 관계 기록, 앱 이벤트, 법적 동의 기록 등이 처리될 수 있습니다.'
            },
            {
              title: '이용 목적',
              body: '입력한 답변과 Diary는 U-Map 구성, Signature 요약, 탐구 흐름 추천, 서비스 품질 개선, 고객 지원, 법적 동의 기록 관리를 위해 사용될 수 있습니다.'
            },
            {
              title: '데이터 관리 권리',
              body: '사용자는 데이터 열람, 내보내기, 기록 초기화, 계정 삭제를 요청할 수 있습니다. 세부 절차는 Android 앱 출시 시점의 정책과 기능 범위에 맞춰 안내됩니다.'
            },
            {
              title: '보안',
              body: 'FI-YOU는 인증된 사용자 중심으로 데이터 접근을 제한하고, 사용자가 자신의 기록만 조회하고 관리할 수 있도록 접근 정책을 적용합니다.'
            }
          ]
        },
        disclaimer: {
          eyebrow: 'Disclaimer',
          title: '면책 고지',
          intro: 'FI-YOU의 결과와 요약은 자기 이해를 위한 참고 자료입니다.',
          sections: [
            {
              title: '진단이 아닙니다',
              body: 'U-Map, Diary 요약, Signature는 심리검사 결과, 의료 진단, 치료 계획, 상담 의견이 아닙니다.'
            },
            {
              title: 'AI 요약의 한계',
              body: 'AI가 정리한 내용은 사용자가 입력한 기록과 표현을 바탕으로 한 참고용 요약입니다. 실제 감정, 성향, 관계를 완전하게 판정하지 않습니다.'
            },
            {
              title: '중요한 결정',
              body: '건강, 안전, 관계, 법률, 재정 등 중요한 결정은 FI-YOU의 문구만으로 판단하지 말고 적절한 전문가나 신뢰할 수 있는 사람의 도움을 함께 고려해야 합니다.'
            }
          ]
        },
        refund: {
          eyebrow: 'Refund Policy',
          title: '환불 정책',
          intro: 'FI-YOU의 유료 기능이나 앱 내 결제가 제공되는 경우 환불은 앱 마켓 및 결제 제공자의 정책과 FI-YOU 정책에 따라 처리됩니다.',
          sections: [
            {
              title: '출시 전 상태',
              body: '현재 웹사이트는 웹 결제나 상품 판매를 앞세우지 않습니다. 실제 결제 기능이 공개되기 전까지 가격 및 환불 조건은 확정 안내가 아닙니다.'
            },
            {
              title: '앱 마켓 기준',
              body: 'Android 앱 공개 후 결제가 제공되는 경우 Google Play 정책, 결제 제공자 정책, FI-YOU의 고지된 환불 기준이 함께 적용될 수 있습니다.'
            },
            {
              title: '검수 필요',
              body: '환불 문구는 Product QA & Policy Lead가 앱 출시 버전, 상품 구조, 마켓 정책을 기준으로 최종 검수해야 합니다.'
            }
          ]
        }
      }
    }
  },
  en: {
    navItems: [
      { label: 'Service', href: '/#service' },
      { label: 'U-Map', href: '/#u-map' },
      { label: 'How It Works', href: '/#how-it-works' },
      { label: 'Android Launch', href: '/#android-launch' }
    ],
    common: {
      download: 'Android launch',
      brandSubtitle: 'AI-powered self-discovery platform'
    },
    hero: {
      badge: 'AI Self-Discovery Companion',
      titleTop: 'Understand yourself',
      titleBottom: 'as a living pattern.',
      description:
        'FI-YOU is an AI-powered self-discovery platform for the Flutter Android app, helping users reflect on their own records through questions, Diary, U-Map, and Signature.',
      primaryCta: 'Join Android waitlist',
      secondaryCta: 'Explore the service',
      phoneEyebrow: 'Android Release Preview',
      phoneTitle: 'A flow of you, built from your records',
      nextQuestion: 'Where has your mind been heading lately?',
      navLabels: ['Home', 'Diary', 'Explore', 'U-Map', 'Profile']
    },
    about: {
      eyebrow: 'What FI-YOU Supports',
      title: 'A record-based way to understand yourself more clearly',
      cards: [
        {
          title: 'Moments in Diary',
          body: 'Record emotional, personal, and relational clues so you can look back with more context.'
        },
        {
          title: 'Flow through U-Map',
          body: 'U-Map is a reference map based on current answers and Diary entries. It is not a fixed personality type.'
        },
        {
          title: 'Clues in Signature',
          body: 'Signature gently summarizes repeated clues in your language, choices, and reflections.'
        },
        {
          title: 'Reflection, not diagnosis',
          body: 'FI-YOU does not provide psychological counseling, medical diagnosis, or treatment. For important concerns, consider professional support.'
        }
      ]
    },
    how: {
      eyebrow: 'How It Works',
      title: 'A quiet self-discovery loop inside the Android app',
      steps: [
        {
          title: 'Answer questions',
          body: 'Respond to reflective prompts and capture today’s thoughts and emotions.'
        },
        {
          title: 'Add Diary context',
          body: 'Build a record of events, feelings, and relationship clues over time.'
        },
        {
          title: 'Review U-Map',
          body: 'See a current map formed from your records and use it as a reference.'
        },
        {
          title: 'Reflect on Signature',
          body: 'Review recurring patterns as a gentle, non-diagnostic summary.'
        }
      ]
    },
    stories: {
      eyebrow: 'Android Release',
      title: 'Core features the website should explain before launch',
      previous: 'Previous note',
      next: 'Next note',
      cards: [
        {
          title: 'U-Map',
          body: 'A record-based self-understanding map. It does not make final judgments about personality or define users as fixed types.',
          status: 'Release core'
        },
        {
          title: 'Diary',
          body: 'A place to collect answers and daily records as material for later reflection.',
          status: 'Release core'
        },
        {
          title: 'Signature',
          body: 'A reference summary of recurring clues found in answers and Diary entries.',
          status: 'Release core'
        }
      ]
    },
    finalCta: {
      title: 'FI-YOU for Android is being prepared',
      body: 'The website does not replace the app. Before launch, it explains the brand and policies. After launch, it will guide users to the Android app on Play Store.',
      primaryCta: 'Waitlist coming soon',
      secondaryCta: 'Play Store link pending'
    },
    footer: {
      service: 'Service',
      company: 'Company',
      support: 'Support',
      diary: 'Diary',
      report: 'Launch notes',
      about: 'About',
      launch: 'Android launch',
      contact: 'Contact',
      terms: 'Terms of Service',
      privacy: 'Privacy Policy',
      disclaimer: 'Disclaimer',
      refund: 'Refund Policy'
    },
    legal: {
      updated: 'Last updated: June 17, 2026',
      sourceNote: 'This is a pre-launch Android release policy draft. Product QA & Policy Lead review is required.',
      pages: {
        terms: {
          eyebrow: 'Terms of Service',
          title: 'Terms of Service',
          intro: 'FI-YOU is an AI-powered self-discovery platform centered on the Android app experience: questions, Diary, U-Map, and Signature.',
          sections: [
            {
              title: 'Nature of the service',
              body: 'FI-YOU provides reference information for self-understanding based on answers and records provided by the user. It does not finalize personality or fix people into types.'
            },
            {
              title: 'Non-medical and non-counseling notice',
              body: 'FI-YOU does not provide psychological counseling, medical diagnosis, treatment, legal advice, or financial advice. For health, safety, legal, or other important concerns, users should consult appropriate professionals.'
            },
            {
              title: 'Managing user records',
              body: 'Users should carefully create and manage potentially sensitive information such as answers, Diary entries, and relationship records. Do not enter another person’s personal data or sensitive information without consent.'
            },
            {
              title: 'Pre-launch guidance',
              body: 'Website CTAs and feature descriptions are provided to explain Android launch preparation. Actual feature availability may vary by app release version and app marketplace policy.'
            }
          ]
        },
        privacy: {
          eyebrow: 'Privacy Policy',
          title: 'Privacy Policy',
          intro: 'FI-YOU may process answers and records entered in the Android app to provide U-Map, Diary, and Signature experiences.',
          sections: [
            {
              title: 'Information that may be processed',
              body: 'During service use, FI-YOU may process account information, basic profile information, question answers, Diary entries, emotion and relationship records, app events, and legal consent records.'
            },
            {
              title: 'Purpose of use',
              body: 'Answers and Diary entries may be used to form U-Map, summarize Signature, recommend exploration flows, improve service quality, provide support, and manage legal consent records.'
            },
            {
              title: 'Data management rights',
              body: 'Users may request data access, export, record reset, or account deletion. Detailed procedures should be aligned with the Android launch version and policy scope.'
            },
            {
              title: 'Security',
              body: 'FI-YOU applies access policies around authenticated users so users can access and manage only their own records.'
            }
          ]
        },
        disclaimer: {
          eyebrow: 'Disclaimer',
          title: 'Disclaimer',
          intro: 'FI-YOU outputs and summaries are reference material for self-understanding.',
          sections: [
            {
              title: 'Not a diagnosis',
              body: 'U-Map, Diary summaries, and Signature are not psychological test results, medical diagnoses, treatment plans, or counseling opinions.'
            },
            {
              title: 'Limits of AI summaries',
              body: 'AI-organized content is a reference summary based on user-provided records and language. It does not make complete judgments about emotions, personality, relationships, or life direction.'
            },
            {
              title: 'Important decisions',
              body: 'For health, safety, relationships, legal, or financial decisions, users should not rely only on FI-YOU copy and should consider support from appropriate professionals or trusted people.'
            }
          ]
        },
        refund: {
          eyebrow: 'Refund Policy',
          title: 'Refund Policy',
          intro: 'If paid features or in-app purchases are introduced, refunds may be handled according to app marketplace rules, payment provider rules, and FI-YOU policy.',
          sections: [
            {
              title: 'Pre-launch status',
              body: 'This website does not prioritize web payments or product sales. Until actual payment features are released, price and refund conditions are not final.'
            },
            {
              title: 'Marketplace rules',
              body: 'After Android launch, Google Play policy, payment provider rules, and FI-YOU’s stated refund policy may apply together.'
            },
            {
              title: 'Review required',
              body: 'Refund copy must be reviewed by the Product QA & Policy Lead against the app release version, product structure, and marketplace policy.'
            }
          ]
        }
      }
    }
  }
} as const;

type Copy = (typeof translations)[Language];

type LanguageContextValue = {
  language: Language;
  setLanguage: (language: Language) => void;
  t: Copy;
};

const LanguageContext = createContext<LanguageContextValue | null>(null);

function getInitialLanguage(): Language {
  if (typeof window === 'undefined') {
    return 'kr';
  }

  return window.localStorage.getItem('fi-you-language') === 'en' ? 'en' : 'kr';
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<Language>(getInitialLanguage);

  const setLanguage = (nextLanguage: Language) => {
    setLanguageState(nextLanguage);
    window.localStorage.setItem('fi-you-language', nextLanguage);
  };

  useEffect(() => {
    document.documentElement.lang = language === 'kr' ? 'ko' : 'en';
  }, [language]);

  const value = useMemo(
    () => ({
      language,
      setLanguage,
      t: translations[language]
    }),
    [language]
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

export function useI18n() {
  const context = useContext(LanguageContext);

  if (!context) {
    throw new Error('useI18n must be used within LanguageProvider');
  }

  return context;
}
