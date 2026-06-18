import { FileText } from 'lucide-react';
import { useI18n } from '../lib/i18n';
import { Footer } from './Footer';
import { Header } from './Header';

export type LegalPageType = 'terms' | 'privacy' | 'disclaimer' | 'refund';

type LegalPageProps = {
  type: LegalPageType;
};

export function LegalPage({ type }: LegalPageProps) {
  const { t } = useI18n();
  const page = t.legal.pages[type];

  return (
    <div className="min-h-screen bg-fi-canvas text-white">
      <Header />
      <main>
        <section className="border-t border-white/8 px-5 py-16 lg:px-0">
          <div className="mx-auto max-w-[900px]">
            <p className="inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/[0.03] px-4 py-2 text-xs font-black uppercase tracking-normal text-fi-gold">
              <FileText className="h-4 w-4" />
              {page.eyebrow}
            </p>
            <h1 className="mt-7 text-4xl font-black leading-tight text-white sm:text-5xl">{page.title}</h1>
            <p className="mt-5 text-sm font-bold text-fi-muted">{t.legal.updated}</p>
            <p className="mt-7 max-w-3xl text-lg font-medium leading-8 text-fi-text">{page.intro}</p>

            <div className="mt-10 grid gap-5">
              {page.sections.map((section) => (
                <article key={section.title} className="rounded-[18px] border border-white/10 bg-card p-7 shadow-card">
                  <h2 className="text-xl font-black text-white">{section.title}</h2>
                  <p className="mt-4 text-base font-medium leading-8 text-fi-text">{section.body}</p>
                </article>
              ))}
            </div>

            <p className="mt-8 rounded-[16px] border border-white/10 bg-white/[0.03] p-5 text-sm font-medium leading-7 text-fi-muted">{t.legal.sourceNote}</p>
          </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}
